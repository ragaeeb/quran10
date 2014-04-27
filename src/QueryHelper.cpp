#include "precompiled.h"

#include "QueryHelper.h"
#include "customsqldatasource.h"
#include "Logger.h"
#include "Persistance.h"

namespace quran {

using namespace canadainc;

QueryHelper::QueryHelper(Persistance* persist) : m_persist(persist), m_currentId(0)
{
    settingChanged("bookmarks");

    m_sql.setSource("app/native/assets/dbase/quran.db");

    connect( persist, SIGNAL( settingChanged(QString const&) ), this, SLOT( settingChanged(QString const&) ), Qt::QueuedConnection );
    connect( &m_sql, SIGNAL( dataLoaded(int, QVariant const&) ), this, SLOT( dataLoaded(int, QVariant const&) ), Qt::QueuedConnection );
}


void QueryHelper::settingChanged(QString const& key)
{
    if (key == "bookmarks")
    {
        LOGGER("Total bookmarks changed");
        emit totalBookmarksChanged();
    } else if (key == "translation" || key == "primary") {
        emit textualChange();
    }
}


void QueryHelper::dataLoaded(int id, QVariant const& data)
{
    //LOGGER(id);
    QPair<QObject*, QueryId::Type> value = m_idToObjectQueryType[id];
    QObject* caller = value.first;
    QueryId::Type t = value.second;

    m_idToObjectQueryType.remove(id);

    QMap<int,bool> idsForObject = m_objectToIds[caller];
    idsForObject.remove(id);

    if ( !idsForObject.isEmpty() ) {
        m_objectToIds[caller] = idsForObject;
    } else {
        m_objectToIds.remove(caller);
    }

    //LOGGER("Emitting data loaded" << t << caller);

    //LOGGER("DATA" << data);
    QMetaObject::invokeMethod(caller, "onDataLoaded", Qt::QueuedConnection, Q_ARG(QVariant, t), Q_ARG(QVariant, data) );
}


void QueryHelper::executeQuery(QObject* caller, QString const& query, QueryId::Type t, QVariantList const& args)
{
    ++m_currentId;

    //LOGGER(caller << query << t << m_currentId);

    QPair<QObject*, QueryId::Type> pair = qMakePair<QObject*, QueryId::Type>(caller, t);
    m_idToObjectQueryType.insert(m_currentId, pair);

    if ( !m_objectToIds.contains(caller) ) {
        connect( caller, SIGNAL( destroyed(QObject*) ), this, SLOT( destroyed(QObject*) ) );
    }

    QMap<int,bool> idsForObject = m_objectToIds[caller];
    idsForObject.insert(m_currentId, true);
    m_objectToIds[caller] = idsForObject;

    m_sql.setQuery(query);

    if ( args.isEmpty() ) {
        m_sql.load(m_currentId);
    } else {
        m_sql.executePrepared(args, m_currentId);
    }
}


void QueryHelper::destroyed(QObject* obj)
{
    QMap<int,bool> idsForObject = m_objectToIds[obj];
    m_objectToIds.remove(obj);

    QList<int> ids = idsForObject.keys();

    for (int i = ids.size()-1; i >= 0; i--) {
        m_idToObjectQueryType.remove(ids[i]);
    }
}


void QueryHelper::fetchAllDuaa(QObject* caller)
{
    executeQuery(caller, "select supplications.surah_id,supplications.verse_id,chapters.english_name,chapters.arabic_name FROM supplications INNER JOIN chapters ON supplications.surah_id=chapters.surah_id", QueryId::FetchAllDuaa);
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
        query = "SELECT surah_id,arabic_name,english_name,english_translation FROM chapters";
    }

