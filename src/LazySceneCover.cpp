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


void LazySceneCover::onThumbnail()
{
	LOGGER("Thumbnailed");

	if ( Application::instance()->cover() == NULL )
	{
		LOGGER("Creating thumbnail scene cover for first time!");

		QmlDocument* qmlCover = QmlDocument::create( "asset:///"+property("qml").toString() ).parent(this);
		Control* sceneRoot = qmlCover->createRootObject<Control>();
		SceneCover* cover = SceneCover::create().content(sceneRoot);
		Application::instance()->setCover(cover);
	}
}


LazySceneCover::~LazySceneCover()
{
}

} /* namespace canadainc */
