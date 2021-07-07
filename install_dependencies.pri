# Author(s) : Loic Touraine, Stephane Leduc

ignorefile = packageignoreinstall.txt
exists($$_PRO_FILE_PWD_/$${ignorefile}) {
    IGNOREFILE_CONTENT = $$cat($$_PRO_FILE_PWD_/$${ignorefile},lines)
    write_file($$_PRO_FILE_PWD_/build/$${ignorefile}, IGNOREFILE_CONTENT)
}

ignorefile = packageignoreinstall-win.txt
win32:!android:exists($$_PRO_FILE_PWD_/$${ignorefile}) {
    IGNOREFILE_CONTENT = $$cat($$_PRO_FILE_PWD_/$${ignorefile},lines)
    write_file($$_PRO_FILE_PWD_/build/$${ignorefile}, IGNOREFILE_CONTENT)
}

ignorefile = packageignoreinstall-unix.txt
unix:exists($$_PRO_FILE_PWD_/$${ignorefile}) {
    IGNOREFILE_CONTENT = $$cat($$_PRO_FILE_PWD_/$${ignorefile},lines)
    write_file($$_PRO_FILE_PWD_/build/$${ignorefile}, IGNOREFILE_CONTENT)
}

ignorefile = packageignoreinstall-mac.txt
macx:!android:exists($$_PRO_FILE_PWD_/$${ignorefile}) {
    IGNOREFILE_CONTENT = $$cat($$_PRO_FILE_PWD_/$${ignorefile},lines)
    write_file($$_PRO_FILE_PWD_/build/$${ignorefile}, IGNOREFILE_CONTENT)
}

ignorefile = packageignoreinstall-linux.txt
linux:!android:exists($$_PRO_FILE_PWD_/$${ignorefile}) {
    IGNOREFILE_CONTENT = $$cat($$_PRO_FILE_PWD_/$${ignorefile},lines)
    write_file($$_PRO_FILE_PWD_/build/$${ignorefile}, IGNOREFILE_CONTENT)
}

ignorefile = packageignoreinstall-android.txt
android:exists($$_PRO_FILE_PWD_/$${ignorefile}) {
    IGNOREFILE_CONTENT = $$cat($$_PRO_FILE_PWD_/$${ignorefile},lines)
    write_file($$_PRO_FILE_PWD_/build/$${ignorefile}, IGNOREFILE_CONTENT)
}

defined(PROJECTDEPLOYDIR,var) {
    packageignore_files.path = $${PROJECTDEPLOYDIR}

    # package ignore files
    exists($$_PRO_FILE_PWD_/build/packageignoreinstall.txt) {
        packageignore_files.files += $$_PRO_FILE_PWD_/build/packageignoreinstall.txt
    }
    win32:!android:exists($$_PRO_FILE_PWD_/build/packageignoreinstall-win.txt) {
        packageignore_files.files += $$_PRO_FILE_PWD_/build/packageignoreinstall-win.txt
    }
    unix:exists($$_PRO_FILE_PWD_/build/packageignoreinstall-unix.txt) {
        packageignore_files.files += $$_PRO_FILE_PWD_/build/packageignoreinstall-unix.txt
    }
    macx:!android:exists($$_PRO_FILE_PWD_/build/packageignoreinstall-mac.txt) {
        packageignore_files.files += $$_PRO_FILE_PWD_/build/packageignoreinstall-mac.txt
    }
    linux:!android:exists($$_PRO_FILE_PWD_/build/packageignoreinstall-linux.txt) {
        packageignore_files.files += $$_PRO_FILE_PWD_/build/packageignoreinstall-linux.txt
    }
    android:exists($$_PRO_FILE_PWD_/build/packageignoreinstall-android.txt) {
        packageignore_files.files += $$_PRO_FILE_PWD_/build/packageignoreinstall-android.txt
    }
    INSTALLS += packageignore_files
}

CONFIG(debug,debug|release) {
    RemakenConfig = debug
}
CONFIG(release,debug|release) {
    RemakenConfig = release
}

contains(CONFIG,c++11) {
    RemakenCppStd=11
}
contains(CONFIG,c++14) {
    RemakenCppStd=14
}
contains(CONFIG,c++1z)|contains(CONFIG,c++17) {
    RemakenCppStd=17
}
contains(CONFIG,c++2a)|contains(CONFIG,c++20) {
    RemakenCppStd=20
}

contains(DEPENDENCIESCONFIG,install_recurse) {
    remakenBundleRecurseOption = --recurse
}

exists($$_PRO_FILE_PWD_/build/packagedependencies.txt) {
    verboseMessage("remaken bundle $$_PRO_FILE_PWD_/build/packagedependencies.txt -d $$shell_quote($$clean_path($${TARGETDEPLOYDIR})) -c $${RemakenConfig} -cpp-std $${RemakenCppStd} -b $${REMAKEN_BUILD_TOOLCHAIN} -o $${REMAKEN_OS} -a $${BCOM_TARGET_ARCH} -v $${remakenBundleRecurseOption}")
    REMAKEN_BUNDLE_COMMAND = remaken bundle $$_PRO_FILE_PWD_/build/packagedependencies.txt -d $$shell_quote($$clean_path($${TARGETDEPLOYDIR})) -c $${RemakenConfig} --cpp-std $${RemakenCppStd} -b $${REMAKEN_BUILD_TOOLCHAIN} -o $${REMAKEN_OS} -a $${BCOM_TARGET_ARCH} -v $${remakenBundleRecurseOption}

    win32 {
        contains(PROJECTCONFIG,QTVS) {
            # bundle dependencies only if configured in project
            contains(DEPENDENCIESCONFIG,install)|contains(DEPENDENCIESCONFIG,install_recurse) {
                !equals(QMAKE_POST_LINK,"") {
                    QMAKE_POST_LINK += &&
                }
                # NB : remaken doesn't create output dir in context of post build call - scope check and create dir 
                QMAKE_POST_LINK += ($${QMAKE_CHK_DIR_EXISTS} $$shell_quote($$shell_path($${TARGETDEPLOYDIR})) $${QMAKE_MKDIR} $$shell_quote($$shell_path($${TARGETDEPLOYDIR}))) &&
                QMAKE_POST_LINK += $${REMAKEN_BUNDLE_COMMAND}
            }
        }
    }

    isEmpty(QMAKE_POST_LINK) {
        install_deps.commands += $${REMAKEN_BUNDLE_COMMAND}
        install_deps.depends += install
    }
}
QMAKE_EXTRA_TARGETS  += install_deps
