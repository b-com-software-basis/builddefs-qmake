QT       -= core gui
CONFIG -= app_bundle qt

TARGET = %{ApplicationName}
TARGET = %{ModuleName}
@if '%{ApplicationName}' === '%{PackageNameKey}'
FRAMEWORK = $${TARGET}
@else
FRAMEWORK = %{PackageNameKey}
@endif
@if '%{InstallSubDir}'
INSTALLSUBDIR =  %{InstallSubDir}
@endif
VERSION=%{PackageVersionKey}
DEFINES +=  $${TARGET}VERSION=\\\"$${VERSION}\\\"

CONFIG += c++1z
CONFIG += console
CONFIG += shared

# Uncomment following line to add more verbose information from builddefs-qmake rules
# CONFIG += verbose
# Uncomment following line to prepare remaken package
# CONFIG += package_remaken

@if '%{withQTVS}' && '%{withQTVS}' === 'QTVS'
CONFIG += with_qtvs
@else
# Uncomment following line to use rules with QTVS plugin mode for visual studio
# CONFIG += with_qtvs
@endif

with_qtvs {
    PROJECTCONFIG = QTVS
}

include(findremakenrules.pri)

@if '%{dependenciesBuildMode}' === 'shared'
DEPENDENCIESCONFIG = sharedlib
REMAKEN_PKGSUBDIR=shared
@else
DEPENDENCIESCONFIG = staticlib
REMAKEN_PKGSUBDIR=static
@endif
@if '%{recurseDependencies}' === 'recurse' && '%{dependenciesInstallMode}' !== 'install_recurse'
DEPENDENCIESCONFIG += recurse
@endif
@if '%{dependenciesInstallMode}' !== 'noinstall'
DEPENDENCIESCONFIG += %{dependenciesInstallMode}
@endif

CONFIG(debug,debug|release) {
    DEFINES += _DEBUG=1
    DEFINES += DEBUG=1
    REMAKEN_PKGSUBDIR=$${REMAKEN_PKGSUBDIR}/debug
}

CONFIG(release,debug|release) {
    DEFINES += NDEBUG=1
    REMAKEN_PKGSUBDIR=$${REMAKEN_PKGSUBDIR}/release
}

package_remaken {
    message("Preparing remaken package installation in $${REMAKEN_PKGSUBDIR}")
    INSTALLSUBDIR=$${REMAKEN_PKGSUBDIR}
}

## Configuration for Visual Studio to install binaries and dependencies. Work also for QT Creator by replacing QMAKE_INSTALL
@if '%{withQTVS}' && '%{withQTVS}' === 'QTVS'
PROJECTCONFIG = QTVS
@endif

#NOTE : CONFIG as staticlib or sharedlib, DEPENDENCIESCONFIG as staticlib or sharedlib and PROJECTDEPLOYDIR MUST BE DEFINED BEFORE templatelibbundle.pri inclusion
include ($${QMAKE_REMAKEN_RULES_ROOT}/templateappconfig.pri)

#DEFINES += BOOST_ALL_NO_LIB
DEFINES += BOOST_ALL_DYN_LINK
DEFINES += BOOST_AUTO_LINK_NOMANGLE
DEFINES += BOOST_LOG_DYN_LINK

HEADERS += \

SOURCES += \
    %{CppFileName}

unix {
    LIBS += -ldl
    QMAKE_CXXFLAGS += -DBOOST_LOG_DYN_LINK
}

macx {
    QMAKE_MAC_SDK= macosx
    QMAKE_CXXFLAGS += -fasm-blocks -x objective-c++
}

win32 {
    QMAKE_LFLAGS += /MACHINE:X64
    DEFINES += WIN64 UNICODE _UNICODE
    QMAKE_COMPILER_DEFINES += _WIN64
    QMAKE_CXXFLAGS += -wd4250 -wd4251 -wd4244 -wd4275

    # Windows Kit (msvc2013 64)
    LIBS += -L$$(WINDOWSSDKDIR)lib/winv6.3/um/x64 -lshell32 -lgdi32 -lComdlg32
    INCLUDEPATH += $$(WINDOWSSDKDIR)lib/winv6.3/um/x64
 }

INCLUDEPATH += $${PWD}

DISTFILES += \
    Makefile

OTHER_FILES += \
    packagedependencies.txt

with_qtvs {
#NOTE : Must be placed at the end of the .pro
@if '%{remakenRules}' === 'local'
    include (builddefs/qmake/remaken_install_target.pri)
@else
    include ($${QMAKE_REMAKEN_RULES_ROOT}/remaken_install_target.pri)
@endif
}
