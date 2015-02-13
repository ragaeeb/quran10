#include "precompiled.h"

#include "QueryHelper.h"
#include "customsqldatasource.h"
#include "Logger.h"
#include "Persistance.h"
#include "TextUtils.h"

#define ATTACH_TAFSIR m_sql.attachIfNecessary( showTranslation() ? tafsirName() : "quran_tafsir_arabic", true ); m_sql.attachIfNecessary( showTranslation() ? QString("articles_%1").arg(m_translation) : "articles_arabic", true );
#define TRANSLATION QString("quran_%1").arg(m_translation)
#define MIN_CHARS_FOR_SURAH_SEARCH 2
#define LIKE_CLAUSE QString("(%1 LIKE '%' || ? || '%')").arg(textField)

namespace {

QString combine(QVariantList const& arabicIds)
{
    QStringList ids;

    foreach (QVariant const& entry, arabicIds) {
        ids << QString::number( entry.toInt() );
    }

    return ids.join(",");
}

}

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

    QTime time = QTime::currentTime();
    qsrand( (uint)time.msec() );
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


void QueryHelper::fetchAllChapters(QObject* caller)
{
    QString query = "SELECT id AS surah_id,name,verse_count,revelation_order,j.id AS juz_id,verse_number FROM surahs LEFT JOIN juzs j ON j.surah_id=a.id";

    if ( showTranslation() ) {
        query = "SELECT a.id AS surah_id,name,verse_count,revelation_order,transliteration,j.id AS juz_id,verse_number FROM surahs a INNER JOIN chapters t ON a.id=t.id LEFT JOIN juzs j ON j.surah_id=a.id";
    }

    m_sql.executeQuery(caller, query, QueryId::FetchAllChapters);
}


