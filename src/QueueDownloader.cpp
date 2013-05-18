#include "precompiled.h"

#include "QueueDownloader.h"
#include "Logger.h"

namespace canadainc {

using namespace bb::system;

QueueDownloader::QueueDownloader()
{
	m_progress.setState(SystemUiProgressState::Inactive);

    connect( &m_network, SIGNAL( requestComplete(QVariant const&, QByteArray const&) ), this, SLOT( onRequestComplete(QVariant const&, QByteArray const&) ) );
    connect( &m_network, SIGNAL( downloadProgress(QVariant const&, qint64, qint64) ), this, SLOT( onDownloadProgress(QVariant const&, qint64, qint64) ) );
}

QueueDownloader::~QueueDownloader()
{
}

void QueueDownloader::queue(QString const& url, QVariant const& cookie, bool getRequest)
{
	QVariantMap map;
	map["url"] = url;
	map["cookie"] = cookie;
	map["getRequest"] = getRequest;

	m_queue.enqueue(map);

	if ( m_queue.size() == 1 ) // first one
	{
		m_progress.setState(SystemUiProgressState::Active);
		m_progress.setStatusMessage( tr("0% complete...") );
		m_progress.setProgress(0);

		if (getRequest) {
			m_network.doGet(url, cookie);
		} else {
			m_network.doRequest(url, cookie);
		}
	} // else, we'll do the request when the first one finishes

	m_progress.setBody( tr("%n downloads left...", "The message to show for the number of downloads left.", m_queue.size() ) );
	m_progress.show();
}

void QueueDownloader::onRequestComplete(QVariant const& cookie, QByteArray const& data)
{
	bool completed = false;

	if ( m_queue.isEmpty() ) {
		LOGGER("Last request completed, all downloads finished!" << cookie);

		m_progress.cancel();
		m_progress.setState(SystemUiProgressState::Inactive);
		completed = true;
	} else {
		QVariantMap map = m_queue.dequeue();

		LOGGER("Request completed, now processing" << map);

		m_progress.setBody( tr("%n downloads left...", "The message to show for the number of downloads left.", m_queue.size() ) );

		if ( map["getRequest"].toBool() ) {
			m_network.doGet( map["url"].toString(), map["cookie"] );
		} else {
			m_network.doRequest( map["url"].toString(), map["cookie"] );
		}
	}

	emit requestComplete(cookie, data);

	if (completed) {
		emit queueCompleted();
	}
}


void QueueDownloader::onDownloadProgress(QVariant const& cookie, qint64 bytesReceived, qint64 bytesTotal)
{
	int progress = (double)bytesReceived/bytesTotal * 100;

	m_progress.setProgress(progress);
	m_progress.setStatusMessage( tr("%1% complete...").arg(progress) );
	m_progress.show();
}


void QueueDownloader::cancel() {
	m_queue.clear();
}


NetworkProcessor* QueueDownloader::networkConnection() {
	return &m_network;
}

} /* namespace canadainc */
