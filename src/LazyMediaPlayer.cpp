#include "LazyMediaPlayer.h"
#include "Logger.h"

#include <bb/multimedia/MediaPlayer>
#include <bb/multimedia/NowPlayingConnection>

namespace canadainc {

using namespace bb::multimedia;

LazyMediaPlayer::LazyMediaPlayer(QObject* parent) : QObject(parent), m_mp(NULL), m_npc(NULL)
{
}


void LazyMediaPlayer::setName(QString const& name) {
	m_name = name;
}


void LazyMediaPlayer::play(QString const& uri)
{
	LOGGER("Play" << uri);

	if (m_npc == NULL) {
		LOGGER("Creating MediaPlayer for first time");
		m_mp = new MediaPlayer(this);
		m_npc = new NowPlayingConnection(m_name, this);

		connect( m_npc, SIGNAL( pause() ), m_mp, SLOT( pause() ) );
		connect( m_npc, SIGNAL( acquired() ), m_mp, SLOT( play() ) );
		connect( m_npc, SIGNAL( play() ), m_mp, SLOT( play() ) );
		connect( m_npc, SIGNAL( revoked() ), m_mp, SLOT( stop() ) );
		connect( m_mp, SIGNAL( playbackCompleted() ), m_npc, SLOT( acquire() ) );
		connect( m_mp, SIGNAL( playbackCompleted() ), this, SLOT( onPlaybackCompleted() ) );
	} else {
		m_mp->reset();
	}

	m_mp->setSourceUrl( QUrl(uri) );

	if ( m_npc->isAcquired() ) {
		LOGGER("Already acquired, playing!");
		m_mp->play();
	} else {
		LOGGER("Acquiring NPC!");
		m_npc->acquire();
	}
}


void LazyMediaPlayer::onPlaybackCompleted() {
	emit playbackCompleted();
}


LazyMediaPlayer::~LazyMediaPlayer()
{
	if (m_npc != NULL) {
		m_npc->revoke();
	}
}

} /* namespace salat */
