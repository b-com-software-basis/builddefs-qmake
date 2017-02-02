# Author(s) : Loic Touraine

# Define target architecture path
# Defaults to x86_64
BCOM_TARGET_ARCH = x86_64
macx {
    # To build for i386, duplicate the 64 bits build kit and change the compilers used : Qmake specs are adapted for 32 bits build
    contains(CONFIG, x86) {
        BCOM_TARGET_ARCH = i386
    }
}
win32 {
    # Deduce for windows as it depends on the build kit used (each kit handles either 32 or 64 bits build, but not both)
    contains(QMAKE_TARGET.arch, x86) {
        BCOM_TARGET_ARCH = i386
    }
}
