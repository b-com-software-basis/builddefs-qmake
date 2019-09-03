# Author(s) : Loic Touraine, Stephane Leduc

# Detect build toolchain, define BCOM_TARGET_ARCH and BCOM_TARGET_PLATFORM
include(bcom_arch_define.pri)

# Check input parameters existence
!defined(FRAMEWORK,var) {
    error("FRAMEWORK must be defined before templatelibconfig.pri inclusion. A typical definition is FRAMEWORK = \$\$TARGET.")
}

!defined(INSTALLSUBDIR,var) {
    message("INSTALLSUBDIR can be defined before templatelibconfig.pri inclusion. INSTALLSUBDIR is optional. Values can be : build (own build), thirdParties... A typical definition is INSTALLSUBDIR = build.")
}

!defined(PROJECTDEPLOYDIR,var) {
    PROJECTDEPLOYDIR = $${REMAKENDEPSFOLDER}/$${BCOM_TARGET_PLATFORM}/$${FRAMEWORK}/$${VERSION}
    defined(INSTALLSUBDIR,var) {
        PROJECTDEPLOYDIR = $${REMAKENDEPSFOLDER}/$${INSTALLSUBDIR}/$${BCOM_TARGET_PLATFORM}/$${FRAMEWORK}/$${VERSION}
    }
    warning("PROJECTDEPLOYDIR may be defined before templatelibconfig.pri inclusion => Defaulting PROJECTDEPLOYDIR to $${PROJECTDEPLOYDIR}. ")
}
