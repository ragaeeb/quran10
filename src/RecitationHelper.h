#ifndef RECITATIONHELPER_H_
#define RECITATIONHELPER_H_

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

    QueueDownloader* m_queue;
    Persistance* m_persistance;
    QFutureWatcher<QVariantList> m_future;

    void startPlayback();
    QVariantList generatePlaylist(int chapter, int fromVerse, int toVerse, bool write);
    QVariantList generateMemorization(int chapter, int fromVerse, int toVerse);

private slots:
    void onFinished();
    void onRequestComplete(QVariant const& cookie, QByteArray const& data);
    void onWritten();

signals:
    void readyToPlay(QUrl const& uri);

public:
    RecitationHelper(QueueDownloader* queue, Persistance* p, QObject* parent=NULL);
    virtual ~RecitationHelper();

    /**
     * @pre The directory must have been set up.
     */
    Q_INVOKABLE void downloadAndPlay(int chapter, int fromVerse, int toVerse);
    Q_INVOKABLE void memorize(int chapter, int fromVerse, int toVerse);
    Q_INVOKABLE static int extractIndex(QVariantMap const& m);
};

} /* namespace quran */

#endif /* RECITATIONHELPER_H_ */
