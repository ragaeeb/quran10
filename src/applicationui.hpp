#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include "LazySceneCover.h"
#include "MushafHelper.h"
#include "Persistance.h"
#include "QueryHelper.h"
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
	MushafHelper m_mushaf;
	RecitationHelper m_recitation;
	int m_verseId;

    ApplicationUI(bb::cascades::Application *app);
    QObject* init(QString const& qml, bool invoked=false);
    void finishWithToast(QString const& message);

private slots:
    void childCardDone(bb::system::CardDoneMessage const& message=bb::system::CardDoneMessage());
	void invoked(bb::system::InvokeRequest const& request);
	void lazyInit();
	void onDataLoaded(QVariant id, QVariant data);

signals:
    void initialize();

public:
	static void create(bb::cascades::Application* app);
    virtual ~ApplicationUI();

    Q_INVOKABLE void bookmarkVerse(QString const& surahName, int surahNumber, QVariantMap const& verseData);
    Q_INVOKABLE void addToHomeScreen(int chapter, int verse, QString const& label);
};

} // quran

#endif /* ApplicationUI_HPP_ */
