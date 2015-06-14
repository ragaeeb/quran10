#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include "InvokeHelper.h"
#include "LazySceneCover.h"
#include "LocaleUtil.h"
#include "MushafHelper.h"
#include "Offloader.h"
#include "Persistance.h"
#include "QueryHelper.h"
#include "QueueDownloader.h"
#include "RecitationHelper.h"

#include <bb/system/CardDoneMessage>

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

	LocaleUtil m_locale;
	LazySceneCover m_sceneCover;
	Persistance m_persistance;
	QueryHelper m_helper;
	bb::system::InvokeRequest m_request;
	QueueDownloader m_queue;
    MushafHelper m_mushaf;
    RecitationHelper m_recitation;
    Offloader m_offloader;
    InvokeHelper m_invoke;

    void init(QString const& qml);

private slots:
    void childCardDone(bb::system::CardDoneMessage const& message=bb::system::CardDoneMessage());
	void invoked(bb::system::InvokeRequest const& request);
	void lazyInit();
	void onCaptureCompleted();
	void onDataLoaded(QVariant id, QVariant data);
	void onMissingAyatImagesFinished();
    void onRequestComplete(QVariant const& cookie, QByteArray const& data);
    void onUpdateCheckNeeded(QVariantMap const& params);
    void onDeflationDone(QVariantMap const& m);
    void onDownloadPlugins(QVariantList const& m);

signals:
    void ayatsCaptured(QVariantList const& result);
    void childCardFinished(QString const& message);
    void initialize();
    void lazyInitComplete();

public:
    ApplicationUI(bb::system::InvokeManager* im);
    virtual ~ApplicationUI();

    Q_SLOT void checkMissingAyatImages();
};

} // quran

#endif /* ApplicationUI_HPP_ */
