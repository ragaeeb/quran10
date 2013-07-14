#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include "LazySceneCover.h"
#include "Persistance.h"
#include "QueueDownloader.h"

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

	QueueDownloader m_queue;
	LazySceneCover m_sceneCover;
	Persistance m_persistance;

    ApplicationUI(bb::cascades::Application *app);
    QStringList getMissingFiles(QStringList const& playlist);

private slots:
	void onRequestComplete(QVariant const& cookie, QByteArray const& data);

public:
	static void create(bb::cascades::Application* app);
    virtual ~ApplicationUI();

    Q_INVOKABLE void downloadChapter(int chapter, int numVerses);
    Q_INVOKABLE QStringList generatePlaylist(int chapter, int fromVerse, int toVerse);
    Q_INVOKABLE void bookmarkVerse(QString const& surahName, int surahNumber, QVariantMap const& verseData);
};

} // quran

#endif /* ApplicationUI_HPP_ */
