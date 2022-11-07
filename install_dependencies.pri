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

COMMAND_EXIT_PARAM=
win32 {
    COMMAND_EXIT_PARAM=/b
}

#default error command
install_deps.commands = echo "Error: call 'install_deps' target without DEPENDENCIESCONFIG=install/install_recurse" & exit $${COMMAND_EXIT_PARAM} 2
install_xpcf_deps.commands = echo "Error: call 'install_xpcf_deps' target without DEPENDENCIESCONFIG=install/install_recurse" & exit $${COMMAND_EXIT_PARAM} 2

# bundle dependencies only if configured in project
contains(DEPENDENCIESCONFIG,install)|contains(DEPENDENCIESCONFIG,install_recurse) {
    #bundle
    exists($$_PRO_FILE_PWD_/$${REMAKEN_BUILD_RULES_FOLDER}/$${REMAKEN_FULL_PLATFORM}/$${PKGDEPFILENAME}) {
        verboseMessage("remaken bundle $$_PRO_FILE_PWD_/$${REMAKEN_BUILD_RULES_FOLDER}/$${REMAKEN_FULL_PLATFORM}/$${PKGDEPFILENAME} -d $$shell_quote($$clean_path($${TARGETDEPLOYDIR})) -c $${RemakenConfig} --cpp-std $${RemakenCppStd} -b $${REMAKEN_BUILD_TOOLCHAIN} -o $${REMAKEN_OS} -a $${REMAKEN_TARGET_ARCH} -v $${remakenBundleRecurseOption} -f")
        REMAKEN_BUNDLE_COMMAND = remaken bundle $$_PRO_FILE_PWD_/$${REMAKEN_BUILD_RULES_FOLDER}/$${REMAKEN_FULL_PLATFORM}/$${PKGDEPFILENAME} -d $$shell_quote($$clean_path($${TARGETDEPLOYDIR})) -c $${RemakenConfig} --cpp-std $${RemakenCppStd} -b $${REMAKEN_BUILD_TOOLCHAIN} -o $${REMAKEN_OS} -a $${REMAKEN_TARGET_ARCH} -v $${remakenBundleRecurseOption} -f
        win32 {
            contains(PROJECTCONFIG,QTVS) {
                install_deps.commands = echo "Info: call 'install_deps' target in QTVS mode : target is empty"
                !equals(QMAKE_POST_LINK,"") {
                    QMAKE_POST_LINK += &&
                }
                # NB : remaken doesn't create output dir in context of post build call - scope check and create dir
                QMAKE_POST_LINK += ($${QMAKE_CHK_DIR_EXISTS} $$shell_quote($$shell_path($${TARGETDEPLOYDIR})) $${QMAKE_MKDIR} $$shell_quote($$shell_path($${TARGETDEPLOYDIR}))) &&
                QMAKE_POST_LINK += $${REMAKEN_BUNDLE_COMMAND}
            }
        }
        # linux or (win32 and not QTVS)
        isEmpty(QMAKE_POST_LINK) {
            install_deps.commands = $${REMAKEN_BUNDLE_COMMAND}
            install_deps.depends = install
        }
    } else {
        install_deps.commands = echo "Error: call 'install_deps' target without a packagedependencies file" & exit $${COMMAND_EXIT_PARAM} 2
    }

    install_xpcf_deps.commands = if [$${INSTALL_XPCF_XML_FILE}]==[] (echo "Error: call 'install_xpcf_deps' target without INSTALL_XPCF_XML_FILE var defined" & exit $${COMMAND_EXIT_PARAM} 2)

    #bundleXPCF
    defined(INSTALL_XPCF_XML_FILE,var) {
        !exists($${INSTALL_XPCF_XML_FILE}) {
            error("  --> [ERROR] file $${INSTALL_XPCF_XML_FILE} doesn't exist (cf INSTALL_XPCF_XML_FILE var)")
        }
        verboseMessage("remaken bundleXpcf -d $$shell_quote($$clean_path($${TARGETDEPLOYDIR})) -c $${RemakenConfig} --cpp-std $${RemakenCppStd} -b $${REMAKEN_BUILD_TOOLCHAIN} -o $${REMAKEN_OS} -a $${REMAKEN_TARGET_ARCH} -v $${remakenBundleRecurseOption} -f $${INSTALL_XPCF_XML_FILE}")
        REMAKEN_BUNDLE_XPCF_COMMAND = remaken bundleXpcf -d $$shell_quote($$clean_path($${TARGETDEPLOYDIR})) -c $${RemakenConfig} --cpp-std $${RemakenCppStd} -b $${REMAKEN_BUILD_TOOLCHAIN} -o $${REMAKEN_OS} -a $${REMAKEN_TARGET_ARCH} -v $${remakenBundleRecurseOption} -f $${INSTALL_XPCF_XML_FILE}
        win32 {
            contains(PROJECTCONFIG,QTVS) {
                install_xpcf_deps.commands = echo "Info: call 'install_xpcf_deps' target in QTVS mode : target is empty"
                !equals(QMAKE_POST_LINK,"") {
                    QMAKE_POST_LINK += &&
                }
                # NB : remaken doesn't create output dir in context of post build call - scope check and create dir
                QMAKE_POST_LINK += ($${QMAKE_CHK_DIR_EXISTS} $$shell_quote($$shell_path($${TARGETDEPLOYDIR})) $${QMAKE_MKDIR} $$shell_quote($$shell_path($${TARGETDEPLOYDIR}))) &&
                QMAKE_POST_LINK += $${REMAKEN_BUNDLE_XPCF_COMMAND}
            }
        }
        # linux or (win32 and not QTVS)
        isEmpty(QMAKE_POST_LINK) {
            install_xpcf_deps.commands = $${REMAKEN_BUNDLE_XPCF_COMMAND}
            install_xpcf_deps.depends = install
        }
    }

    #defined(INSTALL_XPCF_XML_FILE,var) {
}
QMAKE_EXTRA_TARGETS  += install_deps install_xpcf_deps
