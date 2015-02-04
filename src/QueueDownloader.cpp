#include "QueueDownloader.h"
#include "Persistance.h"
#include "Logger.h"

namespace canadainc {

QueueDownloader::QueueDownloader(QObject* parent) : DataModel(parent)
{
    connect( &m_network, SIGNAL( requestComplete(QVariant const&, QByteArray const&) ), this, SLOT( onRequestComplete(QVariant const&, QByteArray const&) ) );
    connect( &m_network, SIGNAL( requestComplete(QVariant const&, QByteArray const&) ), this, SIGNAL( requestComplete(QVariant const&, QByteArray const&) ) );
    connect( &m_network, SIGNAL( downloadProgress(QVariant const&, qint64, qint64) ), this, SIGNAL( downloadProgress(QVariant const&, qint64, qint64) ) );
    connect( &m_network, SIGNAL( sizeFetched(QVariant const&, qint64) ), this, SIGNAL( sizeFetched(QVariant const&, qint64) ) );

    connect( &m_model, SIGNAL( itemAdded(QVariantList) ), this, SIGNAL( itemAdded(QVariantList) ) );
    connect( &m_model, SIGNAL( itemUpdated(QVariantList) ), this, SIGNAL( itemUpdated(QVariantList) ) );
    connect( &m_model, SIGNAL( itemRemoved(QVariantList) ), this, SIGNAL( itemRemoved(QVariantList) ) );
    connect( &m_model, SIGNAL( itemsChanged(bb::cascades::DataModelChangeType::Type, QSharedPointer<bb::cascades::DataModel::IndexMapper>) ), this, SIGNAL( itemsChanged(bb::cascades::DataModelChangeType::Type, QSharedPointer<bb::cascades::DataModel::IndexMapper>) ) );

    connect( &m_model, SIGNAL( itemAdded(QVariantList) ), this, SIGNAL( queueChanged() ) );
    connect( &m_model, SIGNAL( itemRemoved(QVariantList) ), this, SIGNAL( queueChanged() ) );
    connect( &m_model, SIGNAL( itemsChanged(bb::cascades::DataModelChangeType::Type, QSharedPointer<bb::cascades::DataModel::IndexMapper>) ), this, SIGNAL( queueChanged() ) );

    m_model.setGrouping(ItemGrouping::ByFullValue);
    m_model.setSortingKeys( QStringList() << "timestamp" );
}

QueueDownloader::~QueueDownloader()
{
}


void QueueDownloader::checkSize(QVariant const& cookie, QString const& uri)
{
    m_network.getFileSize(uri, cookie);
}


void QueueDownloader::processNext()
{
    if ( !m_model.isEmpty() )
    {
        QVariantList firstIndex = m_model.first();
        QVariantMap current = m_model.data(firstIndex).toMap();
        current["timestamp"] = QDateTime::currentMSecsSinceEpoch();

        LOGGER("Request completed, now processing" << current);
        m_network.doGet( current.value("uri").toString() , current );

        m_model.removeAt(firstIndex);
    }
}


void QueueDownloader::process(QVariantMap const& toProcess) {
    process( QVariantList() << toProcess );
}


void QueueDownloader::process(QVariantList const& toProcess)
{
    if ( !m_network.online() ) {
        Persistance::showBlockingToast( tr("It seems your device is offline, please connect to Wi-Fi or enable your data connection to proceed."), tr("OK"), "asset:///images/toast/ic_offline.png" );
    } else {
        m_model.insertList(toProcess);
        processNext();
    }
}


void QueueDownloader::onRequestComplete(QVariant const& cookie, QByteArray const& data)
{
    Q_UNUSED(data);
    Q_UNUSED(cookie);
    processNext();
}


int QueueDownloader::childCount(const QVariantList &indexPath) {
    return m_model.childCount(indexPath);
}


bool QueueDownloader::hasChildren(const QVariantList &indexPath) {
    return m_model.hasChildren(indexPath);
}


QString QueueDownloader::itemType(const QVariantList &indexPath) {
    return m_model.itemType(indexPath);
}


QVariant QueueDownloader::data(const QVariantList &indexPath) {
    return m_model.data(indexPath);
}


void QueueDownloader::abort()
{
	m_network.abort();
	m_model.clear();
}


int QueueDownloader::queued() const {
	return m_model.size();
}


} /* namespace canadainc */
