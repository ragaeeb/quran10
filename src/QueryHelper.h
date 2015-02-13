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

    qint64 generateIndividualField(QObject* caller, QString const& value);
    bool initBookmarks(QObject* caller);

private slots:
    void onDataLoaded(QVariant id, QVariant data);
    void settingChanged(QString const& key);

signals:
    void textualChange();

public:
	QueryHelper(Persistance* persist);
	virtual ~QueryHelper();

    Q_INVOKABLE void addTafsir(QObject* caller, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference);
    Q_INVOKABLE void addTafsirPage(QObject* caller, qint64 suiteId, QString const& body);
    Q_INVOKABLE void clearAllBookmarks(QObject* caller);
    Q_INVOKABLE void editIndividual(QObject* caller, qint64 id, QString const& prefix, QString const& name, QString const& kunya, QString const& url, QString const& bio, bool hidden);
    Q_INVOKABLE void editTafsir(QObject* caller, qint64 suiteId, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference);
    Q_INVOKABLE void editTafsirPage(QObject* caller, qint64 suitePageId, QString const& body);
    Q_INVOKABLE void fetchAllBookmarks(QObject* caller);
    Q_INVOKABLE void fetchAllChapters(QObject* caller);
    Q_INVOKABLE void fetchAllDuaa(QObject* caller);
    Q_INVOKABLE void fetchAllAyats(QObject* caller, int fromChapter, int toChapter=0);
    Q_INVOKABLE void fetchAllTafsir(QObject* caller);
    Q_INVOKABLE void fetchAllTafsirForAyat(QObject* caller, int chapterNumber, int verseNumber);
    Q_INVOKABLE void fetchAllTafsirForSuite(QObject* caller, qint64 suiteId);
    Q_INVOKABLE void fetchAyat(QObject* caller, int surahId, int ayatId);
    Q_INVOKABLE void fetchAyatsForTafsir(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE bool fetchChapters(QObject* caller, QString const& text=QString());
    Q_INVOKABLE void fetchChapter(QObject* caller, int chapter);
    Q_INVOKABLE void fetchJuzInfo(QObject* caller, int juzId);
    Q_INVOKABLE void fetchPageNumbers(QObject* caller);
    Q_INVOKABLE void fetchAllQarees(QObject* caller, int minLevel=1);
    Q_INVOKABLE void fetchRandomAyat(QObject* caller);
    Q_INVOKABLE void fetchSimilarAyatContent(QObject* caller, int chapterNumber, int verseNumber);
    Q_INVOKABLE void fetchSurahHeader(QObject* caller, int chapterNumber);
    Q_INVOKABLE void fetchTafsirContent(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void removeBookmark(QObject* caller, int id);
    Q_INVOKABLE void saveBookmark(QObject* caller, int surahId, int verseId, QString const& name, QString const& tag);
    Q_INVOKABLE void searchQuery(QObject* caller, QString const& trimmedText, int chapterNumber=0, QVariantList additional=QVariantList(), bool andMode=true);
    Q_INVOKABLE void searchIndividuals(QObject* caller, QString const& trimmedText);
    Q_INVOKABLE QVariantList normalizeJuzs(QVariantList const& source);
    Q_INVOKABLE QVariantList removeOutOfRange(QVariantList input, int fromChapter, int fromVerse, int toChapter, int toVerse);

    bool showTranslation() const;
    int primarySize() const;
    int translationSize() const;
    Q_SLOT void lazyInit();
    Q_SLOT void initForeignKeys();
    QString tafsirName() const;
};

} /* namespace quran */
#endif /* QUERYHELPER_H_ */
