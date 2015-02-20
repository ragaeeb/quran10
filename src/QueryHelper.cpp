#include "precompiled.h"

#include "QueryHelper.h"
#include "customsqldatasource.h"
#include "Logger.h"
#include "Persistance.h"
#include "TextUtils.h"
#include "ThreadUtils.h"

#define ATTACH_ARTICLES m_sql.attachIfNecessary( QString("articles_%1").arg(m_translation), true );
#define ATTACH_TAFSIR m_sql.attachIfNecessary( tafsirName(), true ); ATTACH_ARTICLES;
#define TRANSLATION QString("quran_%1").arg(m_translation)

namespace quran {

using namespace canadainc;
using namespace bb::data;

QueryHelper::QueryHelper(Persistance* persist) :
        m_sql( QString("%1/assets/dbase/quran_arabic.db").arg( QCoreApplication::applicationDirPath() ) ),
        m_persist(persist), m_tafsirHelper(&m_sql), m_bookmarkHelper(&m_sql)
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

    QTime time = QTime::currentTime();
    qsrand( (uint)time.msec() );
}


void QueryHelper::settingChanged(QString const& key)
{
    if (key == "translation")
    {
        if ( showTranslation() ) {
            m_sql.detach(TRANSLATION);
        }

        m_translation = m_persist->getValueFor("translation").toString();

        emit textualChange();
    }
}


void QueryHelper::fetchAllDuaa(QObject* caller)
{
    if ( showTranslation() ) {
        m_sql.executeQuery(caller, "SELECT surah_id,name,transliteration,verse_number_start FROM supplications INNER JOIN chapters ON supplications.surah_id=chapters.id INNER JOIN surahs ON chapters.id=surahs.id", QueryId::FetchAllDuaa);
    } else {
        m_sql.executeQuery(caller, "SELECT surah_id,name,verse_number_start FROM supplications INNER JOIN surahs ON supplications.surah_id=surahs.id", QueryId::FetchAllDuaa);
    }
}


void QueryHelper::fetchAllChapters(QObject* caller)
{
    QString query = "SELECT surahs.id AS surah_id,name,verse_count,revelation_order,j.id AS juz_id,verse_number FROM surahs LEFT JOIN juzs j ON j.surah_id=surahs.id";

    if ( showTranslation() ) {
        query = "SELECT a.id AS surah_id,name,verse_count,revelation_order,transliteration,j.id AS juz_id,verse_number FROM surahs a INNER JOIN chapters t ON a.id=t.id LEFT JOIN juzs j ON j.surah_id=a.id";
    }

    m_sql.executeQuery(caller, query, QueryId::FetchAllChapters);
}


bool QueryHelper::fetchChapters(QObject* caller, QString const& text)
{
    QVariantList args;
    QString query = ThreadUtils::buildChaptersQuery( args, text, showTranslation() );

    if ( !query.isNull() ) {
        m_sql.executeQuery(caller, query, QueryId::FetchChapters, args);
        return true;
    }

    return false;
}


void QueryHelper::fetchChapter(QObject* caller, int chapter)
{
    LOGGER(chapter);

    if ( showTranslation() ) {
        m_sql.executeQuery(caller, QString("SELECT a.id AS surah_id,name,verse_count,revelation_order,transliteration,j.id AS juz_id,verse_number FROM surahs a INNER JOIN chapters t ON a.id=t.id LEFT JOIN juzs j ON j.surah_id=a.id WHERE a.id=%1").arg(chapter), QueryId::FetchChapters);
    } else {
        m_sql.executeQuery(caller, QString("SELECT surahs.id AS surah_id,name,verse_count,revelation_order,j.id AS juz_id,verse_number FROM surahs LEFT JOIN juzs j ON j.surah_id=a.id WHERE id=%1").arg(chapter), QueryId::FetchChapters );
    }
}


void QueryHelper::fetchRandomAyat(QObject* caller)
{
    LOGGER("fetchRandomAyat");
    int x = TextUtils::randInt(1, 6236);

    if ( !showTranslation() ) {
        m_sql.executeQuery(caller, QString("SELECT surah_id,verse_number AS verse_id,content AS text FROM ayahs WHERE id=%1").arg(x), QueryId::FetchRandomAyat);
    } else {
        m_sql.executeQuery(caller, QString("SELECT surah_id,verse_number AS verse_id,translation AS text FROM ayahs a INNER JOIN verses v ON a.id=v.id WHERE a.id=%1").arg(x), QueryId::FetchRandomAyat);
    }
}


