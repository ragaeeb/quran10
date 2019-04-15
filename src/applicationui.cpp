#include "precompiled.h"

#include "applicationui.hpp"
#include "AppLogFetcher.h"
#include "CommonConstants.h"
#include "IOUtils.h"
#include "Logger.h"
#include "QueryId.h"
#include "ThreadUtils.h"

#define DEFAULT_RECITER "Hudhaify_64kbps"
#define SETTING_KEY_BOOKMARKS "bookmarks"

using namespace bb::cascades;

namespace quran {

using namespace bb::data;
using namespace bb::system;
using namespace canadainc;

ApplicationUI::ApplicationUI(InvokeManager* im) :
        m_sceneCover( im->startupMode() != ApplicationStartupMode::InvokeCard, this ),
        m_persistance(im),
        m_helper(&m_persistance), m_mushaf(&m_queue, &m_persistance),
        m_recitation(&m_queue, &m_persistance), m_offloader(&m_persistance),
        m_invoke(im, &m_helper)
{
    switch ( im->startupMode() )
    {
    	case ApplicationStartupMode::LaunchApplication:
    		init("main.qml");
    		break;

    	case ApplicationStartupMode::InvokeCard:
    	    connect( im, SIGNAL( cardPooled(bb::system::CardDoneMessage const&) ), QCoreApplication::instance(), SLOT( quit() ) );
    	    connect( im, SIGNAL( invoked(bb::system::InvokeRequest const&) ), this, SLOT( invoked(bb::system::InvokeRequest const&) ) );
    	    break;
    	case ApplicationStartupMode::InvokeApplication:
    		connect( im, SIGNAL( invoked(bb::system::InvokeRequest const&) ), this, SLOT( invoked(bb::system::InvokeRequest const&) ) );
    		break;

    	default:
    		break;
    }

    connect( im, SIGNAL( childCardDone(bb::system::CardDoneMessage const&) ), this, SLOT( childCardDone(bb::system::CardDoneMessage const&) ) );
}


void ApplicationUI::invoked(bb::system::InvokeRequest const& request) {
    init( m_invoke.invoked(request) );
}


void ApplicationUI::initDefault()
{
    AppLogFetcher* alf = AppLogFetcher::create( &m_persistance, &ThreadUtils::compressFiles, this, false );

    if ( alf->upgradedApp() )
    {
        QVariant bookmarks = m_persistance.getValueFor(SETTING_KEY_BOOKMARKS);

        m_persistance.clear();
        m_persistance.forceSync();
        m_persistance.saveValueFor(SETTING_KEY_BOOKMARKS, bookmarks, false);

        QtConcurrent::run(ThreadUtils::cleanLegacyPics);
    } else if ( m_persistance.getValueFor(KEY_RECITER).toString() == "Salah_Al_Budair_128kbps" ) {
        m_persistance.saveValueFor(KEY_RECITER, DEFAULT_RECITER, false);
    }

    if ( !m_persistance.contains(KEY_TRANSLATION) )
    {
        QString defaultTranslation = ENGLISH_TRANSLATION;
        QString locale = m_locale.locale().toLower();

        QMap<QString, QString> localeToTranslation;
        localeToTranslation["ar"] = ARABIC_KEY;
        localeToTranslation["de"] = "german";
        localeToTranslation["es"] = "spanish";
        localeToTranslation["fr"] = "french";
        localeToTranslation["id"] = "indo";
        localeToTranslation["ru"] = "russian";
        localeToTranslation["th"] = "thai";

        foreach ( QString const& l, localeToTranslation.keys() )
        {
            if ( locale.startsWith(l) || locale.endsWith(l) ) {
                defaultTranslation = localeToTranslation[l];
            }
        }

        m_persistance.saveValueFor(KEY_TRANSLATION, defaultTranslation);
    }

    INIT_SETTING(KEY_PRIMARY_SIZE, 18);
    INIT_SETTING(KEY_TRANSLATION_SIZE, 12);
    INIT_SETTING(KEY_JOIN_LETTERS, 0);
    INIT_SETTING("repeat", 1);
}


void ApplicationUI::init(QString const& qmlDoc)
{
    initDefault();

    QMap<QString, QObject*> context;
    context.insert( "bookmarkHelper", m_helper.getBookmarkHelper() );
    context.insert("helper", &m_helper);
    context.insert("mushaf", &m_mushaf);
    context.insert("offloader", &m_offloader);
    context.insert("queue", &m_queue);
    context.insert("recitation", &m_recitation);

    m_sceneCover.setContext("helper", &m_helper);

    QmlDocument* qml = QmlDocument::create("asset:///TransfersDialog.qml").parent(this);
    qml->setContextProperty("queue", &m_queue);
    qml->createRootObject<QObject>();

    m_invoke.init(qmlDoc, context, this);

    emit initialize();
}


void ApplicationUI::lazyInit()
{
    disconnect( this, SIGNAL( initialize() ), this, SLOT( lazyInit() ) ); // in case we get invoked again

    INIT_SETTING(KEY_RECITER, DEFAULT_RECITER);
    INIT_SETTING(KEY_OUTPUT_FOLDER, Persistance::hasSharedFolderAccess() ? QString("%1/misc/quran10").arg(directory_local_shared) : QDir::homePath() );
    INIT_SETTING(KEY_MUSHAF_STYLE, "style1");

    connect( Application::instance(), SIGNAL( aboutToQuit() ), &m_queue, SLOT( abort() ) );

    m_helper.lazyInit();
    m_mushaf.lazyInit();
    m_invoke.process();

    QtConcurrent::run( &ThreadUtils::preventIndexing, m_persistance.getValueFor(KEY_OUTPUT_FOLDER).toString() );

    emit lazyInitComplete();
}


void ApplicationUI::onDataLoaded(QVariant id, QVariant data)
{
    QVariantList result = data.toList();
    int q = id.toInt();

    if (q == QueryId::FetchAllChapterAyatCount)
    {
        QFutureWatcher<QVariantList>* qfw = new QFutureWatcher<QVariantList>(this);
        connect( qfw, SIGNAL( finished() ), this, SLOT( onMissingAyatImagesFinished() ) );

        QFuture<QVariantList> future = QtConcurrent::run( &ThreadUtils::allAyatImagesExist, result, Persistance::hasSharedFolderAccess() ? m_persistance.getValueFor(KEY_OUTPUT_FOLDER).toString() : QDir::homePath(), m_mushaf.ayatImageFolder() );
        qfw->setFuture(future);
    }
}


void ApplicationUI::onMissingAyatImagesFinished()
{
    QFutureWatcher<QVariantList>* qfw = static_cast< QFutureWatcher<QVariantList>* >( sender() );
    QVariantList result = qfw->result();

    if ( !result.isEmpty() ) { // redownload
        m_mushaf.requestAllAyatImages(result);
    }

    qfw->deleteLater();
}


void ApplicationUI::checkMissingAyatImages() {
    m_helper.fetchAllChapterAyatCount(this);
}


void ApplicationUI::childCardDone(bb::system::CardDoneMessage const& message)
{
    LOGGER( message.data() );
    emit childCardFinished( message.data() );

    if ( !message.data().isEmpty() ) {
        m_persistance.invokeManager()->sendCardDone(message);
    }
}


ApplicationUI::~ApplicationUI()
{
}

} // quran
