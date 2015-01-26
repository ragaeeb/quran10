#include "precompiled.h"

#include "QueryHelper.h"
#include "customsqldatasource.h"
#include "Logger.h"
#include "Persistance.h"

#define TRANSLATION QString("quran_%1").arg(m_translation)
#define MIN_CHARS_FOR_SURAH_SEARCH 2

namespace quran {

using namespace canadainc;
using namespace bb::data;

QueryHelper::QueryHelper(Persistance* persist) :
        m_sql( QString("%1/assets/dbase/quran_arabic.db").arg( QCoreApplication::applicationDirPath() ) ), m_persist(persist)
{
    connect( persist, SIGNAL( settingChanged(QString const&) ), this, SLOT( settingChanged(QString const&) ), Qt::QueuedConnection );
    //connect( &m_watcher, SIGNAL( fileChanged(QString const&) ), this, SIGNAL( bookmarksUpdated(QString const&) ) );
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
        QString query = "SELECT id,surah_id,verse_id,name,tag,timestamp FROM bookmarks";
        m_sql.executeQuery(caller, query, QueryId::FetchAllBookmarks);
    }
}


bool QueryHelper::initBookmarks(QObject* caller)
{
    QFile bookmarksPath(BOOKMARKS_PATH);
    bool ready = bookmarksPath.exists() && bookmarksPath.size() > 0;

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


bool QueryHelper::fetchChapters(QObject* caller, QString const& text, QString sortOrder)
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

        if ( !sortOrder.isEmpty() )
        {
            if ( sortOrder == "name" && showTranslation() ) {
                sortOrder = "transliteration";
            }

            query += QString(" ORDER BY %1").arg(sortOrder);
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


void QueryHelper::fetchAyat(QObject* caller, int surahId, int ayatId)
{
    LOGGER(surahId << ayatId);

    QString query;

    if ( showTranslation() ) {
        query = QString("SELECT content,verse_number,translation FROM ayahs INNER JOIN verses on ayahs.id=verses.id AND surah_id=%1").arg(surahId);
    } else {
        query = QString("SELECT content AS arabic,verse_number AS verse_id FROM ayahs WHERE surah_id=%1").arg(surahId);
    }

    m_sql.executeQuery(caller, query, QueryId::FetchAyat);
}


void QueryHelper::searchQuery(QObject* caller, QString const& trimmedText)
{
    LOGGER(trimmedText);
    QString table = m_persist->getValueFor("translation").toString();
    QVariantList args = QVariantList() << trimmedText;

    if ( !table.isEmpty() ) {
        m_sql.executeQuery(caller, QString("select %1.surah_id,%1.verse_id,%1.text,chapters.english_name as name, chapters.english_name, chapters.arabic_name, chapters.english_translation from %1 INNER JOIN chapters on chapters.surah_id=%1.surah_id AND %1.text LIKE '%' || ? || '%'").arg(table), QueryId::SearchQueryTranslation, args);
    }

    table = m_persist->getValueFor("primary").toString();

    if (table != "transliteration") {
        m_sql.executeQuery(caller, QString("select %1.surah_id,%1.verse_id,%1.text,chapters.arabic_name as name, chapters.english_name, chapters.arabic_name, chapters.english_translation from %1 INNER JOIN chapters on chapters.surah_id=%1.surah_id AND %1.text LIKE '%' || ? || '%'").arg(table), QueryId::SearchQueryPrimary, args);
    }
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
