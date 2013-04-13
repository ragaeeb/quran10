#include "customsqldatasource.h"
#include "Logger.h"

#include <bb/data/SqlConnection>
#include <QFile>

namespace {

const int LOAD_EXECUTION = 0;

}

namespace canadainc {

using namespace bb::data;

CustomSqlDataSource::CustomSqlDataSource(QObject *parent) : QObject(parent)
{
}

CustomSqlDataSource::~CustomSqlDataSource()
{
}


void CustomSqlDataSource::setQuery(QString const& query)
{
    if (m_query.compare(query) != 0) {
        m_query = query;
        emit queryChanged(m_query);
    }
}

QString CustomSqlDataSource::query() {
    return m_query;
}

bool CustomSqlDataSource::checkConnection()
{
    if (m_sqlConnector) {
        return true;
    } else {
        QFile newFile(m_source);

        if (newFile.exists()) {

            // Remove the old connection if it exists
            if(m_sqlConnector){
                disconnect( m_sqlConnector, SIGNAL( reply(const bb::data::DataAccessReply&) ), this, SLOT( onLoadAsyncResultData(const bb::data::DataAccessReply&) ) );
                m_sqlConnector->setParent(NULL);
                delete m_sqlConnector;
            }

            // Set up a connection to the data base
            m_sqlConnector = new SqlConnection(m_source, "connect", this);

            // Connect to the reply function
            connect(m_sqlConnector, SIGNAL( reply(const bb::data::DataAccessReply&) ), this, SLOT( onLoadAsyncResultData(const bb::data::DataAccessReply&) ) );

            return true;

        } else {
            LOGGER("Failed to load data base, file does not exist.");
        }
    }

    return false;
}

DataAccessReply CustomSqlDataSource::executeAndWait(QVariant const& criteria, int id)
{
    DataAccessReply reply;

    if ( checkConnection() )
    {
        reply = m_sqlConnector->executeAndWait(criteria, id);

        if ( reply.hasError() ) {
            LOGGER("error " << reply);
        }
    }

    return reply;
}

void CustomSqlDataSource::execute(QVariant const& criteria, int id)
{
    if ( checkConnection() ) {
        m_sqlConnector->execute(criteria, id);
    }
}


void CustomSqlDataSource::load()
{
    if ( !m_query.isEmpty() ) {
        execute(m_query, LOAD_EXECUTION);
    }
}

void CustomSqlDataSource::onLoadAsyncResultData(const bb::data::DataAccessReply& replyData)
{
    if ( replyData.hasError() ) {
        LOGGER( replyData.id() << ", SQL error: " << replyData );
    } else {
        if(replyData.id() == LOAD_EXECUTION) {
            // The reply belongs to the execution of the query property of the data source
            // Emit the the data loaded signal so that the model can be populated.
            QVariantList resultList = replyData.result().toList();
            emit dataLoaded(resultList);
        } else {
            // Forward the reply signal.
            emit reply(replyData);
        }
    }
}


void CustomSqlDataSource::setSource(QString const& source) {
	m_source = source;
}


QString CustomSqlDataSource::source() const {
	return m_source;
}

}
