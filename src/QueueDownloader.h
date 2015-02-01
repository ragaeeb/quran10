#ifndef QUEUEDOWNLOADER_H_
#define QUEUEDOWNLOADER_H_

#include <bb/cascades/GroupDataModel>

#include "NetworkProcessor.h"

namespace canadainc {

using namespace bb::cascades;

class QueueDownloader : public DataModel
{
    Q_OBJECT
    Q_PROPERTY(int queued READ queued NOTIFY queueChanged)

    GroupDataModel m_model;
    NetworkProcessor m_network;

    void processNext();

private slots:
    void onRequestComplete(QVariant const& cookie, QByteArray const& data);

public:
    QueueDownloader(QStringList const& sortingKeys, QObject* parent=NULL);
    virtual ~QueueDownloader();
    int childCount(const QVariantList &indexPath);
    bool hasChildren(const QVariantList &indexPath);
    QString itemType(const QVariantList &indexPath);
    QVariant data(const QVariantList &indexPath);

    /**
     * Queues up a batch of requests.
     * @param toProcess The first key is the URL to download, and the second is the cookie.
     */
    Q_INVOKABLE void process(QVariantList const& toProcess);
    Q_INVOKABLE void abort();
    int queued() const;
    void checkSize(QVariant const& cookie, QString const& uri);

signals:
    void downloadProgress(QVariant const& cookie, qint64 bytesReceived, qint64 bytesTotal);
    void itemAdded(QVariantList);
    void itemUpdated(QVariantList);
    void itemRemoved(QVariantList);
    void itemsChanged(bb::cascades::DataModelChangeType::Type, QSharedPointer<bb::cascades::DataModel::IndexMapper>);
    void queueChanged();
    void requestComplete(QVariant const& cookie, QByteArray const& data);
    void sizeFetched(QVariant const& cookie, qint64 size);
};


} /* namespace canadainc */
#endif /* QUEUEDOWNLOADER_H_ */
