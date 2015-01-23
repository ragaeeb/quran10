#ifndef QUERYHELPER_H_
#define QUERYHELPER_H_

#include <QDateTime>

#include "DatabaseHelper.h"
#include "QueryId.h"

#define AYAT_NUMERIC_PATTERN "^\\d{1,3}:\\d{1,3}$"
#define BOOKMARKS_PATH QString("%1/bookmarks.db").arg( QDir::homePath() )
#define SIMILAR_DB "similar"
#define TAFSIR_ARABIC_DB "tafsir_arabic"

namespace canadainc {
	class Persistance;
}

namespace quran {

using namespace canadainc;

class QueryHelper : public QObject
{
	Q_OBJECT
	Q_PROPERTY(bool showTranslation READ showTranslation NOTIFY textualChange)
	Q_PROPERTY(int primarySize READ primarySize NOTIFY textualChange)
	Q_PROPERTY(int translationSize READ translationSize NOTIFY textualChange)

    DatabaseHelper m_sql;
    Persistance* m_persist;
    QString m_translation;
    QFileSystemWatcher m_watcher;

    bool initBookmarks(QObject* caller);

private slots:
    void settingChanged(QString const& key);
    void onDataLoaded(QVariant id, QVariant data);

signals:
    void textualChange();

public:
	QueryHelper(Persistance* persist);
	virtual ~QueryHelper();

    Q_INVOKABLE void clearAllBookmarks(QObject* caller);
    Q_INVOKABLE void fetchAllBookmarks(QObject* caller);
    Q_INVOKABLE void fetchAllDuaa(QObject* caller);
    Q_INVOKABLE void fetchAllAyats(QObject* caller, int chapterNumber);
    Q_INVOKABLE void fetchAyat(QObject* caller, int surahId, int ayatId);
    Q_INVOKABLE void fetchChapters(QObject* caller, QString const& text=QString(), QString sortOrder=QString());
    Q_INVOKABLE void fetchPageNumbers(QObject* caller);
    Q_INVOKABLE void fetchRandomAyat(QObject* caller);
    Q_INVOKABLE void fetchSurahHeader(QObject* caller, int chapterNumber);
    Q_INVOKABLE void removeBookmark(QObject* caller, int id);
    Q_INVOKABLE void saveBookmark(QObject* caller, int surahId, int verseId, QString const& name, QString const& tag);
    Q_INVOKABLE void searchQuery(QObject* caller, QString const& trimmedText);

    bool showTranslation() const;
    int primarySize() const;
    int translationSize() const;
    Q_SLOT void lazyInit();
    Q_SLOT void initForeignKeys();
};

} /* namespace quran */
#endif /* QUERYHELPER_H_ */
