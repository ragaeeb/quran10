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

struct ThreadUtils
{
    static QVariantList allAyatImagesExist(QVariantList const& surahData, QString const& outputDirectory, QString const& ayatDirectory);
    static bool performRestore(QString const& source);
    static QString buildChaptersQuery(QVariantList& args, QString const& text, bool showTranslation);
    static QString buildSearchQuery(QVariantList& params, bool isArabic, int chapterNumber, QVariantList additional, bool andMode);
    static QString compressBookmarks(QString const& destinationZip);
    static QVariantList normalizeJuzs(QVariantList const& source);
    static QVariantList removeOutOfRange(QVariantList input, int fromChapter, int fromVerse, int toChapter, int toVerse);
    static void cleanLegacyPics();
    static void compressFiles(canadainc::Report& r, QString const& zipPath, const char* password);
    static QVariantMap matchSurah(QVariantMap input, QVariantList const& allSurahs);
    static void preventIndexing(QString const& dirPath);
};

} /* namespace quran */

#endif /* THREADUTILS_H_ */
