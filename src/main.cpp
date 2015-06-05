#include "precompiled.h"

#include "applicationui.hpp"
#include "Logger.h"

using namespace bb::cascades;
using namespace quran;

Q_DECL_EXPORT int main(int argc, char **argv)
{
    Application app(argc, argv);

    registerLogging( QString::number( app.applicationPid() ) );
    ApplicationUI ui;

    return Application::exec();
}
