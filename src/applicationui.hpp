#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include "AdminHelper.h"
#include "LazySceneCover.h"
#include "MushafHelper.h"
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
    void onArchiveWritten();
    void onBookmarksRestored();
	void onBookmarksSaved();
	void onDataLoaded(QVariant id, QVariant data);
	void onMissingAyatImagesFinished();
	void onPicked(int chapter, int verse);
	void onResultsDecorated();
    void onTafsirDownloaded(QVariant const& cookie, QByteArray const& data);
    void onTafsirMissing(QString const& tafsirName);
    void onTranslationMissing(QString const& language);

signals:
    void backupComplete(QString const& file);
    void deflationDone(bool success, QString const& error);
    void archiveDeflationProgress(qint64 current, qint64 total);
    void initialize();
    void lazyInitComplete();
    void restoreComplete(bool success);

public:
	static void create(bb::cascades::Application* app);
    virtual ~ApplicationUI();

    Q_INVOKABLE void addToHomeScreen(int chapter, int verse, QString const& label);
    Q_INVOKABLE void addToHomeScreen(qint64 suitePageId, QString const& label);
    Q_INVOKABLE void backup(QString const& destination);
    Q_SLOT void checkMissingAyatImages();
    Q_INVOKABLE void restore(QString const& source);
    Q_INVOKABLE void decorateSearchResults(QVariantList const& input, QString const& searchText, bb::cascades::ArrayDataModel* adm, QVariantList const& additional=QVariantList());
    Q_INVOKABLE void decorateSimilarResults(QVariantList const& input, QString const& mainText, bb::cascades::ArrayDataModel* adm, bb::cascades::AbstractTextControl* atc);
    Q_INVOKABLE void decorateTafsir(bb::cascades::ArrayDataModel* adm);
    Q_INVOKABLE QString bytesToSize(qint64 size);
    Q_INVOKABLE qint64 getFreeSpace();
};

} // quran

#endif /* ApplicationUI_HPP_ */
