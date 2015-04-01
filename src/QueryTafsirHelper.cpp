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


void QueryTafsirHelper::addCompanions(QObject* caller, QVariantList const& ids)
{
    LOGGER(ids);

    m_sql->executeQuery(caller, QString("INSERT OR IGNORE INTO companions VALUES(%1)").arg( TextUtils::getPlaceHolders( ids.size() ) ), QueryId::AddCompanions, ids);
}


bool QueryTafsirHelper::addWebsite(QObject* caller, qint64 individualId, QString const& address)
{
    QUrl uri(address);

    if ( uri.isValid() )
    {
        QString query = QString("INSERT INTO websites (individual,uri) VALUES(%1,?)").arg(individualId);
        m_sql->executeQuery(caller, query, QueryId::AddWebsite, QVariantList() << address);
        return true;
    } else {
        return false;
    }
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


void QueryTafsirHelper::addTafsirPage(QObject* caller, qint64 suiteId, QString const& body, QString const& heading)
{
    LOGGER( suiteId << body.length() );

    QString query = QString("INSERT OR IGNORE INTO suite_pages (id,suite_id,body,heading) VALUES(%1,%2,?,?)").arg( QDateTime::currentMSecsSinceEpoch() ).arg(suiteId);
    m_sql->executeQuery(caller, query, QueryId::AddTafsirPage, QVariantList() << body << ( heading.isEmpty() ? QVariant() : heading ) );
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


void QueryTafsirHelper::editTafsirPage(QObject* caller, qint64 suitePageId, QString const& body, QString const& heading)
{
    LOGGER( suitePageId << body.length() << heading );

    QString query = QString("UPDATE suite_pages SET body=?, heading=? WHERE id=%1").arg(suitePageId);
    m_sql->executeQuery( caller, query, QueryId::EditTafsirPage, QVariantList() << body << ( heading.isEmpty() ? QVariant() : heading ) );
}


void QueryTafsirHelper::editIndividual(QObject* caller, qint64 id, QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female)
{
    LOGGER( id << prefix << name << kunya << displayName << hidden << birth << death << female );

    QString query = QString("UPDATE individuals SET prefix=?, name=?, kunya=?, displayName=?, hidden=%1, birth=?, death=?, female=%3 WHERE id=%2").arg(hidden ? 1 : 0).arg(id).arg(female ? 1 : 0);

    QVariantList args;
    args << protect(prefix);
    args << name;
    args << protect(kunya);
    args << protect(displayName);
    args << ( birth > 0 ? birth : QVariant() );
    args << ( death > 0 ? death : QVariant() );

    m_sql->executeQuery(caller, query, QueryId::EditIndividual, args);
}


void QueryTafsirHelper::editQuote(QObject* caller, qint64 quoteId, QString const& author, QString const& body, QString const& reference)
{
    LOGGER(quoteId << author << body << reference);

    qint64 authorId = generateIndividualField(caller, author);
    QString query = QString("UPDATE quotes SET author=%2,body=?,reference=? WHERE id=%1").arg(quoteId).arg(authorId);
    m_sql->executeQuery(caller, query, QueryId::EditQuote, QVariantList() << body << reference);
}


void QueryTafsirHelper::fetchAllIndividuals(QObject* caller) {
    m_sql->executeQuery(caller, "SELECT individuals.id,prefix,name,kunya,hidden,birth,death,companions.id AS companion_id FROM individuals LEFT JOIN companions ON individuals.id=companions.id ORDER BY name,kunya,prefix", QueryId::FetchAllIndividuals);
}


void QueryTafsirHelper::fetchMentions(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);
    m_sql->executeQuery(caller, QString("SELECT %1 AS author,body,reference,points FROM mentions INNER JOIN individuals i ON mentions.from_id=i.id WHERE mentions.target=%2").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchMentions);
}


void QueryTafsirHelper::fetchTeachers(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);
    m_sql->executeQuery(caller, QString("SELECT i.id,%1 AS teacher FROM teachers INNER JOIN individuals i ON teachers.teacher=i.id WHERE teachers.individual=%2").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchTeachers);
}


