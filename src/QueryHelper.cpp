#include "precompiled.h"

#include "QueryHelper.h"
#include "customsqldatasource.h"
#include "Logger.h"
#include "Persistance.h"

#define TAFSIR QString("tafsir_%1").arg(m_translation)
#define ATTACH_TAFSIR m_sql.attachIfNecessary(TAFSIR, true);

namespace quran {

using namespace canadainc;
using namespace bb::data;

QueryHelper::QueryHelper(Persistance* persist) :
        m_sql( QString("%1/assets/dbase/quran_arabic.db").arg( QCoreApplication::applicationDirPath() ) ), m_persist(persist)
{
    connect( persist, SIGNAL( settingChanged(QString const&) ), this, SLOT( settingChanged(QString const&) ), Qt::QueuedConnection );
    connect( &m_watcher, SIGNAL( fileChanged(QString const&) ), this, SIGNAL( bookmarksUpdated(QString const&) ) );
}


void QueryHelper::apply(QString const& text)
{
    m_sql.executeQuery(this, text, 56);
}


void QueryHelper::onDataLoaded(QVariant id, QVariant data)
{
    Q_UNUSED(data);

    if ( id.toInt() == QueryId::UpdatePlugins ) {
        showPluginsUpdatedToast();
    }
}


void QueryHelper::showPluginsUpdatedToast() {
    m_persist->showToast( tr("Similar Narrations and Tafsir Databases Updated!"), "", "asset:///images/dropdown/similar.png" );
}


void QueryHelper::lazyInit()
{
    m_translation = m_persist->getValueFor("translation").toString();

    m_sql.attachIfNecessary( QString("quran_%1").arg(m_translation), m_translation != "english" ); // since english translation is loaded by default
}


void QueryHelper::settingChanged(QString const& key)
{
    if (key == "translation" || key == "primary")
    {
        m_translation = m_persist->getValueFor("translation").toString();
        m_sql.detach(TAFSIR);
        emit textualChange();
    }
}


void QueryHelper::fetchAllBookmarks(QObject* caller)
{
    LOGGER("fetchAllBookmarks");
    QString query = "SELECT id as bid,aid as id,collection,hadithNumber,name,tag,timestamp FROM bookmarks ORDER BY timestamp DESC";

    m_sql.executeQuery(caller, query, QueryId::FetchAllBookmarks);
}


void QueryHelper::fetchAllTafsir(QObject* caller)
{
    ATTACH_TAFSIR;
    QString query = "SELECT id,author,title FROM suites ORDER BY id DESC";
    m_sql.executeQuery(caller, query, QueryId::FetchAllTafsir);
}


void QueryHelper::fetchAllDuaa(QObject* caller)
{
    m_sql.executeQuery(caller, "SELECT surah_id,name,transliteration,verse_number_start FROM supplications INNER JOIN chapters ON supplications.surah_id=chapters.id INNER JOIN surahs ON chapters.id=surahs.id ORDER BY surah_id,verse_number_start ASC", QueryId::FetchAllDuaa);
}


void QueryHelper::fetchChapters(QObject* caller, QString const& text)
{
    QString query;

    static QRegExp chapterAyatNumeric = QRegExp(AYAT_NUMERIC_PATTERN);
    static QRegExp chapterNumeric = QRegExp("^\\d{1,3}$");

    if ( chapterAyatNumeric.exactMatch(text) || chapterNumeric.exactMatch(text) )
    {
        int chapter = text.split(":").first().toInt();

        if (chapter > 0 && chapter <= 114) {
            query = QString("SELECT surah_id,arabic_name,english_name,english_translation FROM chapters WHERE surah_id=%1").arg(chapter);
        }
    } else if ( text.length() > 2 ) {
        query = QString("SELECT surah_id,arabic_name,english_name,english_translation FROM chapters WHERE english_name like '%%1%' OR arabic_name like '%%1%'").arg(text);
    } else if ( text.isEmpty() ) {
        query = "SELECT a.id AS surah_id,name,transliteration FROM surahs a INNER JOIN chapters t ON a.id=t.id";
    }

    if ( !query.isNull() ) {
        m_sql.executeQuery(caller, query, QueryId::FetchChapters);
    }
}


void QueryHelper::fetchRandomAyat(QObject* caller)
{
    //LOGGER("fetchRandomAyat");

    QString table = m_persist->getValueFor("translation").toString();

    if ( table.isEmpty() )
    {
        table = m_persist->getValueFor("primary").toString();

        if (table == "transliteration") {
            table = "arabic_uthmani";
        }
    }

    m_sql.executeQuery( caller, QString("SELECT * FROM %1 ORDER BY RANDOM() LIMIT 1").arg(table), QueryId::FetchRandomAyat );
}


void QueryHelper::fetchTafsirForAyat(QObject* caller, int chapterNumber, int verseId)
{
    //LOGGER(chapterNumber << verseId);
    m_sql.executeQuery( caller, QString("SELECT id,verse_id,explainer,description FROM tafsir_english WHERE surah_id=%1 AND verse_id=%2").arg(chapterNumber).arg(verseId), QueryId::FetchTafsirForAyat );
}


void QueryHelper::fetchTafsirContent(QObject* caller, QString const& tafsirId)
{
    //LOGGER(tafsirId);
    m_sql.executeQuery( caller, QString("SELECT * from tafsir_english WHERE id=%1").arg(tafsirId), QueryId::FetchTafsirContent );
}


void QueryHelper::fetchSurahHeader(QObject* caller, int chapterNumber)
{
    //LOGGER(chapterNumber);

    m_sql.executeQuery( caller, QString("SELECT english_name, english_translation, arabic_name FROM chapters WHERE surah_id=%1").arg(chapterNumber), QueryId::FetchSurahHeader );
}


void QueryHelper::fetchTafsirForSurah(QObject* caller, int chapterNumber, bool excludeVerses)
{
    //LOGGER(chapterNumber);

    if (excludeVerses) {
        m_sql.executeQuery( caller, QString("SELECT id,description,verse_id,explainer FROM tafsir_english WHERE surah_id=%1 AND verse_id ISNULL").arg(chapterNumber), QueryId::FetchTafsirForSurah );
    } else {
        m_sql.executeQuery( caller, QString("SELECT id,verse_id,explainer FROM tafsir_english WHERE surah_id=%1 AND verse_id NOT NULL").arg(chapterNumber), QueryId::FetchTafsirForSurah );
    }
}


void QueryHelper::fetchAllAyats(QObject* caller, int chapterNumber)
{
    //LOGGER(chapterNumber);

    QString query;

    if ( !m_translation.isEmpty() ) {
        query = QString("SELECT content AS arabic,verse_number AS verse_id,translation FROM ayahs INNER JOIN verses on ayahs.id=verses.id AND surah_id=%1").arg(chapterNumber);
    } else {
        //query = QString("SELECT text as arabic,verse_id FROM %1 WHERE surah_id=%2").arg(primary).arg(chapterNumber);
    }

    m_sql.executeQuery(caller, query, QueryId::FetchAllAyats);
}


void QueryHelper::fetchTafsirIbnKatheer(QObject* caller, int chapterNumber)
{
    //LOGGER(chapterNumber);

    if (chapterNumber == 114) {
        chapterNumber = 113;
    }

    m_sql.executeQuery(caller, QString("SELECT title,body FROM ibn_katheer_english WHERE surah_id=%1").arg(chapterNumber), QueryId::FetchTafsirIbnKatheerForSurah);
}



void QueryHelper::searchQuery(QObject* caller, QString const& trimmedText)
{
    //LOGGER(trimmedText);
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
    //LOGGER("fetchPageNumbers");
    m_sql.executeQuery(caller, "SELECT MIN(page_number) as page_number,chapters.english_name,chapters.arabic_name from mushaf_pages INNER JOIN chapters ON mushaf_pages.surah_id=chapters.surah_id GROUP BY mushaf_pages.surah_id", QueryId::FetchPageNumbers);
}


void QueryHelper::addTafsir(QObject* caller, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference)
{
    LOGGER(author << translator << explainer << title << description << reference);

    QString query = QString("INSERT OR IGNORE INTO suites (id,author,translator,explainer,title,description,reference) VALUES(%1,?,?,?,?,?,?)").arg( QDateTime::currentMSecsSinceEpoch() );
    m_sql.executeQuery(caller, query, QueryId::AddTafsir, QVariantList() << author << translator << explainer << title << description << reference);
}


void QueryHelper::addTafsirPage(QObject* caller, qint64 suiteId, QString const& body)
{
    LOGGER( suiteId << body.length() );

    QString query = QString("INSERT OR IGNORE INTO suite_pages (id,suite_id,body) VALUES(%1,%2,?)").arg( QDateTime::currentMSecsSinceEpoch() ).arg(suiteId);
    m_sql.executeQuery(caller, query, QueryId::AddTafsirPage, QVariantList() << body);
}


void QueryHelper::editTafsir(QObject* caller, qint64 suiteId, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference)
{
    LOGGER(suiteId << author << translator << explainer << title << description << reference);

    QString query = QString("UPDATE suites SET author=?,translator=?,explainer=?,title=?,description=?,reference=? WHERE id=%1").arg(suiteId);
    m_sql.executeQuery(caller, query, QueryId::EditTafsir, QVariantList() << author << translator << explainer << title << description << reference);
}


void QueryHelper::editTafsirPage(QObject* caller, qint64 suitePageId, QString const& body)
{
    LOGGER( suitePageId << body.length() );

    QString query = QString("UPDATE suite_pages SET body=? WHERE id=%1").arg(suitePageId);
    m_sql.executeQuery(caller, query, QueryId::EditTafsirPage, QVariantList() << body);
}


void QueryHelper::removeTafsirPage(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);

