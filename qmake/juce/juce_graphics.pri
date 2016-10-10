# Author(s) : Loic Touraine

#Note (QT Creator Bug ?): files shown in the project tree are NOT the files used for compiling
#The variable $$SOURCES contains the good files' subset and is correctly forwarded to the Makefile

#Inclusion of other modules must occur FIRST !
include($$_PRO_FILE_PWD_/builddefs/qmake/juce/juce_core.pri)
include($$_PRO_FILE_PWD_/builddefs/qmake/juce/juce_events.pri)

JUCEPATH=$$_PRO_FILE_PWD_/libs/Juce

QMAKE_JUCEMODULENAME=juceGraphics

!contains(QMAKE_JUCEMODULECONFIG,$${QMAKE_JUCEMODULENAME}) {
message("Including " $${QMAKE_JUCEMODULENAME})
QMAKE_JUCEMODULECONFIG += $${QMAKE_JUCEMODULENAME}
DEFINES += JUCE_MODULE_$${QMAKE_JUCEMODULENAME}=1

!contains(INCLUDEPATH,$${JUCEPATH}) {
    INCLUDEPATH += $${JUCEPATH}
}



# Common sources
SOURCES += \
    $${JUCEPATH}/modules/juce_graphics/juce_graphics.cpp
}