void QueryTafsirHelper::fetchStudents(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);
    m_sql->executeQuery(caller, QString("SELECT i.id,%1 AS student FROM teachers INNER JOIN individuals i ON teachers.individual=i.id WHERE teachers.teacher=%2").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchStudents);
}


void QueryTafsirHelper::fetchFrequentIndividuals(QObject* caller, int n) {
    m_sql->executeQuery(caller, QString("SELECT author AS id,prefix,name,kunya,uri,hidden,biography,birth,death,companions.id AS companion_id FROM (SELECT author,COUNT(author) AS n FROM suites GROUP BY author UNION SELECT translator AS author,COUNT(translator) AS n FROM suites GROUP BY author UNION SELECT explainer AS author,COUNT(explainer) AS n FROM suites GROUP BY author ORDER BY n DESC LIMIT %1) INNER JOIN individuals ON individuals.id=author LEFT JOIN companions ON companions.id=individuals.id GROUP BY individuals.id ORDER BY name,kunya,prefix").arg(n), QueryId::FetchAllIndividuals);
}


void QueryTafsirHelper::fetchAllWebsites(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);
    m_sql->executeQuery(caller, QString("SELECT id,uri FROM websites WHERE individual=%1 ORDER BY uri").arg(individualId), QueryId::FetchAllWebsites);
}


void QueryTafsirHelper::fetchAllTafsir(QObject* caller, qint64 individualId)
{
    LOGGER("fetchAllTafsir");

    QStringList queryParams = QStringList() << "SELECT suites.id AS id,individuals.name AS author,title FROM suites INNER JOIN individuals ON individuals.id=suites.author";

    if (individualId) {
        queryParams << QString("WHERE (author=%1 OR translator=%1 OR explainer=%1)").arg(individualId);
    }

    queryParams << "ORDER BY id DESC";

    m_sql->executeQuery(caller, queryParams.join(" "), QueryId::FetchAllTafsir);
}


void QueryTafsirHelper::fetchTafsirMetadata(QObject* caller, qint64 suiteId)
{
    LOGGER(suiteId);

    QString query = QString("SELECT author,translator,explainer,title,description,reference FROM suites WHERE id=%1").arg(suiteId);
    m_sql->executeQuery(caller, query, QueryId::FetchTafsirHeader);
}


void QueryTafsirHelper::fetchIndividualData(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);

    QString query = QString("SELECT * FROM individuals WHERE id=%1").arg(individualId);
    m_sql->executeQuery(caller, query, QueryId::FetchIndividualData);
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


void QueryTafsirHelper::createIndividual(QObject* caller, QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, int birth, int death)
{
    LOGGER( prefix << name << kunya << displayName << birth << death );

    qint64 id = QDateTime::currentMSecsSinceEpoch();
    QString query = QString("INSERT INTO individuals (id,prefix,name,kunya,displayName,birth,death) VALUES (%1,?,?,?,?,?,?)").arg(id);

    QVariantList args;
    args << protect(prefix);
    args << name;
    args << protect(kunya);
    args << protect(displayName);
    args << ( birth > 0 ? birth : QVariant() );
    args << ( death > 0 ? death : QVariant() );

    m_sql->executeQuery(caller, query, QueryId::AddIndividual, args);
}


void QueryTafsirHelper::linkAyatToTafsir(QObject* caller, qint64 suitePageId, int chapter, int fromVerse, int toVerse, QueryId::Type linkId)
{
    LOGGER(suitePageId << chapter << fromVerse << toVerse);
    QString query;

    if (chapter > 0)
    {
        if (fromVerse == 0) {
            query = QString("INSERT OR REPLACE INTO explanations (surah_id,suite_page_id) VALUES(%1,%2)").arg(chapter).arg(suitePageId);
        } else {
            query = QString("INSERT OR REPLACE INTO explanations (surah_id,from_verse_number,to_verse_number,suite_page_id) VALUES(%1,%2,%3,%4)").arg(chapter).arg(fromVerse).arg(toVerse).arg(suitePageId);
        }

        m_sql->executeQuery(caller, query, linkId);
    }
}


