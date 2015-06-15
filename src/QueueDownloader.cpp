#include "QueueDownloader.h"
#include "Persistance.h"
#include "Logger.h"

namespace canadainc {

QueueDownloader::QueueDownloader(QObject* parent) :
        QObject(parent), m_currentIndex(0), m_blockingCount(0)
{
    connect( &m_network, SIGNAL( requestComplete(QVariant const&, QByteArray const&, bool) ), this, SLOT( onRequestComplete(QVariant const&, QByteArray const&, bool) ) );
    connect( &m_network, SIGNAL( downloadProgress(QVariant const&, qint64, qint64) ), this, SLOT( onDownloadProgress(QVariant const&, qint64, qint64) ) );
    connect( &m_network, SIGNAL( onlineChanged() ), this, SLOT( onOnlineChanged() ) );
    connect( &m_network, SIGNAL( sizeFetched(QVariant const&, qint64) ), this, SIGNAL( sizeFetched(QVariant const&, qint64) ) );

    m_model.setParent(this);
}

QueueDownloader::~QueueDownloader() {
    m_model.setParent(NULL);
}


bool QueueDownloader::processNext()
{
    // 0 elements, -1
    // 1 element, -1
    // 2 elements, 0

    if ( m_currentIndex < m_model.size() && m_network.online() )
    {
        QVariantMap current = m_model.value(m_currentIndex).toMap();

        QUrl uri = current.value(URI_KEY).toUrl();
        LOGGER("Request completed, now processing" << uri.host()+"/"+uri.path());

        m_uriToIndex.insert( uri.toString(), m_currentIndex );
        m_network.doGet(uri, current);

        ++m_currentIndex;
        emit currentIndexChanged();

        return true;
    }

    return false;
}


void QueueDownloader::onOnlineChanged()
{
    if ( m_network.online() ) {
        processNext();
    }
}


void QueueDownloader::process(QVariantMap const& toProcess, bool force)
{
    if ( !m_uriToIndex.contains( toProcess.value(URI_KEY).toUrl().toString() ) || force )
    {
        m_model.append(toProcess);
        emit queueChanged();

        if ( toProcess.contains(KEY_BLOCKED) )
        {
            bool blocked = isBlocked();
            ++m_blockingCount;

            if ( isBlocked() != blocked ) {
                emit isBlockedChanged();
            }
        }

        processNext();
    }
}


void QueueDownloader::process(QVariantList const& toProcess)
{
    QVariantList cleaned;
    bool blocked = isBlocked();

    foreach (QVariant const& current, toProcess)
    {
        QVariantMap qvm = current.toMap();

        if ( !m_uriToIndex.contains( qvm.value(URI_KEY).toUrl().toString() ) )
        {
            if ( qvm.contains(KEY_BLOCKED) ) {
                ++m_blockingCount;
            }

            cleaned << current;
        }
    }

    m_model.append(cleaned);
    emit queueChanged();

    if ( isBlocked() != blocked ) {
        emit isBlockedChanged();
    }

    processNext();
}


void QueueDownloader::onDownloadProgress(QVariant const& cookie, qint64 bytesReceived, qint64 bytesTotal)
{
    QVariantMap element = cookie.toMap();
    element[KEY_CURRENT_PROGRESS] = QString::number( (bytesReceived*100.0)/bytesTotal, 'f', 2 );
    element[KEY_TOTAL_SIZE] = 100;

    updateData(element);

    emit downloadProgress(cookie, bytesReceived, bytesTotal);
}


void QueueDownloader::onRequestComplete(QVariant const& cookie, QByteArray const& data, bool error)
{
    QVariantMap element = cookie.toMap();
    element[KEY_CURRENT_PROGRESS] = element[KEY_TOTAL_SIZE] = 100;

    updateData(element, error);

    if ( !processNext() ) {
        emit queueCompleted();
    }

    if (!error) {
        emit requestComplete(cookie, data);
    }
}


QVariantMap QueueDownloader::updateData(QVariantMap cookie, bool error, QString const& pendingStatus)
{
    if (error) {
        cookie[KEY_ERROR] = true;
    } else if ( !pendingStatus.isEmpty() ) {
        cookie[KEY_BUSY] = pendingStatus;
    } else {
        cookie.remove(KEY_ERROR);
        cookie.remove(KEY_BUSY);
    }

    if ( updateData(cookie) )
    {
        QString uri = cookie.value(URI_KEY).toUrl().toString();

        if (error)
        {
            m_uriToIndex.remove(uri); // remove it so that user can attempt to redownload it

            if ( cookie.contains(KEY_BLOCKED) ) {
                decreaseBlockingCount();
            }
        }
    }

    return cookie;
}


bool QueueDownloader::updateData(QVariantMap const& cookie)
{
    QUrl url = cookie.value(URI_KEY).toUrl();
    QString uri = url.toString();

    if ( m_uriToIndex.contains(uri) )
    {
        int i = m_uriToIndex.value(uri);
        m_model.replace(i, cookie);

        return true;
    }

    return false;
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


int QueueDownloader::currentIndex() const {
    return m_currentIndex;
}


bool QueueDownloader::isBlocked() const {
    return m_blockingCount > 0;
}


void QueueDownloader::decreaseBlockingCount()
{
    int blocked = isBlocked();

    --m_blockingCount;

    if (m_blockingCount < 0) {
        m_blockingCount = 0;
    }

    if ( isBlocked() != blocked ) {
        emit isBlockedChanged();
    }
}


} /* namespace canadainc */
