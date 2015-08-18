#include "precompiled.h"

#include "InvokeHelper.h"
#include "AppLogFetcher.h"
#include "CardUtils.h"
#include "CommonConstants.h"
#include "DeviceUtils.h"
#include "LazyMediaPlayer.h"
#include "Logger.h"
#include "Persistance.h"
#include "QueryHelper.h"
#include "QueryId.h"
#include "ThreadUtils.h"

#define CHAPTER_OK(chapter) chapter > 0 && chapter <= 114
#define INVOKE_AYAT_NUMERIC_PATTERN "[0-9]{1,3}\\s{0,1}:\\s{0,1}[0-9]{1,3}[\\)\\]]|[0-9]{1,3}:[0-9]{1,3}\\s{0,1}-\\s{0,1}[0-9]{1,3}[\\)\\]]"
#define INVOKE_AYAT_TEXT_PATTERN "[A-Za-z\\-']+\\s{0,1}:\\s{0,1}[0-9]{1,3}\\s{0,1}-\\s{0,1}[0-9]{1,3}[\\)\\]]|[A-Za-z\\-']+\\s{0,1}:\\s{0,1}[0-9]{1,3}[\\)\\]]"
#define QML_SURAH_PAGE "SurahPage.qml"
#define QURAN_PREFIX "quran://"
#define TARGET_AYAT_PICKER "com.canadainc.Quran10.ayat.picker"
#define TARGET_BIO "com.canadainc.Quran10.bio.previewer"
#define TARGET_PREVIEW "com.canadainc.Quran10.previewer"
#define TARGET_SHARE "com.canadainc.Quran10.share"
#define TARGET_SEARCH "com.canadainc.Quran10.search"
#define TARGET_SEARCH_PICKER "com.canadainc.Quran10.search.picker"
#define TARGET_SHORTCUT "com.canadainc.Quran10.shortcut"
#define TARGET_SURAH_PICKER "com.canadainc.Quran10.surah.picker"
#define TARGET_TAFSIR_SHORTCUT "com.canadainc.Quran10.tafsir.previewer"
#define TARGET_VERSE_RANGE "com.canadainc.Quran10.verse_range"

