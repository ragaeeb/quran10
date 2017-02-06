#ifndef OFFLOADER_H_
#define OFFLOADER_H_

#include <QObject>
#include <QVariant>

namespace bb {
    namespace cascades {
        class DataModel;
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

signals:
    void deflationDone(QVariantMap const& cookie);
    void downloadPlugins(QVariantList const& queue);

public:
    Offloader(Persistance* persist, QueueDownloader* queue, QObject* parent=NULL);
    virtual ~Offloader();

    Q_INVOKABLE QString textualizeAyats(bb::cascades::DataModel* adm, QVariantList const& selectedIndices, QString const& chapterTitle, bool showTranslation);
    Q_INVOKABLE QVariantList normalizeJuzs(QVariantList const& source);
    Q_INVOKABLE QVariantList removeOutOfRange(QVariantList input, int fromChapter, int fromVerse, int toChapter, int toVerse);
    Q_INVOKABLE void addToHomeScreen(int chapter, int verse, QString const& label);
    Q_INVOKABLE void addToHomeScreen(qint64 suitePageId, QString const& label);
    Q_INVOKABLE void decorateTafsir(bb::cascades::ArrayDataModel* adm, QString const& defaultImage="images/list/ic_tafsir.png");
};

} /* namespace quran */

#endif /* OFFLOADER_H_ */
