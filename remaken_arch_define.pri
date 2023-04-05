# Author(s) : Loic Touraine

REMAKEN_BUILD_RULES_FOLDER = .build-rules
REMAKEN_INFO_SUFFIX=remakeninfo.txt
!win32 {
    include(builddefs_info.pri)
}

android {
    # unix path
    USERHOMEFOLDER = $$clean_path($$(HOME))
    isEmpty(USERHOMEFOLDER) {
        # windows path
        USERHOMEFOLDER = $$clean_path($$(USERPROFILE))
        isEmpty(USERHOMEFOLDER) {
            USERHOMEFOLDER = $$clean_path($$(HOMEDRIVE)$$(HOMEPATH))
        }
    }
}

unix:!android {
    USERHOMEFOLDER = $$clean_path($$(HOME))
}

win32 {
    USERHOMEFOLDER = $$clean_path($$(USERPROFILE))
    isEmpty(USERHOMEFOLDER) {
        USERHOMEFOLDER = $$clean_path($$(HOMEDRIVE)$$(HOMEPATH))
    }
}

# For backward compatibility
isEmpty(REMAKENDEPSFOLDER) {
    REMAKENDEPSROOTFOLDER = $$clean_path($$(REMAKEN_PKG_ROOT))
    isEmpty(REMAKENDEPSROOTFOLDER) {
        exists($${USERHOMEFOLDER}/.remaken/.packagespath) {
            REMAKENDEPSROOTFOLDER = $$clean_path($$cat($${USERHOMEFOLDER}/.remaken/.packagespath))
        }
    }
    !isEmpty(REMAKENDEPSROOTFOLDER) {
        REMAKENDEPSFOLDER = $$clean_path($${REMAKENDEPSROOTFOLDER})
    }
    else { #new remaken behavior
        isEmpty(USERHOMEFOLDER) {
            error("[ERROR] REMAKENDEPSROOTFOLDER dependencies folder is empty. Please check your system environment path (HOME for unix, USERPROFILE for windows)")
        }

        # Read REMAKENDEVPROP qmake property
        REMAKENDEPSFOLDER = $$clean_path($$[REMAKENDEPSFOLDERPROP])

        isEmpty(REMAKENDEPSFOLDER) { # REMAKENDEVPROP not defined in qmake's properties
            message("NO REMAKENDEPSFOLDERPROP defined in qmake : setting REMAKENDEPSFOLDER to " $${REMAKENDEPSROOTFOLDER}/.remaken/packages)
            REMAKENDEPSFOLDER = $${USERHOMEFOLDER}/.remaken/packages
        }
    }
    message("REMAKENDEPSFOLDER Dependencies folder is set to " $${REMAKENDEPSFOLDER})
}

# Define target architecture path depending on the build kit used if not overloaded in user's project file
isEmpty(REMAKEN_TARGET_ARCH) {
  # Defaults to x86_64
  REMAKEN_TARGET_ARCH = x86_64
  conanArch = "arch=x86_64"
  win32:!android {
      # Deduce for windows as it depends on the build kit used (each kit handles either 32 or 64 bits build, but not both)
      vcpkgtriplet = x64-windows
      contains(QMAKE_TARGET.arch, x86) {
          REMAKEN_TARGET_ARCH = i386
          conanArch = "arch=x86"
          vcpkgtriplet = x86-windows
      }
  }
  unix:!android {
      # To build for i386, duplicate the 64 bits build kit and change the compilers used : Qmake specs are adapted for 32 bits build
      contains(CONFIG, x86) {
          REMAKEN_TARGET_ARCH = i386
          conanArch = "arch=x86"
      }
  }
  macx:!android {
      # To build for i386, duplicate the 64 bits build kit and change the compilers used : Qmake specs are adapted for 32 bits build
      vcpkgtriplet = x64-osx
      contains(CONFIG, x86) {
          REMAKEN_TARGET_ARCH = i386
          conanArch = "arch=x86"
          vcpkgtriplet = x86-osx
      }
      contains(CONFIG, arm64) {
          REMAKEN_TARGET_ARCH = arm64
          conanArch = "arch=armv8"
          vcpkgtriplet = arm64-osx
      }
  }
  linux:!android {
      # To build for i386, duplicate the 64 bits build kit and change the compilers used : Qmake specs are adapted for 32 bits build
      vcpkgtriplet = x64-linux
      contains(CONFIG, x86) {
          REMAKEN_TARGET_ARCH = i386
          conanArch = "arch=x86"
          vcpkgtriplet = x86-linux
      }
  }
  android {
      REMAKEN_TARGET_ARCH = $${ANDROID_TARGET_ARCH}
      vcpkgtriplet = x64-android
      contains(ANDROID_TARGET_ARCH, armeabi-v7a) {
          conanArch = "arch=armv7"
          vcpkgtriplet = arm-android
      }
      contains(ANDROID_TARGET_ARCH, arm64-v8a) {
          conanArch = "arch=armv8"
          vcpkgtriplet = arm64-android
      }
      contains(ANDROID_TARGET_ARCH, x86) {
          conanArch = "arch=x86"
          vcpkgtriplet = x86-android
      }
  }
}

win32:!android {
    REMAKEN_OS = win
}
unix:!android {
    REMAKEN_OS = unix
}
macx:!android {
    REMAKEN_OS = mac
}
linux:!android {
    REMAKEN_OS = linux
}
android {
    REMAKEN_OS = android
}
ios {
    REMAKEN_OS = ios
}

