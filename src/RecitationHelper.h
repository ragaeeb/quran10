#ifndef RECITATIONHELPER_H_
#define RECITATIONHELPER_H_

#include "QueueDownloader.h"

#include <QFutureWatcher>

namespace canadainc {
    class Persistance;
}

namespace bb {
    namespace cascades {
        class ArrayDataModel;
    }
}

namespace quran {

using namespace canadainc;

class RecitationHelper : public QObject
{
    Q_OBJECT

    QueueDownloader* m_queue;
    Persistance* m_persistance;
    QFutureWatcher<QVariantMap> m_futureResult;
    QString m_anchor;
    QMap< QPair<int,int>, int > m_ayatToIndex;
    QUrl m_playlistUrl;

    void startPlayback();

private slots:
    void onPlaylistReady();
    void onRequestComplete(QVariant const& cookie, QByteArray const& data);
    void onWritten();

signals:
    void readyToPlay(QUrl const& uri);

public:
    RecitationHelper(QueueDownloader* queue, Persistance* p, QObject* parent=NULL);
    virtual ~RecitationHelper();

    /**
     * @pre The directory must have been set up.
     */
    Q_INVOKABLE void downloadAndPlay(int chapter, int verse);
    Q_INVOKABLE void downloadAndPlayAll(bb::cascades::ArrayDataModel* adm, int from=0, int to=-1);
    Q_INVOKABLE void memorize(bb::cascades::ArrayDataModel* adm, int from, int to);
    Q_INVOKABLE int extractIndex(QVariantMap const& m);
    Q_INVOKABLE bool isDownloaded(int chapter, int verse);
};

} /* namespace quran */

#endif /* RECITATIONHELPER_H_ */
