#ifndef QUEUEDOWNLOADER_H_
#define QUEUEDOWNLOADER_H_

#include <bb/system/SystemProgressToast>

#include <QQueue>

#include "NetworkProcessor.h"

namespace canadainc {

class QueueDownloader : public QObject
{
	Q_OBJECT

	QQueue<QVariantMap> m_queue;
	NetworkProcessor m_network;
	bb::system::SystemProgressToast m_progress;

signals:
	void requestComplete(QVariant const& cookie, QByteArray const& data);
	void queueCompleted();

private slots:
	void onRequestComplete(QVariant const& cookie, QByteArray const& data);
	void onDownloadProgress(QVariant const& cookie, qint64 bytesReceived, qint64 bytesTotal);

public:
	QueueDownloader();
	virtual ~QueueDownloader();

	void queue(QString const& url, QVariant const& cookie, bool getRequest=true);
	NetworkProcessor* networkConnection();
	void cancel();
};

} /* namespace canadainc */
#endif /* QUEUEDOWNLOADER_H_ */
