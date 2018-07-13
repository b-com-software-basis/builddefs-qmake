#Those rules depend upon libs/UnityNativeAudioPlugin submodule

UNITYNATIVEAUDIOPLUGIN_PATH=$$_PRO_FILE_PWD_/libs/UnityNativeAudioPlugin

#Note : hard inclusion to refine
SOURCES +=  $${UNITYNATIVEAUDIOPLUGIN_PATH}/NativeCode/AudioPluginUtil.cpp \

HEADERS += $${UNITYNATIVEAUDIOPLUGIN_PATH}/NativeCode/AudioPluginUtil.h \
           $${UNITYNATIVEAUDIOPLUGIN_PATH}/NativeCode/AudioPluginInterface.h
