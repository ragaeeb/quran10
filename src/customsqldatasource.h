#ifndef QUOTESSQLDATASOURCE_H_
#define QUOTESSQLDATASOURCE_H_

#include <bb/data/DataAccessReply>

namespace bb {
    namespace data {
        class SqlConnection;
    }
}

namespace canadainc {

using namespace bb::data;

class CustomSqlDataSource: public QObject
{
    Q_OBJECT

    /** The path to the SQL database. */
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)

    /** The initial query that will be run on the database. */
    Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged)

    bool checkConnection();

    QString m_query;
    QString m_source;
    SqlConnection* m_sqlConnector;

public:
    CustomSqlDataSource(QObject *parent = 0);
    ~CustomSqlDataSource();

    /**
     * Sets the path to the SQL database
     * @param newStatusText the new string
     */
    void setSource(QString const& source);

    /**
     * Returns the current source path used by the data source
     * @return A string for the current source path
     */
    QString source() const;

    /**
     * Sets the SQL query that should be executed.
     *
     * @param query The new SQL query.
     */
    void setQuery(QString const& query);

    /**
     * The query property contains an SQL query.
     *
     * @return A string containing the query.
     */
    QString query();


    /**
     * Loads the data from the data source.
     */
    Q_INVOKABLE void load();

    /**
     * Executes a SQL query on the database the execution will block and wait for a result.
     * The id has to greater than or equal to 1 (0 is reserved for loading data using the query property)
     *
     * @param The query which should be executed
     * @param An id that can be used to match requests
     */
    Q_INVOKABLE DataAccessReply executeAndWait(QVariant const& criteria, int id = 1);

    /**
     * Executes a SQL query on the database the execution is non blocking the result will be delivered
     * in the dataLoaded signal. The id has to greater than or equal to 1 (0 is reserved
     * for loading data using the query property)
     *
     * @param The query which should be executed
     * @param An id that can be used to match requests
     */
    Q_INVOKABLE void execute(QVariant const& criteria, int id = 1);
signals:

    /**
     * Emitted when the source path changes
     *
     * @param A string containing the new source
     */
    void sourceChanged(QString const& source);

    /**
     * Emitted when the query changes
     *
     * @param A string containing the new query
     */
    void queryChanged(QString const& query);

    /**
     * Emitted when data has been recieved.
     *
     * @param A variant containing the new data.
     */
    void dataLoaded(QVariant const& data);

    /**
     * Emitted when an asynchronous execute operation has completed and has results to return.
     *
     * @param replyData The reply data from the execute operation.
     */
    void reply(const bb::data::DataAccessReply &replyData);

private slots:
    /**
     * Function that is connected to the SqlConnection reply signal.
     *
     * @param reply The reply data delivered from the asynchronous request to the SqlConnection
     */
    void onLoadAsyncResultData(const bb::data::DataAccessReply& reply);
};

}

#endif /* QUOTESDATASOURCE_H_ */
