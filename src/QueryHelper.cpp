#include "precompiled.h"

#include "QueryHelper.h"
#include "customsqldatasource.h"
#include "Logger.h"
#include "Persistance.h"
#include "TextUtils.h"
#include "ThreadUtils.h"

#define ATTACH_TAFSIR m_sql.attachIfNecessary( tafsirName(), true );
#define TRANSLATION QString("quran_%1").arg(m_translation)
#define NAME_FIELD(var) QString("(coalesce(%1.prefix,'') || ' ' || %1.name || ' ' || coalesce(%1.kunya,''))").arg(var)

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

        m_sql.detach( tafsirName() );

        m_translation = m_persist->getValueFor("translation").toString();
        bool inHome = m_translation != "english" && m_translation != "arabic";
        QString translationDir = inHome ? QDir::homePath() : QString("%1/assets/dbase").arg( QCoreApplication::applicationDirPath() );
        QFile translationFile( QString("%1/%2.db").arg(translationDir).arg(TRANSLATION) );

        if ( !translationFile.exists() || translationFile.size() == 0 ) { // translation doesn't exist, download it
            emit translationMissing(TRANSLATION);
        } else {
            m_sql.attachIfNecessary(TRANSLATION, inHome); // since english translation is loaded by default
        }

        QFile tafsirFile( QString("%1/%2.db").arg( QDir::homePath() ).arg( tafsirName() ) );

        if ( !tafsirFile.exists() || tafsirFile.size() == 0 ) { // translation doesn't exist, download it
            emit tafsirMissing( tafsirName() );
        }

        emit textualChange();
    } else if (key == "translationFontSize" || key == "primarySize") {
        emit fontSizeChanged();
    } else if (key == "overlayAyatImages") {
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


void QueryHelper::fetchAllChapterAyatCount(QObject* caller)
{
    m_sql.executeQuery(caller, "SELECT surahs.id AS surah_id,verse_count FROM surahs", QueryId::FetchAllChapterAyatCount);
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
        m_sql.executeQuery(caller, QString("SELECT surah_id,verse_number AS verse_id,content AS text FROM ayahs WHERE ROWID=%1").arg(x), QueryId::FetchRandomAyat);
    } else {
        m_sql.executeQuery(caller, QString("SELECT chapter_id AS surah_id,verse_id,translation AS text FROM verses WHERE ROWID=%1").arg(x), QueryId::FetchRandomAyat);
    }
}


void QueryHelper::fetchAdjacentAyat(QObject* caller, int surahId, int verseId, int delta)
{
    LOGGER(surahId << verseId << delta);

    QString operation = delta >= 0 ? QString("+%1").arg(delta) : QString::number(delta);
    m_sql.executeQuery(caller, QString("SELECT surah_id,verse_number AS verse_id FROM ayahs WHERE ROWID=((SELECT ROWID FROM ayahs WHERE surah_id=%1 AND verse_number=%2)%3)").arg(surahId).arg(verseId).arg(operation), QueryId::FetchAdjacentAyat);
}


