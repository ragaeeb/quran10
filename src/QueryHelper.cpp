#include "precompiled.h"

#include "QueryHelper.h"
#include "customsqldatasource.h"
#include "Logger.h"
#include "Persistance.h"

#define TRANSLATION QString("quran_%1").arg(m_translation)
#define MIN_CHARS_FOR_SURAH_SEARCH 2
#define LIKE_CLAUSE QString("(%1 LIKE '%' || ? || '%')").arg(textField)

namespace quran {

using namespace canadainc;
using namespace bb::data;

QueryHelper::QueryHelper(Persistance* persist) :
        m_sql( QString("%1/assets/dbase/quran_arabic.db").arg( QCoreApplication::applicationDirPath() ) ), m_persist(persist)
{
    connect( persist, SIGNAL( settingChanged(QString const&) ), this, SLOT( settingChanged(QString const&) ), Qt::QueuedConnection );
}


void QueryHelper::onDataLoaded(QVariant id, QVariant data)
{
    Q_UNUSED(data);
    Q_UNUSED(id);
}


void QueryHelper::lazyInit()
{
    settingChanged("translation");
    m_sql.attachIfNecessary(TRANSLATION, m_translation != "english"); // since english translation is loaded by default
}


void QueryHelper::settingChanged(QString const& key)
{
    if (key == "translation")
    {
        if ( showTranslation() )
        {
            m_sql.detach(TRANSLATION);
        }

        m_translation = m_persist->getValueFor("translation").toString();

        emit textualChange();
    }
}


void QueryHelper::fetchAllBookmarks(QObject* caller)
{
    LOGGER("fetchAllBookmarks");

    if ( initBookmarks(caller) )
    {
        QString query = "SELECT bookmarks.id AS id,surah_id,verse_id,bookmarks.name AS name,tag,timestamp,surahs.name AS surah_name FROM bookmarks INNER JOIN surahs ON surahs.id=surah_id";
        m_sql.executeQuery(caller, query, QueryId::FetchAllBookmarks);
    }
}


bool QueryHelper::initBookmarks(QObject* caller)
{
    QFile bookmarksPath(BOOKMARKS_PATH);
    bool ready = bookmarksPath.exists() && bookmarksPath.size() > 0;

    m_sql.attachIfNecessary("bookmarks", true);

    if (!ready) // if no bookmarks created yet
    {
        m_sql.startTransaction(caller, QueryId::SettingUpBookmarks);

        QStringList statements;
        statements << "CREATE TABLE IF NOT EXISTS bookmarks.bookmarks (id INTEGER PRIMARY KEY, surah_id INTEGER REFERENCES surahs(id), verse_id INTEGER REFERENCES ayahs(id), name TEXT, tag TEXT, timestamp INTEGER)";
        statements << "CREATE TABLE IF NOT EXISTS bookmarks.bookmarked_tafsir (id INTEGER PRIMARY KEY, tid INTEGER, author TEXT, title TEXT, name TEXT, tag TEXT, timestamp INTEGER)";

        foreach (QString const& q, statements) {
            m_sql.executeInternal(q, QueryId::SettingUpBookmarks);
        }

        m_sql.endTransaction(caller, QueryId::SetupBookmarks);
    }

    return ready;
}


void QueryHelper::fetchAllDuaa(QObject* caller)
{
    if ( showTranslation() ) {
        m_sql.executeQuery(caller, "SELECT surah_id,name,transliteration,verse_number_start FROM supplications INNER JOIN chapters ON supplications.surah_id=chapters.id INNER JOIN surahs ON chapters.id=surahs.id", QueryId::FetchAllDuaa);
    } else {
        m_sql.executeQuery(caller, "SELECT surah_id,name,verse_number_start FROM supplications INNER JOIN surahs ON supplications.surah_id=surahs.id", QueryId::FetchAllDuaa);
    }
}


bool QueryHelper::fetchChapters(QObject* caller, QString const& text)
{
    QString query;

    static QRegExp chapterAyatNumeric = QRegExp(AYAT_NUMERIC_PATTERN);
    static QRegExp chapterNumeric = QRegExp("^\\d{1,3}$");
    QVariantList args;
    int n = text.length();

    if ( chapterAyatNumeric.exactMatch(text) || chapterNumeric.exactMatch(text) )
    {
        int chapter = text.split(":").first().toInt();

        if (chapter > 0 && chapter <= 114) {
            query = QString("SELECT surah_id,arabic_name,english_name,english_translation FROM chapters WHERE surah_id=%1").arg(chapter);
        }
    } else if (n > MIN_CHARS_FOR_SURAH_SEARCH || n == 0) {

        if ( showTranslation() )
        {
            query = "SELECT a.id AS surah_id,name,verse_count,revelation_order,transliteration,j.id AS juz_id,verse_number FROM surahs a INNER JOIN chapters t ON a.id=t.id LEFT JOIN juzs j ON j.surah_id=a.id";

            if (n > MIN_CHARS_FOR_SURAH_SEARCH)
            {
                query += " WHERE name LIKE '%' || ? || '%' OR transliteration LIKE '%' || ? || '%'";
                args << text;
                args << text;
            }
        } else {
            query = "SELECT id AS surah_id,name,verse_count,revelation_order,j.id AS juz_id,verse_number FROM surahs LEFT JOIN juzs j ON j.surah_id=a.id";

            if (n > MIN_CHARS_FOR_SURAH_SEARCH)
            {
                query += " WHERE name LIKE '%' || ? || '%'";
                args << text;
            }
        }
    }

    if ( !query.isNull() ) {
        m_sql.executeQuery(caller, query, QueryId::FetchChapters, args);
        return true;
    }

    return false;
}


void QueryHelper::fetchRandomAyat(QObject* caller)
{
    LOGGER("fetchRandomAyat");

    if ( !showTranslation() ) {
        m_sql.executeQuery(caller, "SELECT surah_id,verse_number AS verse_id,content AS text FROM ayahs WHERE RANDOM() % 6000 = 0 LIMIT 1", QueryId::FetchRandomAyat);
    } else {
        m_sql.executeQuery(caller, "SELECT surah_id,verse_number AS verse_id,translation AS text FROM ayahs a INNER JOIN verses v ON a.id=v.id WHERE RANDOM() % 6000 = 0 LIMIT 1", QueryId::FetchRandomAyat);
    }
}


void QueryHelper::fetchSurahHeader(QObject* caller, int chapterNumber)
{
    LOGGER(chapterNumber);

    if ( showTranslation() ) {
        m_sql.executeQuery( caller, QString("SELECT name,translation,transliteration FROM surahs s INNER JOIN chapters c ON s.id=c.id WHERE s.id=%1").arg(chapterNumber), QueryId::FetchSurahHeader );
    } else {
        m_sql.executeQuery( caller, QString("SELECT name FROM surahs WHERE id=%1").arg(chapterNumber), QueryId::FetchSurahHeader );
    }
}


void QueryHelper::fetchAllAyats(QObject* caller, int chapterNumber)
{
    LOGGER(chapterNumber);

    QString query;

    if ( showTranslation() ) {
        query = QString("SELECT content AS arabic,verse_number AS verse_id,translation FROM ayahs INNER JOIN verses on ayahs.id=verses.id AND surah_id=%1").arg(chapterNumber);
    } else {
        query = QString("SELECT content AS arabic,verse_number AS verse_id FROM ayahs WHERE surah_id=%1").arg(chapterNumber);
    }

    m_sql.executeQuery(caller, query, QueryId::FetchAllAyats);
}


void QueryHelper::fetchAllTafsirForAyat(QObject* caller, int chapterNumber, int verseNumber)
{
    LOGGER(chapterNumber << verseNumber);

    //m_sql.executeQuery(caller, "", QueryId::FetchTafsirForAyat);
}


void QueryHelper::fetchSimilarAyat(QObject* caller, int chapterNumber, int verseNumber)
{
    LOGGER(chapterNumber << verseNumber);
    //m_sql.executeQuery(caller, "", QueryId::FetchSimilarAyat);
}


void QueryHelper::fetchAyat(QObject* caller, int surahId, int ayatId)
{
    LOGGER(surahId << ayatId);

    QString query;

    if ( showTranslation() ) {
        query = QString("SELECT content,translation FROM ayahs INNER JOIN verses on ayahs.id=verses.id WHERE ayahs.surah_id=%1 AND ayahs.verse_number=%2").arg(surahId).arg(ayatId);
    } else {
        query = QString("SELECT content FROM ayahs WHERE surah_id=%1 AND verse_number=%2").arg(surahId).arg(ayatId);
    }

    m_sql.executeQuery(caller, query, QueryId::FetchAyat);
}


void QueryHelper::searchQuery(QObject* caller, QString const& trimmedText, QVariantList additional, bool andMode, bool shortNarrations)
{
    LOGGER(trimmedText << additional << andMode << shortNarrations);

    QStringList constraints;
    QVariantList params = QVariantList() << trimmedText;
    bool isArabic = trimmedText.isRightToLeft() || !showTranslation();
    QString textField = isArabic ? "searchable" : "translation";
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
        query = QString("SELECT surah_id,verse_id,content,name FROM ayahs INNER JOIN surahs ON ayahs.surah_id=surahs.id WHERE (%1").arg(textField).arg(LIKE_CLAUSE);
    } else {
        query = QString("SELECT ayahs.surah_id AS surah_id,ayahs.verse_number AS verse_id,verses.translation AS translation,transliteration,%1 FROM verses INNER JOIN ayahs ON verses.id=ayahs.id INNER JOIN chapters ON ayahs.surah_id=chapters.id WHERE (%2").arg(textField).arg(LIKE_CLAUSE);
    }

