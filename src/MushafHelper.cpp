#include "precompiled.h"

#include "MushafHelper.h"
#include "AppLogFetcher.h"
#include "CommonConstants.h"
#include "IOUtils.h"
#include "JlCompress.h"
#include "Logger.h"
#include "Persistance.h"
#include "QueryId.h"
#include "QueueDownloader.h"
#include "TextUtils.h"

#define KEY_SETTING_KEEP_AWAKE "keepAwakeDuringPlay"
#define KEY_STRETCH_MUSHAF "stretchMushaf"
#define KEY_TICKET_ID "ticketId"
#define LOCAL_PAGE_PATH "localUri"
#define normalize(a) TextUtils::zeroFill(a,3)
#define TOTAL_PAGES 604
#define AYAT_HOST(hq) qgetenv(hq ? "HOST_HQ_AYATS" : "HOST_LQ_AYATS");

using namespace canadainc;

namespace {

QVariantMap writePage(QVariantMap result, QByteArray const& data)
{
    QUrl path = result.value(LOCAL_PAGE_PATH).toUrl();
    QFileInfo qfi( path.toLocalFile() );

    if ( !qfi.dir().exists() ) {
        qfi.dir().mkpath(".");
    }

    bool success = IOUtils::writeFile( path.toLocalFile(), data );

    if (!success) {
        result[KEY_ERROR] = QObject::tr("The download was corrupt. Please retry the download again...");
    }

    return result;
}

QUrl getPageUrl(QString const& style, QString const& name, int page)
{
    bool style2 = style == "style2";

    QUrl url;
    url.setScheme("http");
    url.setHost( qgetenv("HOST_MUSHAF") );
    url.setPath( QString("quran/images%1/%2.%3").arg(style2 ? "6" : "1").arg( style2 ? TextUtils::zeroFill(page, 4) : name ).arg( style2 ? "JPG" : "jpg" ) );
    return url;
}

QVariantList getMissingPages(QString const& output, QString const& style)
{
    QVariantList missing;

    for (int page = 1; page <= TOTAL_PAGES; page++)
    {
        QString name = normalize(page);
        QString actualPath = QString("%1/%2/%3.jpg").arg(output).arg(style).arg(name);

        QVariantMap q;
        q[LOCAL_PAGE_PATH] = QUrl::fromLocalFile(actualPath);
        q[KEY_TRANSFER_NAME] = QObject::tr("Page #%1").arg(name);

        if ( !QFile::exists(actualPath) )
        {
            q[URI_KEY] = getPageUrl(style, name, page);
            missing << q;
        }
    }

    return missing;
}

}

