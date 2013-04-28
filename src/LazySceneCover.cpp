#include "LazySceneCover.h"
#include "Logger.h"

#include <bb/cascades/Application>
#include <bb/cascades/Control>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/SceneCover>

namespace canadainc {

using namespace bb::cascades;

LazySceneCover::LazySceneCover(QString const& sceneCoverQml)
{
	setProperty("qml", sceneCoverQml);
	connect( Application::instance(), SIGNAL( thumbnail() ), this, SLOT( onThumbnail() ) );
}


void LazySceneCover::setContext(QString const& key, QObject* value) {
	m_context.insert(key, value);
}


void LazySceneCover::onThumbnail()
{
	LOGGER("Thumbnailed");

	if ( Application::instance()->cover() == NULL )
	{
		LOGGER("Creating thumbnail scene cover for first time!");

		QmlDocument* qmlCover = QmlDocument::create( "asset:///"+property("qml").toString() ).parent(this);

		QStringList keys = m_context.keys();

		for (int i = keys.size()-1; i >= 0; i--) {
			qmlCover->setContextProperty( keys[i], m_context.value(keys[i]) );
		}

		Control* sceneRoot = qmlCover->createRootObject<Control>();
		SceneCover* cover = SceneCover::create().content(sceneRoot);
		Application::instance()->setCover(cover);
	}
}


LazySceneCover::~LazySceneCover()
{
}

} /* namespace canadainc */
