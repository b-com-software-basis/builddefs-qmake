# Author(s) : Loic Touraine, Stephane Leduc

# Check input parameters existence
!defined(PROJECTDEPLOYDIR,var) {
    error("PROJECTDEPLOYDIR must be defined before templatelibconfig.pri inclusion. A typical definition is $$(BCOMDEVROOT)/$${INSTALLSUBDIR}/$${FRAMEWORK}/$${VERSION}.")
}


# Detect build toolchain and define BCOM_TARGET_ARCH
include($$_PRO_FILE_PWD_/builddefs/qmake/bcom_arch_define.pri)

# Include extended compiler rules
include ($$_PRO_FILE_PWD_/builddefs/qmake/bcom_compiler_specs.prf)

TEMPLATE = lib

staticlib {
    LINKMODE = static
} else {
    LINKMODE = shared
}

# TODO manage IPP config

CONFIG(debug,debug|release) {
    OUTPUTDIR = debug
}

CONFIG(release,debug|release) {
    OUTPUTDIR = release
}

TARGETDEPLOYDIR = $${PROJECTDEPLOYDIR}/lib/$${BCOM_TARGET_ARCH}/$${LINKMODE}/$$OUTPUTDIR

unix {
    target.path = /usr/lib
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
    QMAKE_LFLAGS_SONAME = -Wl,-install_name,$${TARGETDEPLOYDIR}/
    contains(BCOM_TARGET_ARCH, x86_64) {
        QMAKE_CFLAGS += -arch x86_64
        QMAKE_CXXFLAGS += -arch x86_64
        QMAKE_LFLAGS += -arch x86_64
    }
    contains(BCOM_TARGET_ARCH, i386) {
        QMAKE_CFLAGS += -arch i386
        QMAKE_CXXFLAGS += -arch i386
        QMAKE_LFLAGS += -arch i386
    }
}

win32 {
    LIBPREFIX = ''
    DYNLIBEXT = dll
    LIBEXT = lib
    # do not add version to target name for shared link mode
    CONFIG += skip_target_version_ext

    # qmake processing only 1 time (http://stackoverflow.com/questions/17360553/qmake-processes-my-pro-file-three-times-instead-of-one)
    CONFIG -= debug_and_release

    # multiprocessor build
    QMAKE_CXXFLAGS += /MP8
    QMAKE_CFLAGS += /MP8

    # override qmake.conf that force MD also for static configurations
    # could be override by dependencies link in packagedependencies.pri
    staticlib {
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

target.path = $${TARGETDEPLOYDIR}
INSTALLS += target

# Parse dependencies if any and fill CFLAGS,CXXFLAGS and LFLAGS
include ($$_PRO_FILE_PWD_/builddefs/qmake/packagedependencies.pri)
