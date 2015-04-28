#ifndef ALLTESTS_H_
#define ALLTESTS_H_

#include <QObject>

#include "Persistance.h"
#include "QueryHelper.h"

namespace quran {

using namespace canadainc;

class AllTests : public QObject
{
    Q_OBJECT

    Persistance m_persist;
    QueryHelper m_db;

private slots:
    void onDataLoaded(QVariant id, QVariant data)
    {

    }

public:
    AllTests() : m_db(&m_persist)
    {

    }

    virtual ~AllTests() {}
};

} /* namespace quran */

#endif /* ALLTESTS_H_ */
