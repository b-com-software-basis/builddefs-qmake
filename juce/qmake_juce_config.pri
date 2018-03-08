# Author(s) : Loic Touraine

# Check input parameters existence
!defined(QMAKE_JUCEAUDIOCONFIG,var) {
    error("QMAKE_JUCEAUDIOCONFIG must be defined before qmake_juce_config.pri inclusion")
}
!defined(JUCEPLUGIN_PLUGINCODE,var) {
    error("JUCEPLUGIN_PLUGINCODE must be defined before qmake_juce_config.pri inclusion")
}

for (audio_config, QMAKE_JUCEAUDIOCONFIG) {
    !defined(JUCEPLUGIN_CATEGORY.$${audio_config},var) {
        error("JUCEPLUGIN_CATEGORY not defined for audio configuration $${audio_config}")
    }
}


# Include needed juce files for audio plugins
include(juce_audio_devices.pri)
include(juce_audio_plugin_client.pri)
include(juce_opengl.pri)

# Include product configuration definitions
#include($$_PRO_FILE_PWD_/_ProductConfig.pri)
JUCEPLUGIN_PROJECTNAME=$${TARGET}
DEFINES += JUCEPLUGIN_PROJECTNAME=$${JUCEPLUGIN_PROJECTNAME}

DEFINES += JUCE_APP_CONFIG_HEADER=\\\"AppConfig.h\\\"

# Handle audio unit plugin category to audio unit plist type transcription
equals(JUCEPLUGIN_CATEGORY.juceAU,kAudioUnitType_Effect)|equals(JUCEPLUGIN_CATEGORY.juceAUv3,kAudioUnitType_Effect) {
    JUCEPLUGIN_AUTYPE = aufx
    defined(JUCEPLUGIN_CATEGORY.juceAUv3,var) {
        !defined(JUCEPLUGIN_AUV3TAGS,var) {
            JUCEPLUGIN_AUV3TAGS = Effects
        }
    }
}
equals(JUCEPLUGIN_CATEGORY.juceAU,kAudioUnitType_Generator)|equals(JUCEPLUGIN_CATEGORY.juceAUv3,kAudioUnitType_Generator) {
    JUCEPLUGIN_AUTYPE = augn
    defined(JUCEPLUGIN_CATEGORY.juceAUv3,var) {
        !defined(JUCEPLUGIN_AUV3TAGS,var) {
            JUCEPLUGIN_AUV3TAGS = Generator
        }
    }
}
equals(JUCEPLUGIN_CATEGORY.juceAU,kAudioUnitType_MusicDevice)|equals(JUCEPLUGIN_CATEGORY.juceAUv3,kAudioUnitType_MusicDevice) {
    JUCEPLUGIN_AUTYPE = aumu
    defined(JUCEPLUGIN_CATEGORY.juceAUv3,var) {
        !defined(JUCEPLUGIN_AUV3TAGS,var) {
            JUCEPLUGIN_AUV3TAGS = Synthesizer
        }
    }
}
equals(JUCEPLUGIN_CATEGORY.juceAU,kAudioUnitType_MusicEffect)|equals(JUCEPLUGIN_CATEGORY.juceAUv3,kAudioUnitType_MusicEffect) {
    JUCEPLUGIN_AUTYPE = aufm
    defined(JUCEPLUGIN_CATEGORY.juceAUv3,var) {
        !defined(JUCEPLUGIN_AUV3TAGS,var) {
            JUCEPLUGIN_AUV3TAGS = Effects
        }
    }
}
JUCEPLUGIN_AUSUBTYPE=$${JUCEPLUGIN_PLUGINCODE}
JUCEPLUGIN_AUEXPORTPREFIX=$${JUCEPLUGIN_PROJECTNAME}AU
JUCEPLUGIN_AUEXPORTPREFIXQUOTED="$${JUCEPLUGIN_PROJECTNAME}AU"

exists(JuceHeader.h):exists(AppConfig.h.in) {
    HEADERS += \
        builddefs/qmake/juce/JuceHeader.h \
        builddefs/qmake/juce/AppConfig.h.in \
        $$OUT_PWD/AppConfig.h
}

