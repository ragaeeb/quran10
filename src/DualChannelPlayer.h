#ifndef DUALCHANNELPLAYER_H_
#define DUALCHANNELPLAYER_H_

#include <QObject>
#include <QStringList>

#include <bb/multimedia/MediaState>

namespace bb {
	namespace multimedia {
		class MediaPlayer;
		class NowPlayingConnection;
	}
}

namespace canadainc {

using namespace bb::multimedia;

/**
 * This class will attempt to play audio using 2 channels that it will toggle between. This will give us better performance because while the first
 * channel is playing, the second channel can be preparing and vice-versa so that when the play() happens, it should be immediate without awkward pauses.
 */
class DualChannelPlayer : public QObject
{
	Q_OBJECT

	Q_PROPERTY(qreal index READ index NOTIFY indexChanged)
	Q_PROPERTY(qreal playing READ playing NOTIFY playingChanged)
	Q_PROPERTY(qreal paused READ paused NOTIFY pausedChanged)
	Q_PROPERTY(bool repeat READ repeat WRITE setRepeat NOTIFY repeatChanged)

	QStringList m_playlist;
	int m_index;
	MediaPlayer* m_channel1;
	MediaPlayer* m_channel2;
	NowPlayingConnection* m_npc;
	bool m_repeat;
	int m_cachedIndex;
	bool m_active;
	bool m_playing;
	bool m_paused;

	void restart();
	MediaPlayer* currentPlayer() const;

signals:
	void indexChanged();
	void playingChanged();
	void pausedChanged();
	void repeatChanged();
	void playbackCompleted(int index);

private slots:
	void positionChanged(unsigned int position);
	void refresh();
	void deActivate();

public:
	DualChannelPlayer(QObject* parent=NULL);

	/**
	 * @param playlist A playlist of URIs to play.
	 */
	Q_INVOKABLE void play(QStringList const& playlist);
	void setRepeat(bool repeat);
	bool repeat() const;
	bool playing() const;
	bool paused() const;
	int index() const;
	virtual ~DualChannelPlayer();
	Q_SLOT void pause();
	Q_SLOT void resume();
};

} /* namespace canadainc */
#endif /* DUALCHANNELPLAYER_H_ */
