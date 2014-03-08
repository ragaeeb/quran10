#ifndef QUEUEDOWNLOADER_H_
#define QUEUEDOWNLOADER_H_

#include "NetworkProcessor.h"

namespace canadainc {

class QueueDownloader : public QObject
{
	Q_OBJECT
	Q_PROPERTY(int queued READ queued NOTIFY queueChanged)

	QQueue< QPair<QString,QVariant> > m_queue;
	NetworkProcessor m_network;

signals:
	void queueChanged();
	void downloadProgress(QVariant const& cookie, qint64 bytesReceived, qint64 bytesTotal);
	void requestComplete(QVariant const& cookie, QByteArray const& data);

private slots:
	void onRequestComplete(QVariant const& cookie, QByteArray const& data);

public:
	QueueDownloader();
	virtual ~QueueDownloader();

	/**
	 * Queues up a batch of requests.
	 * @param toProcess The first key is the URL to download, and the second is the cookie.
	 */
	Q_INVOKABLE void process(QQueue< QPair<QString,QVariant> > const& toProcess);
	Q_INVOKABLE void abort();
	int queued() const;
};

} /* namespace canadainc */
#endif /* QUEUEDOWNLOADER_H_ */