void QueryTafsirHelper::linkAyatsToTafsir(QObject* caller, qint64 suitePageId, QVariantList const& chapterVerseData)
{
    m_sql->startTransaction(caller, QueryId::LinkingAyatsToTafsir);

    foreach (QVariant const& q, chapterVerseData)
    {
        QVariantMap qvm = q.toMap();
        linkAyatToTafsir( caller, suitePageId, qvm.value(CHAPTER_KEY).toInt(), qvm.value(FROM_VERSE_KEY).toInt(), qvm.value(TO_VERSE_KEY).toInt() );
    }

    m_sql->endTransaction(caller, QueryId::LinkAyatsToTafsir);
}


void QueryTafsirHelper::removeCompanions(QObject* caller, QVariantList const& ids)
{
    LOGGER(ids);

    QStringList allIds;
    foreach (QVariant const& id, ids) {
        allIds << QString::number( id.toLongLong() );
    }

    m_sql->executeQuery(caller, QString("DELETE FROM companions WHERE id IN (%1)").arg( allIds.join(",") ), QueryId::RemoveCompanions);
}


void QueryTafsirHelper::removeQuote(QObject* caller, qint64 id)
{
    LOGGER(id);
    QString query = QString("DELETE FROM quotes WHERE id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::RemoveQuote);
}


void QueryTafsirHelper::removeWebsite(QObject* caller, qint64 id)
{
    LOGGER(id);
    QString query = QString("DELETE FROM websites WHERE id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::RemoveWebsite);
}


void QueryTafsirHelper::removeIndividual(QObject* caller, qint64 id)
{
    LOGGER(id);
    QString query = QString("DELETE FROM individuals WHERE id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::RemoveIndividual);
}


void QueryTafsirHelper::removeTafsir(QObject* caller, qint64 suiteId)
{
    LOGGER(suiteId);

    QString query = QString("DELETE FROM suites WHERE id=%1").arg(suiteId);
    m_sql->executeQuery(caller, query, QueryId::RemoveTafsir);
}


void QueryTafsirHelper::removeTafsirPage(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);

    QString query = QString("DELETE FROM suite_pages WHERE id=%1").arg(suitePageId);
    m_sql->executeQuery(caller, query, QueryId::RemoveTafsirPage);
}


void QueryTafsirHelper::replaceIndividual(QObject* caller, qint64 toReplaceId, qint64 actualId)
{
    LOGGER(toReplaceId << actualId);

    m_sql->startTransaction(caller, QueryId::ReplacingIndividual);
    m_sql->executeQuery(caller, QString("UPDATE quotes SET author=%1 WHERE author=%2").arg(actualId).arg(toReplaceId), QueryId::ReplacingIndividual);
    m_sql->executeQuery(caller, QString("UPDATE suites SET author=%1 WHERE author=%2").arg(actualId).arg(toReplaceId), QueryId::ReplacingIndividual);
    m_sql->executeQuery(caller, QString("UPDATE suites SET translator=%1 WHERE translator=%2").arg(actualId).arg(toReplaceId), QueryId::ReplacingIndividual);
    m_sql->executeQuery(caller, QString("UPDATE suites SET explainer=%1 WHERE explainer=%2").arg(actualId).arg(toReplaceId), QueryId::ReplacingIndividual);
    m_sql->executeQuery(caller, QString("DELETE FROM individuals WHERE id=%1").arg(toReplaceId), QueryId::ReplacingIndividual);
    m_sql->endTransaction(caller, QueryId::ReplaceIndividual);
}


void QueryTafsirHelper::searchIndividuals(QObject* caller, QString const& trimmedText)
{
    LOGGER(trimmedText);
    m_sql->executeQuery(caller, "SELECT individuals.id,prefix,name,kunya,hidden,birth,death,companions.id AS companion_id FROM individuals LEFT JOIN companions ON individuals.id=companions.id WHERE name LIKE '%' || ? || '%' OR kunya LIKE '%' || ? || '%'  ORDER BY name,kunya,prefix", QueryId::SearchIndividuals, QVariantList() << trimmedText << trimmedText);
}


void QueryTafsirHelper::searchQuote(QObject* caller, QString const& fieldName, QString const& searchTerm)
{
    LOGGER(fieldName << searchTerm);

    QString query;

    if (fieldName == "author") {
        query = "SELECT quotes.id AS id,individuals.name AS author,body FROM quotes INNER JOIN individuals ON individuals.id=quotes.author WHERE individuals.name LIKE '%' || ? || '%' ORDER BY id DESC";
    } else if (fieldName == "body") {
        query = "SELECT quotes.id AS id,individuals.name AS author,body FROM quotes INNER JOIN individuals ON individuals.id=quotes.author WHERE body LIKE '%' || ? || '%' ORDER BY id DESC";
    }

    if ( !query.isEmpty() ) {
        m_sql->executeQuery(caller, query, QueryId::SearchQuote, QVariantList() << searchTerm);
    }
}


void QueryTafsirHelper::searchTafsir(QObject* caller, QString const& fieldName, QString const& searchTerm)
{
    LOGGER(fieldName << searchTerm);

    QString query;

    if (fieldName == "author" || fieldName == "explainer" || fieldName == "translator")
    {
        if (fieldName == "author") {
            query = QString("SELECT suites.id,individuals.name AS author,title FROM suites INNER JOIN individuals ON individuals.id=suites.author WHERE individuals.name LIKE '%' || ? || '%' ORDER BY suites.id DESC").arg(fieldName);
        } else {
            query = QString("SELECT suites.id,individuals.name AS author,title FROM suites INNER JOIN individuals ON individuals.id=suites.author INNER JOIN individuals t ON t.id=suites.%1 WHERE t.name LIKE '%' || ? || '%' ORDER BY suites.id DESC").arg(fieldName);
        }
    } else if (fieldName == "body") {
        query = "SELECT suites.id,individuals.name AS author,title FROM suites INNER JOIN individuals ON individuals.id=suites.author INNER JOIN suite_pages ON suites.id=suite_pages.suite_id WHERE body LIKE '%' || ? || '%' ORDER BY suites.id DESC";
    } else {
        query = QString("SELECT suites.id,individuals.name AS author,title FROM suites INNER JOIN individuals ON individuals.id=suites.author WHERE %1 LIKE '%' || ? || '%' ORDER BY suites.id DESC").arg(fieldName);
    }

    m_sql->executeQuery(caller, query, QueryId::SearchTafsir, QVariantList() << searchTerm);
}


void QueryTafsirHelper::unlinkAyatsForTafsir(QObject* caller, QVariantList const& ids, qint64 suitePageId)
{
    LOGGER(ids << suitePageId);

    QString query = QString("DELETE FROM explanations WHERE id IN (%1) AND suite_page_id=%2").arg( combine(ids) ).arg(suitePageId);
    m_sql->executeQuery(caller, query, QueryId::UnlinkAyatsFromTafsir);
}


void QueryTafsirHelper::updateTafsirLink(QObject* caller, qint64 explanationId, int surahId, int fromVerse, int toVerse)
{
    LOGGER(explanationId << surahId << fromVerse << toVerse);

    QString query = QString("UPDATE explanations SET surah_id=%2,from_verse_number=%3,to_verse_number=%4 WHERE id=%1").arg(explanationId).arg(surahId).arg(fromVerse).arg(toVerse);
    m_sql->executeQuery(caller, query, QueryId::UpdateTafsirLink);
}


QueryTafsirHelper::~QueryTafsirHelper()
{
}

} /* namespace quran */
