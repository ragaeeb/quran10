#include "precompiled.h"

#include "RecitationHelper.h"
#include "InvocationUtils.h"
#include "IOUtils.h"
#include "Logger.h"
#include "Persistance.h"
#include "TextUtils.h"

#define normalize(a) TextUtils::zeroFill(a,3)
#define PLAYLIST_TARGET "/var/tmp/playlist.m3u"
#define remote "http://www.everyayah.com/data"
#define ITERATION 20
#define CHUNK_SIZE 4

using namespace canadainc;

namespace {

void writeVerse(QVariant const& cookie, QByteArray const& data) {
    canadainc::IOUtils::writeFile( cookie.toMap().value("local").toString(), data );
}

QVariantMap processPlaylist(QString const& reciter, QString const& outputDirectory, QList< QPair<int,int> > const& playlist)
{
    QVariantMap result;

    if ( !Persistance::hasSharedFolderAccess() ) {
        result["error"] = QObject::tr("Quran10 does not have access to your Shared Folder. The app cannot download any recitations without this permission.");
        return result;
    }

    QDir q( QString("%1/%2").arg(outputDirectory).arg(reciter) );
    if ( !q.exists() ) {
        q.mkpath(".");
    }

    if ( !q.exists() ) {
        result["error"] = QObject::tr("Quran10 does not seem to be able to write to the output folder. Please try selecting a different output folder or restart your device.");
        return result;
    }

    int n = playlist.size();
    QVariantList queue;
    QStringList toPlay;

    for (int i = 0; i < n; i++)
    {
        QPair<int,int> track = playlist[i];

        QString fileName = QString("%1%2.mp3").arg( normalize(track.first) ).arg( normalize(track.second) );
        QString absolutePath = QString("%1/%2").arg( q.path() ).arg(fileName);

        if ( !QFile(absolutePath).exists() )
        {
            QVariantMap q;
            q["uri"] = QString("%1/%2/%3").arg(remote).arg(reciter).arg(fileName);
            q["local"] = absolutePath;
            q["name"] = QObject::tr("%1:%2 recitation").arg(track.first).arg(track.second);
            q["recitation"] = true;

            queue << q;
        } else {
            toPlay << absolutePath;
        }
    }

    result["queue"] = queue;

    bool written = IOUtils::writeTextFile( PLAYLIST_TARGET, playlist.join("\n"), true, false );
    LOGGER(written);

    if (written) {
        result["playlist"] = PLAYLIST_TARGET;
    } else {
        result["error"] = QObject::tr("Quran10 could not write the playlist. Please try restarting your device.");
    }

    return result;
}

}