void QueryHelper::fetchRandomQuote(QObject* caller)
{
    LOGGER("fetchRandomQuote");

    ATTACH_ARTICLES;
    m_sql.executeQuery(caller, QString("SELECT individuals.name AS author,body,reference FROM quotes INNER JOIN individuals ON individuals.id=quotes.author WHERE quotes.id=( ABS( RANDOM() % (SELECT COUNT() AS total_quotes FROM quotes) )+1 )"), QueryId::FetchRandomQuote);
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


void QueryHelper::fetchAllAyats(QObject* caller, int fromChapter, int toChapter)
{
    LOGGER(fromChapter << toChapter);

    if (toChapter == 0) {
        toChapter = fromChapter;
    }

    QString query;

    if ( showTranslation() ) {
        query = QString("SELECT surah_id,content AS arabic,verse_number AS verse_id,translation FROM ayahs INNER JOIN verses on ayahs.id=verses.id AND surah_id BETWEEN %1 AND %2").arg(fromChapter).arg(toChapter);
    } else {
        query = QString("SELECT surah_id,content AS arabic,verse_number AS verse_id FROM ayahs WHERE surah_id BETWEEN %1 AND %2").arg(fromChapter).arg(toChapter);
    }

    m_sql.executeQuery(caller, query, QueryId::FetchAllAyats);
}


void QueryHelper::fetchJuzInfo(QObject* caller, int juzId)
{
    LOGGER(juzId);

    m_sql.executeQuery(caller, QString("SELECT surah_id,verse_number FROM juzs WHERE id BETWEEN %1 AND %2").arg(juzId).arg(juzId+1), QueryId::FetchJuz);
}


void QueryHelper::fetchAllTafsir(QObject* caller)
{
    ATTACH_TAFSIR;
    m_tafsirHelper.fetchAllTafsir(caller);
}


void QueryHelper::fetchAllTafsirForAyat(QObject* caller, int chapterNumber, int verseNumber)
{
    LOGGER(chapterNumber << verseNumber);

    ATTACH_TAFSIR;
    m_sql.executeQuery(caller, QString("SELECT suite_page_id AS id,name AS author,title,body FROM explanations INNER JOIN suite_pages ON suite_pages.id=explanations.suite_page_id INNER JOIN suites ON suites.id=suite_pages.suite_id INNER JOIN individuals ON individuals.id=suites.author WHERE explanations.surah_id=%1 AND from_verse_number=%2").arg(chapterNumber).arg(verseNumber), QueryId::FetchTafsirForAyat);
}


void QueryHelper::fetchAllTafsirForChapter(QObject* caller, int chapterNumber)
{
    LOGGER(chapterNumber);

    ATTACH_TAFSIR;
    m_sql.executeQuery(caller, QString("SELECT suite_page_id AS id,name AS author,title FROM explanations INNER JOIN suite_pages ON suite_pages.id=explanations.suite_page_id INNER JOIN suites ON suites.id=suite_pages.suite_id INNER JOIN individuals ON individuals.id=suites.author WHERE explanations.surah_id=%1 AND from_verse_number ISNULL").arg(chapterNumber), QueryId::FetchTafsirForSurah);
}


void QueryHelper::fetchTafsirCountForAyat(QObject* caller, int chapterNumber, int verseNumber)
{
    LOGGER(chapterNumber << verseNumber);

    ATTACH_TAFSIR;
    m_sql.executeQuery(caller, QString("SELECT COUNT() AS tafsir_count FROM explanations WHERE surah_id=%1 AND from_verse_number=%2").arg(chapterNumber).arg(verseNumber), QueryId::FetchTafsirCountForAyat);
}


void QueryHelper::fetchAllTafsirForSuite(QObject* caller, qint64 suiteId)
{
    LOGGER(suiteId);

    ATTACH_TAFSIR;
    QString query = QString("SELECT id,body FROM suite_pages WHERE suite_id=%1 ORDER BY id DESC").arg(suiteId);
    m_sql.executeQuery(caller, query, QueryId::FetchAllTafsirForSuite);
}


void QueryHelper::fetchTafsirMetadata(QObject* caller, qint64 suiteId)
{
    LOGGER(suiteId);

    ATTACH_TAFSIR;
    QString query = QString("SELECT author,translator,explainer,title,description,reference FROM suites WHERE id=%1").arg(suiteId);
    m_sql.executeQuery(caller, query, QueryId::FetchTafsirHeader);
}


void QueryHelper::fetchQuote(QObject* caller, qint64 id)
{
    LOGGER(id);

    ATTACH_TAFSIR;
    QString query = QString("SELECT individuals.name AS author,quotes.author AS author_id, body,reference FROM quotes INNER JOIN individuals ON individuals.id=quotes.author WHERE quotes.id=%1").arg(id);
    m_sql.executeQuery(caller, query, QueryId::FetchQuote);
}


void QueryHelper::fetchAyatsForTafsir(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);
    ATTACH_TAFSIR;

    QString query = QString("SELECT id,surah_id,from_verse_number,to_verse_number FROM explanations WHERE suite_page_id=%1 ORDER BY surah_id,from_verse_number,to_verse_number").arg(suitePageId);
    m_sql.executeQuery(caller, query, QueryId::FetchAyatsForTafsir);
}


