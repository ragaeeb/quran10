#ifndef QUEUEDOWNLOADER_H_
#define QUEUEDOWNLOADER_H_

#include <bb/cascades/ArrayDataModel>

#include "NetworkProcessor.h"

#define URI_KEY "uri"
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
    void onOnlineChanged();
    void onRequestComplete(QVariant const& cookie, QByteArray const& data, bool error);

public:
    QueueDownloader(QObject* parent=NULL);
    virtual ~QueueDownloader();

    bool isBlocked() const;
    bool updateData(QVariantMap const& cookie);
    int currentIndex() const;
    int queued() const;
    Q_INVOKABLE void process(QVariantList const& toProcess);
    Q_INVOKABLE void process(QVariantMap const& toProcess, bool force=false);
    Q_SLOT void abort();
    Q_SLOT void decreaseBlockingCount();
    QObject* model();
    QVariantMap updateData(QVariantMap cookie, bool error);

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