    if ( !constraints.isEmpty() ) {
        query += " "+constraints.join(" ")+")";
    } else {
        query += ")";
    }

    /*
    if (shortThreshold > 0) {
        query += QString(" AND length(%1) < %2").arg(textField).arg(shortThreshold);
    } */

    m_sql.executeQuery(caller, query, QueryId::SearchAyats, params);
}


void QueryHelper::fetchPageNumbers(QObject* caller)
{
    LOGGER("fetchPageNumbers");

    if ( showTranslation() ) {

        m_sql.executeQuery(caller, "SELECT MIN(page_number) as page_number,name,translation from mushaf_pages INNER JOIN surahs ON surahs.id=mushaf_pages.surah_id INNER JOIN chapters ON mushaf_pages.surah_id=chapters.id GROUP BY surah_id", QueryId::FetchPageNumbers);
    } else {
        m_sql.executeQuery(caller, "SELECT MIN(page_number) as page_number,name,verse_count from mushaf_pages INNER JOIN surahs ON surahs.id=mushaf_pages.surah_id GROUP BY surah_id", QueryId::FetchPageNumbers);
    }
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
QVariantList QueryHelper::normalizeJuzs(QVariantList const& source)
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


void QueryHelper::initForeignKeys() {
    m_sql.enableForeignKeys();
}


void QueryHelper::removeBookmark(QObject* caller, int id)
{
    LOGGER(id);

    QString query = QString("DELETE FROM bookmarks WHERE id=%1").arg(id);
    m_sql.executeQuery(caller, query, QueryId::RemoveBookmark);
}


void QueryHelper::clearAllBookmarks(QObject* caller)
{
    QString query = "DELETE FROM bookmarks";
    m_sql.executeQuery(caller, query, QueryId::ClearAllBookmarks);
}


void QueryHelper::saveBookmark(QObject* caller, int surahId, int verseId, QString const& name, QString const& tag)
{
    LOGGER(surahId << verseId << name << tag);

    initBookmarks(caller);

    QString query = QString("INSERT INTO bookmarks (surah_id,verse_id,name,tag,timestamp) VALUES (%1,'%2',?,?,%3)").arg(surahId).arg(verseId).arg( QDateTime::currentMSecsSinceEpoch() );
    m_sql.executeQuery(caller, query, QueryId::SaveBookmark, QVariantList() << name << tag);
}

bool QueryHelper::showTranslation() const {
    return !m_translation.isEmpty();
}

int QueryHelper::primarySize() const {
    return m_persist->getValueFor("primarySize").toInt();
}

int QueryHelper::translationSize() const
{
    int result = m_persist->getValueFor("translationSize").toInt();
    return result > 0 ? result : 8;
}


QueryHelper::~QueryHelper()
{
}

} /* namespace oct10 */
