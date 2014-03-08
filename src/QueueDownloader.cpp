#include "QueueDownloader.h"
#include "Logger.h"

namespace canadainc {

QueueDownloader::QueueDownloader()
{
    connect( &m_network, SIGNAL( requestComplete(QVariant const&, QByteArray const&) ), this, SLOT( onRequestComplete(QVariant const&, QByteArray const&) ) );
    connect( &m_network, SIGNAL( requestComplete(QVariant const&, QByteArray const&) ), this, SIGNAL( requestComplete(QVariant const&, QByteArray const&) ) );
    connect( &m_network, SIGNAL( downloadProgress(QVariant const&, qint64, qint64) ), this, SIGNAL( downloadProgress(QVariant const&, qint64, qint64) ) );
}

QueueDownloader::~QueueDownloader() {
	abort();
}


void QueueDownloader::process(QQueue< QPair<QString,QVariant> > const& toProcess)
{
	m_queue.append(toProcess);

	if ( !m_queue.isEmpty() )
	{
		QPair<QString,QVariant> current = m_queue.dequeue();

		LOGGER("Request completed, now processing" << current);
		m_network.doGet(current.first, current.second);
	}

	emit queueChanged();
}


void QueueDownloader::abort()
{
	m_network.abort();
	m_queue.clear();
}


void QueueDownloader::onRequestComplete(QVariant const& cookie, QByteArray const& data)
{
	Q_UNUSED(data);

	if ( m_queue.isEmpty() ) {
		LOGGER("Last request completed, all downloads finished!" << cookie);
	} else {
		QPair<QString,QVariant> current = m_queue.dequeue();

		LOGGER("Request completed, now processing" << current);
		m_network.doGet(current.first, current.second);
	}

	emit queueChanged();
}


int QueueDownloader::queued() const {
	return m_queue.size();
}


} /* namespace canadainc */