    if ( !query.isNull() ) {
        executeQuery(caller, query, QueryId::FetchChapters);
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

    executeQuery( caller, QString("SELECT * FROM %1 ORDER BY RANDOM() LIMIT 1").arg(table), QueryId::FetchRandomAyat );
}


void QueryHelper::fetchTafsirForAyat(QObject* caller, int chapterNumber, int verseId)
{
    //LOGGER(chapterNumber << verseId);
    QString translation = m_persist->getValueFor("translation").toString();

    if (translation == "english")
    {
        executeQuery( caller, QString("SELECT id,verse_id,description FROM tafsir_english WHERE surah_id=%1 AND verse_id=%2").arg(chapterNumber).arg(verseId), QueryId::FetchTafsirForAyat );
    }
}


void QueryHelper::fetchTafsirContent(QObject* caller, QString const& tafsirId)
{
    //LOGGER(tafsirId);
    executeQuery( caller, QString("SELECT * from tafsir_english WHERE id=%1").arg(tafsirId), QueryId::FetchTafsirContent );
}


void QueryHelper::fetchSurahHeader(QObject* caller, int chapterNumber)
{
    //LOGGER(chapterNumber);

    executeQuery( caller, QString("SELECT english_name, english_translation, arabic_name FROM chapters WHERE surah_id=%1").arg(chapterNumber), QueryId::FetchSurahHeader );
}


void QueryHelper::fetchTafsirForSurah(QObject* caller, int chapterNumber, bool excludeVerses)
{
    //LOGGER(chapterNumber);

    if (excludeVerses) {
        executeQuery( caller, QString("SELECT id,description,verse_id FROM tafsir_english WHERE surah_id=%1 AND verse_id ISNULL").arg(chapterNumber), QueryId::FetchTafsirForSurah );
    } else {
        executeQuery( caller, QString("SELECT id,verse_id FROM tafsir_english WHERE surah_id=%1 AND verse_id NOT NULL").arg(chapterNumber), QueryId::FetchTafsirForSurah );
    }
}


void QueryHelper::fetchAllAyats(QObject* caller, int chapterNumber)
{
    //LOGGER(chapterNumber);

    QString primary = m_persist->getValueFor("primary").toString();
    QString translation = m_persist->getValueFor("translation").toString();
    QString query;

    if ( !translation.isEmpty() ) {
        query = QString("SELECT %1.text as arabic,%1.verse_id,%2.text as translation FROM %1 INNER JOIN %2 on %1.surah_id=%2.surah_id AND %1.verse_id=%2.verse_id AND %1.surah_id=%3").arg(primary).arg(translation).arg(chapterNumber);
    } else {
        query = QString("SELECT text as arabic,verse_id FROM %1 WHERE surah_id=%2").arg(primary).arg(chapterNumber);
    }

    executeQuery(caller, query, QueryId::FetchAllAyats);
}


void QueryHelper::fetchTafsirIbnKatheer(QObject* caller, int chapterNumber)
{
    //LOGGER(chapterNumber);

    if (chapterNumber == 114) {
        chapterNumber = 113;
    }

    executeQuery(caller, QString("SELECT title,body FROM ibn_katheer_english WHERE surah_id=%1").arg(chapterNumber), QueryId::FetchTafsirIbnKatheerForSurah);
}


int QueryHelper::totalBookmarks() {
    return m_persist->getValueFor("bookmarks").toList().size();
}


void QueryHelper::searchQuery(QObject* caller, QString const& trimmedText)
{
    //LOGGER(trimmedText);
    QString table = m_persist->getValueFor("translation").toString();
    QVariantList args = QVariantList() << trimmedText;

    if ( !table.isEmpty() ) {
        executeQuery(caller, QString("select %1.surah_id,%1.verse_id,%1.text,chapters.english_name as name, chapters.english_name, chapters.arabic_name, chapters.english_translation from %1 INNER JOIN chapters on chapters.surah_id=%1.surah_id AND %1.text LIKE '%' || ? || '%'").arg(table), QueryId::SearchQueryTranslation, args);
    }

    table = m_persist->getValueFor("primary").toString();

    if (table != "transliteration") {
        executeQuery(caller, QString("select %1.surah_id,%1.verse_id,%1.text,chapters.arabic_name as name, chapters.english_name, chapters.arabic_name, chapters.english_translation from %1 INNER JOIN chapters on chapters.surah_id=%1.surah_id AND %1.text LIKE '%' || ? || '%'").arg(table), QueryId::SearchQueryPrimary, args);
    }
}


void QueryHelper::fetchPageNumbers(QObject* caller)
{
    //LOGGER("fetchPageNumbers");
    executeQuery(caller, "SELECT MIN(page_number) as page_number,chapters.english_name,chapters.arabic_name from mushaf_pages INNER JOIN chapters ON mushaf_pages.surah_id=chapters.surah_id GROUP BY mushaf_pages.surah_id", QueryId::FetchPageNumbers);
}


QueryHelper::~QueryHelper()
{
}

} /* namespace oct10 */
