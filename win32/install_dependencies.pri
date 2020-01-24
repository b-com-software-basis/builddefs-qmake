# Author(s) : Loic Touraine, Stephane Leduc

# echo R for manage Path instead file!
REMAKEN_XCOPY= echo R | xcopy /Y /Q

# manage outputdir (deploydir for lib, and build dir for app)
DEPS_OUTPUTPATH = $${TARGETDEPLOYDIR}/
install_deps.path = $${TARGETDEPLOYDIR}/

# bat init header
contains(PROJECTCONFIG,QTVS) {
    INSTALL_DEPS_FILE=$$OUT_PWD/$${TARGET}-InstallDependencies_$${OUTPUTDIR}.bat
    BAT_HEADER_COMMAND = "@echo off"
    write_file($${INSTALL_DEPS_FILE},BAT_HEADER_COMMAND)
}

# list all shared lib on folder parameter
defineReplace(ListSharedLibrairies) {
    sharedLibFiles=$$files($$1/*.$${DYNLIBEXT})
    !isEmpty(sharedLibFiles) {
        for (sharedLibFile, sharedLibFiles) {
            contains(PROJECTCONFIG,QTVS) {
                BAT_INSTALLDEPS_COMMAND = "$${REMAKEN_XCOPY} $$system_path($${sharedLibFile}) $$shell_quote($$shell_path($${DEPS_OUTPUTPATH}))"
                write_file($${INSTALL_DEPS_FILE},BAT_INSTALLDEPS_COMMAND, append)
            }
        }
        message("    --> [INFO] add install command for shared lib of $$system_path($$1/) ")
    } else {
        message("    --> [INFO] no shared lib in $$system_path($$1/) ")
    }
    return($$sharedLibFiles)
}

# init target
install_deps.files =

message("----------------------------------------------------------------")
contains(DEPENDENCIESCONFIG,install_recurse) {
    #recursive dependencies parsing
    installdeps_depsfiles = $$packagedepsfiles    # used in packagedependencies.pri
    message("---- Install recurse dependencies for project $${TARGET} :" )
} else {
    message("---- Install 1st level dependencies for project $${TARGET} :" )
    # No Recursive dependencie parsing!
    installdeps_depsfiles = $$_PRO_FILE_PWD_/packagedependencies.txt
    win32 {
        installdeps_depsfiles += $$_PRO_FILE_PWD_/packagedependencies-win.txt
    }
    unix {
        installdeps_depsfiles += $$_PRO_FILE_PWD_/packagedependencies-unix.txt
    }
    macx {
        installdeps_depsfiles += $$_PRO_FILE_PWD_/packagedependencies-mac.txt
    }
    linux {
        installdeps_depsfiles += $$_PRO_FILE_PWD_/packagedependencies-linux.txt
    }
}

ignorefile = $$_PRO_FILE_PWD_/packageignoreinstall.txt
exists($${ignorefile}) {
    message("  -- Search Ignore Dependencies in $${ignorefile} --" )
    ignoredeps = $$cat($${ignorefile})
    for(var, ignoredeps) {
        message ($$var)
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

                            !exists($${deployFolder}/lib/$$BCOM_TARGET_ARCH/$${pkg.linkMode}/$$OUTPUTDIR/) {
                                message("    --> [INFO] $${deployFolder}/lib/$$BCOM_TARGET_ARCH/$${pkg.linkMode}/$$OUTPUTDIR/ doesn't exists for package " $${libName})
                            } else {
                                install_deps.files += $$ListSharedLibrairies($${deployFolder}/lib/$$BCOM_TARGET_ARCH/$${pkg.linkMode}/$$OUTPUTDIR)
                            }
                        } else {
                            message("    --> [INFO] Ignore install for $${pkg.repoType} dependency : $${pkg.name}")
                        }
                    }
                }
                equals(pkg.repoType,"conan") {# conan system package handling
                    contains(ignoredeps, $${pkg.name}) {
                        # list of ignored conan dependencies - used for install_recurse
                        REMAKEN_IGNORE_CONAN_BINDIRS += CONAN_BINDIRS_$$upper($${pkg.name})
                        message("    --> [INFO] Ignore install for $${pkg.name} dependency : $$eval(CONAN_BINDIRS_$$upper($${pkg.name}))")
                    } else {
                        # list of conan dependencies to install - used for install (not recurse)
                        REMAKEN_CONAN_BINDIRS += $$eval(CONAN_BINDIRS_$$upper($${pkg.name}))
                    }
                }
            } # pkgConditionFullfilled
        } # end for loop
    }
}

contains(DEPENDENCIESCONFIG,install_recurse) {
    # work on complete list and remove ignored deps in order to have subdepends and inherited deps (for instance bzip2 for boost)
    # allow to use recurse for depends and install only on 1st level deps
    REMAKEN_CONAN_BINDIRS = $$CONAN_BINDIRS
    for (conanBinDir, REMAKEN_IGNORE_CONAN_BINDIRS) {
        REMAKEN_CONAN_BINDIRS -= $$eval($$conanBinDir)
    }
}

exists($$_PRO_FILE_PWD_/build/conanbuildinfo.pri) {
    conanBinDirList = $$split(REMAKEN_CONAN_BINDIRS, " ")
    conanBinDirListSize = $$size(conanBinDirList)
    greaterThan(conanBinDirListSize,0) {
        for (conanBinDir, conanBinDirList) {
            install_deps.files += $$ListSharedLibrairies($${conanBinDir})
        }
    }
}

# only for QT VS tools
contains(PROJECTCONFIG,QTVS) {
    QMAKE_DISTCLEAN += $${INSTALL_DEPS_FILE}
    exists($${INSTALL_DEPS_FILE}) {
        !equals(QMAKE_POST_LINK,"") {
            QMAKE_POST_LINK += &&
        }
        QMAKE_POST_LINK += call $${INSTALL_DEPS_FILE}
    }
} else {
    INSTALLS += install_deps
}

message("----------------------------------------------------------------")

