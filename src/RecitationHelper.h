#ifndef RECITATIONHELPER_H_
#define RECITATIONHELPER_H_

#include "LazyMediaPlayer.h"
#include "QueueDownloader.h"

#include <QFutureWatcher>

namespace canadainc {
    class Persistance;
}

namespace quran {

using namespace canadainc;

class RecitationHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int queued READ queued NOTIFY queueChanged)
    Q_PROPERTY(bool directoryReady READ directoryReady FINAL)
    Q_PROPERTY(QObject* player READ player FINAL)

    QueueDownloader m_queue;
    Persistance* m_persistance;
    QFutureWatcher<QVariantList> m_future;
    LazyMediaPlayer m_player;

    void startPlayback();
    bool directoryReady();
    QVariantList generatePlaylist(int chapter, int fromVerse, int toVerse);

private slots:
    void indexChanged(int index);
    void onFinished();
    void onRequestComplete(QVariant const& cookie, QByteArray const& data);
    void settingChanged(QString const& key);

signals:
    void queueChanged();
    void currentIndexChanged();

public:
    RecitationHelper(Persistance* p, QObject* parent=NULL);
    virtual ~RecitationHelper();

    /**
     * @pre The directory must have been set up.
     */
    Q_INVOKABLE void downloadAndPlay(int chapter, int fromVerse, int toVerse);
    QObject* player();
    int queued() const;
};

} /* namespace quran */

#endif /* RECITATIONHELPER_H_ */
