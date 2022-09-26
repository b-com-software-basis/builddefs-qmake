# Author(s) : Loic Touraine, Stephane Leduc

packageignoredepsfiles = $$_PRO_FILE_PWD_/packageignoreinstall.txt
win32:!android {
    packageignoredepsfiles += $$_PRO_FILE_PWD_/packageignoreinstall-win.txt
}
# Common unix platform (macx, linux, android...)
unix {
    packageignoredepsfiles += $$_PRO_FILE_PWD_/packageignoreinstall-unix.txt
}
macx:!android {
    packageignoredepsfiles += $$_PRO_FILE_PWD_/packageignoreinstall-mac.txt
}
linux:!android {
    packageignoredepsfiles += $$_PRO_FILE_PWD_/packageignoreinstall-linux.txt
}
android {
    packageignoredepsfiles += $$_PRO_FILE_PWD_/packageignoreinstall-android.txt
}

defineReplace(aggregateIgnoreDepsFiles) {
    ignoreDepsFilesList = $$ARGS
    for(depfile, ignoreDepsFilesList) {
        !exists($${depfile}) {
            verboseMessage("  -- No " $${depfile} " file to process for " $$TARGET)
        } else {
            pkgIgnoreFileContent += $$cat($${depfile},lines)

        }
    }
    return($${pkgIgnoreFileContent})
}

IGNOREDEPFILE_CONTENT = $$aggregateIgnoreDepsFiles($${packageignoredepsfiles})
IGNOREPKGDEPFILENAME=packageignoreinstall.txt
!isEmpty(IGNOREDEPFILE_CONTENT) {
    write_file($$_PRO_FILE_PWD_/$${REMAKEN_BUILD_RULES_FOLDER}/$${REMAKEN_FULL_PLATFORM}/$${IGNOREPKGDEPFILENAME}, IGNOREDEPFILE_CONTENT)
}

defined(PROJECTDEPLOYDIR,var) {
    packageignore_files.path = $${PROJECTDEPLOYDIR}
    exists($$_PRO_FILE_PWD_/$${REMAKEN_BUILD_RULES_FOLDER}/$${REMAKEN_FULL_PLATFORM}/$${IGNOREPKGDEPFILENAME}) {
        packageignore_files.files += $$_PRO_FILE_PWD_/$${REMAKEN_BUILD_RULES_FOLDER}/$${REMAKEN_FULL_PLATFORM}/$${IGNOREPKGDEPFILENAME}
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

exists($$_PRO_FILE_PWD_/$${REMAKEN_BUILD_RULES_FOLDER}/$${REMAKEN_FULL_PLATFORM}/$${PKGDEPFILENAME}) {
    verboseMessage("remaken bundle $$_PRO_FILE_PWD_/$${REMAKEN_BUILD_RULES_FOLDER}/$${REMAKEN_FULL_PLATFORM}/$${PKGDEPFILENAME} -d $$shell_quote($$clean_path($${TARGETDEPLOYDIR})) -c $${RemakenConfig} --cpp-std $${RemakenCppStd} -b $${REMAKEN_BUILD_TOOLCHAIN} -o $${REMAKEN_OS} -a $${REMAKEN_TARGET_ARCH} -v $${remakenBundleRecurseOption} -f")
    REMAKEN_BUNDLE_COMMAND = remaken bundle $$_PRO_FILE_PWD_/$${REMAKEN_BUILD_RULES_FOLDER}/$${REMAKEN_FULL_PLATFORM}/$${PKGDEPFILENAME} -d $$shell_quote($$clean_path($${TARGETDEPLOYDIR})) -c $${RemakenConfig} --cpp-std $${RemakenCppStd} -b $${REMAKEN_BUILD_TOOLCHAIN} -o $${REMAKEN_OS} -a $${REMAKEN_TARGET_ARCH} -v $${remakenBundleRecurseOption} -f

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
