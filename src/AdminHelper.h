#ifndef ADMINHELPER_H_
#define ADMINHELPER_H_

#include "NetworkProcessor.h"

namespace canadainc {
    class NetworkProcessor;
    class Persistance;
}

#define PLUGINS_ZIPPED_PATH QString("%1/plugins.zip").arg( QDir::tempPath() )

namespace quran {

using namespace canadainc;

class QueryHelper;

class AdminHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool pendingUpdates READ pendingUpdates NOTIFY pendingUpdatesChanged)

    NetworkProcessor m_network;
    Persistance* m_persist;
    QueryHelper* m_helper;
    qint64 m_lastUpdate;
    QSet<int> m_interested;
    QStringList m_chapters;

    void prepare();

private slots:
    void onAboutToQuit();
    void onCaptureCompleted();
    void onCompressed();
    void onDataLoaded(QVariant id, QVariant data);
    void onExecuted(int id);
    void onRequestComplete(QVariant const& cookie, QByteArray const& data, bool error);
    void uploadUpdates();

signals:
    void compressed();
    void compressing();
    void ayatsCaptured(QVariantList const& result);
    void pendingUpdatesChanged();
    void uploadProgress(QVariant const& cookie, qint64 bytesSent, qint64 bytesTotal);

public:
    AdminHelper(Persistance* persist, QueryHelper* helper);
    virtual ~AdminHelper();

    Q_SLOT void downloadPlugins(bool force=true, QString const& cookie="plugins");
    Q_INVOKABLE void initPage(QObject* page);
    Q_INVOKABLE void doDiff(QVariantList const& input, bb::cascades::ArrayDataModel* adm, QString const& key="id");
    Q_INVOKABLE void analyzeKingFahadFrench(QString text);
    bool pendingUpdates();
    Q_INVOKABLE void captureAyats(QString const& body);
    Q_SLOT void lazyInit();
};

} /* namespace sunnah */

#endif /* ADMINHELPER_H_ */
