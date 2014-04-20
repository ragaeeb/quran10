#include "precompiled.h"

#include "RecitationHelper.h"
#include "InvocationUtils.h"
#include "IOUtils.h"
#include "Logger.h"
#include "Persistance.h"
#include "TextUtils.h"

#include <QtConcurrentRun>

#define normalize(a) TextUtils::zeroFill(a,3)
#define PLAYLIST_TARGET "/var/tmp/playlist.m3u"

namespace {
    const char* remote = "http://www.everyayah.com/data";
}

namespace quran {

using namespace canadainc;

RecitationHelper::RecitationHelper(Persistance* p, QObject* parent) :
        QObject(parent), m_queue( QStringList() << "chapter" << "verse" ), m_persistance(p)
{
    connect( &m_queue, SIGNAL( requestComplete(QVariant const&, QByteArray const&) ), this, SLOT( onRequestComplete(QVariant const&, QByteArray const&) ) );
    connect( &m_future, SIGNAL( finished() ), this, SLOT( onFinished() ) );
    connect( &m_player, SIGNAL( currentIndexChanged(int) ), this, SLOT( indexChanged(int) ) );
    connect( p, SIGNAL( settingChanged(QString const&) ), this, SLOT( settingChanged(QString const&) ) );

    settingChanged("repeat");
}


bool RecitationHelper::directoryReady()
{
    if ( !m_persistance->contains("output") ) {
        m_persistance->saveValueFor( "output", IOUtils::setupOutputDirectory("downloads", "quran10") );
    }

    QString chosenOutputDir = m_persistance->getValueFor("output").toString();
    QString reciter = m_persistance->getValueFor("reciter").toString();
    QString path = QString("%1/%2").arg(chosenOutputDir).arg(reciter);
    QDir dir(path);
    if ( !dir.exists() )
    {
        bool created = dir.mkdir(path);
        LOGGER("Directory didn't exist, creating!" << created);

        if (!created)
        {
            bool result = m_persistance->showBlockingToast( tr("Error: Could not create the directory to download the files into. Please try one of the following to fix this:\n\n1) Swipe-down from the top-bezel & go to the app settings and make sure the Download Directory is set to a valid location.\n\n2) Go to the BB10 device settings -> Security & Privacy -> Application Permissions -> Quran10 & make sure the app has all the permissions it needs."), tr("OK") );
            LOGGER("Could not create directory!!");

            if (result) {
                InvocationUtils::launchAppPermissionSettings();
            }

            return false;
        }
    }

    return true;
}


void RecitationHelper::indexChanged(int index)
{
    LOGGER(index);
    emit currentIndexChanged();
}


void RecitationHelper::downloadAndPlay(int chapter, int fromVerse, int toVerse)
{
    LOGGER(chapter << fromVerse << toVerse);
    QFuture<QVariantList> future = QtConcurrent::run(this, &RecitationHelper::generatePlaylist, chapter, fromVerse, toVerse);
    m_future.setFuture(future);
}


QVariantList RecitationHelper::generatePlaylist(int chapter, int fromVerse, int toVerse)
{
    LOGGER(chapter << fromVerse << toVerse);

    QVariantList queue;

    if (chapter > 0)
    {
        if ( !m_persistance->contains("output") ) {
            m_persistance->saveValueFor( "output", IOUtils::setupOutputDirectory("downloads", "quran10") );
        }

        QStringList playlist;

        QString chapterNumber = normalize(chapter);
        QString reciter = m_persistance->getValueFor("reciter").toString();
        QString directory = QString("%1/%2").arg( m_persistance->getValueFor("output").toString() ).arg( m_persistance->getValueFor("reciter").toString() );
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

        bool written = IOUtils::writeTextFile( PLAYLIST_TARGET, playlist.join("\n"), true, false );
        LOGGER(written);
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
    IOUtils::writeFile( cookie.toMap().value("local").toString(), data );

    if ( queued() == 0 ) { // last one
        startPlayback();
    }
}


void RecitationHelper::startPlayback()
{
    m_player.play( QUrl::fromLocalFile(PLAYLIST_TARGET) );
}


QObject* RecitationHelper::player() {
    return &m_player;
}


int RecitationHelper::queued() const {
    return m_queue.queued();
}


RecitationHelper::~RecitationHelper()
{
    m_queue.abort();
}

} /* namespace quran */
