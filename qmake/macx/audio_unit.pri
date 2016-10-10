#Those rules depend upon libs/CoreAudioUtilityClasses submodule
#TODO : check if some frameworks can be set in juce_audio_plugin, keeping only AU specific frameworks in this file !
LIBS += -framework AudioUnit
LIBS += -framework AudioToolbox
LIBS += -framework CoreAudio
LIBS += -framework CoreAudioKit
LIBS += -framework CoreMIDI
LIBS += -framework Accelerate
LIBS += -framework Cocoa
LIBS += -framework DiscRecording
LIBS += -framework IOKit
LIBS += -framework OpenGL
LIBS += -framework QTKit
LIBS += -framework QuartzCore
LIBS += -framework WebKit

COREAUDIOPATH=$$_PRO_FILE_PWD_/libs/CoreAudioUtilityClasses/CoreAudio
QMAKE_REZ_FLAGS= -I $${COREAUDIOPATH}/AudioUnits/AUPublic/AUBase -F AudioUnit -F CoreServices -F CarbonCore -i /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/CarbonCore.framework/Versions/A/Headers
QMAKE_CXXFLAGS += -I$${COREAUDIOPATH}/AudioUnits/AUPublic/AUViewBase
QMAKE_CXXFLAGS += -I$${COREAUDIOPATH}/AudioUnits/AUPublic/AUBase
QMAKE_CXXFLAGS += -I$${COREAUDIOPATH}/PublicUtility
QMAKE_CXXFLAGS += -I$${COREAUDIOPATH}/AudioUnits/AUPublic/Utility
QMAKE_OBJECTIVE_CFLAGS += -I$${COREAUDIOPATH}/AudioUnits/AUPublic/AUBase
QMAKE_OBJECTIVE_CFLAGS += -I$${COREAUDIOPATH}/AudioUnits/AUPublic/OtherBases
QMAKE_OBJECTIVE_CFLAGS += -I$${COREAUDIOPATH}/AudioUnits/AUPublic/Utility
QMAKE_OBJECTIVE_CFLAGS += -I$${COREAUDIOPATH}/PublicUtility
   # QMAKE_OBJECTIVE_CFLAGS += -I$${COREAUDIOPATH}/AudioCodecs/ACPublic
   # QMAKE_OBJECTIVE_CFLAGS += -I$${COREAUDIOPATH}/AudioFile/AFPublic

   # QMAKE_OBJECTIVE_CFLAGS += -I$${COREAUDIOPATH}/AudioUnits/AUPublic/AUCarbonViewBase
   # QMAKE_OBJECTIVE_CFLAGS += -I$${COREAUDIOPATH}/AudioUnits/AUPublic/AUInstrumentBase
   # QMAKE_OBJECTIVE_CFLAGS += -I$${COREAUDIOPATH}/AudioUnits/AUPublic/AUViewBase


#Note : don't add AUCarbonViewBase : depends on carbon that depends on HIToolbox that is deprecated since 10.7 and for 64 bits apps
#$${COREAUDIOPATH}/AudioUnits/AUPublic/AUBase/AUResources.r \
#Note : hard inclusion of juce wrappers to refine
SOURCES +=  $${COREAUDIOPATH}/AudioUnits/AUPublic/AUBase/AUBase.cpp \
$${COREAUDIOPATH}/AudioUnits/AUPublic/AUBase/AUInputElement.cpp \
$${COREAUDIOPATH}/AudioUnits/AUPublic/AUBase/AUOutputElement.cpp \
$${COREAUDIOPATH}/AudioUnits/AUPublic/AUBase/AUDispatch.cpp \
$${COREAUDIOPATH}/AudioUnits/AUPublic/AUBase/AUBase.h \
$${COREAUDIOPATH}/AudioUnits/AUPublic/AUBase/AUDispatch.h \
$${COREAUDIOPATH}/AudioUnits/AUPublic/AUBase/AUInputElement.h \
$${COREAUDIOPATH}/AudioUnits/AUPublic/AUBase/AUScopeElement.cpp \
$${COREAUDIOPATH}/AudioUnits/AUPublic/AUBase/ComponentBase.cpp \
$${COREAUDIOPATH}/AudioUnits/AUPublic/OtherBases/AUEffectBase.cpp \
$${COREAUDIOPATH}/AudioUnits/AUPublic/OtherBases/AUMIDIBase.cpp \
$${COREAUDIOPATH}/AudioUnits/AUPublic/OtherBases/AUMIDIEffectBase.cpp \
$${COREAUDIOPATH}/AudioUnits/AUPublic/OtherBases/AUOutputBase.cpp \
$${COREAUDIOPATH}/AudioUnits/AUPublic/OtherBases/MusicDeviceBase.cpp \
$${COREAUDIOPATH}/AudioUnits/AUPublic/Utility/AUBuffer.cpp \
$${COREAUDIOPATH}/PublicUtility/CAAUParameter.cpp \
$${COREAUDIOPATH}/PublicUtility/CAAudioChannelLayout.cpp \
$${COREAUDIOPATH}/PublicUtility/CAMutex.cpp \
$${COREAUDIOPATH}/PublicUtility/CAStreamBasicDescription.cpp \
$${COREAUDIOPATH}/PublicUtility/CAVectorUnit.cpp
#$${COREAUDIOPATH}/AudioUnits/AUPublic/AUCarbonViewBase/AUCarbonViewBase.cpp \
#$${COREAUDIOPATH}/AudioUnits/AUPublic/AUCarbonViewBase/AUCarbonViewControl.cpp \
#$${COREAUDIOPATH}/AudioUnits/AUPublic/AUCarbonViewBase/AUCarbonViewDispatch.cpp \
#$${COREAUDIOPATH}/AudioUnits/AUPublic/AUCarbonViewBase/CarbonEventHandler.cpp
