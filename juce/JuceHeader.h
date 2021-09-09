/*

    IMPORTANT! This file is auto-generated each time you save your
    project - if you alter its contents, your changes may be overwritten!

    This is the header file that your files should include in order to get all the
    JUCE library headers. You should avoid including the JUCE headers directly in
    your own source files, because that wouldn't pick up the correct configuration
    options for your app.

*/

#ifndef __APPHEADERFILE_XH9PLR__
#define __APPHEADERFILE_XH9PLR__

#include "AppConfig.h"

#ifdef JUCE_MODULE_AVAILABLE_juce_audio_basics
#include "juce_audio_basics/juce_audio_basics.h"
#endif
#ifdef JUCE_MODULE_AVAILABLE_juce_audio_devices
#include "juce_audio_devices/juce_audio_devices.h"
#endif
#ifdef JUCE_MODULE_AVAILABLE_juce_audio_formats
#include "juce_audio_formats/juce_audio_formats.h"
#endif
#ifdef JUCE_MODULE_AVAILABLE_juce_audio_plugin_client
#include "juce_audio_plugin_client/juce_audio_plugin_client.h"
#endif
#ifdef JUCE_MODULE_AVAILABLE_juce_audio_processors
#include "juce_audio_processors/juce_audio_processors.h"
#endif
#ifdef JUCE_MODULE_AVAILABLE_juce_core
#include "juce_core/juce_core.h"
#endif
#ifdef JUCE_MODULE_AVAILABLE_juce_dsp
#include "juce_dsp/juce_dsp.h"
#endif
#ifdef JUCE_MODULE_AVAILABLE_juce_osc
#include "juce_osc/juce_osc.h"
#endif
#ifdef JUCE_MODULE_AVAILABLE_juce_cryptography
#include "juce_cryptography/juce_cryptography.h"
#endif
#ifdef JUCE_MODULE_AVAILABLE_juce_data_structures
#include "juce_data_structures/juce_data_structures.h"
#endif
#ifdef JUCE_MODULE_AVAILABLE_juce_events
#include "juce_events/juce_events.h"
#endif
#ifdef JUCE_MODULE_AVAILABLE_juce_graphics
#include "juce_graphics/juce_graphics.h"
#endif
#ifdef JUCE_MODULE_AVAILABLE_juce_gui_basics
#include "juce_gui_basics/juce_gui_basics.h"
#endif
#ifdef JUCE_MODULE_AVAILABLE_juce_gui_extra
#include "juce_gui_extra/juce_gui_extra.h"
#endif
#ifdef JUCE_MODULE_AVAILABLE_juce_opengl
#include "juce_opengl/juce_opengl.h"
#endif
#ifdef JUCE_MODULE_AVAILABLE_juce_video
#include "juce_video/juce_video.h"
#endif

#ifdef JUCE_WITHBINARYDATA
#include "BinaryData.h"
#endif

#if ! DONT_SET_USING_JUCE_NAMESPACE
 // If your code uses a lot of JUCE classes, then this will obviously save you
 // a lot of typing, but can be disabled by setting DONT_SET_USING_JUCE_NAMESPACE.
 using namespace juce;
#endif

#if ! JUCE_DONT_DECLARE_PROJECTINFO
namespace ProjectInfo
{
    const char* const  projectName    = JUCE_STRINGIFY(JUCEPLUGIN_PROJECTNAME);
    const char* const  versionString  = JUCE_STRINGIFY(PRODUCT_VERSIONSTRING);
    const int          versionNumber  = PRODUCT_VERSIONCODE;
}
#endif

#endif   // __APPHEADERFILE_XH9PLR__
