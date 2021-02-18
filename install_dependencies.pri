# Author(s) : Loic Touraine, Stephane Leduc

# echo R for manage Path instead file!
REMAKEN_XCOPY= echo R | xcopy /Y /Q

# remove/replace forbidden chars
defineReplace(ReplaceSpecialCharacter) {
    str = $$ARGS
    str = $$replace(str, "<>", "-")
    str = $$replace(str, "<", "")
    str = $$replace(str, ">", "")
    str = $$replace(str, "/", "_")
    #str = $$replace(str, "\\", "_")
    str = $$replace(str, ":", "_")
    #str = $$replace(str, "*", "")
    str = $$replace(str, "\?", "")
    str = $$replace(str, "\"", "_")
    str = $$replace(str, "|", "")
    return($${str})
}

equals (MAKEFILE_GENERATOR, MSBUILD) \
|equals (MAKEFILE_GENERATOR, MSVC.NET) \
|isEmpty(QMAKE_SH) {
    REMAKEN_DEPS_COPY = copy /y
}
else {
    REMAKEN_DEPS_COPY = cp -f -r --preserve=links
}

win32 {
    REMAKEN_CONAN_BINDIRS_BASENAME=CONAN_BINDIRS
    # bat init header
    contains(PROJECTCONFIG,QTVS) {
        INSTALL_DEPS_FILE=$$OUT_PWD/$${TARGET}-InstallDependencies_$${OUTPUTDIR}.bat
        BAT_HEADER_COMMAND = "@echo off"
        write_file($${INSTALL_DEPS_FILE},BAT_HEADER_COMMAND)
    }
}
else {
    REMAKEN_CONAN_BINDIRS_BASENAME=CONAN_LIBDIRS
}


message(" ")
message("----------------------------------------------------------------")
message("STEP => INSTALL - prepare dependencies installation")
message("----------------------------------------------------------------")
message(" ")

win32 {
    !isEmpty(INSTALL_DEPS_FILE) {
        message("---- generates $$INSTALL_DEPS_FILE for msvc post Install  ----" )
    }
}

contains(DEPENDENCIESCONFIG,install_recurse) {
    #recursive dependencies parsing
    installdeps_depsfiles = $$packagedepsfiles    # used in packagedependencies.pri
    message("---- Install recurse dependencies for project $${TARGET} :" )
} else {
    message("---- Install 1st level dependencies for project $${TARGET} :" )
    # No Recursive dependencie parsing!
    installdeps_depsfiles = $$_PRO_FILE_PWD_/packagedependencies.txt
    win32:!android {
        installdeps_depsfiles += $$_PRO_FILE_PWD_/packagedependencies-win.txt
    }
    unix {
        installdeps_depsfiles += $$_PRO_FILE_PWD_/packagedependencies-unix.txt
    }
    macx:!android {
        installdeps_depsfiles += $$_PRO_FILE_PWD_/packagedependencies-mac.txt
    }
    linux:!android {
        installdeps_depsfiles += $$_PRO_FILE_PWD_/packagedependencies-linux.txt
    }
    android {
        installdeps_depsfiles += $$_PRO_FILE_PWD_/packagedependencies-android.txt
    }
}

ignorefile = $$_PRO_FILE_PWD_/packageignoreinstall.txt
exists($${ignorefile}) {
    message("  -- Search Ignore Dependencies in $${ignorefile} --" )
    ignoredeps = $$cat($${ignorefile})
    for(var, ignoredeps) {
        message ("    --> $$var ignored")
    }
}


