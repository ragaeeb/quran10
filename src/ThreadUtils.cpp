#include "precompiled.h"

#include "ThreadUtils.h"
#include "AppLogFetcher.h"
#include "IOUtils.h"
#include "JlCompress.h"
#include "QueryHelper.h"
#include "TextUtils.h"

#define BACKUP_ZIP_PASSWORD "X4*13f3*3qYk3_*"
#define LIKE_CLAUSE QString("(%1 LIKE '%' || ? || '%')").arg(textField)
#define MIN_CHARS_FOR_SURAH_SEARCH 2

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

    return result ? f.fileName() : "";
}

void ThreadUtils::compressFiles(QSet<QString>& attachments)
{
    attachments << CARD_LOG_FILE;
    attachments << BOOKMARKS_PATH;
    canadainc::AppLogFetcher::removeInvalid(attachments);

    JlCompress::compressFiles( ZIP_FILE_PATH, attachments.toList() );
    QFile::remove(CARD_LOG_FILE);
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

    foreach (QVariant const& q, additional) {
        searches << q.toString();
    }

    for (int i = 0; i < n; i++)
    {
        QVariantMap current = input[i].toMap();
        QString text = current.value("ayatText").toString();

        foreach (QString const& searchText, searches) {
            text.replace(searchText, "<span style='font-style:italic;font-weight:bold;color:lightgreen'>"+searchText+"</span>", Qt::CaseInsensitive);
        }

        current["ayatText"] = "<html>"+text+"</html>";
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
            int surah = current.value("surah_id").toInt();

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
        int chapter = c.value("surah_id").toInt();
        int verse = c.value("verse_id").toInt();

        if ( (chapter == fromChapter && verse < fromVerse) || (chapter == toChapter && verse >= toVerse) ) {
            i.remove();
        }
    }

    return input;
}


QString ThreadUtils::buildSearchQuery(QVariantList& params, bool isArabic, QString const& trimmedText, int chapterNumber, QVariantList additional, bool andMode)
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
        query = QString("SELECT surah_id,verse_number AS verse_id,searchable AS ayatText,name FROM ayahs INNER JOIN surahs ON ayahs.surah_id=surahs.id WHERE (%1").arg(LIKE_CLAUSE);
    } else {
        query = QString("SELECT ayahs.surah_id AS surah_id,ayahs.verse_number AS verse_id,verses.translation AS ayatText,transliteration AS name,%1 FROM verses INNER JOIN ayahs ON verses.id=ayahs.id INNER JOIN chapters ON ayahs.surah_id=chapters.id WHERE (%2").arg(textField).arg(LIKE_CLAUSE);
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
    QString query;
    int n = text.length();

    if (n > MIN_CHARS_FOR_SURAH_SEARCH || n == 0)
    {
        if (showTranslation)
        {
            query = "SELECT a.id AS surah_id,name,verse_count,revelation_order,transliteration FROM surahs a INNER JOIN chapters t ON a.id=t.id";

            if (n > MIN_CHARS_FOR_SURAH_SEARCH)
            {
                query += " WHERE name LIKE '%' || ? || '%' OR transliteration LIKE '%' || ? || '%'";
                args << text;
                args << text;
            }
        } else {
            query = "SELECT id AS surah_id,name,verse_count,revelation_order FROM surahs";

            if (n > MIN_CHARS_FOR_SURAH_SEARCH)
            {
                query += " WHERE name LIKE '%' || ? || '%'";
                args << text;
            }
        }
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


QString ThreadUtils::writeTafsirArchive(QVariant const& q, QByteArray const& data)
{
    QString tafsirPath = q.toMap().value("tafsirPath").toString();
    QString target = QString("%1/%2.zip").arg( QDir::tempPath() ).arg(tafsirPath);

    bool written = IOUtils::writeFile(target, data);
    return written ? target : QString();
}

} /* namespace quran */
