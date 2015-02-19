#ifndef QUEUEDOWNLOADER_H_
#define QUEUEDOWNLOADER_H_

#include <bb/cascades/ArrayDataModel>

#include "NetworkProcessor.h"

namespace canadainc {

using namespace bb::cascades;

class QueueDownloader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int queued READ queued NOTIFY queueChanged)
    Q_PROPERTY(QObject* model READ model FINAL)

    ArrayDataModel m_model;
    NetworkProcessor m_network;
    int m_currentIndex;
    QMap<QString, int> m_uriToIndex;

    void processNext();

private slots:
    void onDownloadProgress(QVariant const& cookie, qint64 bytesReceived, qint64 bytesTotal);
    void onRequestComplete(QVariant const& cookie, QByteArray const& data);

public:
    QueueDownloader(QObject* parent=NULL);
    virtual ~QueueDownloader();

    /**
     * Queues up a batch of requests.
     * @param toProcess The first key is the URL to download, and the second is the cookie.
     */
    Q_INVOKABLE void process(QVariantList const& toProcess);
    Q_INVOKABLE void process(QVariantMap const& toProcess);
    Q_SLOT void abort();
    int queued() const;
    void checkSize(QVariant const& cookie, QString const& uri);
    QObject* model();

signals:
    void downloadProgress(QVariant const& cookie, qint64 bytesReceived, qint64 bytesTotal);
    void queueChanged();
    void requestComplete(QVariant const& cookie, QByteArray const& data);
    void sizeFetched(QVariant const& cookie, qint64 size);
};


} /* namespace canadainc */
#endif /* QUEUEDOWNLOADER_H_ */
