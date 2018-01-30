# Author(s) : Loic Touraine

#Note (QT Creator Bug ?): files shown in the project tree are NOT the files used for compiling
#The variable $$SOURCES contains the good files' subset and is correctly forwarded to the Makefile

#Inclusion of other modules must occur FIRST !
include(juce_events.pri)

# Check input parameters existence - libs absolute path
!defined(_BCOM_LIBS_ROOT_,var) {
    _BCOM_LIBS_ROOT_ = $$_PRO_FILE_PWD_
    warning("_BCOM_LIBS_ROOT_ is not defined : libs absolute path defaults to [$$_PRO_FILE_PWD_] value")
}

JUCEPATH=$${_BCOM_LIBS_ROOT_}/libs/Juce/modules

QMAKE_JUCEMODULENAME=juce_graphics

!contains(QMAKE_JUCEMODULECONFIG,$${QMAKE_JUCEMODULENAME}) {
	message("Including " $${QMAKE_JUCEMODULENAME})
	QMAKE_JUCEMODULECONFIG += $${QMAKE_JUCEMODULENAME}
	DEFINES += JUCE_MODULE_AVAILABLE_$${QMAKE_JUCEMODULENAME}=1

	!contains(INCLUDEPATH,$${JUCEPATH}) {
		INCLUDEPATH += $${JUCEPATH}
	}

	# Common sources
	SOURCES += \
		$${JUCEPATH}/juce_graphics/juce_graphics.cpp
        macx {
            LIBS += -framework Cocoa
            LIBS += -framework QuartzCore
        }
}