namespace quran {

using namespace bb::cascades;

MushafHelper::MushafHelper(QueueDownloader* mushafQueue, Persistance* persist, QObject* parent) :
        QObject(parent), m_mushafQueue(mushafQueue), m_persist(persist),
        m_stretch(false), m_active(false), m_keepAwake(false), m_isTopPage(false)
{
}


void MushafHelper::lazyInit()
{
    m_style = m_persist->getValueFor(KEY_MUSHAF_STYLE).toString();
    m_stretch = m_persist->getValueFor(KEY_STRETCH_MUSHAF).toInt() == 1;
    m_keepAwake = m_persist->getValueFor(KEY_SETTING_KEEP_AWAKE).toInt() == 1;

    connect( m_mushafQueue, SIGNAL( requestComplete(QVariant const&, QByteArray const&) ), this, SLOT( onPageDownloaded(QVariant const&, QByteArray const&) ) );
}


void MushafHelper::requestPage(int page)
{
    page = qMin( qMax(1, page), TOTAL_PAGES );
    QString name = normalize(page);

    if ( m_style.isEmpty() ) {
        m_style = "style1";
    }

    QString actualPath = QString("%1/%2/%3.jpg").arg( Persistance::hasSharedFolderAccess() ? m_persist->getValueFor(KEY_OUTPUT_FOLDER).toString() : QDir::homePath() ).arg(m_style).arg(name);

    QVariantMap q;
    q[LOCAL_PAGE_PATH] = QUrl::fromLocalFile(actualPath);
    q[KEY_TRANSFER_NAME] = tr("Page #%1").arg(name);

    if ( !QFile::exists(actualPath) )
    {
        q[URI_KEY] = getPageUrl(m_style, name, page );
        m_mushafQueue->process(q);
    } else {
        emit mushafPageReady(q);
    }
}


void MushafHelper::requestAyat(QObject* caller, int chapter, int verse)
{
    QString name = QString("%1_%2").arg(chapter).arg(verse);
    QString actualPath = QString("%1/%2/%3.png").arg( Persistance::hasSharedFolderAccess() ? m_persist->getValueFor(KEY_OUTPUT_FOLDER).toString() : QDir::homePath() ).arg( ayatImageFolder() ).arg(name);

    QVariantMap q;
    q[LOCAL_PAGE_PATH] = QUrl::fromLocalFile(actualPath);
    q[KEY_TRANSFER_NAME] = tr("Ayat %1").arg(name);
    q[KEY_CHAPTER_ID] = chapter;
    q[KEY_VERSE_ID] = verse;

    if ( !QFile::exists(actualPath) )
    {
        if (caller) {
            q[KEY_TICKET_ID] = m_tickets.stash(caller, QueryId::FetchAyatImage);
        }

        QString host = AYAT_HOST( m_persist->getValueFor(KEY_JOIN_LETTERS) == 2 );
        q[URI_KEY] =QString("%1/%2.png").arg(host).arg(name);
        m_mushafQueue->process(q);
    } else {
        QMetaObject::invokeMethod(caller, "onDataLoaded", Qt::QueuedConnection, Q_ARG(QVariant, QueryId::FetchAyatImage), Q_ARG(QVariant, q) );
    }
}


void MushafHelper::onMissingPagesFound()
{
    QFutureWatcher<QVariantList>* qfw = static_cast< QFutureWatcher<QVariantList>* >( sender() );
    QVariantList result = qfw->result();

    m_mushafQueue->process(result);

    sender()->deleteLater();
}


void MushafHelper::requestEntireMushaf()
{
    QFutureWatcher<QVariantList>* qfw = new QFutureWatcher<QVariantList>(this);
    connect( qfw, SIGNAL( finished() ), this, SLOT( onMissingPagesFound() ) );

    QFuture<QVariantList> future = QtConcurrent::run( getMissingPages, Persistance::hasSharedFolderAccess() ? m_persist->getValueFor(KEY_OUTPUT_FOLDER).toString() : QDir::homePath(), m_style );
    qfw->setFuture(future);
}


void MushafHelper::requestAllAyatImages(QVariantList ayats)
{
    QString outputFolder = Persistance::hasSharedFolderAccess() ? m_persist->getValueFor(KEY_OUTPUT_FOLDER).toString() : QDir::homePath();
    QString imageFolder = ayatImageFolder();
    QString host = AYAT_HOST( m_persist->getValueFor(KEY_JOIN_LETTERS) == 2 );

    for (int i = ayats.size()-1; i >= 0; i--)
    {
        QVariantMap q = ayats[i].toMap();
        int chapter = q.value(KEY_CHAPTER_ID).toInt();
        int verse = q.value(KEY_VERSE_ID).toInt();
        QString name = QString("%1_%2").arg(chapter).arg(verse);
        QString actualPath = QString("%1/%2/%3.png").arg(outputFolder).arg(imageFolder).arg(name);

        q[LOCAL_PAGE_PATH] = QUrl::fromLocalFile(actualPath);
        q[KEY_TRANSFER_NAME] = tr("Surah %1, Ayat %1").arg(chapter).arg(verse);
        q[URI_KEY] = QString("%1/%2.png").arg(name);
        ayats[i] = q;
    }

    m_mushafQueue->process(ayats);
}


void MushafHelper::onPageDownloaded(QVariant const& cookie, QByteArray const& data)
{
    QVariantMap c = cookie.toMap();

    if ( c.contains(LOCAL_PAGE_PATH) )
    {
        LOGGER("LocalPagePath!");
        QFutureWatcher<QVariantMap>* qfw = new QFutureWatcher<QVariantMap>(this);
        connect( qfw, SIGNAL( finished() ), this, SLOT( onWritten() ) );

        QFuture<QVariantMap> future = QtConcurrent::run(writePage, c, data);
        qfw->setFuture(future);
    }
}


void MushafHelper::onWritten()
{
    QFutureWatcher<QVariantMap>* qfw = static_cast< QFutureWatcher<QVariantMap>* >( sender() );
    QVariantMap result = qfw->result();

    if ( result.contains(KEY_ERROR) ) {
        m_persist->showToast( result.value(KEY_ERROR).toString(), "asset:///images/dropdown/ic_cancel_individual.png" );
        m_mushafQueue->updateData(result, true);
        LOGGER("WriteError");
        AppLogFetcher::getInstance()->record( "MushafWriteError", result.value(KEY_ERROR).toString() );
    } else if ( result.contains(LOCAL_PAGE_PATH) ) {
        if ( result.contains(KEY_CHAPTER_ID) && result.contains(KEY_TICKET_ID) ) {
            m_tickets.drop( result[KEY_TICKET_ID].toInt(), result );
        } else {
            emit mushafPageReady(result);
        }

        LOGGER("PageWritten");
    } else {
        LOGGER("UnhandledCase");
    }

    sender()->deleteLater();
}


void MushafHelper::setStretchMushaf(bool stretch)
{
    m_stretch = stretch;
    bool changed = m_persist->saveValueFor(KEY_STRETCH_MUSHAF, m_stretch ? 1 : 0, false);

    if (changed) {
        emit stretchMushafChanged();
    }
}


bool MushafHelper::stretchMushaf() const {
    return m_stretch;
}


QString MushafHelper::mushafStyle() const {
    return m_style;
}


void MushafHelper::setMushafStyle(QString const& mushafStyle)
{
    m_style = mushafStyle;
    bool changed = m_persist->saveValueFor(KEY_MUSHAF_STYLE, m_style, false);

    if (changed) {
        emit mushafStyleChanged();
    }
}


void MushafHelper::refresh()
{
    Application* app = Application::instance();
    app->mainWindow()->setScreenIdleMode( m_keepAwake && m_active && m_isTopPage && app->isFullscreen() && app->isAwake() ? ScreenIdleMode::KeepAwake : ScreenIdleMode::Normal );
    LOGGER( (m_keepAwake && m_active && app->isFullscreen() && app->isAwake())  );
}


bool MushafHelper::active() const {
    return m_active;
}


bool MushafHelper::keepAwake() const {
    return m_keepAwake;
}


void MushafHelper::setActive(bool value)
{
    if (m_active != value)
    {
        m_active = value;
        refresh();

        Application* app = Application::instance();

        if (m_active)
        {
            connect( app, SIGNAL( awake() ), this, SLOT( refresh() ) );
            connect( app, SIGNAL( fullscreen() ), this, SLOT( refresh() ) );
            connect( app, SIGNAL( invisible() ), this, SLOT( refresh() ) );
            connect( app, SIGNAL( thumbnail() ), this, SLOT( refresh() ) );
        } else {
            disconnect( app, SIGNAL( awake() ), this, SLOT( refresh() ) );
            disconnect( app, SIGNAL( fullscreen() ), this, SLOT( refresh() ) );
            disconnect( app, SIGNAL( invisible() ), this, SLOT( refresh() ) );
            disconnect( app, SIGNAL( thumbnail() ), this, SLOT( refresh() ) );
        }
    }
}


void MushafHelper::setKeepAwake(bool value)
{
    if (value != m_keepAwake)
    {
        m_keepAwake = value;
        m_persist->saveValueFor(KEY_SETTING_KEEP_AWAKE, value ? 1 : 0, false);
        emit keepAwakeChanged();

        AppLogFetcher::getInstance()->record( "KeepAwake", value ? "1" : 0 );

        refresh();
    }
}


void MushafHelper::onDestroyed(QObject* q)
{
    Q_UNUSED(q);
    setActive(false);
}


void MushafHelper::onActiveChanged()
{
    bool isActive = sender()->property("playing").toBool();
    setActive(isActive);
}


bool MushafHelper::isTopPage() const {
    return m_isTopPage;
}


void MushafHelper::setIsTopPage(bool value)
{
    if (m_isTopPage != value)
    {
        m_isTopPage = value;
        refresh();
    }
}


void MushafHelper::registerPlayer(QObject* p)
{
    connect( p, SIGNAL( playingChanged() ), this, SLOT( onActiveChanged() ) );
    connect( p, SIGNAL( destroyed(QObject*) ), this, SLOT( onDestroyed(QObject*) ) );
}


QString MushafHelper::ayatImageFolder() {
    return m_persist->getValueFor(KEY_JOIN_LETTERS) == 2 ? "ayats_hq" : "ayats";
}


MushafHelper::~MushafHelper()
{
}

} /* namespace quran */
