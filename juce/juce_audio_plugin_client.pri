# Author(s) : Loic Touraine

#Note (QT Creator Bug ?): files shown in the project tree are NOT the files used for compiling
#The variable $$SOURCES contains the good files' subset and is correctly forwarded to the Makefile

#Inclusion of other modules must occur FIRST !
include(juce_gui_basics.pri)
include(juce_audio_basics.pri)
include(juce_audio_processors.pri)

# Check input parameters existence - libs absolute path
!defined(_BCOM_LIBS_ROOT_,var) {
    _BCOM_LIBS_ROOT_ = $$_PRO_FILE_PWD_
    warning("_BCOM_LIBS_ROOT_ is not defined : libs absolute path defaults to [$$_PRO_FILE_PWD_] value")
}

JUCEPATH=$${_BCOM_LIBS_ROOT_}/libs/Juce


QMAKE_JUCEMODULENAME=juce_audio_plugin_client

!contains(QMAKE_JUCEMODULECONFIG,$${QMAKE_JUCEMODULENAME}) {
	message("Including " $${QMAKE_JUCEMODULENAME})
	QMAKE_JUCEMODULECONFIG += $${QMAKE_JUCEMODULENAME}
	DEFINES += JUCE_MODULE_AVAILABLE_$${QMAKE_JUCEMODULENAME}=1

	!contains(INCLUDEPATH,$${JUCEPATH}) {
		INCLUDEPATH += $${JUCEPATH}
}

contains(QMAKE_JUCEAUDIOCONFIG,juceVST) {
    JUCE_PLUGIN_BUILD_VST=1
    SOURCES += $${JUCEPATH}/modules/juce_audio_plugin_client/VST/juce_VST_Wrapper.cpp
    INCLUDEPATH += $${_BCOM_LIBS_ROOT_}/libs/Steinberg/CommonVST_3.6
} else {
    JUCE_PLUGIN_BUILD_VST=0
}

contains(QMAKE_JUCEAUDIOCONFIG,juceVST3) {
    JUCE_PLUGIN_BUILD_VST3=1
    SOURCES += $${JUCEPATH}/modules/juce_audio_plugin_client/VST3/juce_VST3_Wrapper.cpp
    INCLUDEPATH += $${_BCOM_LIBS_ROOT_}/libs/Steinberg/CommonVST_3.6
} else {
    JUCE_PLUGIN_BUILD_VST3=0
}

contains(QMAKE_JUCEAUDIOCONFIG,juceAAX) {
    JUCE_PLUGIN_BUILD_AAX=1
    SOURCES += $${JUCEPATH}/modules/juce_audio_plugin_client/AAX/juce_AAX_Wrapper.cpp
} else {
    JUCE_PLUGIN_BUILD_AAX=0
}

contains(QMAKE_JUCEAUDIOCONFIG,juceRTAS) {
    JUCE_PLUGIN_BUILD_RTAS=1
    #TODO : add needed definitions
} else {
    JUCE_PLUGIN_BUILD_RTAS=0
}

contains(QMAKE_JUCEAUDIOCONFIG,juceAU) {
    JUCE_PLUGIN_BUILD_AU=1
} else {
    JUCE_PLUGIN_BUILD_AU=0
}

macx {
    include (../macx/audio_unit.pri)
    contains(QMAKE_JUCEAUDIOCONFIG,juceAAX) {
        QMAKE_BUNDLE_EXTENSION_LIST += .aaxplugin
    }
    contains(QMAKE_JUCEAUDIOCONFIG,juceAU) {
        BCOM_OBJECTIVE_SOURCES += $${JUCEPATH}/modules/juce_audio_plugin_client/AU/juce_AU_Wrapper.mm
        BCOM_REZ_FILES += $${JUCEPATH}/modules/juce_audio_plugin_client/AU/juce_AU_Resources.r
        QMAKE_BUNDLE_EXTENSION_LIST += .component
    }

    contains(QMAKE_JUCEAUDIOCONFIG,juceVST) {
        BCOM_OBJECTIVE_SOURCES += $${JUCEPATH}/modules/juce_audio_plugin_client/VST/juce_VST_Wrapper.mm
    }

    contains(QMAKE_JUCEAUDIOCONFIG,juceVST3) {
        BCOM_OBJECTIVE_SOURCES += $${JUCEPATH}/modules/juce_audio_plugin_client/VST3/juce_VST3_Wrapper.mm
    }

    contains(QMAKE_JUCEAUDIOCONFIG,juceVST|juceVST3) {
        QMAKE_BUNDLE_EXTENSION_LIST += .vst
    }

    contains(QMAKE_JUCEAUDIOCONFIG,juceAAX) {
        BCOM_OBJECTIVE_SOURCES += $${JUCEPATH}/modules/juce_audio_plugin_client/AAX/juce_AAX_Wrapper.mm
        QMAKE_BUNDLE_EXTENSION_LIST += .aaxplugin
    }
    # message("Bundle extension list" $${QMAKE_BUNDLE_EXTENSION_LIST})
}

win32 {
    contains(QMAKE_JUCEAUDIOCONFIG,juceAAX) {
        QMAKE_PLUGIN_EXTENSION_LIST += .aaxplugin
    }
    contains(QMAKE_JUCEAUDIOCONFIG,juceAU|juceVST|juceVST3) {
        QMAKE_PLUGIN_EXTENSION_LIST += .dll
    }
}

# Common sources
SOURCES += \
    $${JUCEPATH}/modules/juce_audio_plugin_client/utility/juce_PluginUtilities.cpp
}
