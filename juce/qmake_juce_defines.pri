# Author(s) : Loic Touraine

#Note (QT Creator Bug ?): files shown in the project tree are NOT the files used for compiling

include(../qmake_bcom_defines.pri)

!contains(QMAKE_JUCEDEFINES,"defined") {
    message("Including qmake_juce_defines")
    QMAKE_JUCEDEFINES="defined"
    # Check input parameters existence - libs absolute path
    exists("$${_BCOM_LIBS_ROOT_}/libs/bcom-Juce") {
       JUCEFOLDER = "bcom-Juce"
    } else {
        exists("$${_BCOM_LIBS_ROOT_}/libs/Juce") {
            JUCEFOLDER = "Juce"
        } else {
            error("Unable to find Juce submodule folder : check your git repository and clone options")
        }
    }

    JUCEPATH = $${_BCOM_LIBS_ROOT_}/libs/$${JUCEFOLDER}/modules
    message("Using Juce submodule from $${JUCEPATH}")

    VSTSDKPATH = $${_BCOM_LIBS_ROOT_}/libs/Steinberg/VST3_SDK

    exists($${JUCEPATH}/juce_audio_processors/format_types/VST3_SDK) { #Juce 5 embeds VST SDK
        VSTSDKPATH = $${JUCEPATH}/juce_audio_processors/format_types/VST3_SDK
    }
    message("Using VST SDK from $${VSTSDKPATH}")
}
