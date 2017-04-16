#include "precompiled.h"

#include "QueryHelper.h"
#include "CommonConstants.h"
#include "Logger.h"
#include "Persistance.h"
#include "QueryId.h"
#include "TextUtils.h"
#include "ThreadUtils.h"

#define TAFSIR_NAME(language) QString("quran_tafsir_%1").arg(language != "arabic" ? "english" : language)
#define ATTACH_TAFSIR m_sql.attachIfNecessary( TAFSIR_NAME(m_translation) );
#define NAME_FIELD(var) QString("coalesce(%1.displayName, TRIM( replace( coalesce(%1.kunya,'') || ' ' || (coalesce(%1.prefix,'') || ' ' || %1.name), '  ', ' ' ) ) )").arg(var)
#define TRANSLATION_NAME(language) QString("quran_%1").arg(language)
#define TRANSLATION TRANSLATION_NAME(m_translation)
#define LIKE_CLAUSE2(field,field2) QString("(%1 LIKE '%' || ? || '%' OR %2 LIKE '%' || ? || '%')").arg(field).arg(field2)

namespace {

void patchFolder(QString const& folder)
{
    if ( NOT_APP_DIR(folder) )
    {
        QFile dirPath(folder);
        LOGGER( dirPath.setPermissions(READ_WRITE_EXEC) );
    }
}

}