void QueryHelper::fetchRandomQuote(QObject* caller)
{
    LOGGER("fetchRandomQuote");

    ATTACH_TAFSIR;
    m_sql.executeQuery(caller, QString("SELECT %1 AS author,body,reference,birth,death FROM quotes INNER JOIN individuals i ON i.id=quotes.author WHERE quotes.id=( ABS( RANDOM() % (SELECT COUNT() AS total_quotes FROM quotes) )+1 )").arg( NAME_FIELD("i") ), QueryId::FetchRandomQuote);
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
    QString ayatImagePath = "";
    QVariantList params;

    if ( m_persist->getValueFor("overlayAyatImages").toInt() == 1 )
    {
        QDir q( QString("%1/ayats").arg( m_persist->getValueFor("output").toString() ) );

        if ( q.exists() )
        {
            ayatImagePath = QString(",? || ayahs.surah_id || '_' || ayahs.verse_number || '.png' AS imagePath");
            params << q.path()+"/";
        }
    }

    if ( showTranslation() ) {
        query = QString("SELECT ayahs.surah_id,content AS arabic,ayahs.verse_number AS verse_id,translation%3 FROM ayahs INNER JOIN verses ON (ayahs.surah_id=verses.chapter_id AND ayahs.verse_number=verses.verse_id) WHERE ayahs.surah_id BETWEEN %1 AND %2").arg(fromChapter).arg(toChapter).arg(ayatImagePath);
    } else {
        query = QString("SELECT ayahs.surah_id,content AS arabic,ayahs.verse_number AS verse_id%3 FROM ayahs WHERE ayahs.surah_id BETWEEN %1 AND %2").arg(fromChapter).arg(toChapter).arg(ayatImagePath);
    }

    m_sql.executeQuery(caller, query, QueryId::FetchAllAyats, params);
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
    m_sql.executeQuery(caller, QString("SELECT suite_page_id AS id,%3 AS author,title,body FROM explanations INNER JOIN suite_pages ON suite_pages.id=explanations.suite_page_id INNER JOIN suites ON suites.id=suite_pages.suite_id INNER JOIN individuals i ON i.id=suites.author WHERE explanations.surah_id=%1 AND from_verse_number=%2").arg(chapterNumber).arg(verseNumber).arg( NAME_FIELD("i") ), QueryId::FetchTafsirForAyat);
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
    QString query = QString("SELECT %2 AS author,x.id AS author_id,x.hidden AS author_hidden,x.birth AS author_birth,x.death AS author_death,%3 AS translator,y.id AS translator_id,y.hidden AS translator_hidden,y.birth AS translator_birth,y.death AS translator_death,%4 AS explainer,z.id AS explainer_id,z.hidden AS explainer_hidden,z.birth AS explainer_birth,z.death AS explainer_death,title,description,reference,body FROM suites INNER JOIN suite_pages ON suites.id=suite_pages.suite_id INNER JOIN individuals x ON suites.author=x.id LEFT JOIN individuals y ON suites.translator=y.id LEFT JOIN individuals z ON suites.explainer=z.id WHERE suite_pages.id=%1").arg(suitePageId).arg( NAME_FIELD("x") ).arg( NAME_FIELD("y") ).arg( NAME_FIELD("z") );

    m_sql.executeQuery(caller, query, QueryId::FetchTafsirContent);
}


void QueryHelper::fetchSimilarAyatContent(QObject* caller, int chapterNumber, int verseNumber)
{
    LOGGER(chapterNumber << verseNumber);

    if ( showTranslation() ) {
        m_sql.executeQuery(caller, QString("SELECT other_surah_id AS surah_id,other_from_verse_id AS verse_id,verses.translation AS content,chapters.transliteration AS name FROM related INNER JOIN ayahs ON related.other_surah_id=ayahs.surah_id AND related.other_from_verse_id=ayahs.verse_number INNER JOIN verses ON (ayahs.surah_id=verses.chapter_id AND ayahs.verse_number=verses.verse_id) INNER JOIN chapters ON chapters.id=related.other_surah_id WHERE related.surah_id=%1 AND from_verse_id=%2").arg(chapterNumber).arg(verseNumber), QueryId::FetchSimilarAyatContent);
    } else {
        m_sql.executeQuery(caller, QString("SELECT other_surah_id AS surah_id,other_from_verse_id AS verse_id,content,name FROM related INNER JOIN ayahs ON related.other_surah_id=ayahs.surah_id AND related.other_from_verse_id=ayahs.verse_number INNER JOIN surahs ON surahs.id=related.other_surah_id WHERE related.surah_id=%1 AND from_verse_id=%2").arg(chapterNumber).arg(verseNumber), QueryId::FetchSimilarAyatContent);
    }
}


