# Author(s) : Loic Touraine

# Define target architecture path depending on the build kit used if not overloaded in user's project file
isEmpty(BCOM_TARGET_ARCH) {
  # Defaults to x86_64
  BCOM_TARGET_ARCH = x86_64
  android {
      BCOM_TARGET_ARCH = $${ANDROID_TARGET_ARCH}
  }
  macx {
      # To build for i386, duplicate the 64 bits build kit and change the compilers used : Qmake specs are adapted for 32 bits build
      contains(CONFIG, x86) {
          BCOM_TARGET_ARCH = i386
    }
  }
  unix {
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
}

isEmpty(BCOM_TARGET_PLATFORM) {
    android {
        BCOM_TARGET_PLATFORM = android-$$basename(QMAKE_CC)
    }
    linux:!android {
        BCOM_TARGET_PLATFORM = linux-$$basename(QMAKE_CC)
    }
    macx {
        BCOM_TARGET_PLATFORM = macx-$$basename(QMAKE_CC)
    }
    win32 {
        BCOM_TARGET_PLATFORM = win-$$basename(QMAKE_CC)
    }
}
