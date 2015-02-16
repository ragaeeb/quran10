#include "precompiled.h"

#include "QueryBookmarkHelper.h"
#include "DatabaseHelper.h"
#include "Logger.h"
#include "QueryId.h"

namespace quran {

QueryBookmarkHelper::QueryBookmarkHelper(DatabaseHelper* sql) : m_sql(sql)
{
}


void QueryBookmarkHelper::clearAllBookmarks(QObject* caller)
{
    m_sql->executeQuery(caller, "DELETE FROM bookmarks", QueryId::ClearAllBookmarks);
}


void QueryBookmarkHelper::fetchAllBookmarks(QObject* caller)
{
    LOGGER("fetchAllBookmarks");

    if ( initBookmarks(caller) )
    {
        QString query = "SELECT bookmarks.id AS id,surah_id,verse_id,bookmarks.name AS name,tag,timestamp,surahs.name AS surah_name FROM bookmarks INNER JOIN surahs ON surahs.id=surah_id";
        m_sql->executeQuery(caller, query, QueryId::FetchAllBookmarks);
    }
}


bool QueryBookmarkHelper::initBookmarks(QObject* caller)
{
    QFile bookmarksPath(BOOKMARKS_PATH);
    bool ready = bookmarksPath.exists() && bookmarksPath.size() > 0;

    m_sql->attachIfNecessary("bookmarks", true);

    if (!ready) // if no bookmarks created yet
    {
        m_sql->startTransaction(caller, QueryId::SettingUpBookmarks);

        QStringList statements;
        statements << "CREATE TABLE IF NOT EXISTS bookmarks.bookmarks (id INTEGER PRIMARY KEY, surah_id INTEGER REFERENCES surahs(id), verse_id INTEGER, name TEXT, tag TEXT, timestamp INTEGER)";
        statements << "CREATE TABLE IF NOT EXISTS bookmarks.bookmarked_tafsir (id INTEGER PRIMARY KEY, tid INTEGER, author TEXT, title TEXT, name TEXT, tag TEXT, timestamp INTEGER)";
        statements << "CREATE TABLE IF NOT EXISTS bookmarks.progress (timestamp INTEGER PRIMARY KEY, surah_id INTEGER REFERENCES surahs(id), verse_id INTEGER, name TEXT)";

        foreach (QString const& q, statements) {
            m_sql->executeInternal(q, QueryId::SettingUpBookmarks);
        }

        m_sql->endTransaction(caller, QueryId::SetupBookmarks);
    }

    return ready;
}


void QueryBookmarkHelper::fetchLastProgress(QObject* caller)
{
    LOGGER("fetchLastProgress");

    if ( initBookmarks(caller) ) {
        m_sql->executeQuery(caller, "SELECT timestamp,surah_id,verse_id FROM bookmarks.progress WHERE timestamp=(SELECT MAX(timestamp) FROM bookmarks.progress)", QueryId::FetchLastProgress);
    }
}


void QueryBookmarkHelper::removeBookmark(QObject* caller, int id)
{
    LOGGER(id);

    QString query = QString("DELETE FROM bookmarks WHERE id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::RemoveBookmark);
}


void QueryBookmarkHelper::saveBookmark(QObject* caller, int surahId, int verseId, QString const& name, QString const& tag)
{
    LOGGER(surahId << verseId << name << tag);

    initBookmarks(caller);

    QString query = QString("INSERT INTO bookmarks (surah_id,verse_id,name,tag,timestamp) VALUES (%1,'%2',?,?,%3)").arg(surahId).arg(verseId).arg( QDateTime::currentMSecsSinceEpoch() );
    m_sql->executeQuery(caller, query, QueryId::SaveBookmark, QVariantList() << name << tag);
}


void QueryBookmarkHelper::saveLastProgress(QObject* caller, int surahId, int verseId)
{
    LOGGER(surahId << verseId);

    QString query = QString("INSERT INTO progress (timestamp,surah_id,verse_id) VALUES (%1,%2,%3)").arg( QDateTime::currentMSecsSinceEpoch() ).arg(surahId).arg(verseId);
    m_sql->executeQuery(caller, query, QueryId::SaveLastProgress);
}


QueryBookmarkHelper::~QueryBookmarkHelper()
{
}

} /* namespace quran */