!exists(JuceHeader.h)|!exists(AppConfig.h.in) {
    error("Missing builddefs/qmake/juce/JuceHeader.h and/or builddefs/qmake/juce/AppConfig.h.in files")
}

exists($$_PRO_FILE_PWD_/includes/BinaryData.h):exists($$_PRO_FILE_PWD_/src/BinaryData.cpp) {
    DEFINES += JUCE_WITHBINARYDATA
    HEADERS += includes/BinaryData.h
    SOURCES += src/BinaryData.cpp
}

APPCONFIG_FILEPATH=AppConfig.h.in
exists($${APPCONFIG_FILEPATH}) {
    APPCONFIG_IN_CONTENT = $$cat($${APPCONFIG_FILEPATH},lines)
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCE_PLUGIN_BUILD_VST@", $${JUCE_PLUGIN_BUILD_VST})
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCE_PLUGIN_BUILD_VST3@", $${JUCE_PLUGIN_BUILD_VST3})
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCE_PLUGIN_BUILD_AU@", $${JUCE_PLUGIN_BUILD_AU})
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCE_PLUGIN_BUILD_AUV3@", $${JUCE_PLUGIN_BUILD_AUV3})
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCE_PLUGIN_BUILD_RTAS@", $${JUCE_PLUGIN_BUILD_RTAS})
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCE_PLUGIN_BUILD_AAX@", $${JUCE_PLUGIN_BUILD_AAX})
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCEPLUGIN_NAME@", "$${PRODUCT_MANUFACTURER} $${PRODUCT_NAME}")
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCEPLUGIN_MANUFACTURER@", $${PRODUCT_MANUFACTURER})
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCEPLUGIN_MANUFACTURERCODE@", $${PRODUCT_MANUFACTURERCODE})
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCEPLUGIN_PLUGINCODE@", $${JUCEPLUGIN_PLUGINCODE})
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCEPLUGIN_DESC@", $${PRODUCT_DESCRIPTION})
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCEPLUGIN_VERSIONCODE@", $${PRODUCT_VERSIONCODE})
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCEPLUGIN_VERSION@", $${PRODUCT_VERSION})
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCEPLUGIN_VERSIONSTRING@", $${PRODUCT_VERSIONSTRING})
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCEPLUGIN_AAXCATEGORY@", $${JUCEPLUGIN_CATEGORY.juceAAX})
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCEPLUGIN_AUMAINTYPE@", $${JUCEPLUGIN_CATEGORY.juceAU})
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCEPLUGIN_AUSUBTYPE@", $${JUCEPLUGIN_AUSUBTYPE})
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCEPLUGIN_AUEXPORTPREFIX@", $${JUCEPLUGIN_AUEXPORTPREFIX})
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCEPLUGIN_AUEXPORTPREFIXQUOTED@", $${JUCEPLUGIN_AUEXPORTPREFIXQUOTED})
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCEPLUGIN_VSTCATEGORY@", $${JUCEPLUGIN_CATEGORY.juceVST})
    APPCONFIG_IN_CONTENT = $$replace(APPCONFIG_IN_CONTENT, "@JUCEPLUGIN_CFBUNDLEIDENTIFIER@", "com.bcom.$${PRODUCT_NAME}")
    write_file($$OUT_PWD/AppConfig.h, APPCONFIG_IN_CONTENT)
    QMAKE_DISTCLEAN += $$OUT_PWD/AppConfig.h
}

JUCEHEADER_FILEPATH=JuceHeader.h
exists($${JUCEHEADER_FILEPATH}) {
    JUCEHEADER_CONTENT = $$cat($${JUCEHEADER_FILEPATH},lines)
    write_file($$OUT_PWD/JuceHeader.h, JUCEHEADER_CONTENT)
    QMAKE_DISTCLEAN += $$OUT_PWD/JuceHeader.h
}
INCLUDEPATH += $$OUT_PWD


