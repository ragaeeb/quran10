#ifndef RECITATIONHELPER_H_
#define RECITATIONHELPER_H_

#include "QueueDownloader.h"

#include <QFutureWatcher>

#include <bb/cascades/Page>

#define KEY_RECITER "qaree"

namespace bb {
    namespace cascades {
        class ArrayDataModel;
    }
}

namespace canadainc {
    class Persistance;
}

namespace quran {

using namespace canadainc;

class RecitationHelper : public QObject
{
    Q_OBJECT

    Persistance* m_persistance;
    QFutureWatcher<QVariantMap> m_futureResult;
    QMap< QPair<int,int>, int > m_ayatToIndex;
    QString m_anchor;
    QueueDownloader* m_queue;
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

    Q_INVOKABLE int extractIndex(QVariantMap const& m);
    Q_INVOKABLE void downloadAndPlay(int chapter, int verse);
    Q_INVOKABLE void downloadAndPlayTajweed(int chapter, int verse);
    Q_INVOKABLE void downloadAndPlayAll(bb::cascades::ArrayDataModel* adm, int from=0, int to=-1);
    Q_INVOKABLE void memorize(bb::cascades::ArrayDataModel* adm, int from, int to);
    Q_INVOKABLE bool tajweedAvailable(int chapter, int verse);
};

} /* namespace quran */

#endif /* RECITATIONHELPER_H_ */