void QueryHelper::fetchAyat(QObject* caller, int surahId, int ayatId)
{
    LOGGER(surahId << ayatId);

    QString query;
    QString fetchRelated = QString("(SELECT COUNT() FROM related WHERE surah_id=%1 AND from_verse_id=%2 AND to_verse_id=%2) AS total_similar").arg(surahId).arg(ayatId);

    if ( showTranslation() ) {
        query = QString("SELECT content,translation,%3 FROM ayahs INNER JOIN verses ON (ayahs.surah_id=verses.chapter_id AND ayahs.verse_number=verses.verse_id) WHERE ayahs.surah_id=%1 AND ayahs.verse_number=%2").arg(surahId).arg(ayatId).arg(fetchRelated);
    } else {
        query = QString("SELECT content,%3 FROM ayahs WHERE surah_id=%1 AND verse_number=%2").arg(surahId).arg(ayatId).arg(fetchRelated);
    }

    m_sql.executeQuery(caller, query, QueryId::FetchAyat);
}


void QueryHelper::fetchBio(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);

    ATTACH_TAFSIR;
    m_sql.executeQuery(caller, QString("SELECT %1 AS name,uri,biography FROM individuals i WHERE i.id=%2").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchBio);
}


bool QueryHelper::searchQuery(QObject* caller, QString const& trimmedText, int chapterNumber, QVariantList const& additional, bool andMode)
{
    LOGGER(trimmedText << additional << andMode << chapterNumber);

    QVariantList params = QVariantList() << trimmedText;
    bool isArabic = trimmedText.isRightToLeft() || !showTranslation();
    QString query = ThreadUtils::buildSearchQuery(params, isArabic, chapterNumber, additional, andMode);

    m_sql.executeQuery(caller, query, QueryId::SearchAyats, params);

    return isArabic;
}


void QueryHelper::searchTafsir(QObject* caller, QString const& fieldName, QString const& searchTerm)
{
    LOGGER(fieldName << searchTerm);
    m_tafsirHelper.searchTafsir(caller, fieldName, searchTerm);
}


void QueryHelper::editIndividual(QObject* caller, qint64 id, QString const& prefix, QString const& name, QString const& kunya, QString const& url, QString const& bio, bool hidden, int birth, int death) {
    m_tafsirHelper.editIndividual(caller, id, prefix, name, kunya, url, bio, hidden, birth, death);
}


void QueryHelper::fetchAllIndividuals(QObject* caller) {
    m_sql.executeQuery(caller, "SELECT id,prefix,name,kunya,uri,hidden,biography,birth,death FROM individuals ORDER BY name,kunya,prefix", QueryId::FetchAllIndividuals);
}


void QueryHelper::fetchFrequentIndividuals(QObject* caller, int n) {
    m_sql.executeQuery(caller, QString("SELECT author AS id,prefix,name,kunya,uri,hidden,biography,birth,death FROM (SELECT author,COUNT(author) AS n FROM suites GROUP BY author UNION SELECT translator AS author,COUNT(translator) AS n FROM suites GROUP BY author UNION SELECT explainer AS author,COUNT(explainer) AS n FROM suites GROUP BY author ORDER BY n DESC LIMIT %1) INNER JOIN individuals ON individuals.id=author ORDER BY name,kunya,prefix").arg(n), QueryId::FetchAllIndividuals);
}


void QueryHelper::fetchTransliteration(QObject* caller, int chapter, int verse)
{
    LOGGER(chapter << verse);

    if ( showTranslation() ) {
        m_sql.executeQuery(caller, QString("SELECT html FROM transliteration WHERE chapter_id=%1 AND verse_id=%2").arg(chapter).arg(verse), QueryId::FetchTransliteration);
    }
}


void QueryHelper::searchIndividuals(QObject* caller, QString const& trimmedText)
{
    LOGGER(trimmedText);
    m_sql.executeQuery(caller, "SELECT id,prefix,name,kunya,uri,hidden,biography,birth,death FROM individuals WHERE name LIKE '%' || ? || '%' OR kunya LIKE '%' || ? || '%'  ORDER BY name,kunya,prefix", QueryId::SearchIndividuals, QVariantList() << trimmedText << trimmedText);
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

    ATTACH_TAFSIR;
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
    int result = m_persist->getValueFor("translationFontSize").toInt();
    return result > 0 ? result : 12;
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


QueryBookmarkHelper* QueryHelper::getBookmarkHelper() {
    return &m_bookmarkHelper;
}


QueryHelper::~QueryHelper()
{
}

} /* namespace oct10 */
