#include "precompiled.h"

#include "QueryTafsirHelper.h"
#include "DatabaseHelper.h"
#include "Logger.h"
#include "QueryId.h"

namespace {

QString combine(QVariantList const& arabicIds)
{
    QStringList ids;

    foreach (QVariant const& entry, arabicIds) {
        ids << QString::number( entry.toInt() );
    }

    return ids.join(",");
}

}

namespace quran {

QueryTafsirHelper::QueryTafsirHelper(DatabaseHelper* sql) : m_sql(sql)
{
}


void QueryTafsirHelper::addQuote(QObject* caller, QString const& author, QString const& body, QString const& reference)
{
    LOGGER(author << body << reference);

    qint64 authorId = generateIndividualField(caller, author);
    QString query = QString("INSERT INTO quotes (author,body,reference) VALUES(%1,?,?)").arg(authorId);
    m_sql->executeQuery(caller, query, QueryId::AddQuote, QVariantList() << body << reference);
}


void QueryTafsirHelper::addTafsir(QObject* caller, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference)
{
    LOGGER(author << translator << explainer << title << description << reference);

    qint64 authorId = generateIndividualField(caller, author);
    qint64 translatorId = generateIndividualField(caller, translator);
    qint64 explainerId = generateIndividualField(caller, explainer);

    QString query = QString("INSERT OR IGNORE INTO suites (id,author,translator,explainer,title,description,reference) VALUES(%1,%2,%3,%4,?,?,?)").arg( QDateTime::currentMSecsSinceEpoch() ).arg(authorId).arg(translatorId).arg(explainerId);
    m_sql->executeQuery(caller, query, QueryId::AddTafsir, QVariantList() << title << description << reference);
}


void QueryTafsirHelper::editIndividual(QObject* caller, qint64 id, QString const& prefix, QString const& name, QString const& kunya, QString const& url, QString const& bio, bool hidden)
{
    LOGGER( id << prefix << name << kunya << url << bio.length() << hidden );

    QString query = QString("UPDATE individuals SET prefix=?, name=?, kunya=?, url=?, bio=?, hidden=%1 WHERE id=%2").arg(hidden ? 1 : 0).arg(id);

    QVariantList args;
    args << prefix.trimmed();
    args << name.trimmed();
    args << kunya.trimmed();
    args << url.trimmed();
    args << bio.trimmed();

    m_sql->executeQuery(caller, query, QueryId::EditIndividual, args);
}


void QueryTafsirHelper::editQuote(QObject* caller, qint64 quoteId, QString const& author, QString const& body, QString const& reference)
{
    LOGGER(quoteId << author << body << reference);

    qint64 authorId = generateIndividualField(caller, author);
    QString query = QString("UPDATE quotes SET author=%2,body=?,reference=? WHERE id=%1").arg(quoteId).arg(authorId);
    m_sql->executeQuery(caller, query, QueryId::EditQuote, QVariantList() << body << reference);
}


void QueryTafsirHelper::editTafsir(QObject* caller, qint64 suiteId, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference)
{
    LOGGER(suiteId << author << translator << explainer << title << description << reference);

    qint64 authorId = generateIndividualField(caller, author);
    qint64 translatorId = generateIndividualField(caller, translator);
    qint64 explainerId = generateIndividualField(caller, explainer);

    QString query = QString("UPDATE suites SET author=%2,translator=%3,explainer=%4,title=?,description=?,reference=? WHERE id=%1").arg(suiteId).arg(authorId).arg(translatorId).arg(explainerId);
    m_sql->executeQuery(caller, query, QueryId::EditTafsir, QVariantList() << title << description << reference);
}


void QueryTafsirHelper::fetchAllTafsir(QObject* caller)
{
    LOGGER("fetchAllTafsir");

    QString query = "SELECT suites.id AS id,individuals.name AS author,title FROM suites INNER JOIN individuals ON individuals.id=suites.author ORDER BY id DESC";
    m_sql->executeQuery(caller, query, QueryId::FetchAllTafsir);
}


qint64 QueryTafsirHelper::generateIndividualField(QObject* caller, QString const& value)
{
    static QRegExp allNumbers = QRegExp("\\d+");

    if ( allNumbers.exactMatch(value) ) {
        return value.toLongLong();
    } else {
        qint64 id = QDateTime::currentMSecsSinceEpoch();
        m_sql->executeQuery(caller, QString("INSERT INTO individuals (id,name) VALUES (%1,?)").arg(id), QueryId::AddIndividual, QVariantList() << value);
        return id;
    }
}


void QueryTafsirHelper::linkAyatToTafsir(QObject* caller, qint64 suitePageId, int chapter, int fromVerse, int toVerse)
{
    LOGGER(suitePageId << chapter << fromVerse << toVerse);
    QString query;

    if (chapter > 0)
    {
        if (fromVerse == 0) {
            query = QString("INSERT OR IGNORE INTO explanations (surah_id,suite_page_id) VALUES(%1,%2)").arg(chapter).arg(suitePageId);
        } else {
            query = QString("INSERT OR IGNORE INTO explanations (surah_id,from_verse_number,to_verse_number,suite_page_id) VALUES(%1,%2,%3,%4)").arg(chapter).arg(fromVerse).arg(toVerse).arg(suitePageId);
        }

        m_sql->executeQuery(caller, query, QueryId::LinkAyatsToTafsir);
    }
}


void QueryTafsirHelper::unlinkAyatsForTafsir(QObject* caller, QVariantList const& ids, qint64 suitePageId)
{
    LOGGER(ids << suitePageId);

    QString query = QString("DELETE FROM explanations WHERE id IN (%1) AND suite_page_id=%2").arg( combine(ids) ).arg(suitePageId);
    m_sql->executeQuery(caller, query, QueryId::UnlinkAyatsFromTafsir);
}


QueryTafsirHelper::~QueryTafsirHelper()
{
}

} /* namespace quran */
