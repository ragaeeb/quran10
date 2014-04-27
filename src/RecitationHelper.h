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
    Q_PROPERTY(bool repeat READ repeat NOTIFY repeatChanged)

    QueueDownloader m_queue;
    Persistance* m_persistance;
    QFutureWatcher<QVariantList> m_future;
    LazyMediaPlayer m_player;

    void startPlayback();
    QVariantList generatePlaylist(int chapter, int fromVerse, int toVerse, bool write);
    QVariantList generateMemorization(int chapter, int fromVerse, int toVerse);

private slots:
    void metaDataChanged(QVariantMap const& m);
    void onFinished();
    void onRequestComplete(QVariant const& cookie, QByteArray const& data);
    void onWritten();
    void settingChanged(QString const& key);

signals:
    void currentIndexChanged(int index);
    void queueChanged();
    void repeatChanged();

public:
    RecitationHelper(Persistance* p, QObject* parent=NULL);
    virtual ~RecitationHelper();

    /**
     * @pre The directory must have been set up.
     */
    Q_INVOKABLE void downloadAndPlay(int chapter, int fromVerse, int toVerse);
    Q_INVOKABLE void memorize(int chapter, int fromVerse, int toVerse);
    Q_SLOT void abort();
    int queued() const;
    bool repeat() const;
};

} /* namespace quran */

#endif /* RECITATIONHELPER_H_ */