void QueryHelper::unlinkAyatsForTafsir(QObject* caller, QVariantList const& ids, qint64 suitePageId) {
    m_tafsirHelper.unlinkAyatsForTafsir(caller, ids, suitePageId);
}


void QueryHelper::addQuote(QObject* caller, QString const& author, QString const& body, QString const& reference) {
    m_tafsirHelper.addQuote(caller, author, body, reference);
}


void QueryHelper::addTafsir(QObject* caller, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference) {
    m_tafsirHelper.addTafsir(caller, author, translator, explainer, title, description, reference);
}


void QueryHelper::editQuote(QObject* caller, qint64 quoteId, QString const& author, QString const& body, QString const& reference) {
    m_tafsirHelper.editQuote(caller, quoteId, author, body, reference);
}


void QueryHelper::editTafsir(QObject* caller, qint64 suiteId, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference) {
    m_tafsirHelper.editTafsir(caller, suiteId, author, translator, explainer, title, description, reference);
}


void QueryHelper::editTafsirPage(QObject* caller, qint64 suitePageId, QString const& body)
{
    LOGGER( suitePageId << body.length() );

    QString query = QString("UPDATE suite_pages SET body=? WHERE id=%1").arg(suitePageId);
    m_sql.executeQuery(caller, query, QueryId::EditTafsirPage, QVariantList() << body);
}


void QueryHelper::linkAyatToTafsir(QObject* caller, qint64 suitePageId, int chapter, int fromVerse, int toVerse) {
    m_tafsirHelper.linkAyatToTafsir(caller, suitePageId, chapter, fromVerse, toVerse);
}


void QueryHelper::addTafsirPage(QObject* caller, qint64 suiteId, QString const& body)
{
    LOGGER( suiteId << body.length() );

    QString query = QString("INSERT OR IGNORE INTO suite_pages (id,suite_id,body) VALUES(%1,%2,?)").arg( QDateTime::currentMSecsSinceEpoch() ).arg(suiteId);
    m_sql.executeQuery(caller, query, QueryId::AddTafsirPage, QVariantList() << body);
}


void QueryHelper::fetchTafsirContent(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);
    ATTACH_TAFSIR;
    QString query = QString("SELECT x.name AS author,x.hidden AS author_hidden,y.name AS translator,y.hidden AS translator_hidden,z.name AS explainer,z.hidden AS explainer_hidden,title,description,reference,body FROM suites INNER JOIN suite_pages ON suites.id=suite_pages.suite_id INNER JOIN individuals x ON suites.author=x.id LEFT JOIN individuals y ON suites.translator=y.id LEFT JOIN individuals z ON suites.explainer=z.id WHERE suite_pages.id=%1").arg(suitePageId);

    m_sql.executeQuery(caller, query, QueryId::FetchTafsirContent);
}


void QueryHelper::fetchSimilarAyatContent(QObject* caller, int chapterNumber, int verseNumber)
{
    LOGGER(chapterNumber << verseNumber);

    if ( showTranslation() ) {
        m_sql.executeQuery(caller, QString("SELECT other_surah_id AS surah_id,other_from_verse_id AS verse_id,verses.translation AS content,chapters.transliteration AS name FROM related INNER JOIN ayahs ON related.other_surah_id=ayahs.surah_id AND related.other_from_verse_id=ayahs.verse_number INNER JOIN verses ON ayahs.id=verses.id INNER JOIN chapters ON chapters.id=related.other_surah_id WHERE related.surah_id=%1 AND from_verse_id=%2").arg(chapterNumber).arg(verseNumber), QueryId::FetchSimilarAyatContent);
    } else {
        m_sql.executeQuery(caller, QString("SELECT other_surah_id AS surah_id,other_from_verse_id AS verse_id,content,name FROM related INNER JOIN ayahs ON related.other_surah_id=ayahs.surah_id AND related.other_from_verse_id=ayahs.verse_number INNER JOIN surahs ON surahs.id=related.other_surah_id WHERE related.surah_id=%1 AND from_verse_id=%2").arg(chapterNumber).arg(verseNumber), QueryId::FetchSimilarAyatContent);
    }
}