for(depfile, installdeps_depsfiles) {
    !exists($${depfile}) {
        message("  -- No " $${depfile} " file to process for " $$TARGET)
    } else {
        message("  -- Install Dependencies Processing $${depfile} --" )
        dependencies = $$cat($${depfile})
        for(var, dependencies) {
            dependencyMetaInf = $$split(var,|)
            pkgInformation = $$member(dependencyMetaInf,0)
            pkgInfoList = $$split(pkgInformation, $$LITERAL_HASH)
            pkg.name = $$member(pkgInfoList,0)
            pkgInComment = $$str_member($${pkg.name}, 0, 1)
            !equals (pkgInComment, $$PKG_COMMENT) {
                pkg.channel = "stable"
                pkgInfoListSize = $$size(pkgInfoList)
                equals(pkgInfoListSize,2) {
                    pkg.channel = $$member(pkgInfoList,1)
                }
                pkg.version = $$member(dependencyMetaInf,1)
                pkgLibInformation = $$member(dependencyMetaInf,2)
                pkgLibConditionList = $$split(pkgLibInformation, %)
                libName = $$take_first(pkgLibConditionList)
                pkgTypeInformation = $$member(dependencyMetaInf,3)
                pkgTypeInfoList = $$split(pkgTypeInformation, @)
                pkg.identifier = $$member(pkgTypeInfoList,0)
                pkg.repoType = $${pkg.identifier}
                pkgTypeInfoListSize = $$size(pkgTypeInfoList)
                equals(pkgTypeInfoListSize,2) {
                    pkg.repoType = $$member(pkgTypeInfoList,1)
                } else {
                   equals(pkg.identifier,"bcomBuild")|equals(pkg.identifier,"thirdParties") {
                        pkg.repoType = "artifactory"
                    }  # otherwise pkg.repoType = pkg.identifier
                }
                pkg.repoUrl=$$member(dependencyMetaInf,4)
                pkg.linkMode = $$member(dependencyMetaInf,5)
                pkg.toolOptions = $$member(dependencyMetaInf,6)
                # check pkg.linkMode not empty and mandatory equals to static|shared, otherwise set to default DEPLINKMODE
                equals(pkg.linkMode,"")|equals(pkg.linkMode,"default") {
                    pkg.linkMode = $${DEPLINKMODE}
                } else {
                    if (!equals(pkg.linkMode,"static"):!equals(pkg.linkMode,"shared"):!equals(pkg.linkMode,"na")){
                        pkg.linkMode = $${DEPLINKMODE}
                    }
                }

                pkgConditionsNotFullfilled = ""
                !isEmpty(pkgLibConditionList) {
                    message("  --> [INFO] Parsing $${pkg.name}_$${pkg.version} compilation flag definitions : $${pkgLibConditionList}")
                    for (condition,pkgLibConditionList) {
                        #message("      --> [INFO] found condition $${condition}")
                        !contains(DEFINES, $${condition}) {
                            pkgConditionsNotFullfilled += $${condition}
                        }
                    }
                }
                !isEmpty (pkgConditionsNotFullfilled) {
                    message("  --> [INFO] Dependency $${pkg.name}_$${pkg.version}@$${pkg.repoType} ignored ! Missing compilation flag definition : $${pkgConditionsNotFullfilled}")
                } else {
                    # Artifactory dependencies
                    equals(pkg.repoType,"artifactory") | equals(pkg.repoType,"github") | equals(pkg.repoType,"nexus") {
                        equals(pkg.linkMode, "shared") {
                            !contains(ignoredeps, $${pkg.name}) {
                                # custom built package handling
                                deployFolder=$${REMAKENDEPSFOLDER}/$${BCOM_TARGET_PLATFORM}/$${pkg.name}/$${pkg.version}
                                !equals(pkg.identifier,$${pkg.repoType}) {
                                    deployFolder=$${REMAKENDEPSFOLDER}/$${pkg.identifier}/$${BCOM_TARGET_PLATFORM}/$${pkg.name}/$${pkg.version}
                                }
                                !exists($${deployFolder}) {
                                    warning("Dependencies source folder should include the target platform information " $${BCOM_TARGET_PLATFORM})
                                    deployFolder=$${REMAKENDEPSFOLDER}/$${pkg.name}/$${pkg.version}
                                    !equals(pkg.identifier,$${pkg.repoType}) {
                                        deployFolder=$${REMAKENDEPSFOLDER}/$${pkg.identifier}/$${pkg.name}/$${pkg.version}
                                    }
                                    warning("Defaulting search folder to " $${deployFolder})
                                }

                                depOutputDir=$${deployFolder}/lib/$$BCOM_TARGET_ARCH/$${pkg.linkMode}/$$OUTPUTDIR
                                !exists($${depOutputDir}/) {
                                    message("    --> [INFO] package without binaries : $${libName}")
                                } else {
                                    sharedLibFiles += $$files($${depOutputDir}/*.$${DYNLIBEXT}*)
                                    message("    --> [INFO] install $${pkg.repoType} dependency : $${pkg.name} (from $${depOutputDir})")
                                }
                            } else {
                                message("    --> [INFO] Ignore install for $${pkg.repoType} dependency : $${pkg.name}")
                            }
                        }
                    }
                    equals(pkg.repoType,"conan") {# conan system package handling
                        contains(ignoredeps, $${pkg.name}) {
                            # list of ignored conan dependencies - used for install_recurse
                            REMAKEN_IGNORE_CONAN_BINDIRS += $${REMAKEN_CONAN_BINDIRS_BASENAME}_$$upper($${pkg.name})
                            message("    --> [INFO] Ignore install for $${pkg.repoType} dependency : $${pkg.name}")
                        } else {
                            # list of conan dependencies to install - used for install (not recurse)
                            REMAKEN_CONAN_BINDIRS += $$eval($${REMAKEN_CONAN_BINDIRS_BASENAME}_$$upper($${pkg.name}))
                            message("    --> [INFO] install $${pkg.repoType} dependency : $${pkg.name} (from $$eval($${REMAKEN_CONAN_BINDIRS_BASENAME}_$$upper($${pkg.name})))")
                        }
                    }
                } # pkgConditionsNotFullfilled
            } # comment package
            else {
                #message(package in comment : $${pkg.name})
            }
        } # for(var, dependencies)
    } #!exists($${depfile})
} # for(depfile, packagedepsfiles)

contains(DEPENDENCIESCONFIG,install_recurse) {
    # work on complete list and remove ignored deps in order to have subdepends and inherited deps (for instance bzip2 for boost)
    # allow to use recurse for depends and install only on 1st level deps
    REMAKEN_CONAN_BINDIRS = $$eval($$REMAKEN_CONAN_BINDIRS_BASENAME)
    for (conanBinDir, REMAKEN_IGNORE_CONAN_BINDIRS) {
        REMAKEN_CONAN_BINDIRS -= $$eval($$conanBinDir)
    }
}

exists($$_PRO_FILE_PWD_/build/$$OUTPUTDIR/conanbuildinfo.pri) {
    conanBinDirList = $$split(REMAKEN_CONAN_BINDIRS, " ")
    conanBinDirListSize = $$size(conanBinDirList)
    greaterThan(conanBinDirListSize,0) {
        for (conanBinDir, conanBinDirList) {
            # remove '-L' on lib path
            conanBinDir = $$replace(conanBinDir, "-L", "")
            sharedLibFiles += $$files($${conanBinDir}/*.$${DYNLIBEXT}*)
        }
    }
}

for (sharedLibFile, sharedLibFiles) {
    !isEmpty(INSTALL_DEPS_FILE) {
        BAT_INSTALLDEPS_COMMAND = "$${REMAKEN_XCOPY} $$shell_quote($$shell_path($${sharedLibFile})) $$shell_quote($$shell_path($${TARGETDEPLOYDIR}/))"
        write_file($${INSTALL_DEPS_FILE},BAT_INSTALLDEPS_COMMAND, append)
    } else {
        targetname = copy_$$ReplaceSpecialCharacter($${sharedLibFile})
        !contains(install_deps.depends, install) {
            # add install target before for folder creation
            install_deps.depends += install
        }
        !contains(QMAKE_EXTRA_TARGETS, $${targetname}) {
            $${targetname}.commands = $$REMAKEN_DEPS_COPY $$shell_quote($$shell_path($${sharedLibFile})) $$shell_quote($$shell_path($${TARGETDEPLOYDIR}/))
            QMAKE_EXTRA_TARGETS += $${targetname}
            install_deps.depends += $${targetname}
        }
    }
}

# only for QT VS tools
!isEmpty(INSTALL_DEPS_FILE) {
    QMAKE_DISTCLEAN += $${INSTALL_DEPS_FILE}
    exists($${INSTALL_DEPS_FILE}) {
        !equals(QMAKE_POST_LINK,"") {
            QMAKE_POST_LINK += &&
        }
        QMAKE_POST_LINK += call $${INSTALL_DEPS_FILE}
    }

}
QMAKE_EXTRA_TARGETS  += install_deps

message("----------------------------------------------------------------")
