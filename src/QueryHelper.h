#ifndef QUERYHELPER_H_
#define QUERYHELPER_H_

#include <QDateTime>

#include "DatabaseHelper.h"
#include "QueryId.h"
#include "QueryBookmarkHelper.h"
#include "QueryTafsirHelper.h"

#define AYAT_NUMERIC_PATTERN "^\\d{1,3}:\\d{1,3}$"
#define SIMILAR_DB "similar"
#define TAFSIR_ARABIC_DB "tafsir_arabic"
#define ENGLISH_TRANSLATION "english"
#define KEY_PRIMARY_SIZE "primarySize"
#define KEY_TRANSLATION "translation"
#define KEY_TRANSLATION_SIZE "translationFontSize"
#define KEY_TAFSIR "tafsir"
#define KEY_FORCED_UPDATE "forcedUpdate" // are we forced to do an update for the translation
#define KEY_LANGUAGE "language"

namespace canadainc {
	class Persistance;
}

namespace quran {

using namespace canadainc;

class QueryHelper : public QObject
{
	Q_OBJECT
	Q_PROPERTY(bool showTranslation READ showTranslation NOTIFY textualChange)
	Q_PROPERTY(int primarySize READ primarySize NOTIFY fontSizeChanged)
	Q_PROPERTY(int translationSize READ translationSize NOTIFY fontSizeChanged)
	Q_PROPERTY(QString translation READ translation NOTIFY textualChange)

    DatabaseHelper m_sql;
    Persistance* m_persist;
    QString m_translation;
    QFileSystemWatcher m_watcher;
    QueryTafsirHelper m_tafsirHelper;
    QueryBookmarkHelper m_bookmarkHelper;

private slots:
    void settingChanged(QString const& key);

signals:
    void fontSizeChanged();
    void updateCheckNeeded(QVariantMap const& params);
    void textualChange();

public:
	QueryHelper(Persistance* persist);
	virtual ~QueryHelper();

    Q_INVOKABLE void fetchChapters(QObject* caller, QString const& text=QString());
    Q_INVOKABLE void copyIndividualsFromSource(QObject* caller, QString const& source);
    Q_INVOKABLE void fetchAdjacentAyat(QObject* caller, int surahId, int verseId, int delta);
    Q_INVOKABLE void fetchAllAyats(QObject* caller, int fromChapter, int toChapter=0);
    Q_INVOKABLE void fetchAllChapters(QObject* caller);
    Q_INVOKABLE void fetchAllChapterAyatCount(QObject* caller);
    Q_INVOKABLE void fetchAllDuaa(QObject* caller);
    Q_INVOKABLE void fetchAllQarees(QObject* caller, int minLevel=1);
    Q_INVOKABLE void fetchAllQuotes(QObject* caller, qint64 individualId=0);
    Q_INVOKABLE void fetchAllTafsir(QObject* caller, qint64 individualId=0);
    Q_INVOKABLE void fetchAllTafsirForAyat(QObject* caller, int chapterNumber, int verseNumber);
    Q_INVOKABLE void fetchAllTafsirForChapter(QObject* caller, int chapterNumber);
    Q_INVOKABLE void fetchAllTafsirForSuite(QObject* caller, qint64 suiteId);
    Q_INVOKABLE void fetchAyat(QObject* caller, int surahId, int ayatId);
    Q_INVOKABLE void fetchAyatsForTafsir(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void fetchBio(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchChapter(QObject* caller, int chapter);
    Q_INVOKABLE void fetchJuzInfo(QObject* caller, int juzId);
    Q_INVOKABLE void fetchPageNumbers(QObject* caller);
    Q_INVOKABLE void fetchQuote(QObject* caller, qint64 id);
    Q_INVOKABLE void fetchRandomAyat(QObject* caller);
    Q_INVOKABLE void fetchRandomQuote(QObject* caller);
    Q_INVOKABLE void fetchSimilarAyatContent(QObject* caller, int chapterNumber, int verseNumber);
    Q_INVOKABLE void fetchSurahHeader(QObject* caller, int chapterNumber);
    Q_INVOKABLE void fetchTafsirContent(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void fetchTafsirCountForAyat(QObject* caller, int chapterNumber, int verseNumber);
    Q_INVOKABLE void fetchTransliteration(QObject* caller, int chapter, int verse);
    Q_INVOKABLE void replaceIndividualsFromSource(QObject* caller, QString const& source);
    Q_INVOKABLE bool searchQuery(QObject* caller, QString const& trimmedText, int chapterNumber=0, QVariantList const& additional=QVariantList(), bool andMode=true);

    bool showTranslation() const;
    int primarySize() const;
    int translationSize() const;
    Q_SLOT void lazyInit();
    Q_SLOT void initForeignKeys();
    QString tafsirName() const;
    QString translation() const;
    QueryBookmarkHelper* getBookmarkHelper();
    QObject* getExecutor();
    QObject* getTafsirHelper();
};

} /* namespace quran */
#endif /* QUERYHELPER_H_ */
