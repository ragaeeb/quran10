#ifndef CANADINCTESTER_H_
#define CANADINCTESTER_H_

#include <bb/cascades/ListItemProvider>
#include <bb/cascades/ListView>
#include <bb/cascades/Page>
#include <bb/cascades/Sheet>
#include <bb/cascades/StandardListItem>
#include <bb/cascades/TitleBar>

#include "Logger.h"

namespace canadainc {

using namespace bb::cascades;

class TestResultListItemProvider : public ListItemProvider
{
    VisualNode* createItem(ListView* list, QString const& type)
    {
        Q_UNUSED(list);
        Q_UNUSED(type);

        return new StandardListItem();
    }


    void updateItem(ListView* list, VisualNode* control, QString const& type, QVariantList const& indexPath, QVariant const& d)
    {
        Q_UNUSED(list);
        Q_UNUSED(indexPath);
        Q_UNUSED(type);

        QVariantMap data = d.toMap();

        StandardListItem* h = static_cast<StandardListItem*>(control);
        h->setTitle( data.value("title").toString() );

        if ( data.contains("passed") )
        {
            bool passed = data.value("passed").toBool();
            h->setImageSource(passed ? QUrl("asset:///images/bugs/ic_bugs_submit.png") : QUrl("asset:///images/bugs/ic_bugs_cancel.png"));
            h->setStatus(passed ? "Passed" : "Failed!");
        } else {
            h->setImageSource(QUrl("asset:///images/menu/ic_help.png"));
            h->resetStatus();
        }

        if ( data.contains("t") ) {
            h->setDescription( QString("%1 ms").arg( data.value("t").toLongLong() ) );
        } else {
            h->resetDescription();
        }
    }
};

class CanadaIncTester : public QObject
{
    Q_OBJECT

    QMap<QString, int> m_testToIndex;
    ArrayDataModel* m_adm;
    QMap<QString, QElapsedTimer*> m_timers;

    CanadaIncTester(QMap<QString, QObject*> context)
    {
        QmlDocument* qml = QmlDocument::create("asset:///AllTests.qml").parent(this);
        qml->setContextProperty("harness", this);

        foreach ( QString const& key, context.keys() ) {
            qml->setContextProperty( key, context.value(key) );
        }

        QObject* tests = qml->createRootObject<QObject>();
        QObjectList all = tests->children();
        m_adm = new ArrayDataModel();

        for (int i = 0; i < all.size(); i++)
        {
            QString name = all[i]->objectName();
            m_testToIndex[name] = i;

            QVariantMap current;
            current["title"] = name;

            m_adm->append(current);
        }

        ListView* lv = ListView::create();
        lv->setListItemProvider( new TestResultListItemProvider() );
        lv->setDataModel(m_adm);

        Sheet* s = Sheet::create().parent(this);

        Page* p = Page::create().titleBar( TitleBar::create().dismissAction( ActionItem::create().title("Close").onTriggered( s, SLOT( close() ) ) ) );
        p->setContent(lv);
        s->setContent(p);

        s->open();
    }

public:
    Q_INVOKABLE void init(QObject* q)
    {
        QElapsedTimer* qet = new QElapsedTimer();
        qet->start();

        m_timers[ q->objectName() ] = qet;
    }


    Q_INVOKABLE void update(QObject* q, bool passed)
    {
        QString name = q->objectName();
        int i = m_testToIndex[name];

        QVariantMap current = m_adm->value(i).toMap();
        current["passed"] = passed;

        if ( m_timers.contains(name) )
        {
            QElapsedTimer* qet = m_timers.value(name);
            current["t"] = qet->elapsed();

            delete qet;
            m_timers.remove(name);
        }

        m_adm->replace(i, current);
    }


    static void create(QMap<QString, QObject*> context) {
        new CanadaIncTester(context);
    }

    virtual ~CanadaIncTester() {}
};

} /* namespace canadainc */

#endif /* CANADINCTESTER_H_ */
