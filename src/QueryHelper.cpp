#include "precompiled.h"

#include "QueryHelper.h"
#include "CommonConstants.h"
#include "customsqldatasource.h"
#include "Logger.h"
#include "Persistance.h"
#include "TextUtils.h"
#include "ThreadUtils.h"

#define ATTACH_TAFSIR m_sql.attachIfNecessary( tafsirName(), true );
#define TRANSLATION QString("quran_%1").arg(m_translation)
#define TAFSIR_NAME(language) QString("quran_tafsir_%1").arg(language)

namespace quran {

using namespace canadainc;
using namespace bb::data;

QueryHelper::QueryHelper(Persistance* persist) :
        m_sql( QString("%1/assets/dbase/quran_arabic.db").arg( QCoreApplication::applicationDirPath() ) ),
        m_persist(persist), m_bookmarkHelper(&m_sql), m_tafsirHelper(&m_sql)
{
    connect( persist, SIGNAL( settingChanged(QString const&) ), this, SLOT( settingChanged(QString const&) ), Qt::QueuedConnection );
}


void QueryHelper::lazyInit()
{
    refreshDatabase();

    QTime time = QTime::currentTime();
    qsrand( (uint)time.msec() );
}


void QueryHelper::refreshDatabase()
{
    settingChanged(KEY_TRANSLATION);
}


void QueryHelper::settingChanged(QString const& key)
{
    if (key == KEY_TRANSLATION)
    {
        if ( showTranslation() ) {
            m_sql.detach(TRANSLATION);
        }

        m_sql.detach( tafsirName() );

        m_translation = m_persist->getValueFor(KEY_TRANSLATION).toString();

        QVariantMap params;
        QStringList forcedUpdates;

        if ( showTranslation() ) // if the user didn't set to Arabic only, since arabic is already attached
        {
            bool inHome = m_translation != ENGLISH_TRANSLATION;
            QString translationDir = inHome ? QDir::homePath() : QString("%1/assets/dbase").arg( QCoreApplication::applicationDirPath() );
            QFile translationFile( QString("%1/%2.db").arg(translationDir).arg(TRANSLATION) );

            if ( !translationFile.exists() || translationFile.size() == 0 ) { // translation doesn't exist, download it
                params[KEY_TRANSLATION] = TRANSLATION;
                forcedUpdates << KEY_TRANSLATION;
            } else {
                m_sql.attachIfNecessary(TRANSLATION, inHome); // since english translation is loaded by default
            }
        }

        QFile tafsirFile( QString("%1/%2.db").arg( QDir::homePath() ).arg( tafsirName() ) );

        if ( !tafsirFile.exists() || tafsirFile.size() == 0 ) { // tafsir doesn't exist, download it
            params[KEY_TAFSIR] = tafsirName();
            forcedUpdates << KEY_TAFSIR;
        } else if ( m_persist->isUpdateNeeded(KEY_LAST_UPDATE, 60) ) {
            params[KEY_TAFSIR] = tafsirName();
            params[KEY_TRANSLATION] = TRANSLATION;
        }

        if ( !forcedUpdates.isEmpty() ) {
            params[KEY_FORCED_UPDATE] = forcedUpdates;
        }

        if ( !params.isEmpty() ) // update check needed
        {
            bool suppress = m_persist->getFlag(KEY_UPDATE_CHECK_FLAG).toInt() == SUPPRESS_UPDATE_FLAG;

            if ( params.contains(KEY_FORCED_UPDATE) || !suppress ) // if it's a forced update
            {
                params[KEY_LANGUAGE] = m_translation;
                emit updateCheckNeeded(params);
            }
        } else {
            ATTACH_TAFSIR;
        }

        emit textualChange();
    } else if (key == KEY_TRANSLATION_SIZE || key == KEY_PRIMARY_SIZE) {
        emit fontSizeChanged();
    }
}


void QueryHelper::fetchAllDuaa(QObject* caller)
{
    if ( showTranslation() ) {
        m_sql.executeQuery(caller, "SELECT supplications.surah_id,transliteration AS name,verse_number_start,verse_number_end,verses.translation AS body FROM supplications INNER JOIN chapters ON supplications.surah_id=chapters.id INNER JOIN verses ON supplications.surah_id=verses.chapter_id AND supplications.verse_number_start=verses.verse_id", QueryId::FetchAllDuaa);
    } else {
        m_sql.executeQuery(caller, "SELECT supplications.surah_id,name,verse_number_start,verse_number_end,content AS body FROM supplications INNER JOIN surahs ON supplications.surah_id=surahs.id INNER JOIN ayahs ON supplications.surah_id=ayahs.surah_id AND supplications.verse_number_start=ayahs.verse_number", QueryId::FetchAllDuaa);
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


void QueryHelper::fetchChapters(QObject* caller, QString const& text)
{
    QVariantList args;
    QString query = ThreadUtils::buildChaptersQuery( args, text, showTranslation() );
    m_sql.executeQuery(caller, query, QueryId::FetchChapters, args);
}


void QueryHelper::fetchChapter(QObject* caller, int chapter, bool juzMode)
{
    LOGGER(chapter);

    if (juzMode)
    {
        if ( showTranslation() ) {
            m_sql.executeQuery(caller, QString("SELECT a.id AS surah_id,name,verse_count,revelation_order,transliteration,j.id AS juz_id,verse_number FROM surahs a INNER JOIN chapters t ON a.id=t.id LEFT JOIN juzs j ON j.surah_id=a.id WHERE a.id=%1").arg(chapter), QueryId::FetchChapters);
        } else {
            m_sql.executeQuery(caller, QString("SELECT surahs.id AS surah_id,name,verse_count,revelation_order,j.id AS juz_id,verse_number FROM surahs LEFT JOIN juzs j ON j.surah_id=a.id WHERE id=%1").arg(chapter), QueryId::FetchChapters );
        }
    } else {
        QString query = "SELECT id AS surah_id,name,verse_count,revelation_order FROM surahs";

        if ( showTranslation() ) {
            query = "SELECT a.id AS surah_id,name,verse_count,revelation_order,transliteration FROM surahs a INNER JOIN chapters t ON a.id=t.id";
        }

        query += QString(" WHERE surah_id=%1").arg(chapter);

        m_sql.executeQuery(caller, query, QueryId::FetchChapters);
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
    m_sql.executeQuery(caller, QString("SELECT %1 AS author,i.hidden,body,TRIM( COALESCE(suites.title,'') || ' ' || COALESCE(quotes.reference,'') ) AS reference,birth,death,female,is_companion FROM quotes INNER JOIN individuals i ON i.id=quotes.author LEFT JOIN suites ON quotes.suite_id=suites.id WHERE quotes.id=( ABS( RANDOM() % (SELECT COUNT() AS total_quotes FROM quotes) )+1 )").arg( NAME_FIELD("i") ), QueryId::FetchRandomQuote);
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

    if ( m_persist->getValueFor(KEY_JOIN_LETTERS).toInt() == 1 )
    {
        QDir q( QString("%1/ayats").arg( m_persist->getValueFor(KEY_OUTPUT_FOLDER).toString() ) );

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


void QueryHelper::fetchAllTafsir(QObject* caller, qint64 individualId)
{
    ATTACH_TAFSIR;
    m_tafsirHelper.fetchAllTafsir(caller, individualId);
}


void QueryHelper::fetchAllTafsirForAyat(QObject* caller, int chapterNumber, int verseNumber)
{
    LOGGER(chapterNumber << verseNumber);

    ATTACH_TAFSIR;
    m_sql.executeQuery(caller, QString("SELECT suite_page_id AS id,%3 AS author,title,substr(body,-5) AS body,heading FROM explanations INNER JOIN suite_pages ON suite_pages.id=explanations.suite_page_id INNER JOIN suites ON suites.id=suite_pages.suite_id INNER JOIN individuals i ON i.id=suites.author WHERE explanations.surah_id=%1 AND (%2 BETWEEN from_verse_number AND to_verse_number)").arg(chapterNumber).arg(verseNumber).arg( NAME_FIELD("i") ), QueryId::FetchTafsirForAyat);
}


void QueryHelper::fetchAllTafsirForChapter(QObject* caller, int chapterNumber)
{
    LOGGER(chapterNumber);

    ATTACH_TAFSIR;
    m_sql.executeQuery(caller, QString("SELECT suite_page_id AS id,%2 AS author,title,heading,substr(body,-5) AS body FROM explanations INNER JOIN suite_pages ON suite_pages.id=explanations.suite_page_id INNER JOIN suites ON suites.id=suite_pages.suite_id INNER JOIN individuals i ON i.id=suites.author WHERE explanations.surah_id=%1 AND from_verse_number ISNULL").arg(chapterNumber).arg( NAME_FIELD("i") ), QueryId::FetchTafsirForSurah);
}


void QueryHelper::fetchTafsirCountForAyat(QObject* caller, int chapterNumber, int verseNumber)
{
    LOGGER(chapterNumber << verseNumber);

    ATTACH_TAFSIR;
    m_sql.executeQuery(caller, QString("SELECT COUNT() AS tafsir_count FROM explanations WHERE surah_id=%1 AND (%2 BETWEEN from_verse_number AND to_verse_number)").arg(chapterNumber).arg(verseNumber), QueryId::FetchTafsirCountForAyat);
}


void QueryHelper::fetchAllTafsirForSuite(QObject* caller, qint64 suiteId)
{
    LOGGER(suiteId);

    ATTACH_TAFSIR;
    QString query = QString("SELECT id,body,heading,reference FROM suite_pages WHERE suite_id=%1 ORDER BY id DESC").arg(suiteId);
    m_sql.executeQuery(caller, query, QueryId::FetchAllTafsirForSuite);
}


void QueryHelper::fetchQuote(QObject* caller, qint64 id)
{
    LOGGER(id);

    ATTACH_TAFSIR;
    QString query = QString("SELECT quotes.author AS author_id, body,reference,suite_id,uri FROM quotes INNER JOIN individuals ON individuals.id=quotes.author WHERE quotes.id=%1").arg(id);
    m_sql.executeQuery(caller, query, QueryId::FetchQuote);
}


void QueryHelper::fetchAyatsForTafsir(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);
    ATTACH_TAFSIR;

    QString query = QString("SELECT id,surah_id,from_verse_number,to_verse_number FROM explanations WHERE suite_page_id=%1 ORDER BY surah_id,from_verse_number,to_verse_number").arg(suitePageId);
    m_sql.executeQuery(caller, query, QueryId::FetchAyatsForTafsir);
}


void QueryHelper::fetchTafsirContent(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);
    ATTACH_TAFSIR;
    QString query = QString("SELECT %2 AS author,x.id AS author_id,x.hidden AS author_hidden,x.birth AS author_birth,x.death AS author_death,%3 AS translator,y.id AS translator_id,y.hidden AS translator_hidden,y.birth AS translator_birth,y.death AS translator_death,%4 AS explainer,z.id AS explainer_id,z.hidden AS explainer_hidden,z.birth AS explainer_birth,z.death AS explainer_death,title,description,suites.reference AS reference,suite_pages.reference AS suite_pages_reference,body,heading FROM suites INNER JOIN suite_pages ON suites.id=suite_pages.suite_id INNER JOIN individuals x ON suites.author=x.id LEFT JOIN individuals y ON suites.translator=y.id LEFT JOIN individuals z ON suites.explainer=z.id WHERE suite_pages.id=%1").arg(suitePageId).arg( NAME_FIELD("x") ).arg( NAME_FIELD("y") ).arg( NAME_FIELD("z") );

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


void QueryHelper::fetchAyats(QObject* caller, QVariantList const& input)
{
    LOGGER(input);

    QString query;
    QSet< QPair<int,int> > all;

    for (int i = input.size()-1; i >= 1; i--)
    {
        QVariantMap q = input[i].toMap();
        all << qMakePair<int,int>( q.value(CHAPTER_KEY).toInt(), q.value(FROM_VERSE_KEY).toInt() );
    }

    QList< QPair<int,int> > cleaned = all.toList();
    QPair<int,int> x = cleaned.takeFirst();

    LOGGER(cleaned);

    QStringList additional;
    for (int i = cleaned.size()-1; i >= 0; i--) {
        //additional << QString(" OR (surah_id=%1 AND verse_id=%2)").arg(cleaned[i].first).arg(cleaned[i].second);
    }

    if ( showTranslation() ) {
        query = QString("SELECT verses.chapter_id AS surah_id,verses.verse_id,verses.translation,transliteration AS name FROM verses INNER JOIN chapters ON verses.chapter_id=chapters.id WHERE (surah_id=%1 AND verse_id=%2)%3").arg(x.first).arg(x.second).arg( additional.join("") );
    } else {
        query = QString("SELECT surah_id,verse_number AS verse_id,searchable,name FROM ayahs INNER JOIN surahs ON ayahs.surah_id=surahs.id WHERE (surah_id=%1 AND verse_id=%2)%3").arg(x.first).arg(x.second).arg( additional.join("") );
    }

    m_sql.executeQuery(caller, query, QueryId::FetchAyats);
}


void QueryHelper::fetchBio(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);

    ATTACH_TAFSIR;
    m_sql.executeQuery(caller, QString("SELECT mentions.id,%1 AS author,heading,body,bio_id,reference,points FROM mentions INNER JOIN biographies ON mentions.bio_id=biographies.id LEFT JOIN individuals i ON target=i.id WHERE target=%2").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchBio);
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


void QueryHelper::fetchTransliteration(QObject* caller, int chapter, int verse)
{
    LOGGER(chapter << verse);

    if ( showTranslation() ) {
        m_sql.executeQuery(caller, QString("SELECT html FROM transliteration WHERE chapter_id=%1 AND verse_id=%2").arg(chapter).arg(verse), QueryId::FetchTransliteration);
    }
}


void QueryHelper::fetchPageNumbers(QObject* caller)
{
    LOGGER("fetchPageNumbers");

    m_sql.executeQuery(caller, "SELECT surah_id,MIN(page_number) as page_number from mushaf_pages GROUP BY surah_id ORDER BY surah_id", QueryId::FetchPageNumbers);
}


void QueryHelper::fetchAllQarees(QObject* caller, int minLevel)
{
    LOGGER(minLevel);

    m_sql.executeQuery(caller, QString("SELECT id,description,name,value FROM qarees INNER JOIN recitations ON qarees.id=recitations.qaree_id WHERE level >= %1 ORDER BY name").arg(minLevel), QueryId::FetchAllRecitations);
}


void QueryHelper::fetchAllQuotes(QObject* caller, qint64 individualId)
{
    LOGGER("fetchAllQuotes" << individualId);

    ATTACH_TAFSIR;

    QStringList queryParams = QStringList() << QString("SELECT quotes.id AS id,%1 AS author,body,reference FROM quotes INNER JOIN individuals i ON i.id=quotes.author").arg( NAME_FIELD("i") );

    if (individualId) {
        queryParams << QString("WHERE quotes.author=%1").arg(individualId);
    }

    queryParams << "ORDER BY id DESC";

    m_sql.executeQuery(caller, queryParams.join(" "), QueryId::FetchAllQuotes);
}


void QueryHelper::initForeignKeys() {
    m_sql.enableForeignKeys();
}


bool QueryHelper::showTranslation() const {
    return m_translation != ARABIC_KEY;
}

int QueryHelper::primarySize() const {
    return m_persist->getValueFor(KEY_PRIMARY_SIZE).toInt();
}

int QueryHelper::translationSize() const
{
    int result = m_persist->getValueFor(KEY_TRANSLATION_SIZE).toInt();
    return result > 0 ? result : 12;
}


QString QueryHelper::tafsirName() const {
    return TAFSIR_NAME(m_translation);
}


QString QueryHelper::translation() const {
    return m_translation;
}


QueryBookmarkHelper* QueryHelper::getBookmarkHelper() {
    return &m_bookmarkHelper;
}


QObject* QueryHelper::getExecutor() {
    return &m_sql;
}

QObject* QueryHelper::getTafsirHelper() {
    return &m_tafsirHelper;
}


QString QueryHelper::tafsirVersion() const {
    return m_persist->getFlag( KEY_TAFSIR_VERSION(m_translation) ).toString();
}


QString QueryHelper::translationVersion() const {
    return m_persist->getFlag( KEY_TRANSLATION_VERSION(m_translation) ).toString();
}


QueryHelper::~QueryHelper()
{
}

} /* namespace oct10 */
