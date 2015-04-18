#ifndef OFFLOADER_H_
#define OFFLOADER_H_

#include <QObject>
#include <QVariant>

namespace bb {
    namespace cascades {
        class DataModel;
        class GroupDataModel;
    }
}

namespace canadainc {
    class Persistance;
    class QueueDownloader;
}

namespace quran {

using namespace canadainc;

class Offloader : public QObject
{
    Q_OBJECT

    Persistance* m_persist;
    QueueDownloader* m_queue;

private slots:
    void onArchiveWritten();
    void onBookmarksRestored();
    void onBookmarksSaved();
    void onResultsDecorated();
    void onFinished(QVariant result, QVariant remember, QVariant data);

signals:
    void backupComplete(QString const& file);
    void deflationDone(QVariantMap const& cookie);
    void downloadPlugins(QVariantList const& queue);
    void restoreComplete(bool success);

public:
    Offloader(Persistance* persist, QueueDownloader* queue, QObject* parent=NULL);
    virtual ~Offloader();

    bool computeNecessaryUpdates(QVariantMap q, QByteArray const& data);
    Q_INVOKABLE bool fillType(QVariantList input, int queryId, bb::cascades::GroupDataModel* gdm);
    Q_INVOKABLE QString textualizeAyats(bb::cascades::DataModel* adm, QVariantList const& selectedIndices, QString const& chapterTitle, bool showTranslation);
    Q_INVOKABLE QVariantList decorateWebsites(QVariantList input);
    Q_INVOKABLE QVariantList normalizeJuzs(QVariantList const& source);
    Q_INVOKABLE QVariantList removeOutOfRange(QVariantList input, int fromChapter, int fromVerse, int toChapter, int toVerse);
    Q_INVOKABLE void addToHomeScreen(int chapter, int verse, QString const& label);
    Q_INVOKABLE void addToHomeScreen(qint64 suitePageId, QString const& label);
    Q_INVOKABLE void backup(QString const& destination);
    Q_INVOKABLE void decorateSearchResults(QVariantList const& input, QString const& searchText, bb::cascades::ArrayDataModel* adm, QVariantList const& additional=QVariantList());
    Q_INVOKABLE void decorateSimilarResults(QVariantList const& input, QString const& mainText, bb::cascades::ArrayDataModel* adm, bb::cascades::AbstractTextControl* atc);
    Q_INVOKABLE void decorateTafsir(bb::cascades::ArrayDataModel* adm);
    Q_INVOKABLE void renderMap(bb::cascades::maps::MapView* mapView, qreal latitude, qreal longitude, QString const& name, QString const& city, qint64 id);
    Q_INVOKABLE void restore(QString const& source);
    Q_INVOKABLE void searchGoogle(QString const& query);
    void processDownloadedPlugin(QVariantMap const& q, QByteArray const& data);
};

} /* namespace quran */

#endif /* OFFLOADER_H_ */
