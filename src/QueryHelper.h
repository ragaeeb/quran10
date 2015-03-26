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
#define CHAPTER_KEY "chapter"
#define FROM_VERSE_KEY "fromVerse"
#define TO_VERSE_KEY "toVerse"
#define ENGLISH_TRANSLATION "english"
#define KEY_PRIMARY_SIZE "primarySize"
#define KEY_TRANSLATION "translation"
#define KEY_TRANSLATION_SIZE "translationFontSize"

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
    void tafsirMissing(QString const& tafsirName);
    void tafsirUpdateCheckNeeded(QString const& tafsirName);
    void textualChange();
    void translationMissing(QString const& translation);

public:
	QueryHelper(Persistance* persist);
	virtual ~QueryHelper();

    Q_INVOKABLE void addQuote(QObject* caller, QString const& author, QString const& body, QString const& reference);
    Q_INVOKABLE void fetchChapters(QObject* caller, QString const& text=QString());
    Q_INVOKABLE void addTafsir(QObject* caller, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference);
    Q_INVOKABLE void addTafsirPage(QObject* caller, qint64 suiteId, QString const& body, QString const& heading);
    Q_INVOKABLE void createIndividual(QObject* caller, QString const& prefix, QString const& name, QString const& kunya, QString const& url, QString const& bio, int birth, int death);
    Q_INVOKABLE void copyIndividualsFromSource(QObject* caller, QString const& source);
    Q_INVOKABLE void editIndividual(QObject* caller, qint64 id, QString const& prefix, QString const& name, QString const& kunya, QString const& url, QString const& bio, bool hidden, int birth, int death, bool female);
    Q_INVOKABLE void editQuote(QObject* caller, qint64 quoteId, QString const& author, QString const& body, QString const& reference);
    Q_INVOKABLE void editTafsir(QObject* caller, qint64 suiteId, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference);
    Q_INVOKABLE void editTafsirPage(QObject* caller, qint64 suitePageId, QString const& body, QString const& heading);
    Q_INVOKABLE void fetchAdjacentAyat(QObject* caller, int surahId, int verseId, int delta);
    Q_INVOKABLE void fetchAllAyats(QObject* caller, int fromChapter, int toChapter=0);
    Q_INVOKABLE void fetchAllChapters(QObject* caller);
    Q_INVOKABLE void fetchAllChapterAyatCount(QObject* caller);
    Q_INVOKABLE void fetchAllDuaa(QObject* caller);
    Q_INVOKABLE void fetchAllIndividuals(QObject* caller);
    Q_INVOKABLE void fetchFrequentIndividuals(QObject* caller, int n=7);
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
    Q_INVOKABLE void fetchTafsirMetadata(QObject* caller, qint64 suiteId);
    Q_INVOKABLE void fetchTransliteration(QObject* caller, int chapter, int verse);
    Q_INVOKABLE void linkAyatsToTafsir(QObject* caller, qint64 suitePageId, QVariantList const& chapterVerseData);
    Q_INVOKABLE void linkAyatToTafsir(QObject* caller, qint64 suitePageId, int chapter, int fromVerse=0, int toVerse=0);
    Q_INVOKABLE void addCompanions(QObject* caller, QVariantList const& ids);
    Q_INVOKABLE void removeCompanions(QObject* caller, QVariantList const& ids);
	Q_INVOKABLE void removeIndividual(QObject* caller, qint64 id);
    Q_INVOKABLE void removeQuote(QObject* caller, qint64 id);
    Q_INVOKABLE void removeTafsir(QObject* caller, qint64 suiteId);
    Q_INVOKABLE void removeTafsirPage(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void replaceIndividual(QObject* caller, qint64 toReplaceId, qint64 actualId);
    Q_INVOKABLE void replaceIndividualsFromSource(QObject* caller, QString const& source);
    Q_INVOKABLE void searchIndividuals(QObject* caller, QString const& trimmedText);
    Q_INVOKABLE bool searchQuery(QObject* caller, QString const& trimmedText, int chapterNumber=0, QVariantList const& additional=QVariantList(), bool andMode=true);
    Q_INVOKABLE void searchQuote(QObject* caller, QString const& fieldName, QString const& searchTerm);
    Q_INVOKABLE void searchTafsir(QObject* caller, QString const& fieldName, QString const& searchTerm);
    Q_INVOKABLE void unlinkAyatsForTafsir(QObject* caller, QVariantList const& ids, qint64 suitePageId);
    Q_INVOKABLE QVariantList normalizeJuzs(QVariantList const& source);
    Q_INVOKABLE QVariantList removeOutOfRange(QVariantList input, int fromChapter, int fromVerse, int toChapter, int toVerse);

    bool showTranslation() const;
    int primarySize() const;
    int translationSize() const;
    Q_SLOT void lazyInit();
    Q_SLOT void initForeignKeys();
    QString tafsirName() const;
    QString translation() const;
    QueryBookmarkHelper* getBookmarkHelper();
    QObject* getExecutor();
};

} /* namespace quran */
#endif /* QUERYHELPER_H_ */