namespace quran {

using namespace canadainc;
using namespace bb::data;

QueryHelper::QueryHelper(Persistance* persist) :
        m_sql( QString("%1/assets/dbase/quran_arabic.db").arg( QCoreApplication::applicationDirPath() ) ),
        m_persist(persist), m_bookmarkHelper(&m_sql)
{
    connect( persist, SIGNAL( settingChanged(QString const&) ), this, SLOT( settingChanged(QString const&) ), Qt::QueuedConnection );
}


void QueryHelper::lazyInit()
{
    refreshDatabase();

    QTime time = QTime::currentTime();
    qsrand( (uint)time.msec() );
}


void QueryHelper::refreshDatabase() {
    settingChanged(KEY_TRANSLATION);
}


void QueryHelper::settingChanged(QString const& key)
{
    if (key == KEY_TRANSLATION)
    {
        if ( showTranslation() )
        {
            m_sql.detach( TRANSLATION_NAME(ENGLISH_TRANSLATION) ); // in case we had to fall back
            m_sql.detach(TRANSLATION);
        }

        m_sql.detach( TAFSIR_NAME(m_translation) );

        m_translation = m_persist->getValueFor(KEY_TRANSLATION).toString();

        if ( showTranslation() ) {
            m_sql.attachIfNecessary(TRANSLATION); // since english translation is loaded by default
        }

        ATTACH_TAFSIR;

        emit textualChange();
    } else if (key == KEY_TRANSLATION_SIZE || key == KEY_PRIMARY_SIZE) {
        emit fontSizeChanged();
    } else if (key == KEY_OUTPUT_FOLDER) {
        QtConcurrent::run( patchFolder, m_persist->getValueFor(key).toString() );
    }
}


void QueryHelper::fetchAllArticles(QObject* caller) {
    m_sql.executeQuery(caller, QString("SELECT suite_pages.id,%1 AS author,title,heading,substr(body,-5) AS body FROM suite_pages INNER JOIN suites ON suite_pages.suite_id=suites.id INNER JOIN individuals i ON suites.author=i.id WHERE suite_pages.id NOT IN (SELECT suite_page_id FROM explanations)").arg( NAME_FIELD("i") ), QueryId::FetchAllArticles);
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

    m_sql.executeQuery(caller, QString("SELECT %1 AS author,%2 AS translator,body,TRIM( COALESCE(suites.title,'') || ' ' || COALESCE(quotes.reference,'') ) AS reference,i.birth,i.death,i.female,i.is_companion,j.birth AS translator_birth,j.death AS translator_death,j.female AS translator_female,j.is_companion AS translator_companion FROM quotes INNER JOIN individuals i ON i.id=quotes.author LEFT JOIN individuals j ON j.id=quotes.translator LEFT JOIN suites ON quotes.suite_id=suites.id WHERE quotes.id=( SELECT ABS( RANDOM() % (SELECT COUNT() AS total_quotes FROM quotes) ) )").arg( NAME_FIELD("i") ).arg( NAME_FIELD("j") ), QueryId::FetchRandomQuote);
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


void QueryHelper::fetchAllAyats(QObject* caller, int fromChapter, int toChapter, int toVerse)
{
    LOGGER(fromChapter << toChapter << toVerse);

    if (toChapter == 0) {
        toChapter = fromChapter;
    }

    QString query;
    QString ayatImagePath = "";
    QVariantList params;

    if ( showTranslation() ) {
        query = QString("SELECT ayahs.surah_id,content AS arabic,ayahs.verse_number AS verse_id,translation%3 FROM ayahs INNER JOIN verses ON (ayahs.surah_id=verses.chapter_id AND ayahs.verse_number=verses.verse_id) WHERE (ayahs.surah_id BETWEEN %1 AND %2)").arg(fromChapter).arg(toChapter).arg(ayatImagePath);
    } else {
        query = QString("SELECT ayahs.surah_id,content AS arabic,ayahs.verse_number AS verse_id%3 FROM ayahs WHERE (ayahs.surah_id BETWEEN %1 AND %2)").arg(fromChapter).arg(toChapter).arg(ayatImagePath);
    }

    if (toVerse > 0) {
        query += QString(" AND ayahs.verse_number <= %1").arg(toVerse);
    }

    m_sql.executeQuery(caller, query, QueryId::FetchAllAyats, params);
}


void QueryHelper::fetchJuzInfo(QObject* caller, int juzId)
{
    LOGGER(juzId);
    m_sql.executeQuery(caller, QString("SELECT surah_id,verse_number FROM juzs WHERE id BETWEEN %1 AND %2").arg(juzId).arg(juzId+1), QueryId::FetchJuz);
}


void QueryHelper::fetchAllTafsirForAyat(QObject* caller, int chapterNumber, int verseNumber)
{
    LOGGER(chapterNumber << verseNumber);

    m_sql.executeQuery(caller, QString("SELECT suite_page_id AS id,%3 AS author,title,substr(body,-5) AS body,heading FROM explanations INNER JOIN suite_pages ON suite_pages.id=explanations.suite_page_id INNER JOIN suites ON suites.id=suite_pages.suite_id INNER JOIN individuals i ON i.id=suites.author WHERE explanations.surah_id=%1 AND (%2 BETWEEN from_verse_number AND to_verse_number) ORDER BY author,title,heading").arg(chapterNumber).arg(verseNumber).arg( NAME_FIELD("i") ), QueryId::FetchTafsirForAyat);
}


void QueryHelper::fetchAllTafsirForChapter(QObject* caller, int chapterNumber)
{
    LOGGER(chapterNumber);

    m_sql.executeQuery(caller, QString("SELECT suite_page_id AS id,%2 AS author,title,heading,substr(body,-5) AS body FROM explanations INNER JOIN suite_pages ON suite_pages.id=explanations.suite_page_id INNER JOIN suites ON suites.id=suite_pages.suite_id INNER JOIN individuals i ON i.id=suites.author WHERE explanations.surah_id=%1 AND from_verse_number ISNULL").arg(chapterNumber).arg( NAME_FIELD("i") ), QueryId::FetchTafsirForSurah);
}


void QueryHelper::fetchTafsirCountForAyat(QObject* caller, int chapterNumber, int verseNumber)
{
    LOGGER(chapterNumber << verseNumber);

    m_sql.executeQuery(caller, QString("SELECT COUNT() AS tafsir_count FROM explanations WHERE surah_id=%1 AND (%2 BETWEEN from_verse_number AND to_verse_number)").arg(chapterNumber).arg(verseNumber), QueryId::FetchTafsirCountForAyat);
}


void QueryHelper::fetchAllTafsirForSuite(QObject* caller, qint64 suiteId)
{
    LOGGER(suiteId);

    QString query = QString("SELECT id,body,heading,reference FROM suite_pages WHERE suite_id=%1 ORDER BY id DESC").arg(suiteId);
    m_sql.executeQuery(caller, query, QueryId::FetchAllTafsirForSuite);
}

void QueryHelper::fetchTafsirContent(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);
    QString query = QString("SELECT %2 AS author,x.birth AS author_birth,x.death AS author_death,%3 AS translator,y.birth AS translator_birth,y.death AS translator_death,%4 AS explainer,z.birth AS explainer_birth,z.death AS explainer_death,title,suites.reference AS reference,suite_pages.reference AS suite_pages_reference,body,heading FROM suites INNER JOIN suite_pages ON suites.id=suite_pages.suite_id LEFT JOIN individuals x ON suites.author=x.id LEFT JOIN individuals y ON suites.translator=y.id LEFT JOIN individuals z ON suites.explainer=z.id WHERE suite_pages.id=%1").arg(suitePageId).arg( NAME_FIELD("x") ).arg( NAME_FIELD("y") ).arg( NAME_FIELD("z") );

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

    if ( showTranslation() ) {
        query = QString("SELECT verses.chapter_id AS surah_id,verses.verse_id,verses.translation,transliteration AS name FROM verses INNER JOIN chapters ON verses.chapter_id=chapters.id WHERE (surah_id=%1 AND verse_id=%2)").arg(x.first).arg(x.second);
    } else {
        query = QString("SELECT surah_id,verse_number AS verse_id,searchable,name FROM ayahs INNER JOIN surahs ON ayahs.surah_id=surahs.id WHERE (surah_id=%1 AND verse_id=%2)").arg(x.first).arg(x.second);
    }

    m_sql.executeQuery(caller, query, QueryId::FetchAyats);
}


void QueryHelper::searchQuery(QObject* caller, QVariantList params, QVariantList const& chapters)
{
    LOGGER(params << chapters);

    int n = params.size();
    bool isArabic = params.first().toString().isRightToLeft();
    QStringList columns = QStringList() << "ayahs.surah_id" << "ayahs.verse_number";
    QMap<QString,QString> joins;

    if (isArabic) {
        columns << "searchable" << "name" << "content";
        joins["surahs"] = "ayahs.surah_id=surahs.id";
        params.append(params);
    } else {
        columns << "verses.translation" << "transliteration AS name";
        joins["verses"] = "(verses.chapter_id=ayahs.surah_id AND verses.verse_id=ayahs.verse_number)";
        joins["chapters"] = "ayahs.surah_id=chapters.id";
    }

    QStringList innerJoins;
    {
        foreach (QString const& key, joins.keys()) {
            innerJoins << QString("%1 ON %2").arg(key).arg( joins.value(key) );
        }
    }

    QString likeClause = isArabic ? LIKE_CLAUSE2("searchable", "content") : LIKE_CLAUSE("verses.translation");
    QString query = QString("SELECT %1 FROM ayahs INNER JOIN %2 WHERE (%3").arg( columns.join(",") ).arg( innerJoins.join(" INNER JOIN ") ).arg(likeClause);

    if (n > 1) {
        query += QString(" AND %1").arg(likeClause).repeated(n-1);
    }

    query += ")";

    if ( !chapters.isEmpty() )
    {
        QStringList all;

        foreach (QVariant const& q, chapters) {
            all << QString::number( q.toInt() );
        }

        query += QString(" AND ayahs.surah_id IN (%1)").arg( all.join(",") );
    }

    m_sql.executeQuery(caller, query, QueryId::SearchAyats, params);
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
    LOGGER(individualId);

    QStringList queryParams = QStringList() << QString("SELECT quotes.id AS id,%1 AS author,body,reference FROM quotes INNER JOIN individuals i ON i.id=quotes.author").arg( NAME_FIELD("i") );

    if (individualId) {
        queryParams << QString("WHERE quotes.author=%1").arg(individualId);
    }

    queryParams << "ORDER BY id DESC";

    m_sql.executeQuery(caller, queryParams.join(" "), QueryId::FetchAllQuotes);
}


void QueryHelper::fetchAllOrigins(QObject* caller)
{
    m_sql.executeQuery(caller, QString("SELECT %1 AS name,i.id,city,i.is_companion,latitude+((RANDOM()%10)*0.0001) AS latitude,longitude+((RANDOM()%10)*0.0001) AS longitude FROM individuals i INNER JOIN locations ON i.location=locations.id").arg( NAME_FIELD("i") ), QueryId::FetchAllOrigins);
}

void QueryHelper::fetchAllTafsir(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);

    QStringList queryParams = QStringList() << QString("SELECT suites.id AS id,%1 AS author,title FROM suites LEFT JOIN individuals i ON i.id=suites.author").arg( NAME_FIELD("i") );

    if (individualId) {
        queryParams << QString("WHERE (author=%1 OR translator=%1 OR explainer=%1)").arg(individualId);
    }

    queryParams << "ORDER BY id DESC";

    m_sql.executeQuery(caller, queryParams.join(" "), QueryId::FetchAllTafsir);
}


void QueryHelper::fetchIndividualData(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);

    QString query = QString("SELECT * FROM individuals WHERE id=%1").arg(individualId);
    m_sql.executeQuery(caller, query, QueryId::FetchIndividualData);
}


bool QueryHelper::disableSpacing() const {
    return m_persist->getValueFor("disableSpacing").toInt() == 1;
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


QString QueryHelper::translation() const {
    return m_translation;
}


QueryBookmarkHelper* QueryHelper::getBookmarkHelper() {
    return &m_bookmarkHelper;
}


QObject* QueryHelper::getExecutor() {
    return &m_sql;
}


QString QueryHelper::translationName() const {
    return TRANSLATION;
}


QueryHelper::~QueryHelper()
{
}

} /* namespace oct10 */
