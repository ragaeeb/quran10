#ifndef THREADUTILS_H_
#define THREADUTILS_H_

#include <QVariant>

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
    static QString buildSearchQuery(QVariantList& params, bool isArabic, QString const& trimmedText, int chapterNumber, QVariantList additional, bool andMode);
    static QString buildChaptersQuery(QVariantList& args, QString const& text, bool showTranslation);
    static QString compressBookmarks(QString const& destinationZip);
    static void compressFiles(QSet<QString>& attachments);
    static bool performRestore(QString const& source);
    static SimilarReference decorateResults(QVariantList input, ArrayDataModel* adm, QString const& mainSearch, QVariantList const& additional);
    static SimilarReference decorateSimilar(QVariantList input, ArrayDataModel* adm, AbstractTextControl* atc, QString body);
    static QString writeTafsirArchive(QVariant const& cookie, QByteArray const& data);
    static QVariantList removeOutOfRange(QVariantList input, int fromChapter, int fromVerse, int toChapter, int toVerse);
    static QVariantList normalizeJuzs(QVariantList const& source);
};

} /* namespace quran */

#endif /* THREADUTILS_H_ */
