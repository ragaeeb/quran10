#include "precompiled.h"

#include "NetworkProcessor.h"
#include "Logger.h"

namespace canadainc {

NetworkProcessor::NetworkProcessor(QObject* parent) : QObject(parent), m_networkManager(NULL)
{
}


void NetworkProcessor::doRequest(QString const& uri, QVariant const& cookie, QVariantMap const& parameters)
{
	LOGGER(uri << parameters);

    QUrl params;

    QStringList keys = m_headers.keys();

    foreach (QString key, keys) {
    	params.addQueryItem( key, m_headers[key] );
    }

    keys = parameters.keys();

    foreach (QString key, keys) {
    	params.addQueryItem( key, parameters[key].toString() );
    }

    QByteArray data;
    data.append( params.toString() );
    data.remove(0,1);

	init();

    QNetworkReply* reply = m_networkManager->post( QNetworkRequest( QUrl(uri) ), data );
    connect( reply, SIGNAL( downloadProgress(qint64,qint64) ), this, SLOT( downloadProgress(qint64,qint64) ) );
    reply->setProperty("cookie", cookie);
}


void NetworkProcessor::init()
{
	if (m_networkManager == NULL) {
		m_networkManager = new QNetworkAccessManager(this);
	    connect( m_networkManager, SIGNAL( finished(QNetworkReply*) ), this, SLOT( onNetworkReply(QNetworkReply*) ) );
	}
}


void NetworkProcessor::doGet(QString const& uri, QVariant const& cookie)
{
	LOGGER(uri << cookie);

	init();

    QNetworkReply* reply = m_networkManager->get( QNetworkRequest( QUrl(uri) ) );
    connect( reply, SIGNAL( downloadProgress(qint64,qint64) ), this, SLOT( downloadProgress(qint64,qint64) ) );
    reply->setProperty("cookie", cookie);
}


void NetworkProcessor::downloadProgress(qint64 bytesReceived, qint64 bytesTotal)
{
	QVariant cookie = sender()->property("cookie");
	LOGGER("received,total" << bytesReceived << bytesTotal << cookie);

	emit downloadProgress(cookie, bytesReceived, bytesTotal);
}


void NetworkProcessor::onNetworkReply(QNetworkReply* reply)
{
	if ( reply->error() == QNetworkReply::NoError )
	{
		int httpStatusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toUInt();

		LOGGER("return code" << httpStatusCode);

		if ( reply->isReadable() )
		{
			LOGGER("Reply readable");

			QByteArray data = reply->readAll();
			emit requestComplete( reply->property("cookie"), data );
		} else {
			LOGGER("\n\n\nUnreadable!!!!!!!\n\n\n");
		}
	}

	reply->deleteLater();
}


void NetworkProcessor::setHeaders(QHash<QString,QString> const& headers) {
	m_headers = headers;
}


NetworkProcessor::~NetworkProcessor()
{
}

} /* namespace canadainc */