bool QueryHelper::fetchChapters(QObject* caller, QString const& text)
{
    QString query;

    QVariantList args;
    int n = text.length();

    if (n > MIN_CHARS_FOR_SURAH_SEARCH || n == 0)
    {
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
            query = "SELECT id AS surah_id,name,verse_count,revelation_order, FROM surahs";

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


void QueryHelper::fetchChapter(QObject* caller, int chapter)
{
    LOGGER(chapter);

    if ( showTranslation() ) {
        m_sql.executeQuery(caller, QString("SELECT a.id AS surah_id,name,verse_count,revelation_order,transliteration,j.id AS juz_id,verse_number FROM surahs a INNER JOIN chapters t ON a.id=t.id LEFT JOIN juzs j ON j.surah_id=a.id WHERE a.id=%1").arg(chapter), QueryId::FetchChapters);
    } else {
        m_sql.executeQuery(caller, QString("SELECT id AS surah_id,name,verse_count,revelation_order,j.id AS juz_id,verse_number FROM surahs LEFT JOIN juzs j ON j.surah_id=a.id WHERE id=%1").arg(chapter), QueryId::FetchChapters );
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
    LOGGER("fetchAllTafsir");

    ATTACH_TAFSIR;
    QString query = "SELECT suites.id AS id,individuals.name AS author,title FROM suites INNER JOIN individuals ON individuals.id=suites.author ORDER BY id DESC";
    m_sql.executeQuery(caller, query, QueryId::FetchAllTafsir);
}


void QueryHelper::fetchAllTafsirForAyat(QObject* caller, int chapterNumber, int verseNumber)
{
    LOGGER(chapterNumber << verseNumber);

    ATTACH_TAFSIR;
    m_sql.executeQuery(caller, QString("SELECT suite_page_id FROM explanations WHERE surah_id=%1 AND from_verse_number=%2").arg(chapterNumber).arg(verseNumber), QueryId::FetchTafsirForAyat);
}


void QueryHelper::fetchAllTafsirForSuite(QObject* caller, qint64 suiteId)
{
    LOGGER(suiteId);

    ATTACH_TAFSIR;
    QString query = QString("SELECT id,body FROM suite_pages WHERE suite_id=%1 ORDER BY id DESC").arg(suiteId);
    m_sql.executeQuery(caller, query, QueryId::FetchAllTafsirForSuite);
}


void QueryHelper::fetchAyatsForTafsir(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);
    ATTACH_TAFSIR;

    QString query;

    if ( showTranslation() ) {
        query = QString("SELECT x.id AS id,a.surah_id,a.verse_number AS verse_id,v.translation AS content,c.transliteration as name FROM ayahs a INNER JOIN verses v ON a.id=v.id INNER JOIN explanations x ON a.surah_id=x.surah_id AND (a.verse_number=x.from_verse_number OR x.from_verse_number ISNULL) INNER JOIN chapters c ON a.surah_id=c.id WHERE x.suite_page_id=%1").arg(suitePageId);
    } else {
        query = QString("SELECT x.id AS id,a.surah_id,a.verse_number AS verse_id,content,s.name FROM ayahs a INNER JOIN explanations x ON a.surah_id=x.surah_id AND a.verse_number=x.from_verse_number INNER JOIN surahs s ON a.surah_id=s.id WHERE x.suite_page_id=%1").arg(suitePageId);
    }

    m_sql.executeQuery(caller, query, QueryId::FetchAyatsForTafsir);
}


void QueryHelper::unlinkAyatsForTafsir(QObject* caller, QVariantList const& ids, qint64 suitePageId)
{
    LOGGER(ids << suitePageId);

    QString query = QString("DELETE FROM explanations WHERE id IN (%1) AND suite_page_id=%2").arg( combine(ids) ).arg(suitePageId);
    m_sql.executeQuery(caller, query, QueryId::UnlinkAyatsFromTafsir);
}


void QueryHelper::addTafsir(QObject* caller, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference)
{
    LOGGER(author << translator << explainer << title << description << reference);

    qint64 authorId = generateIndividualField(caller, author);
    qint64 translatorId = generateIndividualField(caller, translator);
    qint64 explainerId = generateIndividualField(caller, explainer);

    QString query = QString("INSERT OR IGNORE INTO suites (id,author,translator,explainer,title,description,reference) VALUES(%1,%2,%3,%4,?,?,?)").arg( QDateTime::currentMSecsSinceEpoch() ).arg(authorId).arg(translatorId).arg(explainerId);
    m_sql.executeQuery(caller, query, QueryId::AddTafsir, QVariantList() << title << description << reference);
}


void QueryHelper::editTafsir(QObject* caller, qint64 suiteId, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference)
{
    LOGGER(suiteId << author << translator << explainer << title << description << reference);

    qint64 authorId = generateIndividualField(caller, author);
    qint64 translatorId = generateIndividualField(caller, translator);
    qint64 explainerId = generateIndividualField(caller, explainer);

    QString query = QString("UPDATE suites SET author=%2,translator=%3,explainer=%4,title=?,description=?,reference=? WHERE id=%1").arg(suiteId).arg(authorId).arg(translatorId).arg(explainerId);
    m_sql.executeQuery(caller, query, QueryId::EditTafsir, QVariantList() << title << description << reference);
}


void QueryHelper::editTafsirPage(QObject* caller, qint64 suitePageId, QString const& body)
{
    LOGGER( suitePageId << body.length() );

    QString query = QString("UPDATE suite_pages SET body=? WHERE id=%1").arg(suitePageId);
    m_sql.executeQuery(caller, query, QueryId::EditTafsirPage, QVariantList() << body);
}


qint64 QueryHelper::generateIndividualField(QObject* caller, QString const& value)
{
    static QRegExp allNumbers = QRegExp("\\d+");

    if ( allNumbers.exactMatch(value) ) {
        return value.toLongLong();
    } else {
        qint64 id = QDateTime::currentMSecsSinceEpoch();
        m_sql.executeQuery(caller, QString("INSERT INTO individuals (id,name) VALUES (%1,?)").arg(id), QueryId::AddIndividual, QVariantList() << value);
        return id;
    }
}


void QueryHelper::linkAyatToTafsir(QObject* caller, qint64 suitePageId, int chapter, int fromVerse, int toVerse)
{
    LOGGER(suitePageId << chapter << fromVerse << toVerse);
    QString query;

    if (chapter > 0)
    {
        if (fromVerse == 0) {
            query = QString("INSERT OR IGNORE INTO explanations (surah_id,suite_page_id) VALUES(%1,%2)").arg(chapter).arg(suitePageId);
        } else {
            query = QString("INSERT OR IGNORE INTO explanations (surah_id,from_verse_number,to_verse_number,suite_page_id) VALUES(%1,%2,%3,%4)").arg(chapter).arg(fromVerse).arg(toVerse).arg(suitePageId);
        }

        m_sql.executeQuery(caller, query, QueryId::LinkAyatsToTafsir);
    }
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
    QString query = QString("SELECT x.name AS author,y.name AS translator,z.name AS explainer,title,description,reference,body FROM suites INNER JOIN suite_pages ON suites.id=suite_pages.suite_id INNER JOIN individuals x ON suites.author=x.id LEFT JOIN individuals y ON suites.translator=y.id LEFT JOIN individuals z ON suites.explainer=z.id WHERE suite_pages.id=%1").arg(suitePageId);

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


void QueryHelper::searchQuery(QObject* caller, QString const& trimmedText, int chapterNumber, QVariantList additional, bool andMode)
{
    LOGGER(trimmedText << additional << andMode << chapterNumber);

    QStringList constraints;
    QVariantList params = QVariantList() << trimmedText;
    bool isArabic = trimmedText.isRightToLeft() || !showTranslation();
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

    m_sql.executeQuery(caller, query, QueryId::SearchAyats, params);
}


void QueryHelper::editIndividual(QObject* caller, qint64 id, QString const& prefix, QString const& name, QString const& kunya, QString const& url, QString const& bio, bool hidden)
{
    LOGGER( id << prefix << name << kunya << url << bio.length() << hidden );

    QString query = QString("UPDATE individuals SET prefix=?, name=?, kunya=?, url=?, bio=?, hidden=%1 WHERE id=%2").arg(hidden ? 1 : 0).arg(id);

    QVariantList args;
    args << prefix.trimmed();
    args << name.trimmed();
    args << kunya.trimmed();
    args << url.trimmed();
    args << bio.trimmed();

    m_sql.executeQuery(caller, query, QueryId::EditIndividual, args);
}


void QueryHelper::searchIndividuals(QObject* caller, QString const& trimmedText)
{
    LOGGER(trimmedText);

    m_sql.executeQuery(caller, "SELECT id,prefix,name,kunya,uri,hidden,biography FROM individuals WHERE name LIKE '%' || ? || '%'", QueryId::SearchIndividuals, QVariantList() << trimmedText);
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
    m_sql.executeQuery(caller, "DELETE FROM bookmarks", QueryId::ClearAllBookmarks);
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


QString QueryHelper::tafsirName() const {
    return QString("quran_tafsir_%1").arg(m_translation);
}


QVariantList QueryHelper::removeOutOfRange(QVariantList input, int fromChapter, int fromVerse, int toChapter, int toVerse)
{
    int n = input.size();

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


QueryHelper::~QueryHelper()
{
}

} /* namespace oct10 */