namespace quran {

using namespace bb::cascades;
using namespace bb::system;
using namespace canadainc;
using namespace quran;

InvokeHelper::InvokeHelper(InvokeManager* invokeManager, QueryHelper* helper) :
        m_root(NULL), m_invokeManager(invokeManager), m_helper(helper)
{
}


void InvokeHelper::init(QString const& qmlDoc, QMap<QString, QObject*> const& context, QObject* parent)
{
    qmlRegisterUncreatableType<QueryId>("com.canadainc.data", 1, 0, "QueryId", "Can't instantiate");
    qmlRegisterType<canadainc::LazyMediaPlayer>("com.canadainc.data", 1, 0, "LazyMediaPlayer");

    QmlDocument* qml = QmlDocument::create("asset:///GlobalProperties.qml").parent(this);
    QObject* global = qml->createRootObject<QObject>();
    QmlDocument::defaultDeclarativeEngine()->rootContext()->setContextProperty("global", global);

    qml = QmlDocument::create("asset:///NotificationToast.qml").parent(this);
    global = qml->createRootObject<QObject>();
    QmlDocument::defaultDeclarativeEngine()->rootContext()->setContextProperty("notification", global);

    qml = QmlDocument::create("asset:///TutorialTip.qml").parent(this);
    global = qml->createRootObject<QObject>();
    QmlDocument::defaultDeclarativeEngine()->rootContext()->setContextProperty("tutorial", global);

    m_root = CardUtils::initAppropriate(qmlDoc, context, parent);
}


QString InvokeHelper::invoked(bb::system::InvokeRequest const& request)
{
    LOGGER( request.action() << request.target() << request.mimeType() << request.metadata() << request.uri().toString() << QString( request.data() ) );

    QString target = request.target();

    if (target == TARGET_SHORTCUT)
    {
        QString uri = request.uri().toString();

        if ( uri.isEmpty() && !request.data().isEmpty() ) {
            uri = QString::fromUtf8( request.data().data() );
        }

        if ( uri.startsWith( QString("%1tafsir").arg(QURAN_PREFIX) ) ) {
            target = TARGET_TAFSIR_SHORTCUT;
        } else if ( uri.startsWith( QString("%1bio").arg(QURAN_PREFIX) ) ) {
            target = TARGET_BIO;
        }
    }

    QMap<QString,QString> targetToQML;
    targetToQML[TARGET_AYAT_PICKER] = QML_SURAH_PAGE;
    targetToQML[TARGET_BIO] = "IndividualBioPage.qml";
    targetToQML[TARGET_PREVIEW] = "AyatPage.qml";
    targetToQML[TARGET_SEARCH] = "SearchPage.qml";
    targetToQML[TARGET_SEARCH_PICKER] = "SearchPage.qml";
    targetToQML[TARGET_SHARE] = "AyatPage.qml";
    targetToQML[TARGET_SHORTCUT] = "AyatPage.qml";
    targetToQML[TARGET_SURAH_PICKER] = "SurahPickerPage.qml";
    targetToQML[TARGET_TAFSIR_SHORTCUT] = "AyatTafsirPage.qml";
    targetToQML[TARGET_VERSE_RANGE] = QML_SURAH_PAGE;

    QString qml = targetToQML.value(target);

    if ( qml.isNull() ) {
        qml = QML_SURAH_PAGE;
    }

    if (target == TARGET_SHARE) {
        m_helper->disable();
    }

    m_request = request;
    m_request.setTarget(target);

    return qml;
}


void InvokeHelper::process()
{
    QString target = m_request.target();
    bool pending = false;

    if ( !target.isNull() )
    {
        if (target == TARGET_SEARCH || target == TARGET_SEARCH_PICKER)
        {
            QString searchText = QString( m_request.data() );
            m_root->setProperty("searchText", searchText);
            AppLogFetcher::getInstance()->record(target, searchText);

            if (target == TARGET_SEARCH_PICKER) {
                connect( m_root, SIGNAL( picked(int, int) ), this, SLOT( onPicked(int, int) ) );
            } else {
                connect( m_root, SIGNAL( picked(int, int) ), this, SLOT( onSearchPicked(int, int) ) );
            }
        } else if (target == TARGET_BIO) {
            QString id;

            if ( !m_request.data().isEmpty() )
            {
                id = QString::fromUtf8( m_request.data().data() );
                m_request.setUri(id);
            }

            if ( !m_request.uri().isEmpty() ) {
                id = m_request.uri().toString(QUrl::RemoveScheme).mid(2).split("/").last();
            }

            if ( !id.isNull() )
            {
                m_root->setProperty( "individualId", id.toLongLong() );
                AppLogFetcher::getInstance()->record(target, id);
            } else {
                AppLogFetcher::getInstance()->record("InvalidBioID", m_request.uri().toString());
                finishWithToast( tr("Invalid BioID entered! Please file a bug report by swiping down from the top-bezel and choosing 'Bug Reports' and then clicking 'Submit Logs'. Please ensure the problem is reproduced before you file the report. JazakAllahu khayr!") );
            }
        } else if (target == TARGET_TAFSIR_SHORTCUT) {
            if ( !m_request.data().isEmpty() )
            {
                QByteArray q = m_request.data();
                m_request.setUri( QString::fromUtf8( q.data() ) );
            }

            QStringList tokens = m_request.uri().toString(QUrl::RemoveScheme).mid(2).split("/");

            if ( tokens.size() > 1 && tokens.first() == "tafsir" ) {
                qint64 id = tokens.last().toLongLong();
                m_root->setProperty("suitePageId", id);
                AppLogFetcher::getInstance()->record(target, tokens.last());
            } else {
                AppLogFetcher::getInstance()->record("InvalidTafsir", m_request.uri().toString());
                finishWithToast( tr("Invalid invocation scheme entered! Please file a bug report by swiping down from the top-bezel and choosing 'Bug Reports' and then clicking 'Submit Logs'. Please ensure the problem is reproduced before you file the report. JazakAllahu khayr!") );
            }
        } else if (target == TARGET_SURAH_PICKER) {
            connect( m_root, SIGNAL( picked(int, int) ), this, SLOT( onPicked(int, int) ) );
            QMetaObject::invokeMethod(m_root, "ready", Qt::QueuedConnection);
            AppLogFetcher::getInstance()->record(target);
        } else if (target == TARGET_AYAT_PICKER) {
            QString src = QString( m_request.data() );
            int chapter = src.toInt();

            if ( CHAPTER_OK(chapter) )
            {
                connect( m_root, SIGNAL( picked(int, int) ), this, SLOT( onPicked(int, int) ) );

                m_root->setProperty(KEY_SURAH_ID, chapter);
                m_root->setProperty("showContextMenu", false);
                AppLogFetcher::getInstance()->record(target, src);
            } else {
                AppLogFetcher::getInstance()->record("InvalidSurah", src);
                finishWithToast( tr("Invalid surah specified!") );
            }
        } else if (target == TARGET_PREVIEW || target == TARGET_SHORTCUT || target == TARGET_VERSE_RANGE) {
            QString data = QString( m_request.data() );
            QString uri = m_request.uri().toString();
            int chapter = 0;
            int verse = 0;

            if (target == TARGET_VERSE_RANGE) {
                connect( m_root, SIGNAL( picked(int, int) ), this, SLOT( onSearchPicked(int, int) ) );
            }

            if ( !data.isEmpty() )
            {
                if ( QRegExp(INVOKE_AYAT_NUMERIC_PATTERN).exactMatch(data) )
                {
                    data.chop(1); // remove bracket
                    QStringList tokens = data.split(":");
                    chapter = tokens.takeFirst().trimmed().toInt();
                    tokens = tokens.last().split("-");
                    verse = tokens.takeFirst().trimmed().toInt();
                } else if ( QRegExp(INVOKE_AYAT_TEXT_PATTERN).exactMatch(data) ) {
                    QStringList tokens = data.split(":");
                    QString chapterName = tokens.takeFirst();
                    pending = true;

                    if ( m_helper->showTranslation() ) {
                        m_helper->fetchChapters(this);
                    } else {
                        finishWithToast( tr("Translation must be set to other than 'None' for invocations to work.") );
                    }
                }
            } else if ( uri.startsWith(QURAN_PREFIX) ) {
                uri = uri.mid( QString(QURAN_PREFIX).length() );
                QStringList tokens = uri.split("/");

                if ( !tokens.isEmpty() )
                {
                    chapter = tokens.takeFirst().toInt();

                    if ( !tokens.isEmpty() ) {
                        verse = tokens.first().toInt();
                    }
                }
            }

            if ( CHAPTER_OK(chapter) )
            {
                m_root->setProperty(KEY_SURAH_ID, chapter);

                if (verse > 0) {
                    m_root->setProperty(KEY_VERSE_NUMBER, verse);
                }

                AppLogFetcher::getInstance()->record(target, QString("%1:%2").arg(chapter).arg(verse));
            } else if (!pending) {
                AppLogFetcher::getInstance()->record("InvalidSurah", QString::number(chapter));
                finishWithToast( tr("Invalid surah specified") );
            }
        } else if (target == TARGET_SHARE) {
            if ( AppLogFetcher::getInstance()->adminEnabled() )
            {
                QFutureWatcher<bool>* qfw = new QFutureWatcher<bool>(this);
                connect( qfw, SIGNAL( finished() ), this, SLOT( onDatabasePorted() ) );
                QFuture<bool> future = QtConcurrent::run( &ThreadUtils::replaceDatabase, m_request.uri().toLocalFile() );
                qfw->setFuture(future);
            } else {
                finishWithToast( tr("This operation is not currently supported by Quran10 yet but may be added in the future.") );
            }
        }
    }
}


void InvokeHelper::onDataLoaded(QVariant id, QVariant data)
{
    QVariantList result = data.toList();
    int q = id.toInt();

    if (q == QueryId::FetchChapters)
    {
        QStringList tokens = QString( m_request.data() ).trimmed().split(":");

        if ( !tokens.isEmpty() )
        {
            QVariantMap input;
            input[KEY_TRANSLITERATION] = tokens.first().trimmed();

            QString verseData = tokens.last().trimmed();
            verseData.chop(1); // remove bracket
            input[KEY_VERSE_NUMBER] = verseData.split("-").first().trimmed().toInt();

            QFutureWatcher<QVariantMap>* qfw = new QFutureWatcher<QVariantMap>(this);
            connect( qfw, SIGNAL( finished() ), this, SLOT( onChapterMatched() ) );
            QFuture<QVariantMap> future = QtConcurrent::run( &ThreadUtils::matchSurah, input, data.toList() );
            qfw->setFuture(future);
        } else {
            m_chapters.clear();

            QVariantList all = data.toList();

            foreach (QVariant q, all)
            {
                QVariantMap current = q.toMap();
                m_chapters.insert( current.value(KEY_TRANSLITERATION).toString(), current.value(KEY_CHAPTER_ID).toInt() );
            }
        }
    }
}


QMap<QString, int> InvokeHelper::getChapterNames() {
    return m_chapters;
}


void InvokeHelper::onChapterMatched()
{
    QFutureWatcher<QVariantMap>* qfw = static_cast< QFutureWatcher<QVariantMap>* >( sender() );
    QVariantMap result = qfw->result();
    LOGGER(result);

    if ( result.contains(KEY_CHAPTER_ID) ) {
        m_root->setProperty( KEY_SURAH_ID, result.value(KEY_CHAPTER_ID).toInt() );
        m_root->setProperty( KEY_VERSE_NUMBER, result.value(KEY_VERSE_NUMBER).toInt() );
        LOGGER( result.value(KEY_CHAPTER_ID).toInt() << result.value(KEY_VERSE_NUMBER).toInt() );
    } else {
        AppLogFetcher::getInstance()->record( "InvalidSurah", result.value(KEY_TRANSLITERATION).toString() );
        finishWithToast( tr("Invalid surah specified!") );
    }

    sender()->deleteLater();
}


void InvokeHelper::finishWithToast(QString const& message)
{
    Persistance::showBlockingDialog( tr("Quran10"), message, tr("OK"), "" );
    m_invokeManager->sendCardDone( CardDoneMessage() );
}


void InvokeHelper::onPicked(int chapter, int verse)
{
    CardDoneMessage cdm;
    cdm.setDataType("text/chapter_verse_number");
    cdm.setData( QString("%1/%2").arg(chapter).arg(verse) );
    cdm.setReason( QString("%1/%2").arg( m_request.target() ).arg( m_request.action() ) );

    m_invokeManager->sendCardDone(cdm);
}


void InvokeHelper::onDatabasePorted()
{
    QFutureWatcher<bool>* qfw = static_cast< QFutureWatcher<bool>* >( sender() );
    bool copied = qfw->result();

    LOGGER(copied);

    qfw->deleteLater();

    finishWithToast( copied ? tr("Database ported successfully!") : tr("Database could not be copied!") );
}


void InvokeHelper::onSearchPicked(int chapter, int verse)
{
    InvokeRequest request;
    request.setTarget("com.canadainc.Quran10.previewer");
    request.setUri( QString("%1%2/%3").arg(QURAN_PREFIX).arg(chapter).arg(verse) );
    m_invokeManager->invoke(request);
}


InvokeHelper::~InvokeHelper()
{
}

} /* namespace admin */
