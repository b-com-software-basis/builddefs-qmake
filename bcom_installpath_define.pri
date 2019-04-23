# Author(s) : Loic Touraine, Stephane Leduc

# Detect build toolchain, define BCOM_TARGET_ARCH and BCOM_TARGET_PLATFORM
include(bcom_arch_define.pri)

# Check input parameters existence
!defined(FRAMEWORK,var) {
    error("FRAMEWORK must be defined before templatelibconfig.pri inclusion. A typical definition is FRAMEWORK = \$\$TARGET.")
}

!defined(INSTALLSUBDIR,var) {
    warning("INSTALLSUBDIR can be defined before templatelibconfig.pri inclusion. INSTALLSUBDIR is optional and accept two values : bcomBuild or thirdParties. A typical definition is INSTALLSUBDIR = bcomBuild.")
}

defined(INSTALLSUBDIR,var) {
    !contains(INSTALLSUBDIR,bcomBuild):!contains(INSTALLSUBDIR,thirdParties) {
        error("INSTALLSUBDIR is defined with the $$INSTALLSUBDIR unsupported value. Supported values are : bcomBuild or thirdParties")
    }
}

!defined(PROJECTDEPLOYDIR,var) {
    PROJECTDEPLOYDIR = $${REMAKENDEPSFOLDER}/$${BCOM_TARGET_PLATFORM}/$${FRAMEWORK}/$${VERSION}
    defined(INSTALLSUBDIR,var) {
        PROJECTDEPLOYDIR = $${REMAKENDEPSFOLDER}/$${INSTALLSUBDIR}/$${BCOM_TARGET_PLATFORM}/$${FRAMEWORK}/$${VERSION}
    }
    warning("PROJECTDEPLOYDIR may be defined before templatelibconfig.pri inclusion => Defaulting PROJECTDEPLOYDIR to $${PROJECTDEPLOYDIR}. ")
}
