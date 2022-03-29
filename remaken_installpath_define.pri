# Author(s) : Loic Touraine, Stephane Leduc

# Detect build toolchain, define REMAKEN_TARGET_ARCH and REMAKEN_TARGET_PLATFORM
include(remaken_arch_define.pri)

# Check input parameters existence
!defined(FRAMEWORK,var) {
    error("FRAMEWORK must be defined before templatelibconfig.pri inclusion. A typical definition is FRAMEWORK = \$\$TARGET.")
}

!defined(INSTALLSUBDIR,var) {
    message("INSTALLSUBDIR can be defined before templatelibconfig.pri inclusion. INSTALLSUBDIR is optional. Values can be : build (own build), thirdParties... A typical definition is INSTALLSUBDIR = build.")
}

!defined(PROJECTDEPLOYDIR,var) {
    PROJECTDEPLOYDIR = $${REMAKENDEPSFOLDER}/$${REMAKEN_TARGET_PLATFORM}/$${FRAMEWORK}/$${VERSION}
    defined(INSTALLSUBDIR,var) {
        PROJECTDEPLOYDIR = $${REMAKENDEPSFOLDER}/$${REMAKEN_TARGET_PLATFORM}/$${INSTALLSUBDIR}/$${FRAMEWORK}/$${VERSION}
    }
    warning("PROJECTDEPLOYDIR may be defined before templatelibconfig.pri inclusion => Defaulting PROJECTDEPLOYDIR to $${PROJECTDEPLOYDIR}. ")
}
