#include "precompiled.h"

#include "Offloader.h"
#include "CommonConstants.h"
#include "Logger.h"
#include "Persistance.h"
#include "TextUtils.h"
#include "ThreadUtils.h"

#define TAFSIR_MIME_IMAGE "imageSource"

namespace quran {

using namespace canadainc;

Offloader::Offloader(Persistance* persist, QObject* parent) : QObject(parent), m_persist(persist)
{
}


void Offloader::decorateSearchResults(QVariantList const& input, QString const& searchText, bb::cascades::ArrayDataModel* adm, QVariantList const& additional)
{
    LOGGER(input.size() << searchText << additional);

    QFutureWatcher<SimilarReference>* qfw = new QFutureWatcher<SimilarReference>(this);
    connect( qfw, SIGNAL( finished() ), this, SLOT( onResultsDecorated() ) );

    QFuture<SimilarReference> future = QtConcurrent::run(&ThreadUtils::decorateResults, input, adm, searchText, additional);
    qfw->setFuture(future);
}


void Offloader::decorateSimilarResults(QVariantList const& input, QString const& mainText, bb::cascades::ArrayDataModel* adm, bb::cascades::AbstractTextControl* atc)
{
    LOGGER(input.size() << mainText);

    QFutureWatcher<SimilarReference>* qfw = new QFutureWatcher<SimilarReference>(this);
    connect( qfw, SIGNAL( finished() ), this, SLOT( onResultsDecorated() ) );

    QFuture<SimilarReference> future = QtConcurrent::run(&ThreadUtils::decorateSimilar, input, adm, atc, mainText);
    qfw->setFuture(future);
}


void Offloader::onResultsDecorated()
{
    QFutureWatcher<SimilarReference>* qfw = static_cast< QFutureWatcher<SimilarReference>* >( sender() );
    ThreadUtils::onResultsDecorated( qfw->result() );

    sender()->deleteLater();
}


void Offloader::decorateTafsir(bb::cascades::ArrayDataModel* adm)
{
    for (int i = adm->size()-1; i >= 0; i--)
    {
        QVariantMap qvm = adm->value(i).toMap();
        QString body = qvm.value("body").toString();

        if ( body.endsWith("mp3") ) {
            qvm[TAFSIR_MIME_IMAGE] = "images/list/mime_mp3.png";
        } else if ( body.endsWith("doc") || body.endsWith("docx") ) {
            qvm[TAFSIR_MIME_IMAGE] = "images/list/mime_doc.png";
        } else if ( body.endsWith("pdf") ) {
            qvm[TAFSIR_MIME_IMAGE] = "images/list/mime_pdf.png";
        } else {
            qvm[TAFSIR_MIME_IMAGE] = "images/list/ic_tafsir.png";
        }

        adm->replace(i, qvm);
    }
}


void Offloader::backup(QString const& destination)
{
    LOGGER(destination);

    QFutureWatcher<QString>* qfw = new QFutureWatcher<QString>(this);
    connect( qfw, SIGNAL( finished() ), this, SLOT( onBookmarksSaved() ) );

    QFuture<QString> future = QtConcurrent::run(&ThreadUtils::compressBookmarks, destination);
    qfw->setFuture(future);
}


void Offloader::onBookmarksSaved()
{
    QFutureWatcher<QString>* qfw = static_cast< QFutureWatcher<QString>* >( sender() );
    QString result = qfw->result();

    emit backupComplete(result);

    qfw->deleteLater();
}


void Offloader::restore(QString const& source)
{
    LOGGER(source);

    QFutureWatcher<bool>* qfw = new QFutureWatcher<bool>(this);
    connect( qfw, SIGNAL( finished() ), this, SLOT( onBookmarksRestored() ) );

    QFuture<bool> future = QtConcurrent::run(&ThreadUtils::performRestore, source);
    qfw->setFuture(future);
}


void Offloader::onBookmarksRestored()
{
    QFutureWatcher<bool>* qfw = static_cast< QFutureWatcher<bool>* >( sender() );
    bool result = qfw->result();

    LOGGER("RestoreResult" << result);
    emit restoreComplete(result);

    qfw->deleteLater();
}


QString Offloader::textualizeAyats(bb::cascades::DataModel* adm, QVariantList const& selectedIndices, QString const& chapterTitle, bool showTranslation)
{
    QVariantMap first = adm->data( selectedIndices.first().toList() ).toMap();
    QVariantMap last = adm->data( selectedIndices.last().toList() ).toMap();
    int firstChapter = first.value("surah_id").toInt();
    int lastChapter = last.value("surah_id").toInt();
    int firstVerse = first.value("verse_id").toInt();
    int lastVerse = last.value("verse_id").toInt();

    QString footer;
    QStringList ayats;
    QStringList translations;

    if (firstChapter == lastChapter)
    {
        if (firstVerse == lastVerse) {
            footer = tr("%1 %2:%3").arg(chapterTitle).arg(firstChapter).arg(firstVerse);
        } else {
            footer = tr("%1 %2:%3-%4").arg(chapterTitle).arg(firstChapter).arg(firstVerse).arg(lastVerse);
        }
    } else {
        footer = tr("%1:%2-%3:%4").arg(firstChapter).arg(firstVerse).arg(lastChapter).arg(lastVerse);
    }

    int n = selectedIndices.size();

    for (int i = 0; i < n; i++)
    {
        QVariantMap current = adm->data( selectedIndices[i].toList() ).toMap();
        ayats << current.value("arabic").toString();

        if (showTranslation) {
            translations << current.value("translation").toString();
        }
    }

    return ayats.join("\n")+"\n\n"+translations.join("\n")+"\n\n"+footer;
}


qint64 Offloader::getFreeSpace()
{
    bb::FileSystemInfo fs;
    qint64 free = fs.availableFileSystemSpace( m_persist->getValueFor(KEY_OUTPUT_FOLDER).toString() );
    LOGGER("FreeSpace" << free << fs.errorString() << fs.error() );
    return free;
}


void Offloader::addToHomeScreen(int chapter, int verse, QString const& label)
{
    LOGGER(chapter << verse << label);

    bool added = bb::platform::HomeScreen().addShortcut( QString("asset:///images/menu/ic_mushaf.png"), TextUtils::sanitize(label), QString("quran://%1/%2").arg(chapter).arg(verse) );
    QString toastMessage = tr("Added %1 to home screen").arg(label);
    QString icon = "asset:///images/menu/ic_home.png";

    if (!added) {
        toastMessage = tr("Could not add %1 to home screen").arg(label);
        icon = "asset:///images/toast/yellow_delete.png";
    }

    m_persist->showToast(toastMessage, "", icon);
}


void Offloader::addToHomeScreen(qint64 suitePageId, QString const& label)
{
    LOGGER(suitePageId << label);

    bool added = bb::platform::HomeScreen().addShortcut( QString("asset:///images/list/ic_tafsir.png"), TextUtils::sanitize(label), QString("quran://tafsir/%1").arg(suitePageId) );
    QString toastMessage = tr("Added %1 to home screen").arg(label);
    QString icon = "asset:///images/menu/ic_home.png";

    if (!added) {
        toastMessage = tr("Could not add %1 to home screen").arg(label);
        icon = "asset:///images/toast/yellow_delete.png";
    }

    m_persist->showToast(toastMessage, "", icon);
}


Offloader::~Offloader()
{
}

} /* namespace quran */
