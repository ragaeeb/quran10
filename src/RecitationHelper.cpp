#include "precompiled.h"

#include "RecitationHelper.h"
#include "CommonConstants.h"
#include "InvocationUtils.h"
#include "IOUtils.h"
#include "Logger.h"
#include "Persistance.h"
#include "TextUtils.h"

#define normalize(a) TextUtils::zeroFill(a,3)
#define PLAYLIST_TARGET QString("%1/playlist.m3u").arg( QDir::tempPath() )
#define remote "http://www.everyayah.com/data"
#define ITERATION 20
#define CHUNK_SIZE 4
#define COOKIE_RECITATION_MP3 "recitation"
#define ANCHOR_KEY "anchor"
#define PLAYLIST_KEY "playlist"
#define LOCAL_PATH "local"
#define KEY_QUEUE "queue"
#define PLAYLIST_ERROR "error"

using namespace canadainc;

namespace {

QVariantMap writeVerse(QVariant const& cookie, QByteArray const& data)
{
    QVariantMap q = cookie.toMap();

    canadainc::IOUtils::writeFile( q.value(LOCAL_PATH).toString(), data );
    return q;
}

QVariantMap processPlaylist(QString const& reciter, QString const& outputDirectory, QList< QPair<int,int> > const& playlist)
{
    QVariantMap result;

    if ( !Persistance::hasSharedFolderAccess() ) {
        result[PLAYLIST_ERROR] = QObject::tr("Quran10 does not have access to your Shared Folder. The app cannot download any recitations without this permission.");
        return result;
    }

    QDir q( QString("%1/%2").arg(outputDirectory).arg(reciter) );
    if ( !q.exists() ) {
        q.mkpath(".");
    }

    if ( !q.exists() ) {
        result[PLAYLIST_ERROR] = QObject::tr("Quran10 does not seem to be able to write to the output folder. Please try selecting a different output folder or restart your device.");
        return result;
    }

    int n = playlist.size();
    QVariantList queue;
    QStringList toPlay;
    QSet<QString> alreadyQueued; // we maintain this to avoid putting duplicates in the queue (ie: during memorization mode)

    for (int i = 0; i < n; i++)
    {
        QPair<int,int> track = playlist[i];
        QString fileName = QString("%1%2.mp3").arg( normalize(track.first) ).arg( normalize(track.second) );
        QString absolutePath = QString("%1/%2").arg( q.path() ).arg(fileName);

        if ( !QFile(absolutePath).exists() && !alreadyQueued.contains(absolutePath) )
        {
            QVariantMap q;
            q[URI_KEY] = QString("%1/%2/%3").arg(remote).arg(reciter).arg(fileName);
            q[LOCAL_PATH] = absolutePath;
            q["name"] = QObject::tr("%1:%2 recitation").arg(track.first).arg(track.second);
            q[COOKIE_RECITATION_MP3] = true;
            q["chapter"] = track.first;
            q["verse"] = track.second;

            queue << q;
            alreadyQueued << absolutePath;
        }

        toPlay << absolutePath;
    }

    if ( !queue.isEmpty() )
    {
        result[KEY_QUEUE] = queue;
        result[ANCHOR_KEY] = queue.last().toMap().value(URI_KEY).toString();
    }

    if ( toPlay.size() > 1 )
    {
        bool written = !toPlay.isEmpty() ? IOUtils::writeTextFile( PLAYLIST_TARGET, toPlay.join("\n"), true, false ) : false;
        LOGGER(written);

        if (written) {
            result[PLAYLIST_KEY] = QUrl::fromLocalFile(PLAYLIST_TARGET);
        } else {
            result[PLAYLIST_ERROR] = QObject::tr("Quran10 could not write the playlist. Please try restarting your device.");
        }
    } else if ( toPlay.size() == 1 ) {
        result[PLAYLIST_KEY] = QUrl::fromLocalFile( toPlay.first() );
    }

    return result;
}

}

