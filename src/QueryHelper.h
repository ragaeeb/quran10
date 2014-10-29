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
	Q_PROPERTY(QString translation READ translation NOTIFY textualChange)

    DatabaseHelper m_sql;
    Persistance* m_persist;
    QString m_translation;
    QFileSystemWatcher m_watcher;

private slots:
    void settingChanged(QString const& key);
    void onDataLoaded(QVariant id, QVariant data);

signals:
    void bookmarksUpdated(QString const& bookmarks);
    void textualChange();

public:
	QueryHelper(Persistance* persist);
	virtual ~QueryHelper();

    Q_INVOKABLE void addTafsir(QObject* caller, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference);
    Q_INVOKABLE void addTafsirPage(QObject* caller, qint64 suiteId, QString const& body);
    Q_INVOKABLE void clearAllBookmarks(QObject* caller);
    Q_INVOKABLE void editTafsir(QObject* caller, qint64 suiteId, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference);
    Q_INVOKABLE void editTafsirPage(QObject* caller, qint64 suitePageId, QString const& body);
    Q_INVOKABLE void fetchAllBookmarks(QObject* caller);
    Q_INVOKABLE void fetchAllTafsir(QObject* caller);
    Q_INVOKABLE void fetchAllTafsirForSuite(QObject* caller, qint64 suiteId);
    Q_INVOKABLE void fetchAllDuaa(QObject* caller);
    Q_INVOKABLE void fetchAllAyats(QObject* caller, int chapterNumber);
    Q_INVOKABLE void fetchChapters(QObject* caller, QString const& text=QString());
    Q_INVOKABLE void fetchPageNumbers(QObject* caller);
    Q_INVOKABLE void fetchRandomAyat(QObject* caller);
    Q_INVOKABLE void fetchSurahHeader(QObject* caller, int chapterNumber);
    Q_INVOKABLE void fetchTafsirContent(QObject* caller, QString const& tafsirId);
    Q_INVOKABLE void fetchTafsirForAyat(QObject* caller, int chapterNumber, int verseId);
    Q_INVOKABLE void fetchTafsirForSurah(QObject* caller, int chapterNumber, bool excludeVerses=true);
    Q_INVOKABLE void fetchTafsirIbnKatheer(QObject* caller, int chapterNumber);
    Q_INVOKABLE void removeBookmark(QObject* caller, int id);
    Q_INVOKABLE void removeTafsir(QObject* caller, qint64 suiteId);
    Q_INVOKABLE void removeTafsirPage(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void searchQuery(QObject* caller, QString const& trimmedText);
    void diffPlugins(QString const& similarDbase, QString const& tafsirArabicDbase, QString const& tafsirEnglishDbase, QString const& path);

    QString translation() const;

    static bool bookmarksReady();
    bool pluginsExist();
    Q_SLOT bool initDatabase(QObject* caller);
    Q_SLOT void lazyInit();
    Q_SLOT void initForeignKeys();
    Q_SLOT void monitorBookmarks();
    void showPluginsUpdatedToast();
    Q_INVOKABLE void apply(QString const& text);
};

} /* namespace quran */
#endif /* QUERYHELPER_H_ */
