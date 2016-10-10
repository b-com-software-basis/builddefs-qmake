# Author(s) : Loic Touraine

#Note (QT Creator Bug ?): files shown in the project tree are NOT the files used for compiling
#The variable $$SOURCES contains the good files' subset and is correctly forwarded to the Makefile
JUCEPATH=$$_PRO_FILE_PWD_/libs/Juce

QMAKE_JUCEMODULENAME=juce_data_structures

!contains(QMAKE_JUCEMODULECONFIG,$${QMAKE_JUCEMODULENAME}) {
message("Including " $${QMAKE_JUCEMODULENAME})
QMAKE_JUCEMODULECONFIG += $${QMAKE_JUCEMODULENAME}
DEFINES += JUCE_MODULE_AVAILABLE_$${QMAKE_JUCEMODULENAME}=1

!contains(INCLUDEPATH,$${JUCEPATH}) {
    INCLUDEPATH += $${JUCEPATH}
}

# Common sources
SOURCES += \
    $${JUCEPATH}/modules/juce_data_structures/juce_data_structures.cpp
}
