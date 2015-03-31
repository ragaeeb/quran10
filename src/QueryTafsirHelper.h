#ifndef QUERYTAFSIRHELPER_H_
#define QUERYTAFSIRHELPER_H_

#include <QObject>
#include <QVariant>

#include "QueryId.h"

#define CHAPTER_KEY "chapter"
#define FROM_VERSE_KEY "fromVerse"
#define TO_VERSE_KEY "toVerse"

namespace canadainc {
    class DatabaseHelper;
}

namespace quran {

using namespace canadainc;

class QueryTafsirHelper : public QObject
{
    Q_OBJECT

    DatabaseHelper* m_sql;

    qint64 generateIndividualField(QObject* caller, QString const& value);

public:
    QueryTafsirHelper(DatabaseHelper* sql);
    virtual ~QueryTafsirHelper();

    Q_INVOKABLE void addCompanions(QObject* caller, QVariantList const& ids);
    Q_INVOKABLE void addQuote(QObject* caller, QString const& author, QString const& body, QString const& reference);
    Q_INVOKABLE bool addWebsite(QObject* caller, qint64 individualId, QString const& address);
    Q_INVOKABLE void addTafsir(QObject* caller, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference);
    Q_INVOKABLE void addTafsirPage(QObject* caller, qint64 suiteId, QString const& body, QString const& heading);
    Q_INVOKABLE void createIndividual(QObject* caller, QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, int birth, int death);
    Q_INVOKABLE void editIndividual(QObject* caller, qint64 id, QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female);
    Q_INVOKABLE void editQuote(QObject* caller, qint64 quoteId, QString const& author, QString const& body, QString const& reference);
    Q_INVOKABLE void editTafsir(QObject* caller, qint64 suiteId, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference);
    Q_INVOKABLE void editTafsirPage(QObject* caller, qint64 suitePageId, QString const& body, QString const& heading);
    Q_INVOKABLE void fetchAllIndividuals(QObject* caller);
    Q_INVOKABLE void fetchAllWebsites(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchFrequentIndividuals(QObject* caller, int n=7);
    void fetchAllTafsir(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchTafsirMetadata(QObject* caller, qint64 suiteId);
    Q_INVOKABLE void fetchIndividualData(QObject* caller, qint64 individualId);
    Q_INVOKABLE void linkAyatToTafsir(QObject* caller, qint64 suitePageId, int chapter, int fromVerse, int toVerse, QueryId::Type linkId=QueryId::LinkAyatsToTafsir);
    Q_INVOKABLE void linkAyatsToTafsir(QObject* caller, qint64 suitePageId, QVariantList const& chapterVerseData);
    Q_INVOKABLE void removeCompanions(QObject* caller, QVariantList const& ids);
    Q_INVOKABLE void removeIndividual(QObject* caller, qint64 id);
    Q_INVOKABLE void removeQuote(QObject* caller, qint64 id);
    Q_INVOKABLE void removeWebsite(QObject* caller, qint64 id);
    Q_INVOKABLE void removeTafsir(QObject* caller, qint64 suiteId);
    Q_INVOKABLE void removeTafsirPage(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void replaceIndividual(QObject* caller, qint64 toReplaceId, qint64 actualId);
    Q_INVOKABLE void searchIndividuals(QObject* caller, QString const& trimmedText);
    Q_INVOKABLE void searchQuote(QObject* caller, QString const& fieldName, QString const& searchTerm);
    Q_INVOKABLE void searchTafsir(QObject* caller, QString const& fieldName, QString const& searchTerm);
    Q_INVOKABLE void unlinkAyatsForTafsir(QObject* caller, QVariantList const& ids, qint64 suitePageId);
    Q_INVOKABLE void updateTafsirLink(QObject* caller, qint64 explanationId, int surahId, int fromVerse, int toVerse);
};

} /* namespace quran */

#endif /* QUERYTAFSIRHELPER_H_ */
