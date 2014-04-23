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

namespace {

void writeVerse(QVariant const& cookie, QByteArray const& data) {
    canadainc::IOUtils::writeFile( cookie.toMap().value("local").toString(), data );
}

}

namespace quran {

using namespace canadainc;

RecitationHelper::RecitationHelper(Persistance* p, QObject* parent) :
        QObject(parent), m_queue( QStringList() << "chapter" << "verse" ), m_persistance(p)
{
    connect( &m_queue, SIGNAL( requestComplete(QVariant const&, QByteArray const&) ), this, SLOT( onRequestComplete(QVariant const&, QByteArray const&) ) );
    connect( &m_queue, SIGNAL( queueChanged() ), this, SIGNAL( queueChanged() ) );
    connect( &m_future, SIGNAL( finished() ), this, SLOT( onFinished() ) );
    connect( &m_player, SIGNAL( metaDataChanged(QVariantMap const&) ), this, SLOT( metaDataChanged(QVariantMap const&) ) );
    connect( p, SIGNAL( settingChanged(QString const&) ), this, SLOT( settingChanged(QString const&) ) );

    settingChanged("repeat");
}


void RecitationHelper::metaDataChanged(QVariantMap const& m)
{
    QString uri = m.value("uri").toString();
    uri = uri.mid( uri.lastIndexOf("/")+1 );
    uri = uri.left( uri.lastIndexOf(".") );
    int index = uri.mid(3).toInt();

    emit currentIndexChanged(index);
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
    bool sharedOK = InvocationUtils::validateSharedFolderAccess( tr("It appears the app does not have access to your Shared Folder. This permission is needed to download the recitation audio. Please enable the Shared Folder access in the BlackBerry 10 Application Permissions Screen.") );

    if (sharedOK && chapter > 0)
    {
        QDir output( m_persistance->getValueFor("output").toString() );

        if ( !output.exists() ) {
            m_persistance->saveValueFor( "output", IOUtils::setupOutputDirectory("downloads", "quran10") );
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

                queue << q;
            }

            playlist << absolutePath;
        }

        if (write)
        {
            bool written = IOUtils::writeTextFile( PLAYLIST_TARGET, playlist.join("\n"), true, false );
            LOGGER(written);
        }
    }

    return queue;
}


void RecitationHelper::onFinished()
{
    QVariantList queue = m_future.result();

    if ( !queue.isEmpty() ) {
        m_queue.process(queue);
    } else {
        startPlayback();
    }
}


void RecitationHelper::settingChanged(QString const& key)
{
    if (key == "repeat") {
        m_player.setRepeat( m_persistance->getValueFor("repeat").toInt() == 1 );
    }
}


void RecitationHelper::onRequestComplete(QVariant const& cookie, QByteArray const& data)
{
    QFutureWatcher<void>* qfw = new QFutureWatcher<void>(this);
    connect( qfw, SIGNAL( finished() ), this, SLOT( onWritten() ) );

    QFuture<void> future = QtConcurrent::run(writeVerse, cookie, data);
    qfw->setFuture(future);
}


void RecitationHelper::onWritten()
{
    if ( queued() == 0 ) { // last one
        startPlayback();
    }
}


void RecitationHelper::startPlayback()
{
    m_player.play( QUrl::fromLocalFile(PLAYLIST_TARGET) );
}


int RecitationHelper::queued() const {
    return m_queue.queued();
}


void RecitationHelper::abort() {
    m_queue.abort();
}


RecitationHelper::~RecitationHelper()
{
}

} /* namespace quran */
