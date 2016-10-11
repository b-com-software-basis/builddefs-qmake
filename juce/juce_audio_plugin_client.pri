# Author(s) : Loic Touraine

#Note (QT Creator Bug ?): files shown in the project tree are NOT the files used for compiling
#The variable $$SOURCES contains the good files' subset and is correctly forwarded to the Makefile

#Inclusion of other modules must occur FIRST !
include($$_PRO_FILE_PWD_/builddefs/qmake/juce/juce_gui_basics.pri)
include($$_PRO_FILE_PWD_/builddefs/qmake/juce/juce_audio_basics.pri)
include($$_PRO_FILE_PWD_/builddefs/qmake/juce/juce_audio_processors.pri)

JUCEPATH=$$_PRO_FILE_PWD_/libs/Juce


QMAKE_JUCEMODULENAME=juce_audio_plugin_client

!contains(QMAKE_JUCEMODULECONFIG,$${QMAKE_JUCEMODULENAME}) {
	message("Including " $${QMAKE_JUCEMODULENAME})
	QMAKE_JUCEMODULECONFIG += $${QMAKE_JUCEMODULENAME}
	DEFINES += JUCE_MODULE_AVAILABLE_$${QMAKE_JUCEMODULENAME}=1

	!contains(INCLUDEPATH,$${JUCEPATH}) {
		INCLUDEPATH += $${JUCEPATH}
}

contains(QMAKE_JUCEAUDIOCONFIG,juceVST) {
    DEFINES += JUCE_PLUGIN_BUILD_VST=1
    SOURCES += $${JUCEPATH}/modules/juce_audio_plugin_client/VST/juce_VST_Wrapper.cpp
} else {
    DEFINES += JUCE_PLUGIN_BUILD_VST=0
}

contains(QMAKE_JUCEAUDIOCONFIG,juceVST3) {
    DEFINES += JUCE_PLUGIN_BUILD_VST3=1
    SOURCES += $${JUCEPATH}/modules/juce_audio_plugin_client/VST3/juce_VST3_Wrapper.cpp
    INCLUDEPATH += $$_PRO_FILE_PWD_/libs/Steinberg/CommonVST_3.6
} else {
    DEFINES += JUCE_PLUGIN_BUILD_VST3=0
}

contains(QMAKE_JUCEAUDIOCONFIG,juceAAX) {
 DEFINES += JUCE_PLUGIN_BUILD_AAX=1
    SOURCES += $${JUCEPATH}/modules/juce_audio_plugin_client/AAX/juce_AAX_Wrapper.cpp
} else {
    DEFINES += JUCE_PLUGIN_BUILD_AAX=0
}

contains(QMAKE_JUCEAUDIOCONFIG,juceRTAS) {
 DEFINES += JUCE_PLUGIN_BUILD_RTAS=1
    #TODO : add needed definitions
} else {
    DEFINES += JUCE_PLUGIN_BUILD_RTAS=0
}

contains(QMAKE_JUCEAUDIOCONFIG,juceAU) {
    DEFINES += JUCE_PLUGIN_BUILD_AU=1
} else {
    DEFINES += JUCE_PLUGIN_BUILD_AU=0
}

macx {
    include ($$_PRO_FILE_PWD_/builddefs/qmake/macx/audio_unit.pri)
    contains(QMAKE_JUCEAUDIOCONFIG,juceAU) {
        BCOM_OBJECTIVE_SOURCES += $${JUCEPATH}/modules/juce_audio_plugin_client/AU/juce_AU_Wrapper.mm
        BCOM_REZ_FILES += $${JUCEPATH}/modules/juce_audio_plugin_client/AU/juce_AU_Resources.r
    }

    contains(QMAKE_JUCEAUDIOCONFIG,juceVST) {
        BCOM_OBJECTIVE_SOURCES += $${JUCEPATH}/modules/juce_audio_plugin_client/VST/juce_VST_Wrapper.mm
    }

    contains(QMAKE_JUCEAUDIOCONFIG,juceVST3) {
        BCOM_OBJECTIVE_SOURCES += $${JUCEPATH}/modules/juce_audio_plugin_client/VST3/juce_VST3_Wrapper.mm
    }
}

# Common sources
SOURCES += \
    $${JUCEPATH}/modules/juce_audio_plugin_client/utility/juce_PluginUtilities.cpp
}
