#include "QueueDownloader.h"
#include "Persistance.h"
#include "Logger.h"

namespace canadainc {

QueueDownloader::QueueDownloader(QObject* parent) : QObject(parent), m_currentIndex(0)
{
    connect( &m_network, SIGNAL( requestComplete(QVariant const&, QByteArray const&, bool) ), this, SLOT( onRequestComplete(QVariant const&, QByteArray const&, bool) ) );
    connect( &m_network, SIGNAL( downloadProgress(QVariant const&, qint64, qint64) ), this, SLOT( onDownloadProgress(QVariant const&, qint64, qint64) ) );
    connect( &m_network, SIGNAL( sizeFetched(QVariant const&, qint64) ), this, SIGNAL( sizeFetched(QVariant const&, qint64) ) );

    m_model.setParent(this);
}

QueueDownloader::~QueueDownloader() {
    m_model.setParent(NULL);
}


void QueueDownloader::checkSize(QVariant const& cookie, QString const& uri) {
    m_network.getFileSize(uri, cookie);
}


bool QueueDownloader::processNext()
{
    // 0 elements, -1
    // 1 element, -1
    // 2 elements, 0

    if ( m_currentIndex < m_model.size() )
    {
        QVariantMap current = m_model.value(m_currentIndex).toMap();
        current["timestamp"] = QDateTime::currentMSecsSinceEpoch();

        LOGGER("Request completed, now processing" << current);
        QString uri = current.value(URI_KEY).toString();

        m_uriToIndex.insert(uri, m_currentIndex);
        m_network.doGet(uri, current);

        ++m_currentIndex;

        return true;
    }

    return false;
}


void QueueDownloader::process(QVariantMap const& toProcess)
{
    if ( !m_uriToIndex.contains( toProcess.value(URI_KEY).toString() ) )
    {
        m_model.append(toProcess);
        processNext();

        emit queueChanged();
    }
}


void QueueDownloader::process(QVariantList const& toProcess)
{
    QVariantList cleaned;

    foreach (QVariant const& current, toProcess)
    {
        QVariantMap qvm = current.toMap();

        if ( !m_uriToIndex.contains( qvm.value(URI_KEY).toString() ) ) {
            cleaned << current;
        }
    }

    m_model.append(cleaned);
    processNext();

    emit queueChanged();
}


void QueueDownloader::onDownloadProgress(QVariant const& cookie, qint64 bytesReceived, qint64 bytesTotal)
{
    QVariantMap element = cookie.toMap();
    QString uri = element.value(URI_KEY).toString();

    if ( m_uriToIndex.contains(uri) )
    {
        element[KEY_CURRENT_PROGRESS] = QString::number( (bytesReceived*100.0)/bytesTotal, 'f', 2 );
        element[KEY_TOTAL_SIZE] = 100;

        int i = m_uriToIndex.value(uri);
        m_model.replace(i, element);
    }

    emit downloadProgress(cookie, bytesReceived, bytesTotal);
}


void QueueDownloader::onRequestComplete(QVariant const& cookie, QByteArray const& data, bool error)
{
    QVariantMap element = cookie.toMap();
    QString uri = element.value(URI_KEY).toString();

    if ( m_uriToIndex.contains(uri) )
    {
        element[KEY_CURRENT_PROGRESS] = element[KEY_TOTAL_SIZE] = 100;

        if (error) {
            LOGGER("Error" << cookie);
            element[KEY_ERROR] = true;
        }

        int i = m_uriToIndex.value(uri);
        m_model.replace(i, element);

        if (error) {
            m_uriToIndex.remove(uri); // remove it so that user can attempt to redownload it
        }
    }

    if ( !processNext() ) {
        emit queueCompleted();
    }

    if (!error) {
        emit requestComplete(cookie, data);
    }
}


QObject* QueueDownloader::model() {
    return &m_model;
}


void QueueDownloader::abort() {
	m_network.abort();
}


int QueueDownloader::queued() const {
	return m_model.size();
}


} /* namespace canadainc */
