#ifndef NETWORKPROCESSOR_H_
#define NETWORKPROCESSOR_H_

#include <QHash>
#include <QObject>
#include <QString>
#include <QVariantMap>

class QNetworkAccessManager;
class QNetworkReply;

namespace canadainc {

class NetworkProcessor : public QObject
{
	Q_OBJECT

	QHash<QString, QString> m_headers;
    QNetworkAccessManager* m_networkManager;

    void init();

signals:
	void downloadProgress(QVariant const& cookie, qint64 bytesReceived, qint64 bytesTotal);
	void requestComplete(QVariant const& cookie, QByteArray const& data);

private slots:
	void onNetworkReply(QNetworkReply* reply);
	void downloadProgress(qint64 bytesReceived, qint64 bytesTotal);

public:
	NetworkProcessor(QObject* parent=NULL);
	virtual ~NetworkProcessor();

    void doRequest(QString const& uri, QVariant const& cookie=QVariant(), QVariantMap const& parameters=QVariantMap());
    void doGet(QString const& uri, QVariant const& cookie=QVariant());
	void setHeaders(QHash<QString,QString> const& headers);
};

} /* namespace canadainc */
#endif /* NETWORKPROCESSOR_H_ */
