# Author(s) : Loic Touraine

#Note (QT Creator Bug ?): files shown in the project tree are NOT the files used for compiling
#The variable $$SOURCES contains the good files' subset and is correctly forwarded to the Makefile

#Inclusion of other modules must occur FIRST !
include(juce_gui_basics.pri)
include(juce_audio_basics.pri)
include(juce_audio_processors.pri)

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
    SOURCES += $${JUCEPATH}/juce_audio_plugin_client/VST/juce_VST_Wrapper.cpp
    INCLUDEPATH += $${VSTSDKPATH}
} else {
    JUCE_PLUGIN_BUILD_VST=0
}

contains(QMAKE_JUCEAUDIOCONFIG,juceVST3) {
    JUCE_PLUGIN_BUILD_VST3=1
    SOURCES += $${JUCEPATH}/juce_audio_plugin_client/VST3/juce_VST3_Wrapper.cpp
    INCLUDEPATH += $${VSTSDKPATH}
} else {
    JUCE_PLUGIN_BUILD_VST3=0
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

contains(QMAKE_JUCEAUDIOCONFIG,juceAUv3) {
    JUCE_PLUGIN_BUILD_AUV3=1
} else {
    JUCE_PLUGIN_BUILD_AUV3=0
}

 contains(QMAKE_JUCEAUDIOCONFIG,juceAAX) {
        JUCE_PLUGIN_BUILD_AAX=1
    } else {
        JUCE_PLUGIN_BUILD_AAX=0
    }

macx {
    contains(QMAKE_JUCEAUDIOCONFIG,juceAAX) {
        OBJECTIVE_SOURCES += $${JUCEPATH}/juce_audio_plugin_client/juce_audio_plugin_client_AAX.mm
        QMAKE_BUNDLE_EXTENSION_LIST += .aaxplugin
    }

    contains(QMAKE_JUCEAUDIOCONFIG,juceAU) {
        OBJECTIVE_SOURCES += $${JUCEPATH}/juce_audio_plugin_client/juce_audio_plugin_client_AU_1.mm
        OBJECTIVE_SOURCES += $${JUCEPATH}/juce_audio_plugin_client/juce_audio_plugin_client_AU_2.mm
    }

    contains(QMAKE_JUCEAUDIOCONFIG,juceAUv3) {
        OBJECTIVE_SOURCES += $${JUCEPATH}/juce_audio_plugin_client/juce_audio_plugin_client_AUv3.mm
        QMAKE_BUNDLE_EXTENSION_LIST += .appex
    }

    contains(QMAKE_JUCEAUDIOCONFIG,juceAU) {
        QMAKE_BUNDLE_EXTENSION_LIST += .component
    }

    contains(QMAKE_JUCEAUDIOCONFIG,juceAU|juceAUv3) {
        !contains(LIBS,"AudioUnit") {
            LIBS += -framework AudioUnit
        }

        REMAKEN_REZ_FILES += $${JUCEPATH}/juce_audio_plugin_client/juce_audio_plugin_client_AU.r
        QMAKE_REZ_FLAGS= -F AudioUnit -F CoreServices -F CarbonCore -i /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/CarbonCore.framework/Versions/A/Headers
    }

    contains(QMAKE_JUCEAUDIOCONFIG,juceVST|juceVST3) {
        OBJECTIVE_SOURCES += $${JUCEPATH}/juce_audio_plugin_client/juce_audio_plugin_client_VST_utils.mm
    }

    contains(QMAKE_JUCEAUDIOCONFIG,juceVST) {
        QMAKE_BUNDLE_EXTENSION_LIST += .vst
    }

    contains(QMAKE_JUCEAUDIOCONFIG,juceVST3) {
        QMAKE_BUNDLE_EXTENSION_LIST += .vst3
    }

    # message("Bundle extension list" $${QMAKE_BUNDLE_EXTENSION_LIST})
}

win32 {
    contains(QMAKE_JUCEAUDIOCONFIG,juceAAX) {
        SOURCES += $${JUCEPATH}/juce_audio_plugin_client/AAX/juce_AAX_Wrapper.cpp
        QMAKE_PLUGIN_EXTENSION_LIST += .aaxplugin
    }
    
    contains(QMAKE_JUCEAUDIOCONFIG,juceAU|juceVST) {
        QMAKE_PLUGIN_EXTENSION_LIST += .dll
    }

    contains(QMAKE_JUCEAUDIOCONFIG,juceVST3) {
        QMAKE_PLUGIN_EXTENSION_LIST += .vst3
    }
}

# Common sources
SOURCES += \
    $${JUCEPATH}/juce_audio_plugin_client/utility/juce_PluginUtilities.cpp
}
