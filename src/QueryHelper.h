#ifndef QUERYHELPER_H_
#define QUERYHELPER_H_

#include "DatabaseHelper.h"
#include "QueryBookmarkHelper.h"

#define AYAT_NUMERIC_PATTERN "^\\d{1,3}:\\d{1,3}$"
#define ENGLISH_TRANSLATION "english"

#define CHAPTER_KEY "chapter"
#define FROM_VERSE_KEY "fromVerse"
#define TO_VERSE_KEY "toVerse"

namespace canadainc {
	class Persistance;
}

namespace quran {

using namespace canadainc;

class QueryHelper : public QObject
{
	Q_OBJECT
    Q_PROPERTY(bool showTranslation READ showTranslation NOTIFY textualChange)
	Q_PROPERTY(bool disableSpacing READ disableSpacing NOTIFY fontSizeChanged)
    Q_PROPERTY(int primarySize READ primarySize NOTIFY fontSizeChanged)
    Q_PROPERTY(int translationSize READ translationSize NOTIFY fontSizeChanged)
    Q_PROPERTY(QString translation READ translation NOTIFY textualChange)
    Q_PROPERTY(QString translationName READ translationName NOTIFY textualChange)

    DatabaseHelper m_sql;
    Persistance* m_persist;
    QString m_translation;
    QueryBookmarkHelper m_bookmarkHelper;

private slots:
    void settingChanged(QString const& key);

signals:
    void fontSizeChanged();
    void textualChange();

public:
	QueryHelper(Persistance* persist);
	virtual ~QueryHelper();

    bool disableSpacing() const;
    bool showTranslation() const;
    int primarySize() const;
    int translationSize() const;

    Q_INVOKABLE void searchQuery(QObject* caller, QVariantList params, QVariantList const& chapters=QVariantList());
    Q_INVOKABLE void fetchAdjacentAyat(QObject* caller, int surahId, int verseId, int delta);
    Q_INVOKABLE void fetchAllAyats(QObject* caller, int fromChapter, int toChapter=0, int toVerse=0);
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
    Q_INVOKABLE void fetchAyat(QObject* caller, int surahId, int ayatId);
    Q_INVOKABLE void fetchAyats(QObject* caller, QVariantList const& input);
    Q_INVOKABLE void fetchChapter(QObject* caller, int chapter, bool juzMode=false);
    Q_INVOKABLE void fetchChapters(QObject* caller, QString const& text=QString());
    Q_INVOKABLE void fetchIndividualData(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchJuzInfo(QObject* caller, int juzId);
    Q_INVOKABLE void fetchPageNumbers(QObject* caller);
    Q_INVOKABLE void fetchRandomAyat(QObject* caller);
    Q_INVOKABLE void fetchRandomQuote(QObject* caller);
    Q_INVOKABLE void fetchSimilarAyatContent(QObject* caller, int chapterNumber, int verseNumber);
    Q_INVOKABLE void fetchSurahHeader(QObject* caller, int chapterNumber);
    Q_INVOKABLE void fetchTafsirContent(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void fetchTafsirCountForAyat(QObject* caller, int chapterNumber, int verseNumber);
    Q_INVOKABLE void fetchTransliteration(QObject* caller, int chapter, int verse);
    Q_SLOT void lazyInit();
    Q_SLOT void refreshDatabase();

    Q_INVOKABLE QObject* getExecutor();
    QString translation() const;
    QString translationName() const;
    QueryBookmarkHelper* getBookmarkHelper();
};

} /* namespace quran */
#endif /* QUERYHELPER_H_ */