namespace quran {

RecitationHelper::RecitationHelper(QueueDownloader* queue, Persistance* p, QObject* parent) :
        QObject(parent), m_queue(queue), m_persistance(p)
{
    connect( queue, SIGNAL( requestComplete(QVariant const&, QByteArray const&) ), this, SLOT( onRequestComplete(QVariant const&, QByteArray const&) ) );
    connect( &m_future, SIGNAL( finished() ), this, SLOT( onFinished() ) );
}


int RecitationHelper::extractIndex(QVariantMap const& m)
{
    QString uri = m.value("uri").toString();
    uri = uri.mid( uri.lastIndexOf("/")+1 );
    uri = uri.left( uri.lastIndexOf(".") );
    return uri.mid(3).toInt();
}


void RecitationHelper::memorize(int chapter, int fromVerse, int toVerse)
{
    LOGGER(chapter << fromVerse << toVerse);

    if ( !m_future.isRunning() )
    {
        QFuture<QVariantList> future = QtConcurrent::run(this, &RecitationHelper::generateMemorization, chapter, fromVerse, toVerse);
        m_future.setFuture(future);
    }
}


QVariantList RecitationHelper::generateMemorization(int chapter, int from, int toVerse)
{
    LOGGER(chapter << from << toVerse);

    QVariantList queue = generatePlaylist(chapter, from, toVerse, false);

    QStringList playlist;

    QString chapterNumber = normalize(chapter);
    QString reciter = m_persistance->getValueFor("reciter").toString();
    QString directory = QString("%1/%2").arg( m_persistance->getValueFor("output").toString() ).arg(reciter);

    int k = 0;
    int fromVerse = from;

    while (k < 2)
    {
        int endPoint = fromVerse+CHUNK_SIZE;

        if (endPoint > toVerse) {
            endPoint = toVerse+1;
        }

        for (int verse = fromVerse; verse < endPoint; verse++)
        {
            QString currentVerse = QString::number(verse);
            QString fileName = QString("%1%2.mp3").arg(chapterNumber).arg( normalize(verse) );
            QString absolutePath = QString("%1/%2").arg(directory).arg(fileName);

            for (int j = 0; j < ITERATION; j++) {
                playlist << absolutePath;
            }
        }

        for (int j = 0; j < ITERATION; j++)
        {
            for (int verse = fromVerse; verse < endPoint; verse++)
            {
                QString currentVerse = QString::number(verse);
                QString fileName = QString("%1%2.mp3").arg(chapterNumber).arg( normalize(verse) );
                QString absolutePath = QString("%1/%2").arg(directory).arg(fileName);
                playlist << absolutePath;
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
        for (int verse = from; verse <= toVerse; verse++)
        {
            QString currentVerse = QString::number(verse);
            QString fileName = QString("%1%2.mp3").arg(chapterNumber).arg( normalize(verse) );
            QString absolutePath = QString("%1/%2").arg(directory).arg(fileName);
            playlist << absolutePath;
        }
    }

    bool written = IOUtils::writeTextFile( PLAYLIST_TARGET, playlist.join("\n"), true, false );
    LOGGER(written);

    return queue;
}


void RecitationHelper::downloadAndPlay(int chapter, int fromVerse, int toVerse)
{
    LOGGER(chapter << fromVerse << toVerse);

    if ( !m_future.isRunning() )
    {
        QFuture<QVariantList> future = QtConcurrent::run(this, &RecitationHelper::generatePlaylist, chapter, fromVerse, toVerse, true);
        m_future.setFuture(future);
    }
}


QVariantList RecitationHelper::generatePlaylist(int chapter, int fromVerse, int toVerse, bool write)
{
    LOGGER(chapter << fromVerse << toVerse << write);

    QVariantList queue;

    if (chapter > 0)
    {
        QDir output( m_persistance->getValueFor("output").toString() );

        if ( !m_persistance->contains("output") || !output.exists() ) {
            m_persistance->saveValueFor( "output", IOUtils::setupOutputDirectory("misc", "quran10"), false );
        }

        QStringList playlist;

        QString chapterNumber = normalize(chapter);
        QString reciter = m_persistance->getValueFor("reciter").toString();
        QString directory = QString("%1/%2").arg( m_persistance->getValueFor("output").toString() ).arg(reciter);
        QDir outDir(directory);

        if ( !outDir.exists() ) {
            bool created = outDir.mkdir(directory);
            LOGGER("Directory created" << created);
        }

        for (int verse = fromVerse; verse <= toVerse; verse++) // fromVerse = 1, toVerse = 100
        {
            QString fileName = QString("%1%2.mp3").arg(chapterNumber).arg( normalize(verse) );
            QString absolutePath = QString("%1/%2").arg(directory).arg(fileName);

            if ( !QFile(absolutePath).exists() )
            {
                QString remoteFile = QString("%1/%2/%3").arg(remote).arg(reciter).arg(fileName);

                QVariantMap q;
                q["uri"] = remoteFile;
                q["local"] = absolutePath;
                q["chapter"] = chapter;
                q["verse"] = verse;
                q["name"] = tr("%1:%2 recitation").arg(chapter).arg(verse);
                q["recitation"] = true;

                queue << q;
            }

            playlist << absolutePath;
        }

        bool written = IOUtils::writeTextFile( PLAYLIST_TARGET, playlist.join("\n"), true, false );
        LOGGER(written);
    }

    return queue;
}


void RecitationHelper::onFinished()
{
    QVariantList queue = m_future.result();

    if ( !queue.isEmpty() ) {
        m_queue->process(queue);
    } else {
        startPlayback();
    }
}


void RecitationHelper::onRequestComplete(QVariant const& cookie, QByteArray const& data)
{
    if ( cookie.toMap().contains("recitation") )
    {
        QFutureWatcher<void>* qfw = new QFutureWatcher<void>(this);
        connect( qfw, SIGNAL( finished() ), this, SLOT( onWritten() ) );

        QFuture<void> future = QtConcurrent::run(writeVerse, cookie, data);
        qfw->setFuture(future);
    }
}


void RecitationHelper::onWritten()
{
    /*
    if ( queued() == 0 ) { // last one
        startPlayback();
    } */
}


void RecitationHelper::downloadAndPlayAll(bb::cascades::ArrayDataModel* adm)
{
    QList< QPair<int,int> > all;
    int n = adm->size();

    for (int i = 0; i < n; i++)
    {
        QVariantMap q = adm->value(i).toMap();
        all << qMakePair<int,int>( q.value("surah_id").toInt(), q.value("verse_id").toInt() );
    }
}


void RecitationHelper::startPlayback() {
    emit readyToPlay( QUrl::fromLocalFile(PLAYLIST_TARGET) );
}


RecitationHelper::~RecitationHelper()
{
}

} /* namespace quran */
