#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include "LazySceneCover.h"
#include "Persistance.h"

namespace bb {
	namespace cascades {
		class Application;
	}
}

namespace quran {

using namespace canadainc;

class ApplicationUI : public QObject
{
	Q_OBJECT

	LazySceneCover m_sceneCover;
	Persistance m_persistance;

    ApplicationUI(bb::cascades::Application *app);

public:
	static void create(bb::cascades::Application* app);
    virtual ~ApplicationUI();
};

} // salat

#endif /* ApplicationUI_HPP_ */
