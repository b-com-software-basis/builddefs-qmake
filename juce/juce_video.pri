# Author(s) : Loic Touraine

#Note (QT Creator Bug ?): files shown in the project tree are NOT the files used for compiling
#The variable $$SOURCES contains the good files' subset and is correctly forwarded to the Makefile

#Inclusion of other modules must occur FIRST !
include(juce_gui_extra.pri)

QMAKE_JUCEMODULENAME=juce_video

!contains(QMAKE_JUCEMODULECONFIG,$${QMAKE_JUCEMODULENAME}) {
    message("Including " $${QMAKE_JUCEMODULENAME})
    QMAKE_JUCEMODULECONFIG += $${QMAKE_JUCEMODULENAME}
    DEFINES += JUCE_MODULE_AVAILABLE_$${QMAKE_JUCEMODULENAME}=1

    !contains(INCLUDEPATH,$${JUCEPATH}) {
        INCLUDEPATH += $${JUCEPATH}
    }

    # Common sources
    SOURCES += \
            $${JUCEPATH}/juce_video/juce_video.cpp

    macx {
        !contains(LIBS,"AVKit") {
            LIBS += -framework AVKit
        }
        !contains(LIBS,"AVFoundation") {
            LIBS += -framework AVFoundation
        }
        !contains(LIBS,"CoreMedia") {
            LIBS += -framework CoreMedia
        }
    }
}
