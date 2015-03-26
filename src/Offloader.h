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
}

namespace quran {

using namespace canadainc;

class Offloader : public QObject
{
    Q_OBJECT

    Persistance* m_persist;

private slots:
    void onBookmarksRestored();
    void onBookmarksSaved();
    void onResultsDecorated();

signals:
    void backupComplete(QString const& file);
    void restoreComplete(bool success);

public:
    Offloader(Persistance* persist, QObject* parent=NULL);
    virtual ~Offloader();

    Q_INVOKABLE void addToHomeScreen(int chapter, int verse, QString const& label);
    Q_INVOKABLE void addToHomeScreen(qint64 suitePageId, QString const& label);
    Q_INVOKABLE void backup(QString const& destination);
    Q_INVOKABLE void decorateSearchResults(QVariantList const& input, QString const& searchText, bb::cascades::ArrayDataModel* adm, QVariantList const& additional=QVariantList());
    Q_INVOKABLE void decorateSimilarResults(QVariantList const& input, QString const& mainText, bb::cascades::ArrayDataModel* adm, bb::cascades::AbstractTextControl* atc);
    Q_INVOKABLE void decorateTafsir(bb::cascades::ArrayDataModel* adm);
    Q_INVOKABLE qint64 getFreeSpace();
    Q_INVOKABLE void restore(QString const& source);
    Q_INVOKABLE QString textualizeAyats(bb::cascades::DataModel* adm, QVariantList const& selectedIndices, QString const& chapterTitle, bool showTranslation);
};

} /* namespace quran */

#endif /* OFFLOADER_H_ */
