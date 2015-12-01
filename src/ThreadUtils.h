#ifndef THREADUTILS_H_
#define THREADUTILS_H_

#include <QVariant>

#include "Report.h"

#define CARD_LOG_FILE QString("%1/logs/card.log").arg( QDir::currentPath() )

namespace bb {
    namespace cascades {
        class ArrayDataModel;
        class AbstractTextControl;
    }
}

namespace quran {

using namespace bb::cascades;

struct SimilarReference
{
    ArrayDataModel* adm;
    QVariantList input;
    AbstractTextControl* textControl;
    QString body;

    SimilarReference();
};

struct ThreadUtils
{
    static bool allAyatImagesExist(QVariantList const& surahData, QString const& outputDirectory);
    static bool performRestore(QString const& source);
    static QString buildChaptersQuery(QVariantList& args, QString const& text, bool showTranslation);
    static QString buildSearchQuery(QVariantList& params, bool isArabic, int chapterNumber, QVariantList additional, bool andMode);
    static QString compressBookmarks(QString const& destinationZip);
    static QVariantList normalizeJuzs(QVariantList const& source);
    static QVariantList removeOutOfRange(QVariantList input, int fromChapter, int fromVerse, int toChapter, int toVerse);
    static QVariantMap writePluginArchive(QVariantMap const& cookie, QByteArray const& data, QString const& pathKey);
    static SimilarReference decorateResults(QVariantList input, ArrayDataModel* adm, QString const& mainSearch, QVariantList const& additional);
    static SimilarReference decorateSimilar(QVariantList input, ArrayDataModel* adm, AbstractTextControl* atc, QString body);
    static void cleanLegacyPics();
    static void compressFiles(canadainc::Report& r, QString const& zipPath, const char* password);
    static void onResultsDecorated(SimilarReference const& result);
    static QVariantMap matchSurah(QVariantMap input, QVariantList const& allSurahs);
    static QVariantList captureAyatsInBody(QString body, QMap<QString, int> const& chapterToId);
    static bool replaceDatabase(QString const& src);
    static void clearCachedDB(QString const& language);
};

} /* namespace quran */

#endif /* THREADUTILS_H_ */
