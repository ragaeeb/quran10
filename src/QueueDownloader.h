#ifndef QUEUEDOWNLOADER_H_
#define QUEUEDOWNLOADER_H_

#include <bb/cascades/ArrayDataModel>

#include "NetworkProcessor.h"

#define URI_KEY "uri"
#define KEY_BUSY "busy"
#define KEY_ERROR "error"
#define KEY_CURRENT_PROGRESS "current"
#define KEY_TRANSFER_NAME "name"
#define KEY_TOTAL_SIZE "total"
#define KEY_BLOCKED "blockedKey"

namespace canadainc {

using namespace bb::cascades;

class QueueDownloader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int queued READ queued NOTIFY queueChanged)
    Q_PROPERTY(int isBlocked READ isBlocked NOTIFY isBlockedChanged)
    Q_PROPERTY(QObject* model READ model FINAL)
    Q_PROPERTY(int currentIndex READ currentIndex NOTIFY currentIndexChanged)

    ArrayDataModel m_model;
    NetworkProcessor m_network;
    int m_currentIndex;
    int m_blockingCount;
    QMap<QString, int> m_uriToIndex;

    bool processNext();

private slots:
    void onDownloadProgress(QVariant const& cookie, qint64 bytesReceived, qint64 bytesTotal);
    void onRequestComplete(QVariant const& cookie, QByteArray const& data, bool error);

public:
    QueueDownloader(QObject* parent=NULL);
    virtual ~QueueDownloader();

    /**
     * Queues up a batch of requests.
     * @param toProcess The first key is the URL to download, and the second is the cookie.
     */
    Q_INVOKABLE void process(QVariantList const& toProcess);
    Q_INVOKABLE void process(QVariantMap const& toProcess, bool force=false);
    Q_SLOT void abort();
    bool isBlocked() const;
    int queued() const;
    int currentIndex() const;
    QObject* model();
    Q_SLOT void decreaseBlockingCount();
    void updateData(QVariantMap cookie, bool error, QString const& pendingStatus=QString());

signals:
    void currentIndexChanged();
    void downloadProgress(QVariant const& cookie, qint64 bytesReceived, qint64 bytesTotal);
    void isBlockedChanged();
    void queueChanged();
    void queueCompleted();
    void requestComplete(QVariant const& cookie, QByteArray const& data);
    void sizeFetched(QVariant const& cookie, qint64 size);
};


} /* namespace canadainc */
#endif /* QUEUEDOWNLOADER_H_ */
