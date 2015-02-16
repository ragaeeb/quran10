#ifndef QUERYTAFSIRHELPER_H_
#define QUERYTAFSIRHELPER_H_

#include <QObject>
#include <QVariant>

namespace canadainc {
    class DatabaseHelper;
}

namespace quran {

using namespace canadainc;

class QueryTafsirHelper
{
    DatabaseHelper* m_sql;

    qint64 generateIndividualField(QObject* caller, QString const& value);
    void populateTafsirFields(QObject* caller, QStringList& fields, QVariantList& args, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference);

public:
    QueryTafsirHelper(DatabaseHelper* sql);
    virtual ~QueryTafsirHelper();

    void addQuote(QObject* caller, QString const& author, QString const& body, QString const& reference);
    void addTafsir(QObject* caller, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference);
    void editIndividual(QObject* caller, qint64 id, QString const& prefix, QString const& name, QString const& kunya, QString const& url, QString const& bio, bool hidden);
    void editQuote(QObject* caller, qint64 quoteId, QString const& author, QString const& body, QString const& reference);
    void editTafsir(QObject* caller, qint64 suiteId, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference);
    void fetchAllTafsir(QObject* caller);
    void linkAyatToTafsir(QObject* caller, qint64 suitePageId, int chapter, int fromVerse, int toVerse);
    void unlinkAyatsForTafsir(QObject* caller, QVariantList const& ids, qint64 suitePageId);
};

} /* namespace quran */

#endif /* QUERYTAFSIRHELPER_H_ */
