#include "precompiled.h"

#include "ThreadUtils.h"
#include "AppLogFetcher.h"
#include "CommonConstants.h"
#include "IOUtils.h"
#include "JlCompress.h"
#include "Logger.h"
#include "QueryHelper.h"
#include "QueueDownloader.h"
#include "TextUtils.h"

#define BACKUP_ZIP_PASSWORD "X4*13f3*3qYk3_*"
#define LIKE_CLAUSE QString("(%1 LIKE '%' || ? || '%')").arg(textField)

namespace {

void analyzeVerse(QStringList tokens, int chapter, QVariantList& result)
{
    tokens = tokens.last().trimmed().split("-");
    int fromVerse = tokens.first().trimmed().toInt();
    int toVerse = tokens.last().trimmed().toInt();

    if (chapter >= 1 && chapter <= 114 && fromVerse >= 1 && fromVerse <= 286 && toVerse >= fromVerse)
    {
        QVariantMap q;
        q[CHAPTER_KEY] = chapter;
        q[FROM_VERSE_KEY] = fromVerse;
        q[TO_VERSE_KEY] = toVerse;
        result << q;
    }
}

void analyzeAyats(QRegExp const& regex, QVariantList& result, QString const& body)
{
    int pos = 0;
    while ( (pos = regex.indexIn(body, pos) ) != -1)
    {
        QString current = regex.capturedTexts().first();
        current.remove(")");
        current.remove("(");
        current.remove(" ");
        QStringList tokens = current.split(":");

        int chapter = tokens.first().trimmed().toInt();

        analyzeVerse(tokens, chapter, result);;

        pos += regex.matchedLength();
    }
}

}