namespace quran {

RecitationHelper::RecitationHelper(QueueDownloader* queue, Persistance* p, QObject* parent) :
        QObject(parent), m_persistance(p), m_queue(queue)
{
    connect( queue, SIGNAL( requestComplete(QVariant const&, QByteArray const&) ), this, SLOT( onRequestComplete(QVariant const&, QByteArray const&) ) );
    connect( &m_futureResult, SIGNAL( finished() ), this, SLOT( onPlaylistReady() ) );
}


int RecitationHelper::extractIndex(QVariantMap const& m)
{
    if ( m_ayatToIndex.isEmpty() ) {
        return -1;
    }

    QString uri = m.value(URI_KEY).toString();
    uri = uri.mid( uri.lastIndexOf("/")+1 );
    uri = uri.left( uri.lastIndexOf(".") );
    int verse = uri.mid(3).toInt();
    int chapter = uri.left(3).toInt();

    return m_ayatToIndex.value( qMakePair<int,int>(chapter,verse) );
}


void RecitationHelper::memorize(bb::cascades::ArrayDataModel* adm, int from, int to)
{
    LOGGER(adm->size() << from << to);

    if ( !m_futureResult.isRunning() )
    {
        m_ayatToIndex.clear();

        for (int i = from; i <= to; i++)
        {
            QVariantMap q = adm->value(i).toMap();
            QPair<int,int> ayat = qMakePair<int,int>( q.value("surah_id").toInt(), q.value("verse_id").toInt() );
            m_ayatToIndex.insert(ayat, i);
        }

        QList< QPair<int,int> > all;
        int k = 0;
        int fromVerse = from;

        while (k < 2)
        {
            int endPoint = from+CHUNK_SIZE;

            if (endPoint > to) {
                endPoint = to+1;
            }

            for (int verse = fromVerse; verse < endPoint; verse++)
            {
                for (int j = 0; j < ITERATION; j++)
                {
                    QVariantMap q = adm->value(verse).toMap();
                    all << qMakePair<int,int>( q.value("surah_id").toInt(), q.value("verse_id").toInt() );
                }
            }

            for (int j = 0; j < ITERATION; j++)
            {
                for (int verse = fromVerse; verse < endPoint; verse++)
                {
                    QVariantMap q = adm->value(verse).toMap();
                    all << qMakePair<int,int>( q.value("surah_id").toInt(), q.value("verse_id").toInt() );
                }
            }

            fromVerse += CHUNK_SIZE;

            if (fromVerse > endPoint) {
                break;
            }

            ++k;
        }

        for (int j = 0; j < ITERATION; j++)
        {
            for (int verse = from; verse < to; verse++)
            {
                QVariantMap q = adm->value(verse).toMap();
                all << qMakePair<int,int>( q.value("surah_id").toInt(), q.value("verse_id").toInt() );
            }
        }

        QFuture<QVariantMap> future = QtConcurrent::run(processPlaylist, m_persistance->getValueFor(KEY_RECITER).toString(), m_persistance->getValueFor(KEY_OUTPUT_FOLDER).toString(), all);
        m_futureResult.setFuture(future);
    }
}


void RecitationHelper::downloadAndPlay(int chapter, int verse)
{
    LOGGER(chapter << verse);

    if ( !m_futureResult.isRunning() )
    {
        QList< QPair<int,int> > all;
        all << qMakePair<int,int>(chapter, verse);

        QFuture<QVariantMap> future = QtConcurrent::run(processPlaylist, m_persistance->getValueFor(KEY_RECITER).toString(), m_persistance->getValueFor(KEY_OUTPUT_FOLDER).toString(), all);
        m_futureResult.setFuture(future);
    }
}


void RecitationHelper::onRequestComplete(QVariant const& cookie, QByteArray const& data)
{
    if ( cookie.toMap().contains(COOKIE_RECITATION_MP3) )
    {
        QFutureWatcher<QVariantMap>* qfw = new QFutureWatcher<QVariantMap>(this);
        connect( qfw, SIGNAL( finished() ), this, SLOT( onWritten() ) );

        QFuture<QVariantMap> future = QtConcurrent::run(writeVerse, cookie, data);
        qfw->setFuture(future);
    }
}


void RecitationHelper::onWritten()
{
    QFutureWatcher<QVariantMap>* qfw = static_cast< QFutureWatcher<QVariantMap>* >( sender() );
    QVariantMap result = qfw->result();

    if ( !m_anchor.isEmpty() && m_anchor == result.value(URI_KEY).toString() ) {
        startPlayback();
    }

    qfw->deleteLater();
}


void RecitationHelper::onPlaylistReady()
{
    QVariantMap result = m_futureResult.result();

    LOGGER(result);

    if ( result.contains(PLAYLIST_ERROR) ) {
        m_persistance->showToast( result.value(PLAYLIST_ERROR).toString(), ASSET_YELLOW_DELETE );
    } else if ( result.contains(KEY_QUEUE) ) {
        QVariantList queue = result.value(KEY_QUEUE).toList();
        m_anchor = result.value(ANCHOR_KEY).toString();
        m_queue->process(queue);

        if ( result.contains(PLAYLIST_KEY) ) {
            m_playlistUrl = result.value(PLAYLIST_KEY).toUrl();
        }
    } else if ( result.contains(PLAYLIST_KEY) ) {
        m_playlistUrl = result.value(PLAYLIST_KEY).toUrl();
        startPlayback();
    }
}


void RecitationHelper::downloadAndPlayAll(bb::cascades::ArrayDataModel* adm, int from, int to)
{
    LOGGER( adm->size() << from << to );

    if ( !m_futureResult.isRunning() )
    {
        QList< QPair<int,int> > all;
        int n = to >= from ? to : adm->size()-1;
        m_ayatToIndex.clear();

        for (int i = from; i <= n; i++)
        {
            QVariantMap q = adm->value(i).toMap();
            QPair<int,int> ayat = qMakePair<int,int>( q.value("surah_id").toInt(), q.value("verse_id").toInt() );
            all << ayat;
            m_ayatToIndex.insert(ayat, i);
        }

        QFuture<QVariantMap> future = QtConcurrent::run(processPlaylist, m_persistance->getValueFor(KEY_RECITER).toString(), m_persistance->getValueFor(KEY_OUTPUT_FOLDER).toString(), all);
        m_futureResult.setFuture(future);
    }
}


bool RecitationHelper::isDownloaded(int chapter, int verse)
{
    QString fileName = QString("%1%2.mp3").arg( normalize(chapter) ).arg( normalize(verse) );
    QDir q( QString("%1/%2").arg( m_persistance->getValueFor(KEY_OUTPUT_FOLDER).toString() ).arg( m_persistance->getValueFor(KEY_RECITER).toString() ) );
    QString absolutePath = QString("%1/%2").arg( q.path() ).arg(fileName);

    return QFile::exists(absolutePath);
}


void RecitationHelper::startPlayback() {
    emit readyToPlay(m_playlistUrl);
}


RecitationHelper::~RecitationHelper()
{
}

} /* namespace quran */
