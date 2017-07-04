# Author(s) : Loic Touraine

#Note (QT Creator Bug ?): files shown in the project tree are NOT the files used for compiling
#The variable $$SOURCES contains the good files' subset and is correctly forwarded to the Makefile

# Check input parameters existence - libs absolute path
!defined(_BCOM_LIBS_ROOT_,var) {
    _BCOM_LIBS_ROOT_ = $$_PRO_FILE_PWD_
    warning("_BCOM_LIBS_ROOT_ is not defined : libs absolute path defaults to [$$_PRO_FILE_PWD_] value")
}

JUCEPATH=$${_BCOM_LIBS_ROOT_}/libs/Juce

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
		$${JUCEPATH}/modules/juce_core/juce_core.cpp
}
