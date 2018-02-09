# Author(s) : Loic Touraine

include(qmake_juce_defines.pri)

QMAKE_JUCEMODULENAME=juce_core

!contains(QMAKE_JUCEMODULECONFIG,$${QMAKE_JUCEMODULENAME}) {
	message("Including " $${QMAKE_JUCEMODULENAME})
	QMAKE_JUCEMODULECONFIG += $${QMAKE_JUCEMODULENAME}
	DEFINES += JUCE_MODULE_AVAILABLE_$${QMAKE_JUCEMODULENAME}=1

	!contains(INCLUDEPATH,$${JUCEPATH}) {
		INCLUDEPATH += $${JUCEPATH}
	}

	# Specific DEBUG/RELEASE juce mandatory defines (also mandatory for VST/VST3 build)
	CONFIG(debug,debug|release) {
	    DEFINES += _DEBUG=1
	    DEFINES += DEBUG=1
	}

	CONFIG(release,debug|release) {
	    DEFINES += _NDEBUG=1
	    DEFINES += NDEBUG=1
	}

	# Common sources
	SOURCES += \
                $${JUCEPATH}/juce_core/juce_core.cpp
}
