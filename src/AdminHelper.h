#ifndef ADMINHELPER_H_
#define ADMINHELPER_H_

#include <QObject>

namespace canadainc {
    class NetworkProcessor;
    class Persistance;
}

#define PLUGINS_ZIPPED_PATH QString("%1/plugins.zip").arg( QDir::tempPath() )

namespace sunnah {

using namespace canadainc;

class AdminHelper : public QObject
{
    Q_OBJECT

    NetworkProcessor* m_network;
    Persistance* m_persist;

    void prepare(QString const& remoteFunc);

private slots:
    void onCompressed();
    void submitUpdates();
    void uploadUpdates();

public:
    AdminHelper(NetworkProcessor* network, Persistance* persist);
    virtual ~AdminHelper();

    Q_SLOT void downloadPlugins(bool force=true, QString const& cookie="plugins");
    Q_INVOKABLE void initPage(QObject* page);
};

} /* namespace sunnah */

#endif /* ADMINHELPER_H_ */
