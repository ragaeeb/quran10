#include "precompiled.h"

#include "ThreadUtils.h"
#include "AppLogFetcher.h"
#include "JlCompress.h"
#include "QueryHelper.h"
#include "TextUtils.h"

#define BACKUP_ZIP_PASSWORD "X4*13f3*3qYk3_*"

namespace quran {

using namespace bb::cascades;

SimilarReference::SimilarReference() : adm(NULL), textControl(NULL)
{
}

QString ThreadUtils::compressBookmarks(QString const& destinationZip)
{
    bool result = JlCompress::compressFile(destinationZip, BOOKMARKS_PATH, BACKUP_ZIP_PASSWORD);
    QFileInfo f(destinationZip);

    return result ? f.fileName() : "";
}

void ThreadUtils::compressFiles(QSet<QString>& attachments)
{
    attachments << CARD_LOG_FILE;
    attachments << BOOKMARKS_PATH;
    canadainc::AppLogFetcher::removeInvalid(attachments);

    JlCompress::compressFiles( ZIP_FILE_PATH, attachments.toList() );
    QFile::remove(CARD_LOG_FILE);
}

bool ThreadUtils::performRestore(QString const& source)
{
    QStringList files = JlCompress::extractDir( source, QDir::homePath(), BACKUP_ZIP_PASSWORD );
    return !files.isEmpty();
}

SimilarReference ThreadUtils::decorateResults(QVariantList input, ArrayDataModel* adm, QString const& mainSearch, QVariantList const& additional)
{
    int n = input.size();

    QSet<QString> searches;
    searches << mainSearch;

    foreach (QVariant const& q, additional) {
        searches << q.toString();
    }

    for (int i = 0; i < n; i++)
    {
        QVariantMap current = input[i].toMap();
        QString text = current.value("ayatText").toString();

        foreach (QString const& searchText, searches) {
            text.replace(searchText, "<span style='font-style:italic;font-weight:bold;color:lightgreen'>"+searchText+"</span>", Qt::CaseInsensitive);
        }

        current["ayatText"] = "<html>"+text+"</html>";
        input[i] = current;
    }

    SimilarReference s;
    s.adm = adm;
    s.input = input;

    return s;
}


SimilarReference ThreadUtils::decorateSimilar(QVariantList input, ArrayDataModel* adm, AbstractTextControl* atc, QString body)
{
    SimilarReference s;
    s.adm = adm;
    s.textControl = atc;

    int n = input.size();

    if (n > 0) {
        QString common = canadainc::TextUtils::longestCommonSubstring( body, input[0].toMap().value("content").toString() );
        s.body = "<html>"+body.replace(common, "<span style='font-style:italic;color:lightgreen'>"+common+"</span>", Qt::CaseInsensitive)+"</html>";
    }

    for (int i = 0; i < n; i++)
    {
        QVariantMap current = input[i].toMap();
        QString text = current.value("content").toString();
        QString common = canadainc::TextUtils::longestCommonSubstring(text, body);

        text.replace(common, "<span style='font-style:italic;color:lightgreen'>"+common+"</span>", Qt::CaseInsensitive);

        current["content"] = "<html>"+text+"</html>";
        input[i] = current;
    }

    s.input = input;

    return s;
}

} /* namespace quran */
