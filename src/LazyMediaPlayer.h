#ifndef LAZYMEDIAPLAYER_H_
#define LAZYMEDIAPLAYER_H_

#include <QObject>

namespace bb {
	namespace multimedia {
		class MediaPlayer;
		class NowPlayingConnection;
	}
}

namespace canadainc {

using namespace bb::multimedia;

class LazyMediaPlayer : public QObject
{
	Q_OBJECT

	QString m_name;
	MediaPlayer* m_mp;
	NowPlayingConnection* m_npc;

private slots:
	void onPlaybackCompleted();

signals:
	void playbackCompleted();

public:
	LazyMediaPlayer(QObject* parent=NULL);
	virtual ~LazyMediaPlayer();

	Q_INVOKABLE void setName(QString const& name);
	Q_INVOKABLE void play(QString const& uri);
};

} /* namespace salat */
#endif /* LazyMediaPlayer_H_ */
