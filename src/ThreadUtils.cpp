#include "precompiled.h"

#include "ThreadUtils.h"
#include "AppLogFetcher.h"
#include "CommonConstants.h"
#include "DatabaseHelper.h"
#include "IOUtils.h"
#include "JlCompress.h"
#include "Logger.h"
#include "QueryHelper.h"
#include "QueueDownloader.h"
#include "TextUtils.h"

#define BACKUP_ZIP_PASSWORD "X4*13f3*3qYk3_*"

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
using namespace std;

QString ThreadUtils::compressBookmarks(QString const& destinationZip)
{
    bool result = JlCompress::compressFile(destinationZip, BOOKMARKS_PATH, BACKUP_ZIP_PASSWORD);
    QFileInfo f(destinationZip);

    return result && f.size() > 0 ? f.fileName() : "";
}

void ThreadUtils::compressFiles(Report& r, QString const& zipPath, const char* password)
{
    if (r.type == ReportType::BugReportAuto || r.type == ReportType::BugReportManual) {
        r.attachments << BOOKMARKS_PATH;
    }

    JlCompress::compressFiles(zipPath, r.attachments, password);
}

bool ThreadUtils::performRestore(QString const& source)
{
    QStringList files = JlCompress::extractDir( source, QDir::homePath(), BACKUP_ZIP_PASSWORD );
    return !files.isEmpty();
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
                constraints << QString("AND %1").arg( LIKE_CLAUSE(textField) );
            } else {
                constraints << QString("OR %1").arg( LIKE_CLAUSE(textField) );
            }

            params << queryValue;
        }
    }

    if (isArabic) {
        query = QString("SELECT surah_id,verse_number,searchable,name FROM ayahs INNER JOIN surahs ON ayahs.surah_id=surahs.id WHERE (%1").arg( LIKE_CLAUSE(textField) );
    } else {
        query = QString("SELECT ayahs.surah_id AS surah_id,ayahs.verse_number,verses.translation,transliteration AS name,%1 FROM verses INNER JOIN ayahs ON (verses.chapter_id=ayahs.surah_id AND verses.verse_id=ayahs.verse_number) INNER JOIN chapters ON ayahs.surah_id=chapters.id WHERE (%2").arg(textField).arg( LIKE_CLAUSE(textField) );
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


QVariantList ThreadUtils::allAyatImagesExist(QVariantList const& surahData, QString const& outputDirectory, QString const& ayatDirectory)
{
    QDir q(outputDirectory);
    q.cd(ayatDirectory);
    QSet<QString> all = QSet<QString>::fromList( q.entryList(QDir::Files | QDir::NoDot | QDir::NoDotDot) );
    QVariantList missing;

    foreach (QVariant const& surah, surahData)
    {
        QVariantMap s = surah.toMap();
        int surahId = s.value(KEY_CHAPTER_ID).toInt();
        int n = s.value("verse_count").toInt();

        for (int i = 1; i <= n; i++)
        {
            QString absolutePath = QString("%1_%2.png").arg(surahId).arg(i);

            if ( !all.contains(absolutePath) )
            {
                QVariantMap qvm;
                qvm[KEY_CHAPTER_ID] = surahId;
                qvm[KEY_VERSE_ID] = i;
                missing << qvm;
            }
        }
    }

    QFile dirPath( q.path() );

    if ( dirPath.permissions() != READ_WRITE_EXEC && NOT_APP_DIR(outputDirectory) )
    {
        LOGGER("WasNotModded!" << q.path() );

        bool modded = dirPath.setPermissions(READ_WRITE_EXEC);

        if (!modded) {
            LOGGER("CantBeModded!");
        }
    }

    LOGGER( "SomethingMissing!" << all.size() << surahData.size() );
    return missing;
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


void ThreadUtils::preventIndexing(QString const& dirPath)
{
    QDir q(dirPath);

    if ( q.exists() && NOT_APP_DIR(dirPath) )
    {
        QFile f( QString("%1/.nomedia").arg(dirPath) );

        if ( !f.exists() ) {
            bool written = f.open(QIODevice::WriteOnly);
            f.close();
            LOGGER(f.fileName() << "written" << written);
        } else {
            LOGGER(".nomediaExists");
        }
    } else {
        LOGGER(dirPath << "noexists");
    }
}


} /* namespace quran */