namespace quran {

using namespace bb::cascades;
using namespace canadainc;

SimilarReference::SimilarReference() : adm(NULL), textControl(NULL)
{
}

QString ThreadUtils::compressBookmarks(QString const& destinationZip)
{
    bool result = JlCompress::compressFile(destinationZip, BOOKMARKS_PATH, BACKUP_ZIP_PASSWORD);
    QFileInfo f(destinationZip);

    return result && f.size() > 0 ? f.fileName() : "";
}

void ThreadUtils::compressFiles(Report& r, QString const& zipPath, const char* password)
{
    if (r.type == ReportType::Periodic) {
        r.attachments << BOOKMARKS_PATH;
    }

    JlCompress::compressFiles(zipPath, r.attachments, password);
}

bool ThreadUtils::performRestore(QString const& source)
{
    QStringList files = JlCompress::extractDir( source, QDir::homePath(), BACKUP_ZIP_PASSWORD );
    return !files.isEmpty();
}

SimilarReference ThreadUtils::decorateResults(QVariantList input, ArrayDataModel* adm, QString const& mainSearch, QVariantList const& additional)
{
    int n = input.size();

    QSet<QString> searches;
    searches << mainSearch;

    foreach (QVariant const& q, additional)
    {
        QString value = q.toString();

        if ( !value.isEmpty() ) {
            searches << value;
        }
    }

    for (int i = 0; i < n; i++)
    {
        QVariantMap current = input[i].toMap();
        QString textKey = current.contains("searchable") ? "searchable" : "translation";
        QString text = current.value(textKey).toString();

        foreach (QString const& searchText, searches) {
            text.replace(searchText, "<span style='font-style:italic;font-weight:bold;color:lightgreen'>"+searchText+"</span>", Qt::CaseInsensitive);
        }

        current[textKey] = "<html>"+text+"</html>";
        input[i] = current;
    }

    SimilarReference s;
    s.adm = adm;
    s.input = input;

    return s;
}


SimilarReference ThreadUtils::decorateSimilar(QVariantList input, ArrayDataModel* adm, AbstractTextControl* atc, QString body)
{
    SimilarReference s;
    s.adm = adm;
    s.textControl = atc;

    int n = input.size();

    if (n > 0) {
        QString common = canadainc::TextUtils::longestCommonSubstring( body, input[0].toMap().value("content").toString() );
        s.body = "<html>"+body.replace(common, "<span style='font-style:italic;color:lightgreen'>"+common+"</span>", Qt::CaseInsensitive)+"</html>";
    }

    for (int i = 0; i < n; i++)
    {
        QVariantMap current = input[i].toMap();
        QString text = current.value("content").toString();
        QString common = canadainc::TextUtils::longestCommonSubstring(text, body);

        text.replace(common, "<span style='font-style:italic;color:lightgreen'>"+common+"</span>", Qt::CaseInsensitive);

        current["content"] = "<html>"+text+"</html>";
        input[i] = current;
    }

    s.input = input;

    return s;
}


/**
 * Juz 1, Fatiha, s1, v1
 * Juz 2, Baqara, s2, v142
 * Juz 3, Baqara, s2, v253
 *
 * needs to turn into
 * Juz 1, fatiha s1,v1
 * juz2, baqara,s2,v142
 * juz3, baqara,s2,v253
 * juz 1, baqara s2,v1
 */
QVariantList ThreadUtils::normalizeJuzs(QVariantList const& source)
{
    QVariantList result;
    int lastJuzId = 1;
    int n = source.size();

    QMap<int,bool> processed;

    for (int i = 0; i < n; i++)
    {
        QVariantMap current = source[i].toMap();

        if ( current.value("juz_id").toInt() > 0 )
        {
            lastJuzId = current.value("juz_id").toInt();
            int surah = current.value(KEY_CHAPTER_ID).toInt();

            if ( current.value("verse_number").toInt() > 1 && !processed.contains(surah) )
            {
                QVariantMap copy = current;
                copy["juz_id"] = lastJuzId-1;
                copy["verse_number"] = 1;

                result << copy; // baqara:1
                processed[surah] = true;
            }
        } else {
            current["juz_id"] = lastJuzId;
        }

        result << current;
    }

    return result;
}


QVariantList ThreadUtils::removeOutOfRange(QVariantList input, int fromChapter, int fromVerse, int toChapter, int toVerse)
{
    QMutableListIterator<QVariant> i(input);
    while ( i.hasNext() )
    {
        QVariantMap c = i.next().toMap();
        int chapter = c.value(KEY_CHAPTER_ID).toInt();
        int verse = c.value(KEY_VERSE_ID).toInt();

        if ( (chapter == fromChapter && verse < fromVerse) || (chapter == toChapter && verse >= toVerse) ) {
            i.remove();
        }
    }

    return input;
}


QString ThreadUtils::buildSearchQuery(QVariantList& params, bool isArabic, int chapterNumber, QVariantList additional, bool andMode)
{
    QStringList constraints;
    QString textField = isArabic ? "searchable" : "verses.translation";
    QString query;

    foreach (QVariant const& entry, additional)
    {
        QString queryValue = entry.toString();

        if ( !queryValue.isEmpty() )
        {
            if (andMode) {
                constraints << QString("AND %1").arg(LIKE_CLAUSE);
            } else {
                constraints << QString("OR %1").arg(LIKE_CLAUSE);
            }

            params << queryValue;
        }
    }

    if (isArabic) {
        query = QString("SELECT surah_id,verse_number AS verse_id,searchable,name FROM ayahs INNER JOIN surahs ON ayahs.surah_id=surahs.id WHERE (%1").arg(LIKE_CLAUSE);
    } else {
        query = QString("SELECT ayahs.surah_id AS surah_id,ayahs.verse_number AS verse_id,verses.translation,transliteration AS name,%1 FROM verses INNER JOIN ayahs ON (verses.chapter_id=ayahs.surah_id AND verses.verse_id=ayahs.verse_number) INNER JOIN chapters ON ayahs.surah_id=chapters.id WHERE (%2").arg(textField).arg(LIKE_CLAUSE);
    }

    if ( !constraints.isEmpty() ) {
        query += " "+constraints.join(" ")+")";
    } else {
        query += ")";
    }

    if (chapterNumber > 0) {
        query += QString(" AND ayahs.surah_id=%1").arg(chapterNumber);
    }

    query += " ORDER BY surah_id,verse_id";
    return query;
}


QString ThreadUtils::buildChaptersQuery(QVariantList& args, QString const& text, bool showTranslation)
{
    QString query = "SELECT id AS surah_id,name,verse_count,revelation_order FROM surahs";
    int n = text.length();

    if (showTranslation)
    {
        query = "SELECT a.id AS surah_id,name,verse_count,revelation_order,transliteration FROM surahs a INNER JOIN chapters t ON a.id=t.id";

        if (n > 0)
        {
            query += " WHERE name LIKE '%' || ? || '%' OR transliteration LIKE '%' || ? || '%'";
            args << text;
            args << text;
        }
    } else if (n > 0) {
        query += " WHERE name LIKE '%' || ? || '%'";
        args << text;
    }

    return query;
}


void ThreadUtils::onResultsDecorated(SimilarReference const& result)
{
    QVariantList data = result.input;

    if (result.adm)
    {
        ArrayDataModel* adm = result.adm;

        for (int i = data.size()-1; i >= 0; i--) {
            adm->replace(i, data[i]);
        }
    }

    if (result.textControl) {
        result.textControl->setText(result.body);
    }
}


QVariantMap ThreadUtils::writePluginArchive(QVariantMap const& cookie, QByteArray const& data, QString const& pathKey)
{
    QVariantMap q = cookie;
    QString filePath = q.value(pathKey).toString();
    QString target = QString("%1/%2.zip").arg( QDir::tempPath() ).arg(filePath);
    QString expectedMd5 = q.value(KEY_MD5).toString();

    bool valid = IOUtils::writeIfValidMd5(target, expectedMd5, data);

    if (valid)
    {
        QStringList files = JlCompress::extractDir( target, QDir::homePath(), q.value(KEY_ARCHIVE_PASSWORD).toString().toStdString().c_str() );

        if ( !files.isEmpty() ) {
            return q;
        }
    }

    q[KEY_ERROR] = true;

    return q;
}


bool ThreadUtils::allAyatImagesExist(QVariantList const& surahData, QString const& outputDirectory)
{
    QDir q(outputDirectory);
    q.cd(JOINED_LETTERS_DIRECTORY);
    QSet<QString> all = QSet<QString>::fromList( q.entryList(QDir::Files | QDir::NoDot | QDir::NoDotDot) );

    if ( all.size() >= surahData.size() )
    {
        foreach (QVariant const& surah, surahData)
        {
            QVariantMap s = surah.toMap();
            int id = s.value(KEY_CHAPTER_ID).toInt();
            int n = s.value("verse_count").toInt();

            for (int i = 1; i <= n; i++)
            {
                QString absolutePath = QString("%1_%2.png").arg(id).arg(i);

                if ( !all.contains(absolutePath) ) {
                    LOGGER("NotFound" << absolutePath);
                    return false;
                }
            }
        }

        QFile dirPath( q.path() );

        if ( dirPath.permissions() != READ_WRITE_EXEC )
        {
            LOGGER("WasNotModded!" << q.path() );

            bool modded = dirPath.setPermissions(READ_WRITE_EXEC);

            if (!modded) {
                LOGGER("CantBeModded!");
            }
        }

        return true;
    }

    LOGGER( "SomethingMissing!" << all.size() << surahData.size() );
    return false;
}


void ThreadUtils::cleanLegacyPics()
{
    QDir selectedDir( QDir::home() );

    selectedDir.setFilter(QDir::Files | QDir::NoDot | QDir::NoDotDot);
    selectedDir.setNameFilters( QStringList() << "*.jpg" );

    QDirIterator it(selectedDir);
    int count = 0;

    while ( it.hasNext() ) {
        QFile::remove( it.next() );
        ++count;
    }

    LOGGER("Removed" << count);
}


QVariantMap ThreadUtils::matchSurah(QVariantMap input, QVariantList const& allSurahs)
{
    QString surahName = input.value(KEY_TRANSLITERATION).toString();

    foreach (QVariant q, allSurahs)
    {
        QVariantMap current = q.toMap();
        QString transliteration = current.value(KEY_TRANSLITERATION).toString();

        if ( TextUtils::isSimilar(transliteration, surahName, 75) )
        {
            current[KEY_TRANSLITERATION] = transliteration;
            current[KEY_VERSE_NUMBER] = input[KEY_VERSE_NUMBER];
            input = current;
            LOGGER(current);
            break;
        }
    }

    return input;
}


QVariantList ThreadUtils::captureAyatsInBody(QString body, QMap<QString, int> const& chapterToId)
{
    body.remove( QChar(8217) ); // remove special apostrophe character
    body = body.simplified();

    QVariantList result;
    analyzeAyats( QRegExp("[0-9]{1,3}:[0-9]{1,3}\\s{0,1}-\\s{0,1}[0-9]{1,3}[\\)\\]]|[0-9]{1,3}:[0-9]{1,3}[\\)\\]]|\\([0-9]{1,3}\\) {0,1}: {0,1}[0-9]{1,3}- {0,1}[0-9]{1,3}|\\([0-9]{1,3}\\) {0,1}: {0,1}[0-9]{1,3}"), result, body );

    QRegExp nameRegex = QRegExp("[A-Za-z\\-']+\\s{0,1}:\\s{0,1}[0-9]{1,3}\\s{0,1}-\\s{0,1}[0-9]{1,3}[\\)\\]]|[A-Za-z\\-']+\\s{0,1}:\\s{0,1}[0-9]{1,3}[\\)\\]]");
    int pos = 0;

    while ( (pos = nameRegex.indexIn(body, pos) ) != -1)
    {
        QString current = nameRegex.capturedTexts().first();
        LOGGER(current);
        current.chop(1);
        QStringList tokens = current.split(":");

        QString chapterName = tokens.first().trimmed();
        int chapter = 0;

        QStringList chapters = chapterToId.keys();

        for (int i = chapters.size()-1; i >= 0; i--)
        {
            if ( canadainc::TextUtils::isSimilar(chapters[i], chapterName, 70) )
            {
                chapter = chapterToId.value(chapters[i]);
                break;
            }
        }

        analyzeVerse(tokens, chapter, result);

        pos += nameRegex.matchedLength();
    }

    return result;
}


bool ThreadUtils::replaceDatabase(QString const& src)
{
    QFileInfo qfi(src);
    QString dest = QString("%1/%2").arg( QDir::homePath() ).arg( qfi.fileName() );

    if ( QFile::exists(dest) ) {
        LOGGER("Removing" << dest);
        LOGGER( QFile::remove(dest) );
    }

    LOGGER(src << dest);

    return QFile::copy(src, dest);
}


} /* namespace quran */
