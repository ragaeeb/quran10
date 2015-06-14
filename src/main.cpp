#include "precompiled.h"

#include "applicationui.hpp"
#include "Logger.h"

using namespace bb::cascades;
using namespace quran;

Q_DECL_EXPORT int main(int argc, char **argv)
{
    Application app(argc, argv);

    bb::system::InvokeManager i;
    registerLogging( i.startupMode() == bb::system::ApplicationStartupMode::InvokeCard ? CARD_LOG : UI_LOG );

    ApplicationUI appui(&i);

    return Application::exec();
}
