# Author(s) : Loic Touraine, Stephane Leduc

TEMPLATE = app
CONFIG += app_bundle

# Detect build toolchain and define BCOM_TARGET_ARCH
include(bcom_arch_define.pri)

# Include extended compiler rules
include (bcom_compiler_specs.prf)

CONFIG(debug,debug|release) {
    OUTPUTDIR = debug
}

CONFIG(release,debug|release) {
    OUTPUTDIR = release
}

unix {
    LIBPREFIX = lib
    DYNLIBEXT = so
    LIBEXT = a
}

macx {
    LIBPREFIX = lib
    DYNLIBEXT = dylib
    LIBEXT = a
    #NOTE : the following override is mandatory to get a correct install_name in the target library header
    #This name ensure later calls of macdylibbundler will correctly work when deploying this library with an executable
    QMAKE_LFLAGS_SONAME  = -Wl,-install_name,@executable_path/

    TARGET_CUSTOM_EXT = .app
    DEPLOY_COMMAND = macdeployqt
    DEPLOY_TARGET = $$shell_path($${OUT_PWD}/$${TARGET}$${TARGET_CUSTOM_EXT})
    DEPLOY_BINTARGETPATH = $$shell_path($${OUT_PWD}/$${TARGET}$${TARGET_CUSTOM_EXT}/Contents/MacOS)
    DEPLOY_OPTIONS = -dmg
}

win32 {
    LIBPREFIX = ''
    DYNLIBEXT = dll
    LIBEXT = lib

    # qmake processing only 1 time (http://stackoverflow.com/questions/17360553/qmake-processes-my-pro-file-three-times-instead-of-one)
    CONFIG -= debug_and_release

    # multiprocessor build
    QMAKE_CXXFLAGS += /MP8
    QMAKE_CFLAGS += /MP8

    # override qmake.conf that force MD also for static configurations
    # could be override by dependencies link in packagedependencies.pri
    static {
        QMAKE_CXXFLAGS_DEBUG += -MTd
        QMAKE_CXXFLAGS_DEBUG -= -MDd
        QMAKE_CFLAGS_DEBUG += -MTd
        QMAKE_CFLAGS_DEBUG -= -MDd
        QMAKE_CXXFLAGS_RELEASE += -MT
        QMAKE_CXXFLAGS_RELEASE -= -MD
        QMAKE_CFLAGS_RELEASE += -MT
        QMAKE_CFLAGS_RELEASE -= -MD
    }

    # RC informations
    QMAKE_TARGET_COMPANY=b<>com
    QMAKE_TARGET_DESCRIPTION=$$TARGET
    QMAKE_TARGET_COPYRIGHT=Copyright (c) 2016 b-com
    QMAKE_TARGET_PRODUCT=$$TARGET
}

# Parse dependencies if any and fill CFLAGS,CXXFLAGS and LFLAGS
include (packagedependencies.pri)

# Add post build copy of dependencies with application
include (bcom_package_app.pri)
