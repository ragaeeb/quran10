#ifndef INVOKEHELPER_H_
#define INVOKEHELPER_H_

#include <QObject>

#include <bb/system/InvokeRequest>

namespace bb {
    namespace system {
        class InvokeManager;
    }
}

namespace quran {

using namespace quran;
using namespace bb::system;

class QueryHelper;

class InvokeHelper : public QObject
{
    Q_OBJECT

    bb::system::InvokeRequest m_request;
    QObject* m_root;
    InvokeManager* m_invokeManager;
    QueryHelper* m_helper;
    QMap<QString, int> m_chapters;

    void finishWithToast(QString const& message);

private slots:
    void onChapterMatched();
    void onDataLoaded(QVariant id, QVariant data);
    void onDatabasePorted();
    void onPicked(int chapter, int verse);
    void onSearchPicked(int chapter, int verse);

public:
    InvokeHelper(InvokeManager* invokeManager, QueryHelper* helper);
    virtual ~InvokeHelper();

    void init(QString const& qmlDoc, QMap<QString, QObject*> const& context, QObject* parent);
    QString invoked(bb::system::InvokeRequest const& request);
    void process();
    QMap<QString, int> getChapterNames();
};

} /* namespace admin */

#endif /* INVOKEHELPER_H_ */