    QString query = QString("DELETE FROM suite_pages WHERE id=%1").arg(suitePageId);
    m_sql.executeQuery(caller, query, QueryId::RemoveTafsirPage);
}


void QueryHelper::removeTafsir(QObject* caller, qint64 suiteId)
{
    LOGGER(suiteId);

    QString query = QString("DELETE FROM suites WHERE id=%1").arg(suiteId);
    m_sql.executeQuery(caller, query, QueryId::RemoveTafsir);
}


void QueryHelper::initForeignKeys() {
    m_sql.enableForeignKeys();
}


void QueryHelper::monitorBookmarks() {
    m_watcher.addPath(BOOKMARKS_PATH);
}


void QueryHelper::diffPlugins(QString const& similarDbase, QString const& tafsirArabicDbase, QString const& translationDbase, QString const& path)
{
    LOGGER(similarDbase << tafsirArabicDbase << translationDbase << path);

    m_sql.attachIfNecessary(SIMILAR_DB, true);
    m_sql.attachIfNecessary(TAFSIR_ARABIC_DB, true);
    m_sql.attachIfNecessary(TAFSIR, true);
    m_sql.attachIfNecessary(similarDbase, path);
    m_sql.attachIfNecessary(tafsirArabicDbase, path);
    m_sql.attachIfNecessary(translationDbase, path);

    m_sql.startTransaction(NULL, QueryId::UpdatePlugins);
    m_sql.executeQuery(NULL, QString("INSERT OR IGNORE INTO tafsir_arabic.suites SELECT * FROM %1.suites").arg(tafsirArabicDbase), QueryId::AddTafsir);
    m_sql.executeQuery(NULL, QString("INSERT OR IGNORE INTO tafsir_arabic.suite_pages SELECT * FROM %1.suite_pages").arg(tafsirArabicDbase), QueryId::AddTafsirPage);
    m_sql.executeQuery(NULL, QString("INSERT OR IGNORE INTO tafsir_arabic.explanations SELECT * FROM %1.explanations").arg(tafsirArabicDbase), QueryId::LinkAyatsToTafsir);
    m_sql.executeQuery(NULL, QString("INSERT OR IGNORE INTO tafsir_english.suites SELECT * FROM %1.suites").arg(translationDbase), QueryId::AddTafsir);
    m_sql.executeQuery(NULL, QString("INSERT OR IGNORE INTO tafsir_english.suite_pages SELECT * FROM %1.suite_pages").arg(translationDbase), QueryId::AddTafsirPage);
    m_sql.executeQuery(NULL, QString("INSERT OR IGNORE INTO tafsir_english.explanations SELECT * FROM %1.explanations").arg(translationDbase), QueryId::LinkAyatsToTafsir);
    m_sql.endTransaction(NULL, QueryId::UpdatePlugins);

    m_sql.detach(similarDbase);
    m_sql.detach(tafsirArabicDbase);
    m_sql.detach(translationDbase);
}