isEmpty(CONAN_MAJOR_VERSION) {
    CONAN_VERSION_CMD_RESULT += $$system(conan --version)
    CONAN_MAJOR_VERSION=1
    !isEmpty(CONAN_VERSION_CMD_RESULT) {
        CONAN_VERSION_INFO_LIST = $$split(CONAN_VERSION_CMD_RESULT, ' ')
        CONAN_VERSION_INFO_LIST_SIZE = $$size(CONAN_VERSION_INFO_LIST)
        equals(CONAN_VERSION_INFO_LIST_SIZE,3) {
            CONAN_VERSION = $$member(CONAN_VERSION_INFO_LIST,2)
            CONAN_VERSION_LIST = $$split(CONAN_VERSION, .)
            CONAN_VERSION_LIST_SIZE = $$size(CONAN_VERSION_LIST)
            equals(CONAN_VERSION_LIST_SIZE,3) {
                CONAN_MAJOR_VERSION=$$member(CONAN_VERSION_LIST,0)
            }
        }
    }
    message("Conan version detected : $${CONAN_VERSION} - (major version = $${CONAN_MAJOR_VERSION})")
}

isEmpty(REMAKEN_TARGET_PLATFORM) {
    REMAKEN_BUILD_TOOLCHAIN = $$basename(QMAKE_CC)
    win32 {
        !defined(QMAKE_MSC_VER,var) {
            !defined (MSVC_VER, var) {
                error("Unable to find msvc version : Use minimum Qt 5.6 version.")
            } else {
                REMAKEN_COMPILER_VER = $$MSVC_VER
            }
        } else {
            # msvc version : https://stackoverflow.com/questions/70013/how-to-detect-if-im-compiling-code-with-visual-studio-2008
            greaterThan(QMAKE_MSC_VER, 1499) {
                # Visual Studio 2008 (9.0) / Visual C++ 15.0 and up
                REMAKEN_COMPILER_VER = 9.0
            }
            greaterThan(QMAKE_MSC_VER, 1599) {
                # Visual Studio 2010 (10.0) / Visual C++ 16.0 and up
                REMAKEN_COMPILER_VER = 10.0
            }
            greaterThan(QMAKE_MSC_VER, 1699) {
                # Visual Studio 2012 (11.0) / Visual C++ 17.0 and up
                REMAKEN_COMPILER_VER = 11.0
            }
            greaterThan(QMAKE_MSC_VER, 1799) {
                # Visual Studio 2013 (12.0) / Visual C++ 18.0 and up
                REMAKEN_COMPILER_VER = 12.0
            }
            greaterThan(QMAKE_MSC_VER, 1899) {
                # Visual Studio 2015 (14.0) / Visual C++ 19.0 and up
                REMAKEN_COMPILER_VER = 14.0
            }
            greaterThan(QMAKE_MSC_VER, 1909) {
                # Visual Studio 2017 (14.x with x >= 1 and < 2 ) / Visual C++ 19.10 and up to 19.16
                # Note : msvc version set to 14.1 for Visual Studio 2017 in order to separate version from msvc 2015!
                REMAKEN_COMPILER_VER = 14.1
                equals(CONAN_MAJOR_VERSION,1) {
                   CONAN_WIN_COMPILER_VERSION = 15     # visual studio version removed with conan 2.x
                }
                else {
                   CONAN_WIN_COMPILER_VERSION = 191    # msvc version
                }
            }
            greaterThan(QMAKE_MSC_VER, 1920) {
                # Visual Studio 2019 (14.x with x >= 2 and < 30) / Visual C++ 19.20 and up to 19.29
                # Note : msvc version set to 14.1 - TODO change to 14.2??
                REMAKEN_COMPILER_VER = 14.1
                equals(CONAN_MAJOR_VERSION,1) {
                   CONAN_WIN_COMPILER_VERSION = 16
                }
                else {
                   CONAN_WIN_COMPILER_VERSION = 192
                }
            }
            greaterThan(QMAKE_MSC_VER, 1930) {
                # Visual Studio 2022 (14.x with x >= 30) / Visual C++ 19.30 and up
                # Note : msvc version set to 14.1 - TODO change to 14.30??
                REMAKEN_COMPILER_VER = 14.1
                equals(CONAN_MAJOR_VERSION,1) {
                   CONAN_WIN_COMPILER_VERSION = 17
                }
                else {
                   CONAN_WIN_COMPILER_VERSION = 193
                }
            }
        }
        contains(CONFIG,c++14)|contains(CONFIG,c++1z)|contains(CONFIG,c++17)|contains(CONFIG,c++2a)|contains(CONFIG,c++20) {
            contains(CONFIG,c++11) {
                CONFIG -= c++11
            }
        }

        # note : when icl is used with msvc, the most important is the msvc compiler version!
        REMAKEN_BUILD_TOOLCHAIN=$$basename(QMAKE_CC)-$$REMAKEN_COMPILER_VER
    }
    REMAKEN_TARGET_PLATFORM = $${REMAKEN_OS}-$${REMAKEN_BUILD_TOOLCHAIN}
    REMAKEN_FULL_PLATFORM = $${REMAKEN_TARGET_PLATFORM}-$${REMAKEN_TARGET_ARCH}
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
