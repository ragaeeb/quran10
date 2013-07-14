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
	Q_PROPERTY(bool mushafReady READ mushafReady NOTIFY mushafReadyChanged)

	QueueDownloader m_queue;
	QueueDownloader m_mushafQueue;
	LazySceneCover m_sceneCover;
	Persistance m_persistance;

    ApplicationUI(bb::cascades::Application *app);
    QStringList getMissingFiles(QStringList const& playlist);

signals:
	void mushafReadyChanged();
	void mushafPageReady(QString const& imageSource);

private slots:
	void onRequestComplete(QVariant const& cookie, QByteArray const& data);
	void onPageDownloaded(QVariant const& cookie, QByteArray const& data);

public:
	static void create(bb::cascades::Application* app);
    virtual ~ApplicationUI();

    Q_INVOKABLE void downloadChapter(int chapter, int numVerses);
    Q_INVOKABLE QStringList generatePlaylist(int chapter, int fromVerse, int toVerse);
    Q_INVOKABLE void bookmarkVerse(QString const& surahName, int surahNumber, QVariantMap const& verseData);
    Q_INVOKABLE void downloadMushaf();
    Q_INVOKABLE static QStringList getMushafPages();
    Q_INVOKABLE static QStringList getDownloadedMushafPages();
    bool mushafReady() const;
};

} // quran

#endif /* ApplicationUI_HPP_ */
