#include "DualChannelPlayer.h"
#include "Logger.h"

#include <bb/cascades/Application>

#include <bb/multimedia/MediaPlayer>
#include <bb/multimedia/NowPlayingConnection>

namespace canadainc {

using namespace bb::multimedia;
using namespace bb::cascades;

DualChannelPlayer::DualChannelPlayer(QObject* parent) :
		QObject(parent), m_index(-1), m_channel1(NULL), m_channel2(NULL), m_npc(NULL), m_repeat(false), m_cachedIndex(-1), m_active(false), m_playing(false), m_paused(false)
{
	Application* app = Application::instance();

	if (app)
	{
		connect( app, SIGNAL( fullscreen() ), this, SLOT( refresh() ) );
		connect( app, SIGNAL( awake() ), this, SLOT( refresh() ) );
		connect( app, SIGNAL( thumbnail() ), this, SLOT( deActivate() ) );
		connect( app, SIGNAL( invisible() ), this, SLOT( deActivate() ) );
		connect( app, SIGNAL( asleep() ), this, SLOT( deActivate() ) );
	}
}


void DualChannelPlayer::refresh()
{
	if (m_channel1 && m_channel2 && !m_active)
	{
		m_active = true;

		if (m_cachedIndex != -1) {
			emit playbackCompleted(m_cachedIndex);
		}

		emit indexChanged();
	}
}


void DualChannelPlayer::deActivate()
{
	if (m_channel1 && m_channel2 && m_active) {
		m_active = false;
		m_cachedIndex = m_index;
	}
}


void DualChannelPlayer::play(QStringList const& playlist)
{
	m_playlist = playlist;

	if (m_npc == NULL)
	{
		m_channel1 = new MediaPlayer(this);
		m_channel1->setStatusInterval(500);
		connect( m_channel1, SIGNAL( positionChanged(unsigned int) ), this, SLOT( positionChanged(unsigned int) ) );

		m_channel2 = new MediaPlayer(this);
		m_channel2->setStatusInterval(500);
		connect( m_channel2, SIGNAL( positionChanged(unsigned int) ), this, SLOT( positionChanged(unsigned int) ) );

		m_npc = new NowPlayingConnection(this);
		m_npc->setIconUrl( QUrl( QString("file://%1/app/native/icon.png").arg( QDir::currentPath() ) ) );
		connect( m_npc, SIGNAL( pause() ), this, SLOT( pause() ) );
		connect( m_npc, SIGNAL( acquired() ), this, SLOT( resume() ) );
		connect( m_npc, SIGNAL( play() ), this, SLOT( resume() ) );
		connect( m_npc, SIGNAL( revoked() ), this, SLOT( pause() ) );

		refresh();
	}

	restart();
}


void DualChannelPlayer::pause() {
	LOGGER("================ PAUSE()" << m_index);
	currentPlayer()->pause();

	if (m_playing) {
		m_playing = false;
		emit playingChanged();
	}

	if (!m_paused) {
		m_paused = true;
		emit pausedChanged();
	}
}


void DualChannelPlayer::resume() {
	LOGGER("========== RESUME, current playing" << m_index);
	currentPlayer()->play();

	if (!m_playing) {
		m_playing = true;
		emit playingChanged();
	}

	if (m_paused) {
		m_paused = false;
		emit pausedChanged();
	}
}


MediaPlayer* DualChannelPlayer::currentPlayer() const {
	return m_index %2 == 0 ? m_channel1 : m_channel2;
}


void DualChannelPlayer::restart()
{
	LOGGER(">>>>>>>>> RESTART!!!");
	m_index = 0;

	if (m_active) {
		emit indexChanged();
	}

	QUrl destination = QUrl(m_playlist[m_index]);

	if ( m_channel1->sourceUrl() != destination ) {
		m_channel1->setSourceUrl(destination);
	}

	if ( m_npc->isAcquired() ) {
		m_channel1->play();

		if (!m_playing) {
			m_playing = true;
			emit playingChanged();
		}

		if (m_paused) {
			m_paused = false;
			emit pausedChanged();
		}
	} else {
		m_npc->acquire();
	}
}


void DualChannelPlayer::positionChanged(unsigned int position)
{
	MediaPlayer* source = static_cast<MediaPlayer*>( sender() );
	MediaPlayer* target = sender() == m_channel1 ? m_channel2 : m_channel1;

	if ( position > source->duration()-500 && target->mediaState() != MediaState::Started && m_index >= 0 )
	{
		if (m_active) {
			emit playbackCompleted(m_index);
		}

		if ( m_index < m_playlist.size()-1 ) {
			++m_index;

			if (m_active) {
				emit indexChanged();
			}

			target->setSourceUrl( QUrl(m_playlist[m_index]) );

			if ( m_npc->isAcquired() ) {
				target->play();

				if (!m_playing) {
					m_playing = true;
					emit playingChanged();
				}

				if (m_paused) {
					m_paused = false;
					emit pausedChanged();
				}
			} else {
				m_npc->acquire();
			}
		} else if (m_repeat) {
			restart();
		} else {
			m_index = -1;

			if (m_active) {
				emit indexChanged();
			}

			m_playing = false;
			emit playingChanged();
		}
	}
}


bool DualChannelPlayer::repeat() const {
	return m_repeat;
}


bool DualChannelPlayer::paused() const {
	return m_paused;
}


bool DualChannelPlayer::playing() const {
	return m_playing;
}


void DualChannelPlayer::setRepeat(bool repeat) {
	m_repeat = repeat;
}


int DualChannelPlayer::index() const {
	return m_index;
}


DualChannelPlayer::~DualChannelPlayer()
{
}

} /* namespace canadainc */
