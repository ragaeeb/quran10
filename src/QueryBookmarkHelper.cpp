#include "precompiled.h"

#include "QueryBookmarkHelper.h"
#include "CommonConstants.h"
#include "DatabaseHelper.h"
#include "Logger.h"
#include "QueryId.h"
#include "ThreadUtils.h"

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
        statements << "CREATE TABLE IF NOT EXISTS bookmarks.bookmarks (id INTEGER PRIMARY KEY, surah_id INTEGER, verse_id INTEGER, name TEXT, tag TEXT, timestamp INTEGER)";
        statements << "CREATE TABLE IF NOT EXISTS bookmarks.progress (timestamp INTEGER PRIMARY KEY, surah_id INTEGER, verse_id INTEGER)";

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

    initBookmarks(caller);

    m_sql->executeQuery(caller, "SELECT timestamp,surah_id,verse_id FROM bookmarks.progress WHERE timestamp=(SELECT MAX(timestamp) FROM bookmarks.progress)", QueryId::FetchLastProgress);
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

    QString query = QString("INSERT INTO bookmarks (surah_id,verse_id,name,tag,timestamp) VALUES (%1,%2,?,?,%3)").arg(surahId).arg(verseId).arg( QDateTime::currentMSecsSinceEpoch() );
    m_sql->executeQuery(caller, query, QueryId::SaveBookmark, QVariantList() << name << tag);
}


void QueryBookmarkHelper::saveLegacyBookmarks(QObject* caller, QVariantList const& data)
{
    LOGGER( data.size() );

    m_sql->startTransaction(caller, QueryId::SettingUpBookmarks);

    foreach (QVariant const& q, data)
    {
        QVariantMap qvm = q.toMap();
        int surahId = qvm.value(KEY_CHAPTER_ID).toInt();
        int verseId = qvm.value(KEY_VERSE_ID).toInt();
        QString name = qvm.value("surah_name").toString();
        QString query = QString("INSERT INTO bookmarks (surah_id,verse_id,name,tag,timestamp) VALUES (%1,%2,?,?,%3)").arg(surahId).arg(verseId).arg( QDateTime::currentMSecsSinceEpoch() );
        m_sql->executeQuery(caller, query, QueryId::SettingUpBookmarks, QVariantList() << name << "");
    }

    m_sql->endTransaction(caller, QueryId::SaveLegacyBookmarks);
}


void QueryBookmarkHelper::saveLastProgress(QObject* caller, int surahId, int verseId)
{
    LOGGER(surahId << verseId);

    QString query = QString("INSERT INTO progress (timestamp,surah_id,verse_id) VALUES (%1,%2,%3)").arg( QDateTime::currentMSecsSinceEpoch() ).arg(surahId).arg(verseId);
    m_sql->executeQuery(caller, query, QueryId::SaveLastProgress);
}


void QueryBookmarkHelper::backup(QString const& destination)
{
    LOGGER(destination);

    QFutureWatcher<QString>* qfw = new QFutureWatcher<QString>(this);
    connect( qfw, SIGNAL( finished() ), this, SLOT( onBookmarksSaved() ) );

    QFuture<QString> future = QtConcurrent::run(&ThreadUtils::compressBookmarks, destination);
    qfw->setFuture(future);
}


void QueryBookmarkHelper::onBookmarksSaved()
{
    QFutureWatcher<QString>* qfw = static_cast< QFutureWatcher<QString>* >( sender() );
    QString result = qfw->result();

    emit backupComplete(result);

    qfw->deleteLater();
}


void QueryBookmarkHelper::restore(QString const& source)
{
    LOGGER(source);

    QFutureWatcher<bool>* qfw = new QFutureWatcher<bool>(this);
    connect( qfw, SIGNAL( finished() ), this, SLOT( onBookmarksRestored() ) );

    QFuture<bool> future = QtConcurrent::run(&ThreadUtils::performRestore, source);
    qfw->setFuture(future);
}


void QueryBookmarkHelper::onBookmarksRestored()
{
    QFutureWatcher<bool>* qfw = static_cast< QFutureWatcher<bool>* >( sender() );
    bool result = qfw->result();

    if (result) {
        m_sql->detach("bookmarks"); // so we reload next call
        emit bookmarksUpdated();
    }

    LOGGER("RestoreResult" << result);
    emit restoreComplete(result);

    qfw->deleteLater();
}


QueryBookmarkHelper::~QueryBookmarkHelper()
{
}

} /* namespace quran */
