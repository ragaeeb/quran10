#include "precompiled.h"

#include "QueryTafsirHelper.h"
#include "DatabaseHelper.h"
#include "Logger.h"
#include "QueryId.h"
#include "TextUtils.h"

namespace {

QString combine(QVariantList const& arabicIds)
{
    QStringList ids;

    foreach (QVariant const& entry, arabicIds) {
        ids << QString::number( entry.toInt() );
    }

    return ids.join(",");
}

QVariant protect(QString const& a) {
    return a.isEmpty() ? QVariant() : a;
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

    QStringList fields = QStringList() << "id" << "author" << "title" << "description" << "reference";
    QVariantList args = QVariantList() << QDateTime::currentMSecsSinceEpoch() << generateIndividualField(caller, author) << title << protect(description) << reference;

    if ( !translator.isEmpty() ) {
        fields << "translator";
        args << generateIndividualField(caller, translator);
    }

    if ( !explainer.isEmpty() ) {
        fields << "explainer";
        args << generateIndividualField(caller, explainer);
    }

    QString query = QString("INSERT OR IGNORE INTO suites (%1) VALUES(%2)").arg( fields.join(",") ).arg( TextUtils::getPlaceHolders( args.size(), false ) );
    m_sql->executeQuery(caller, query, QueryId::AddTafsir, args);
}


void QueryTafsirHelper::editTafsir(QObject* caller, qint64 suiteId, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference)
{
    LOGGER(suiteId << author << translator << explainer << title << description << reference);

    QStringList fields = QStringList() << "author=?" << "title=?" << "description=?" << "reference=?" << "translator=?" << "explainer=?";
    QVariantList args = QVariantList() << generateIndividualField(caller, author);
    args << title;
    args << protect(description);
    args << reference;

    if ( translator.isEmpty() ) {
        args << QVariant();
    } else {
        args << generateIndividualField(caller, translator);
    }

    if ( explainer.isEmpty() ) {
        args << QVariant();
    } else {
        args << generateIndividualField(caller, explainer);
    }

    QString query = QString("UPDATE suites SET %2 WHERE id=%1").arg(suiteId).arg( fields.join(",") );
    m_sql->executeQuery(caller, query, QueryId::EditTafsir, args);
}


void QueryTafsirHelper::editIndividual(QObject* caller, qint64 id, QString const& prefix, QString const& name, QString const& kunya, QString const& url, QString const& bio, bool hidden)
{
    LOGGER( id << prefix << name << kunya << url << bio.length() << hidden );

    QString query = QString("UPDATE individuals SET prefix=?, name=?, kunya=?, uri=?, biography=?, hidden=%1 WHERE id=%2").arg(hidden ? 1 : 0).arg(id);

    QVariantList args;
    args << protect(prefix);
    args << name;
    args << protect(kunya);
    args << protect(url);
    args << protect(bio);

    m_sql->executeQuery(caller, query, QueryId::EditIndividual, args);
}


void QueryTafsirHelper::editQuote(QObject* caller, qint64 quoteId, QString const& author, QString const& body, QString const& reference)
{
    LOGGER(quoteId << author << body << reference);

    qint64 authorId = generateIndividualField(caller, author);
    QString query = QString("UPDATE quotes SET author=%2,body=?,reference=? WHERE id=%1").arg(quoteId).arg(authorId);
    m_sql->executeQuery(caller, query, QueryId::EditQuote, QVariantList() << body << reference);
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
