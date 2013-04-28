APP_NAME = Quran10

CONFIG += qt warn_on cascades10
LIBS += -lbbdata -lbbsystem -lbbcascadespickers -lbbmultimedia

include(config.pri)

device {
    CONFIG(debug, debug|release) {
        # Device-Debug custom configuration
    }

    CONFIG(release, debug|release) {
        # Device-Release custom configuration
    }
}