void QueryHelper::fetchAyat(QObject* caller, int surahId, int ayatId)
{
    LOGGER(surahId << ayatId);

    QString query;

    if ( showTranslation() ) {
        query = QString("SELECT content,translation,(SELECT COUNT() FROM related WHERE surah_id=%1 AND from_verse_id=%2 AND to_verse_id=%2) AS total_similar FROM ayahs INNER JOIN verses on ayahs.id=verses.id WHERE ayahs.surah_id=%1 AND ayahs.verse_number=%2").arg(surahId).arg(ayatId);
    } else {
        query = QString("SELECT content,(SELECT COUNT() FROM related WHERE surah_id=%1 AND from_verse_id=%2 AND to_verse_id=%2) AS total_similar FROM ayahs WHERE surah_id=%1 AND verse_number=%2").arg(surahId).arg(ayatId);
    }

    m_sql.executeQuery(caller, query, QueryId::FetchAyat);
}


void QueryHelper::searchQuery(QObject* caller, QString const& trimmedText, int chapterNumber, QVariantList const& additional, bool andMode)
{
    LOGGER(trimmedText << additional << andMode << chapterNumber);

    QVariantList params = QVariantList() << trimmedText;
    bool isArabic = trimmedText.isRightToLeft() || !showTranslation();
    QString query = ThreadUtils::buildSearchQuery(params, isArabic, chapterNumber, additional, andMode);

    m_sql.executeQuery(caller, query, QueryId::SearchAyats, params);
}


void QueryHelper::editIndividual(QObject* caller, qint64 id, QString const& prefix, QString const& name, QString const& kunya, QString const& url, QString const& bio, bool hidden) {
    m_tafsirHelper.editIndividual(caller, id, prefix, name, kunya, url, bio, hidden);
}


void QueryHelper::searchIndividuals(QObject* caller, QString const& trimmedText)
{
    LOGGER(trimmedText);
    m_sql.executeQuery(caller, "SELECT id,prefix,name,kunya,uri,hidden,biography FROM individuals WHERE name LIKE '%' || ? || '%' OR kunya LIKE '%' || ? || '%'", QueryId::SearchIndividuals, QVariantList() << trimmedText << trimmedText);
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


void QueryHelper::fetchAllQarees(QObject* caller, int minLevel)
{
    LOGGER(minLevel);

    m_sql.executeQuery(caller, QString("SELECT id,description,name,value FROM qarees INNER JOIN recitations ON qarees.id=recitations.qaree_id WHERE level >= %1 ORDER BY name").arg(minLevel), QueryId::FetchAllRecitations);
}


void QueryHelper::fetchAllQuotes(QObject* caller)
{
    LOGGER("fetchAllQuotes");

    ATTACH_ARTICLES;
    m_sql.executeQuery(caller, QString("SELECT quotes.id AS id,individuals.name AS author,body FROM quotes INNER JOIN individuals ON individuals.id=quotes.author ORDER BY id DESC"), QueryId::FetchAllQuotes);
}


QVariantList QueryHelper::normalizeJuzs(QVariantList const& source) {
    return ThreadUtils::normalizeJuzs(source);
}


void QueryHelper::initForeignKeys() {
    m_sql.enableForeignKeys();
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


void QueryHelper::removeQuote(QObject* caller, qint64 id)
{
    LOGGER(id);
    QString query = QString("DELETE FROM quotes WHERE id=%1").arg(id);
    m_sql.executeQuery(caller, query, QueryId::RemoveQuote);
}


bool QueryHelper::showTranslation() const {
    return m_translation != "arabic";
}

int QueryHelper::primarySize() const {
    return m_persist->getValueFor("primarySize").toInt();
}

int QueryHelper::translationSize() const
{
    int result = m_persist->getValueFor("translationSize").toInt();
    return result > 0 ? result : 8;
}


QString QueryHelper::tafsirName() const {
    return QString("quran_tafsir_%1").arg(m_translation);
}


QString QueryHelper::translation() const {
    return m_translation;
}


QVariantList QueryHelper::removeOutOfRange(QVariantList input, int fromChapter, int fromVerse, int toChapter, int toVerse) {
    return ThreadUtils::removeOutOfRange(input, fromChapter, fromVerse, toChapter, toVerse);
}


QObject* QueryHelper::getBookmarkHelper() {
    return &m_bookmarkHelper;
}


QueryHelper::~QueryHelper()
{
}

} /* namespace oct10 */
