# Author(s) : Loic Touraine

REMAKEN_INFO_SUFFIX=remakeninfo.txt
# For backward compatibility
REMAKENDEPSROOTFOLDER=$$(BCOMDEVROOT)
!isEmpty(REMAKENDEPSROOTFOLDER) {
    REMAKENDEPSFOLDER=$${REMAKENDEPSROOTFOLDER}
}
else { #new remaken behavior
    unix {
        REMAKENDEPSROOTFOLDER=$$(HOME)
    }

    win32 {
        REMAKENDEPSROOTFOLDER=$$(USERPROFILE)
        isEmpty(REMAKENDEPSROOTFOLDER) {
            REMAKENDEPSROOTFOLDER=shell_path($$(HOMEDRIVE)$$(HOMEPATH))
        }
    }

    # Read REMAKENDEVPROP qmake property
    REMAKENDEPSFOLDER=$$[REMAKENDEPSFOLDERPROP]

    isEmpty(REMAKENDEPSFOLDER) { # REMAKENDEVPROP not defined in qmake's properties
        message("NO REMAKENDEPSFOLDERPROP defined in qmake : setting REMAKENDEPSFOLDER to " $${REMAKENDEPSROOTFOLDER}/.remaken/packages)
        REMAKENDEPSFOLDER=$${REMAKENDEPSROOTFOLDER}/.remaken/packages
    }
}
message("REMAKENDEPSFOLDER Dependencies folder is set to " $${REMAKENDEPSFOLDER})

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
        BCOM_TARGET_PLATFORM = mac-$$basename(QMAKE_CC)
    }
    win32 {
        !defined(QMAKE_MSC_VER,var) {
            !defined (MSVC_VER, var) {
                error("Unable to find msvc version : Use minimum Qt 5.6 version.")
            } else {
                BCOM_COMPILER_VER = $$MSVC_VER
            }
        } else {
            # msvc version : https://stackoverflow.com/questions/70013/how-to-detect-if-im-compiling-code-with-visual-studio-2008
            greaterThan(QMAKE_MSC_VER, 1499) {
                # Visual Studio 2008 (9.0) / Visual C++ 15.0 and up
                BCOM_COMPILER_VER = 9.0
            }
            greaterThan(QMAKE_MSC_VER, 1599) {
                # Visual Studio 2010 (10.0) / Visual C++ 16.0 and up
                BCOM_COMPILER_VER = 10.0
            }
            greaterThan(QMAKE_MSC_VER, 1699) {
                # Visual Studio 2012 (11.0) / Visual C++ 17.0 and up
                BCOM_COMPILER_VER = 11.0
            }
            greaterThan(QMAKE_MSC_VER, 1799) {
                # Visual Studio 2013 (12.0) / Visual C++ 18.0 and up
                BCOM_COMPILER_VER = 12.0
            }
            greaterThan(QMAKE_MSC_VER, 1899) {
                # Visual Studio 2015 (14.0) / Visual C++ 19.0 and up
                BCOM_COMPILER_VER = 14.0
            }
            greaterThan(QMAKE_MSC_VER, 1909) {
                # Visual Studio 2017 (14.x with x >= 1) / Visual C++ 19.10 and up
                # Note : msvc version set to 14.1 for Visual Studio 2017 in order to separate version from msvc 2015!
                BCOM_COMPILER_VER = 14.1
            }
        }
		# note : when icl is used with msvc, the most important is the msvc compiler version!
        BCOM_TARGET_PLATFORM = win-$$basename(QMAKE_CC)-$$BCOM_COMPILER_VER
    }
}

macx {
    exists(/usr/local/opt/llvm):contains(CONFIG, use_brew_llvm) {
        exists(/usr/local/opt/llvm/bin/clang):exists(/usr/local/opt/llvm/bin/clang++) {
            QMAKE_CC=/usr/local/opt/llvm/bin/clang
            QMAKE_CXX=/usr/local/opt/llvm/bin/clang++
            QMAKE_CFLAGS += -I/usr/local/opt/llvm/include
            QMAKE_CXXFLAGS += -I/usr/local/opt/llvm/include -I/usr/local/opt/llvm/include/c++/v1/
            QMAKE_LINK=/usr/local/opt/llvm/bin/clang++
            QMAKE_LFLAGS += -L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib
        }
    }
}