bool QueryHelper::initDatabase(QObject* caller)
{
    if ( !bookmarksReady() )
    {
        QStringList statements;
        statements << "CREATE TABLE bookmarks (id INTEGER PRIMARY KEY, aid INTEGER, collection TEXT, hadithNumber TEXT, name TEXT, tag TEXT, timestamp INTEGER)";
        statements << "CREATE TABLE bookmarked_tafsir (id INTEGER PRIMARY KEY, tid INTEGER, author TEXT, title TEXT, name TEXT, tag TEXT, timestamp INTEGER)";
        m_sql.initSetup( caller, statements, QueryId::Setup );

        return false;
    }

    monitorBookmarks();

    return true;
}


void QueryHelper::removeBookmark(QObject* caller, int id)
{
    LOGGER(id);

    QString query = QString("DELETE FROM bookmarks WHERE id=%1").arg(id);
    m_sql.executeQuery(caller, query, QueryId::RemoveBookmark);
}


void QueryHelper::fetchAllTafsirForSuite(QObject* caller, qint64 suiteId)
{
    LOGGER(suiteId);

    ATTACH_TAFSIR;
    QString query = QString("SELECT id,body FROM suite_pages WHERE suite_id=%1 ORDER BY id DESC").arg(suiteId);
    m_sql.executeQuery(caller, query, QueryId::FetchAllTafsirForSuite);
}


bool QueryHelper::bookmarksReady()
{
    QFile bookmarksPath(BOOKMARKS_PATH);
    return bookmarksPath.exists() && bookmarksPath.size() > 0;
}


void QueryHelper::clearAllBookmarks(QObject* caller)
{
    QString query = "DELETE FROM bookmarks";
    m_sql.executeQuery(caller, query, QueryId::ClearAllBookmarks);
}


bool QueryHelper::pluginsExist() {
    return QFile::exists( QString("%1/%2.db").arg( QDir::homePath() ).arg(SIMILAR_DB) ) && QFile::exists( QString("%1/%2.db").arg( QDir::homePath() ).arg(TAFSIR) );
}


QString QueryHelper::translation() const {
    return m_translation;
}


QueryHelper::~QueryHelper()
{
}

} /* namespace oct10 */
