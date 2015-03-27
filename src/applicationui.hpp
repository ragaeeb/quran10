#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include "AdminHelper.h"
#include "LazySceneCover.h"
#include "MushafHelper.h"
#include "Offloader.h"
#include "Persistance.h"
#include "QueryHelper.h"
#include "QueueDownloader.h"
#include "RecitationHelper.h"

#include <bb/system/CardDoneMessage>
#include <bb/system/InvokeManager>

namespace bb {
	namespace cascades {
		class Application;
	}
}

namespace quran {

using namespace canadainc;

class ApplicationUI : public QObject
{
	Q_OBJECT

	bb::system::InvokeManager m_invokeManager;
	LazySceneCover m_sceneCover;
	Persistance m_persistance;
	QueryHelper m_helper;
	bb::system::InvokeRequest m_request;
	QObject* m_root;
	QueueDownloader m_queue;
    MushafHelper m_mushaf;
    RecitationHelper m_recitation;
    AdminHelper m_admin;
    Offloader m_offloader;

    ApplicationUI(bb::cascades::Application *app);
    void init(QString const& qml);
    void finishWithToast(QString const& message);
    void processInvoke();
    void initGlobals();
    void complain(QString const& message);

private slots:
    void childCardDone(bb::system::CardDoneMessage const& message=bb::system::CardDoneMessage());
	void invoked(bb::system::InvokeRequest const& request);
	void lazyInit();
	void onDataLoaded(QVariant id, QVariant data);
	void onMissingAyatImagesFinished();
	void onPicked(int chapter, int verse);
    void onRequestComplete(QVariant const& cookie, QByteArray const& data);
    void onUpdateCheckNeeded(QVariantMap const& params);

signals:
    void childCardFinished(QString const& message);
    void archiveDeflationProgress(qint64 current, qint64 total);
    void initialize();
    void lazyInitComplete();

public:
	static void create(bb::cascades::Application* app);
    virtual ~ApplicationUI();

    Q_SLOT void checkMissingAyatImages();
};

} // quran

#endif /* ApplicationUI_HPP_ */
