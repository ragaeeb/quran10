#ifndef MUSHAFHELPER_H_
#define MUSHAFHELPER_H_

#include "TicketManager.h"

namespace canadainc {
    class QueueDownloader;
    class Persistance;
}

#define KEY_MUSHAF_STYLE "mushafStyle"

namespace quran {

using namespace canadainc;
using namespace bb::cascades;

class MushafHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool stretchMushaf READ stretchMushaf WRITE setStretchMushaf NOTIFY stretchMushafChanged)
    Q_PROPERTY(QString mushafStyle READ mushafStyle WRITE setMushafStyle NOTIFY mushafStyleChanged)
    Q_PROPERTY(bool keepAwake READ keepAwake WRITE setKeepAwake NOTIFY keepAwakeChanged)
    Q_PROPERTY(bool active READ active WRITE setActive FINAL)
    Q_PROPERTY(bool isTopPage READ isTopPage WRITE setIsTopPage FINAL)

    QueueDownloader* m_mushafQueue;
    Persistance* m_persist;
    bool m_stretch;
    QString m_style;
    QMap<QString, QVariantMap> m_cached;
    bool m_active;
    bool m_keepAwake;
    bool m_isTopPage;
    TicketManager m_tickets;

private slots:
    void onActiveChanged();
    void onDestroyed(QObject* obj);
    void onMissingPagesFound();
    void onPageDownloaded(QVariant const& cookie, QByteArray const& data);
    void onWritten();
    void refresh();

signals:
    void keepAwakeChanged();
    void mushafPageReady(QVariant const& imageSource);
    void mushafStyleChanged();
    void stretchMushafChanged();

public:
    MushafHelper(QueueDownloader* mushafQueue, Persistance* persist, QObject* parent=NULL);
    virtual ~MushafHelper();

    bool stretchMushaf() const;
    Q_INVOKABLE void requestAllAyatImages(QVariantList ayats);
    Q_SLOT void requestEntireMushaf();
    Q_INVOKABLE void requestPage(int page);
    Q_INVOKABLE void requestAyat(QObject* caller, int chapter, int verse);
    QString mushafStyle() const;
    void setMushafStyle(QString const& mushafStyle);
    void setStretchMushaf(bool stretch);
    Q_INVOKABLE void registerPlayer(QObject* p);
    bool active() const;
    bool keepAwake() const;
    void setActive(bool value);
    void setKeepAwake(bool value);
    bool isTopPage() const;
    void setIsTopPage(bool value);
    void lazyInit();
    QString ayatImageFolder();
};

} /* namespace quran */

#endif /* MUSHAFHELPER_H_ */
