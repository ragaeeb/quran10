#ifndef QUERYHELPER_H_
#define QUERYHELPER_H_

#include <QDateTime>

#include "customsqldatasource.h"
#include "QueryId.h"

namespace canadainc {
	class Persistance;
}

namespace quran {

using namespace canadainc;

class QueryHelper : public QObject
{
	Q_OBJECT
	Q_PROPERTY(int totalBookmarks READ totalBookmarks NOTIFY totalBookmarksChanged)

	CustomSqlDataSource m_sql;
	Persistance* m_persist;
	QMap<int, QPair<QObject*,QueryId::Type> > m_idToObjectQueryType;
	QMap< QObject*, QMap<int,bool> > m_objectToIds;
	int m_currentId;

	void executeQuery(QObject* caller, QString const& query, QueryId::Type t);

private slots:
    void dataLoaded(int id, QVariant const& data);
    void destroyed(QObject* obj);
    void settingChanged(QString const& key);

signals:
    void textualChange();
    void dataLoaded(QObject* caller, int id, QVariant const& data);
    void totalBookmarksChanged();

public:
	QueryHelper(Persistance* persist);
	virtual ~QueryHelper();

	Q_SLOT void fetchAllDuaa(QObject* caller);
	Q_SLOT void fetchAllSurahs(QObject* caller, QVariant const& func);
	Q_SLOT void fetchAllAyats(QObject* caller, int chapterNumber);
    Q_SLOT void fetchPageNumbers(QObject* caller);
	Q_SLOT void fetchRandomAyat(QObject* caller);
    Q_SLOT void fetchSurahHeader(QObject* caller, int chapterNumber);
    Q_SLOT void fetchTafsirContent(QObject* caller, QString const& tafsirId);
	Q_SLOT void fetchTafsirForAyat(QObject* caller, int chapterNumber, int verseId);
	Q_SLOT void fetchTafsirForSurah(QObject* caller, int chapterNumber, bool excludeVerses=true);
    Q_SLOT void fetchTafsirIbnKatheer(QObject* caller, int chapterNumber);
	Q_SLOT void searchQuery(QObject* caller, QString const& trimmedText);
    int totalBookmarks();
};

} /* namespace quran */
#endif /* QUERYHELPER_H_ */
