# Author(s) : Loic Touraine

#Note (QT Creator Bug ?): files shown in the project tree are NOT the files used for compiling
#The variable $$SOURCES contains the good files' subset and is correctly forwarded to the Makefile

#Inclusion of other modules must occur FIRST !
include(juce_audio_formats.pri)

QMAKE_JUCEMODULENAME=juce_dsp

!contains(QMAKE_JUCEMODULECONFIG,$${QMAKE_JUCEMODULENAME}) {
    message("Including " $${QMAKE_JUCEMODULENAME})
    QMAKE_JUCEMODULECONFIG += $${QMAKE_JUCEMODULENAME}
    DEFINES += JUCE_MODULE_AVAILABLE_$${QMAKE_JUCEMODULENAME}=1

    !contains(INCLUDEPATH,$${JUCEPATH}) {
        INCLUDEPATH += $${JUCEPATH}
    }

    # Common sources
    SOURCES += \
            $${JUCEPATH}/juce_dsp/juce_dsp.cpp

    macx {
        !contains(LIBS,"Accelerate") {
            LIBS += -framework Accelerate
        }
    }
}
