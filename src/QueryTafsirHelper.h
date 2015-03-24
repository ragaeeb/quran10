#ifndef QUERYTAFSIRHELPER_H_
#define QUERYTAFSIRHELPER_H_

#include <QObject>
#include <QVariant>

#include "QueryId.h"

namespace canadainc {
    class DatabaseHelper;
}

namespace quran {

using namespace canadainc;

class QueryTafsirHelper
{
    DatabaseHelper* m_sql;

    qint64 generateIndividualField(QObject* caller, QString const& value);

public:
    QueryTafsirHelper(DatabaseHelper* sql);
    virtual ~QueryTafsirHelper();

    void addQuote(QObject* caller, QString const& author, QString const& body, QString const& reference);
    void addTafsir(QObject* caller, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference);
    void createIndividual(QObject* caller, QString const& prefix, QString const& name, QString const& kunya, QString const& url, QString const& bio, int birth, int death);
    void editIndividual(QObject* caller, qint64 id, QString const& prefix, QString const& name, QString const& kunya, QString const& url, QString const& bio, bool hidden, int birth, int death, bool female);
    void editQuote(QObject* caller, qint64 quoteId, QString const& author, QString const& body, QString const& reference);
    void editTafsir(QObject* caller, qint64 suiteId, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference);
    void fetchAllTafsir(QObject* caller, qint64 individualId);
    void linkAyatToTafsir(QObject* caller, qint64 suitePageId, int chapter, int fromVerse, int toVerse, QueryId::Type linkId=QueryId::LinkAyatsToTafsir);
    void searchQuote(QObject* caller, QString const& fieldName, QString const& searchTerm);
    void searchTafsir(QObject* caller, QString const& fieldName, QString const& searchTerm);
    void unlinkAyatsForTafsir(QObject* caller, QVariantList const& ids, qint64 suitePageId);
};

} /* namespace quran */

#endif /* QUERYTAFSIRHELPER_H_ */
