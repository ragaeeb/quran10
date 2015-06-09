#ifndef QUERYHELPER_H_
#define QUERYHELPER_H_

#include "DatabaseHelper.h"
#include "QueryId.h"
#include "QueryBookmarkHelper.h"

#define AYAT_NUMERIC_PATTERN "^\\d{1,3}:\\d{1,3}$"
#define SIMILAR_DB "similar"
#define TAFSIR_ARABIC_DB "tafsir_arabic"
#define ENGLISH_TRANSLATION "english"

#define CHAPTER_KEY "chapter"
#define FROM_VERSE_KEY "fromVerse"
#define TO_VERSE_KEY "toVerse"
#define NAME_FIELD(var) QString("coalesce(%1.displayName, TRIM((coalesce(%1.prefix,'') || ' ' || %1.name || ' ' || coalesce(%1.kunya,''))))").arg(var)

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
    Q_PROPERTY(QString tafsirName READ tafsirName NOTIFY textualChange)
    Q_PROPERTY(QString tafsirVersion READ tafsirVersion NOTIFY textualChange)
    Q_PROPERTY(QString translation READ translation NOTIFY textualChange)
    Q_PROPERTY(QString translationName READ translationName NOTIFY textualChange)
    Q_PROPERTY(QString translationVersion READ translationVersion NOTIFY textualChange)

    DatabaseHelper m_sql;
    Persistance* m_persist;
    QString m_translation;
    QueryBookmarkHelper m_bookmarkHelper;

    void executeAndClear(QStringList& statements);

private slots:
    void settingChanged(QString const& key);

signals:
    void fontSizeChanged();
    void textualChange();
    void updateCheckNeeded(QVariantMap const& params);

public:
	QueryHelper(Persistance* persist);
	virtual ~QueryHelper();

    bool showTranslation() const;
    int primarySize() const;
    int translationSize() const;

    Q_INVOKABLE bool searchQuery(QObject* caller, QString const& trimmedText, int chapterNumber=0, QVariantList const& additional=QVariantList(), bool andMode=true);
    Q_INVOKABLE void fetchAdjacentAyat(QObject* caller, int surahId, int verseId, int delta);
    Q_INVOKABLE void fetchAllAyats(QObject* caller, int fromChapter, int toChapter=0);
    Q_INVOKABLE void fetchAllChapterAyatCount(QObject* caller);
    Q_INVOKABLE void fetchAllChapters(QObject* caller);
    Q_INVOKABLE void fetchAllDuaa(QObject* caller);
    Q_INVOKABLE void fetchAllOrigins(QObject* caller);
    Q_INVOKABLE void fetchAllQarees(QObject* caller, int minLevel=1);
    Q_INVOKABLE void fetchAllQuotes(QObject* caller, qint64 individualId=0);
    Q_INVOKABLE void fetchAllTafsir(QObject* caller, qint64 individualId=0);
    Q_INVOKABLE void fetchAllTafsirForAyat(QObject* caller, int chapterNumber, int verseNumber);
    Q_INVOKABLE void fetchAllTafsirForChapter(QObject* caller, int chapterNumber);
    Q_INVOKABLE void fetchAllTafsirForSuite(QObject* caller, qint64 suiteId);
    Q_INVOKABLE void fetchAllWebsites(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchAyat(QObject* caller, int surahId, int ayatId);
    Q_INVOKABLE void fetchAyats(QObject* caller, QVariantList const& input);
    Q_INVOKABLE void fetchAyatsForTafsir(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void fetchBio(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchChapter(QObject* caller, int chapter, bool juzMode=false);
    Q_INVOKABLE void fetchChapters(QObject* caller, QString const& text=QString());
    Q_INVOKABLE void fetchIndividualData(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchJuzInfo(QObject* caller, int juzId);
    Q_INVOKABLE void fetchPageNumbers(QObject* caller);
    Q_INVOKABLE void fetchQuote(QObject* caller, qint64 id);
    Q_INVOKABLE void fetchRandomAyat(QObject* caller);
    Q_INVOKABLE void fetchRandomQuote(QObject* caller);
    Q_INVOKABLE void fetchSimilarAyatContent(QObject* caller, int chapterNumber, int verseNumber);
    Q_INVOKABLE void fetchStudents(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchSurahHeader(QObject* caller, int chapterNumber);
    Q_INVOKABLE void fetchTafsirContent(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void fetchTafsirCountForAyat(QObject* caller, int chapterNumber, int verseNumber);
    Q_INVOKABLE void fetchTeachers(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchTransliteration(QObject* caller, int chapter, int verse);
    Q_SLOT void lazyInit();
    Q_SLOT void refreshDatabase();
    Q_SLOT void setupTables();

    Q_INVOKABLE QObject* getExecutor();
    QString tafsirName() const;
    QString tafsirVersion() const;
    QString translation() const;
    QString translationName() const;
    QString translationVersion() const;
    QueryBookmarkHelper* getBookmarkHelper();
};

} /* namespace quran */
#endif /* QUERYHELPER_H_ */
