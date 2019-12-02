# Author(s) : Loic Touraine, Stephane Leduc

FRAMEWORK = $$TARGET

# Manage install path
include(bcom_installpath_define.pri)

TEMPLATE = app

# Include extended compiler rules
include (bcom_compiler_specs.prf)

# Check input parameters existence
# Warning : app targetdeploydir depends on DEPENDENCIESCONFIG, and lib depends on CONFIG
!defined(DEPENDENCIESCONFIG,var) {
    warning("DEPENDENCIESCONFIG is not defined : defaulting to shared dependencies mode")
    DEPENDENCIESCONFIG = sharedlib
}
contains(DEPENDENCIESCONFIG,staticlib)|contains(DEPENDENCIESCONFIG,static) {
    LINKMODE = static
} else {
    LINKMODE = shared
}

CONFIG(debug,debug|release) {
    OUTPUTDIR = debug
}

CONFIG(release,debug|release) {
    OUTPUTDIR = release
}

# manage default/custom install dir
!defined(TARGETDEPLOYDIR,var) {
    TARGETDEPLOYDIR = $${PROJECTDEPLOYDIR}/bin/$${BCOM_TARGET_ARCH}/$${LINKMODE}/$$OUTPUTDIR
    warning("TARGETDEPLOYDIR may be defined before templateappconfig.pri inclusion => Defaulting TARGETDEPLOYDIR to $${TARGETDEPLOYDIR}. ")
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
    APPEXT = exe

    !contains(PROJECTCONFIG,QTVS) {
        # qmake processing only 1 time (http://stackoverflow.com/questions/17360553/qmake-processes-my-pro-file-three-times-instead-of-one)
        CONFIG -= debug_and_release
    }

    # multiprocessor build
    QMAKE_CXXFLAGS += /MP8
    QMAKE_CFLAGS += /MP8

    # specify to use the static version of the windows runtime.
    # this value must be used only for full static builds as since VS2017, mixing runtime at link time is prohibited.
    # for mixed libraries link, let qmake set MD also for static configurations.
    usestaticwinrt {
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
    QMAKE_TARGET_PRODUCT=$$TARGET

    # manage copyright
    QMAKE_TARGET_COPYRIGHT = $$PRODUCT_BRIEF_COPYRIGHT
    isEmpty(QMAKE_TARGET_COPYRIGHT) {
        year = $$system("echo %Date:~6,4%")
        yearCheck = $$find(year, ^\d{4}$)
        yearCheckSize = $$size(yearCheck)
        !equals(yearCheckSize,1) {
            YEAR = 2019 # default date
        }
        QMAKE_TARGET_COPYRIGHT=Copyright (c) $$year b-com
    }
}

target.path = $${TARGETDEPLOYDIR}
INSTALLS += target

# Parse dependencies if any and fill CFLAGS,CXXFLAGS and LFLAGS
include (packagedependencies.pri)
# remove .pc and packagedependencies.txt copy
INSTALLS -= package_files

# manage setup creation
contains (CONFIG, app_setup) {
    include (bcom_app_rules.prf)
}
