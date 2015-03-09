#ifndef QUERYBOOKMARKHELPER_H_
#define QUERYBOOKMARKHELPER_H_

#include <QObject>
#include <QVariant>

namespace canadainc {
    class DatabaseHelper;
}

#define BOOKMARKS_PATH QString("%1/bookmarks.db").arg( QDir::homePath() )

namespace quran {

using namespace canadainc;

class QueryBookmarkHelper : public QObject
{
    Q_OBJECT

    DatabaseHelper* m_sql;
    bool initBookmarks(QObject* caller);

public:
    QueryBookmarkHelper(DatabaseHelper* sql);
    virtual ~QueryBookmarkHelper();

    Q_INVOKABLE void clearAllBookmarks(QObject* caller);
    Q_INVOKABLE void fetchAllBookmarks(QObject* caller);
    Q_INVOKABLE void fetchLastProgress(QObject* caller);
    Q_INVOKABLE void removeBookmark(QObject* caller, int id);
    Q_INVOKABLE void saveBookmark(QObject* caller, int surahId, int verseId, QString const& name, QString const& tag);
    Q_INVOKABLE void saveLegacyBookmarks(QObject* caller, QVariantList const& data);
    Q_INVOKABLE void saveLastProgress(QObject* caller, int surahId, int verseId);
};

} /* namespace quran */

#endif /* QUERYBOOKMARKHELPER_H_ */
