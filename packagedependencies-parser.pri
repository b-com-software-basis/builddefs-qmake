# Author(s) : Loic Touraine, Stephane Leduc

packagedepsfiles = $$_PRO_FILE_PWD_/$${REMAKEN_BUILD_RULES_FOLDER}/$${REMAKEN_FULL_PLATFORM}/$${PKGDEPFILENAME}

message(" ")
message("----------------------------------------------------------------")
message("STEP => BUILD - Project dependencies parsing")

contains(DEPENDENCIESCONFIG,recurse)|contains(DEPENDENCIESCONFIG,recursive) {
    message("----------------------------------------------------------------")
    message(" ")
    message("----------------------------------------------------------------")
    message("---- Search recursive dependencies for project $${TARGET} :" )
    for (depFile, packagedepsfiles) {
        baseDepFile = $$basename(depFile)
        write_file($$OUT_PWD/$${TARGET}-$${baseDepFile})
    }

    recursionLevels = 0 1 2 3 4 5 6 7 8 9
    # packagedepsfiles
    subDepsMetaInfoList = $$populateSubDependencies($${packagedepsfiles}, $${TARGET})
    for (i, recursionLevels) {
        subDepsFilesList=
        pkgDepNameList=
        for (subDepsMetaInfo, subDepsMetaInfoList) {
            subDepsList = $$split(subDepsMetaInfo, ;)
            subDepsListSize = $$size(subDepsList)
            equals(subDepsListSize,3) {
                subDepsFilesList += $$member(subDepsList,0)
                pkgDepNameList += $$member(subDepsList,1)
                !contains(subDepsTree, $$member(subDepsList,2)) {
                    subDepsTree += $$member(subDepsList,2)
                }
            } else {
                subDepsFilesList =
                !contains(subDepsTree, $${subDepsList}) {
                    subDepsTree += $${subDepsList}
                }
            }
        }

        subDepsMetaInfoList =
        !isEmpty(subDepsFilesList) {
            packagedepsfiles += $${subDepsFilesList}
            subDepsMetaInfoList = $$populateSubDependencies($${subDepsFilesList}, $${pkgDepNameList})
        }
    }

    # generate output files that will contain complete dependencies informations from recursion
    for (depFile, packagedepsfiles) {
        baseDepFile = $$basename(depFile)
        dependencies = $$cat($${depFile})
        for(dependency, dependencies) {
            fileCurrentDependencies = $$cat($$OUT_PWD/$${TARGET}-$${baseDepFile})
            !contains(fileCurrentDependencies, $$dependency) {
                write_file($$OUT_PWD/$${TARGET}-$${baseDepFile}, dependency, append)
            }
        }
        QMAKE_CLEAN += $$OUT_PWD/$${TARGET}-$${baseDepFile}
    }

    message("---- Complete dependencies list for project $${TARGET} :" )
    targetDepFiles=$$files($$OUT_PWD/$${TARGET}-$${PKGDEPFILENAME})
    for (depfile, targetDepFiles) {
        message( $${depfile} ":")
        dependencies = $$cat($${depfile})
        for(var, dependencies) {
           message("    $$var")
        }
    }

    message("---- Complete dependencies tree for project $${TARGET} :" )
    for (dep, subDepsTree) {
        message("    $${dep}")
    }

    # generate transitives deps to ignore
    for(dep, subDepsTree) {
        depInf = $$split(dep, |)
        pkgParent = $$member(depInf,0)
        pkgName = $$member(depInf,1)
        pkgMode = $$member(depInf,2)

        !equals(pkgParent,$$TARGET):equals(pkgMode,"static") {
            staticParent = $$getStaticParentPkg($${pkgParent}, $${subDepsTree})
            for (i, recursionLevels) {
                !isEmpty(staticParent) {
                    !equals(staticParent, $$TARGET) {
                        staticParent = $$getStaticParentPkg($${staticParent}, $${subDepsTree})
                    }
                } else {
                    !contains(StaticTransitiveDeps,$$pkgName) {
                        StaticTransitiveDeps += $$pkgName
                    }
                }
            }
        }
    }

    message("---- Static transitive dependencies in project $${TARGET} :" )
    for (dep, StaticTransitiveDeps) {
        message("    $${dep}")
    }

    message("----------------------------------------------------------------")
    message(" ")
}

win32 {
    !isEmpty(packagedepsfiles) {
        contains(DEPENDENCIESCONFIG,externaldeps)|contains(CONFIG,externaldeps)|contains(REMAKENCONFIG,externaldeps) {
            QMAKE_CXXFLAGS += /external:anglebrackets /external:W0 /experimental:external /external:templates-
        }
    }
}

message("----------------------------------------------------------------")
for(depfile, packagedepsfiles) {
    !exists($${depfile}) {
        verboseMessage("  -- No " $${depfile} " file to process for " $$TARGET)
    } else {
        message("---- Processing $${depfile} ----" )
        dependencies = $$cat($${depfile})
        for(var, dependencies) {
            dependencyMetaInf = $$split(var, |)
            pkgInformation = $$member(dependencyMetaInf,0)
            pkgInfoList = $$split(pkgInformation, $$LITERAL_HASH)
            pkg.name = $$member(pkgInfoList,0)
            pkg.channel = "stable"
            pkgInfoListSize = $$size(pkgInfoList)
            equals(pkgInfoListSize,2) {
                pkg.channel = $$member(pkgInfoList,1)
            }
            pkg.version = $$member(dependencyMetaInf,1)
            libName = $$member(dependencyMetaInf,2)
            message("---- Processing $${pkg.name} $${pkg.version} package ----" )
            pkgTypeInformation = $$member(dependencyMetaInf,3)
            pkgTypeInfoList = $$split(pkgTypeInformation, @)
            pkg.identifier = $$member(pkgTypeInfoList,0)
            pkg.repoType = $${pkg.identifier}
            pkgTypeInfoListSize = $$size(pkgTypeInfoList)
            equals(pkgTypeInfoListSize,2) {
                pkg.repoType = $$member(pkgTypeInfoList,1)
            } else {
                equals(pkg.identifier,"bcomBuild")|equals(pkg.identifier,"remakenBuild")|equals(pkg.identifier,"thirdParties") {
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

            verboseMessage("  ---- Processing dependency $${pkg.name}_$${pkg.version}@$${pkg.repoType} repository")
            # VPCKG package handling
            equals(pkg.repoType,"vcpkg") {
                deployFolder=$${REMAKENDEPSFOLDER}/$${pkg.repoType}/packages/$${pkg.name}_$${vcpkgtriplet}
                !exists($${deployFolder}) {
                    error("  --> [ERROR] No VPCKG package at " $${REMAKENDEPSFOLDER}/$${pkg.repoType}/packages/$${pkg.name}_$${vcpkgtriplet})
                }
                # TODO : check package version with installed one !
                LIBFOLDER=lib
                equals(OUTPUTDIR,"debug") {
                    LIBFOLDER="debug/lib"
                }
                pkgCfgFilePath = $${deployFolder}/$${LIBFOLDER}/pkgconfig/$${libName}.pc
                !exists($${pkgCfgFilePath}) {# error
                    error("  --> [ERROR] " $${pkgCfgFilePath} " doesn't exists for VCPKG package " $${pkg.name}_$${vcpkgtriplet})
                }
                message("    --> [INFO] " $${pkgCfgFilePath} "exists")
                pkgCfgVars = --define-variable=prefix=$${deployFolder}
                pkgCfgVars += --define-variable=lext=$${LIBEXT}
                pkgCfgVars += --define-variable=libdir=$${deployFolder}/$${LIBFOLDER}

                !win32 {
                    pkgCfgVars += --define-variable=pfx=$${LIBPREFIX}
                }
                else {
                    pkgCfgVars += --define-variable=pfx=$$shell_quote("\'\'")
                }
                pkgCfgLibVars = $$pkgCfgVars
                #static build is not provided for all packages in vcpkg : TODO : howto handle ?
                pkgCfgLibVars += --libs
            }
            equals(pkg.repoType,"system") {# local system package handling
                pkgCfgFilePath = ""
                !equals(pkg.identifier, "choco") {
                    !system(pkg-config --exists $${libName}) {
                        error("  --> [ERROR] no package found with pkg-config for package " $${libName})
                    }
                }
                message("    --> [INFO] found package " $${libName} " with pkg-config")
                message("    --> [INFO] checking local version for package "  $${libName} " : expected version =" $${pkg.version})
                localpkg.version = $$system(pkg-config --modversion $${libName})
                !equals(pkg.version,$${localpkg.version}) {
                        error("    --> [ERROR] expected version for " $${libName} " is " $${pkg.version} ": system's package version is " $${localpkg.version})
                } else {
                    message("    --> [OK] package expected version and local version matched")
                }
                pkgCfgVars = $${libName}
                pkgCfgLibVars = $$pkgCfgVars
                #static build ?? debug builds ???
                pkgCfgLibVars = "--libs $${libName}"
            }
            equals(pkg.repoType,"conan") {# conan system package handling
                message("    --> ["$${pkg.repoType}"] adding " $${pkg.name} " dependency")
                #use url format according to remote as conan-center index urls are now without '@user/channel' suffix
                equals(pkg.repoUrl,conan-center)|equals(pkg.repoUrl,conancenter) {
                    remakenConanDeps += $${pkg.name}/$${pkg.version}
                } else {
                    remakenConanDeps += $${pkg.name}/$${pkg.version}@$${pkg.identifier}/$${pkg.channel}
                }
                sharedLinkMode = False
                equals(pkg.linkMode,shared) {
                    sharedLinkMode = True
                }
                !equals(pkg.linkMode,na) {
                equals(CONAN_MAJOR_VERSION,1) {
                    remakenConanOptions += $${pkg.name}:shared=$${sharedLinkMode}
                }
                else {
                        remakenConanOptions += $${pkg.name}/*:shared=$${sharedLinkMode}
                    }
                }
                conanOptions = $$split(pkg.toolOptions, $$LITERAL_HASH)
                for (conanOption, conanOptions) {
                    conanOptionInfo = $$split(conanOption, :)
                    conanOptionPrefix = $$take_first(conanOptionInfo)
                    isEmpty(conanOptionInfo) {
                        equals(CONAN_MAJOR_VERSION,1) {
                            remakenConanOptions += $${pkg.name}:$${conanOption}
                        }
                        else {
                            remakenConanOptions += $${pkg.name}/*:$${conanOption}
                        }
                    }
                    else {
                        equals(CONAN_MAJOR_VERSION,1) {
                        remakenConanOptions += $${conanOption}
                    }
                    else {
                            conanOptionPkgOption = $$member(conanOptionInfo,0)
                            remakenConanOptions += $${conanOptionPrefix}/*:$${conanOptionPkgOption}
                        }
                    }
                }
                !equals(CONAN_MAJOR_VERSION,1) {
                   remakenConanDepsPkg+=$${libName}"|"$${sharedLinkMode}
                }
            }
            equals(pkg.repoType,"http") |equals(pkg.repoType,"artifactory") | equals(pkg.repoType,"github") | equals(pkg.repoType,"nexus") {
                # custom built package handling
                deployFolder=$${REMAKENDEPSFOLDER}/$${REMAKEN_TARGET_PLATFORM}/$${pkg.name}/$${pkg.version}
                !equals(pkg.identifier,$${pkg.repoType}) {
                    deployFolder=$${REMAKENDEPSFOLDER}/$${REMAKEN_TARGET_PLATFORM}/$${pkg.identifier}/$${pkg.name}/$${pkg.version}
                    !exists($${deployFolder}) { #try old structure for backward compatibility
                        deployFolder=$${REMAKENDEPSFOLDER}/$${pkg.identifier}/$${REMAKEN_TARGET_PLATFORM}/$${pkg.name}/$${pkg.version}
                    }
                }
                !exists($${deployFolder}) {
                    warning("Dependencies source folder should include the target platform information " $${REMAKEN_TARGET_PLATFORM})
                    deployFolder=$${REMAKENDEPSFOLDER}/$${pkg.name}/$${pkg.version}
                    !equals(pkg.identifier,$${pkg.repoType}) {
                        deployFolder=$${REMAKENDEPSFOLDER}/$${pkg.identifier}/$${pkg.name}/$${pkg.version}
                    }
                    warning("Defaulting search folder to " $${deployFolder})
                }
                remakenInfoFilePath = $${deployFolder}/$${libName}-$${pkg.version}_$${REMAKEN_INFO_SUFFIX}
                !exists($${remakenInfoFilePath}) {
                    warning("No information file found for " $${libName}-$${pkg.version}_$${REMAKEN_INFO_SUFFIX} " found.")
                    warning("Package "  $${pkg.name} " was built with an older version of builddefs. Please upgrade the package builddefs' to the latest version ! ")
                } else {
                    verboseMessage("    --> [INFO] "  $${remakenInfoFilePath} " exists : checking build consistency")
                    win32 {
                        REMAKENINFOFILE_CONTENT = $$cat($${remakenInfoFilePath},lines)
                        WINRT = $$find(REMAKENINFOFILE_CONTENT, runtime=.*)
                        usestaticwinrt {
                            contains(WINRT,.*dynamicCRT) {
                                error("    --> [ERROR] Inconsistent configuration :  it is prohibited to mix shared runtime linked dependency with the static windows runtime (prohibited since VS2017, bad practice before). Either remove 'usestaticwinrt' from your build configuration (remove the line 'CONFIG += usestaticwinrt') , or use a static runtime build of " $${pkg.name})
                            }
                        }
                        else {
                            contains(WINRT,.*staticCRT) {
                                error("    --> [ERROR] Inconsistent configuration :  it is prohibited to mix static runtime linked dependency with the shared windows runtime (prohibited since VS2017, bad practice before). Either add 'usestaticwinrt' to your build configuration (add the line 'CONFIG += usestaticwinrt'), or use a dynamic runtime build of " $${pkg.name})
                                }
                        }
                    }
                }
                oldPkgCfgFilePath = $${deployFolder}/$${OLDPFX}$${DEBUGPFX}$${libName}.pc
                pkgCfgFilePath = $${deployFolder}/$${REMAKENPFX}$${DEBUGPFX}$${libName}.pc
                !exists($${pkgCfgFilePath}):!exists($${oldPkgCfgFilePath}) {
                    # No specific .pc file for debug mode :
                    # this package is a remaken like standard package with no library debug suffix
                    pkgCfgFilePath = $${deployFolder}/$${REMAKENPFX}$${libName}.pc
                    oldPkgCfgFilePath = $${deployFolder}/$${OLDPFX}$${libName}.pc
                }
                !exists($${pkgCfgFilePath}):!exists($${oldPkgCfgFilePath}) {# default behavior
                    message("    --> [WARNING] " $${pkgCfgFilePath} " doesn't exists : adding default values")
                    !exists($${deployFolder}/interfaces) {
                        error("    --> [ERROR] " $${deployFolder}/interfaces " doesn't exists for package " $${libName})
                    }
                    !exists($${deployFolder}/lib/$$REMAKEN_TARGET_ARCH/$${pkg.linkMode}/$$OUTPUTDIR/$${LIBPREFIX}$${libName}.$${LIBEXT}) {
                        error("    --> [ERROR] " $${deployFolder}/lib/$$REMAKEN_TARGET_ARCH/$${pkg.linkMode}/$$OUTPUTDIR/$${LIBPREFIX}$${libName}.$${LIBEXT} " doesn't exists for package " $${libName})
                    }

                    contains(DEPENDENCIESCONFIG,externaldeps)|contains(CONFIG,externaldeps)|contains(REMAKENCONFIG,externaldeps) {
                        win32{
                            QMAKE_CXXFLAGS += /external:I $${deployFolder}/interfaces
                        } else {
                            QMAKE_CXXFLAGS += -isystem$${deployFolder}/interfaces
                        }
                    } else {
                    QMAKE_CXXFLAGS += -I$${deployFolder}/interfaces
}

                    equals(pkg.linkMode,"static") {
                        LIBS += $${deployFolder}/lib/$$REMAKEN_TARGET_ARCH/$${pkg.linkMode}/$$OUTPUTDIR/$${LIBPREFIX}$${libName}.$${LIBEXT}
                    } else {
                        LIBS += $${deployFolder}/lib/$$REMAKEN_TARGET_ARCH/$${pkg.linkMode}/$$OUTPUTDIR -l$${libName}
                    }
                } else {
                    exists($${oldPkgCfgFilePath}):!exists($${pkgCfgFilePath}) {
                        # use old prefix file
                        pkgCfgFilePath = $${oldPkgCfgFilePath}
                    }
                    verboseMessage("    --> [INFO] "  $${pkgCfgFilePath} "exists")
                    pkgCfgVars = --define-variable=prefix=$${deployFolder} --define-variable=depdir=$${deployFolder}/lib/dependencies/$$REMAKEN_TARGET_ARCH/$${pkg.linkMode}/$$OUTPUTDIR
                    pkgCfgVars += --define-variable=lext=$${LIBEXT}
                    pkgCfgVars += --define-variable=libdir=$${deployFolder}/lib/$$REMAKEN_TARGET_ARCH/$${pkg.linkMode}/$$OUTPUTDIR
                    !win32 {
                        pkgCfgVars += --define-variable=pfx=$${LIBPREFIX}
                    }
                    else {
                        pkgCfgVars += --define-variable=pfx=$$shell_quote("\'\'")
                    }
                    pkgCfgLibVars = $$pkgCfgVars
                    equals(pkg.linkMode,"static") {
                        pkgCfgLibVars += --libs-only-other --static
                    } else {
                        pkgCfgLibVars += --libs
                    }
                }
            }
            equals(pkg.repoType,"http")|equals(pkg.repoType,"artifactory")|equals(pkg.repoType,"github")|equals(pkg.repoType,"nexus")|equals(pkg.repoType,"system") {
                verboseMessage("    pkg-config variables for includes :")
                verboseMessage("    $$pkgCfgVars")
                PKGCFG_INCLUDE_PATH = $$system(pkg-config --cflags-only-I $$pkgCfgVars $$pkgCfgFilePath)

                # disable external/system warnings
                #TODO manage path with -I inside / manage space in PKGCFG_INCLUDE_PATH (split by -I before reconstruct and...)
                contains(DEPENDENCIESCONFIG,externaldeps)|contains(CONFIG,externaldeps)|contains(REMAKENCONFIG,externaldeps) {
                   win32{
                        QMAKE_CXXFLAGS += $$replace(PKGCFG_INCLUDE_PATH, -I," /external:I ")
                   } else {
                        QMAKE_CXXFLAGS += $$replace(PKGCFG_INCLUDE_PATH, -I, -isystem)
                   }
                } else {
                    INCLUDEPATH += $$replace(PKGCFG_INCLUDE_PATH, -I, "")
                }

                QMAKE_CXXFLAGS += $$system(pkg-config --cflags-only-other $$pkgCfgVars $$pkgCfgFilePath)

                contains(DEPENDENCIESCONFIG,ignore_transitive):contains(StaticTransitiveDeps,$${pkg.name}) {
                    verboseMessage("    libs :")
                    verboseMessage("    Ignore static transitive dependency lib : $${pkg.name}")
                } else {
                    verboseMessage("    pkg-config variables for libs :")
                    verboseMessage("    $$pkgCfgLibVars")
                    LIBS += $$system(pkg-config $$pkgCfgLibVars $$pkgCfgFilePath)
                }
            }
            verboseMessage(" ")
        } # for(var, dependencies)
        verboseMessage(" ")
        verboseMessage("---- process result for $${depfile} :")
        verboseMessage("  --> [INFO] pkg-config INCLUDEPATH : ")
        verboseMessage("  "$${INCLUDEPATH})
        verboseMessage("  --> [INFO] pkg-config QMAKE_CXXFLAGS : ")
        verboseMessage("  "$${QMAKE_CXXFLAGS})
        verboseMessage("  --> [INFO] LIBS : " )
        verboseMessage("  "$${LIBS})
        verboseMessage(" ")
    } #!exists($${depfile})
} # for(depfile, packagedepsfiles)



# Manage conan dependencies
!isEmpty(remakenConanDeps) {
    REMAKEN_CONAN_DEPS_OUTPUTDIR=$$_PRO_FILE_PWD_/$${REMAKEN_BUILD_RULES_FOLDER}/$${REMAKEN_FULL_PLATFORM}/$${LINKMODE}/$$OUTPUTDIR
    !exists($${REMAKEN_CONAN_DEPS_OUTPUTDIR}) {
        mkpath($${REMAKEN_CONAN_DEPS_OUTPUTDIR})
    }

    #create conanfile.txt
    CONANFILECONTENT="[requires]"
    for (dep,remakenConanDeps) {
        CONANFILECONTENT+=$${dep}
    }
    CONANFILECONTENT+=""
    CONANFILECONTENT+="[generators]"

    equals(CONAN_MAJOR_VERSION,1) {
       CONANFILECONTENT+="qmake"
    }
    else {
        CONANFILECONTENT+="PkgConfigDeps"
    }

    CONANFILECONTENT+=""
    CONANFILECONTENT+="[options]"
    for (option,remakenConanOptions) {
        CONANFILECONTENT+=$${option}
    }
    write_file($${REMAKEN_CONAN_DEPS_OUTPUTDIR}/conanfile.txt, CONANFILECONTENT)
    contains(CONFIG,c++11) {
        !msvc {
            conanCppStd=11
        } else {
            error("Invalid setting for conan : compiler.cppstd supported values for msvc are 14, 17, 20")
        }
    }
    contains(CONFIG,c++14) {
        conanCppStd=14
    }
    contains(CONFIG,c++1z)|contains(CONFIG,c++17) {
        conanCppStd=17
    }
    contains(CONFIG,c++2a)|contains(CONFIG,c++20) {
        conanCppStd=20
    }

    equals(CONAN_MAJOR_VERSION,1) {
        installFolderParam = -if
    }
    else {
        installFolderParam = -of
    }
    # remove conan.lock file (conan V2 can't remove v1 file and makes error)
    win32 {
        system(IF EXIST $${REMAKEN_CONAN_DEPS_OUTPUTDIR}/conan.lock $$QMAKE_DEL_FILE /f $$shell_path($${REMAKEN_CONAN_DEPS_OUTPUTDIR}/conan.lock))
    } else {
        system($$QMAKE_DEL_FILE $$shell_path($${REMAKEN_CONAN_DEPS_OUTPUTDIR}/conan.lock))
    }

    android {
        verboseMessage("conan install $${REMAKEN_CONAN_DEPS_OUTPUTDIR}/conanfile.txt -s $${conanArch} -s compiler.cppstd=$${conanCppStd} -s build_type=$${CONANBUILDTYPE} --build=missing $${installFolderParam} $${REMAKEN_CONAN_DEPS_OUTPUTDIR}")
        system(conan install $${REMAKEN_CONAN_DEPS_OUTPUTDIR}/conanfile.txt -s compiler.cppstd=$${conanCppStd} -s build_type=$${CONANBUILDTYPE} -pr android-clang-$${ANDROID_TARGET_ARCH} --build=missing $${installFolderParam} $${REMAKEN_CONAN_DEPS_OUTPUTDIR})
    }
    else {
        CONAN_COMPILER_VERSION_OPTION=
        CONAN_COMPILER_RUNTIME=
        win32 {
            CONAN_COMPILER_VERSION_OPTION=-s compiler.version=$${CONAN_WIN_COMPILER_VERSION}

            # manage runtime
            equals(CONAN_MAJOR_VERSION,1) {
                usestaticwinrt{
                    equals(CONANBUILDTYPE, "Debug") {
                        CONAN_WIN_COMPILER_RUNTIME="MTd"
                    }
                    else {
                        CONAN_WIN_COMPILER_RUNTIME="MT"
                    }
                }
                else
                {
                    equals(CONANBUILDTYPE, "Debug") {
                        CONAN_WIN_COMPILER_RUNTIME="MDd"
                    }
                    else {
                        CONAN_WIN_COMPILER_RUNTIME="MD"
                    }
                }
            }
            else {
                usestaticwinrt {
                    CONAN_WIN_COMPILER_RUNTIME="static"
                } else {
                    CONAN_WIN_COMPILER_RUNTIME="dynamic"
                }
            }

            CONAN_COMPILER_RUNTIME=-s compiler.runtime=$$CONAN_WIN_COMPILER_RUNTIME
        }
        message("conan install $${REMAKEN_CONAN_DEPS_OUTPUTDIR}/conanfile.txt -s $${conanArch} -s compiler.cppstd=$${conanCppStd} -s build_type=$${CONANBUILDTYPE} $${CONAN_COMPILER_VERSION_OPTION} $${CONAN_COMPILER_VERSION_RUNTIME} --build=missing $${installFolderParam} $${REMAKEN_CONAN_DEPS_OUTPUTDIR}")
        system(conan install $${REMAKEN_CONAN_DEPS_OUTPUTDIR}/conanfile.txt -s $${conanArch} -s compiler.cppstd=$${conanCppStd} -s build_type=$${CONANBUILDTYPE} $${CONAN_COMPILER_VERSION_OPTION} $${CONAN_COMPILER_RUNTIME} $${CONAN_COMPILER_VERSION_RUNTIME} --build=missing $${installFolderParam} $${REMAKEN_CONAN_DEPS_OUTPUTDIR})
    }

    equals(CONAN_MAJOR_VERSION,1) {
        CONFIG += conan_basic_setup
        include($${REMAKEN_CONAN_DEPS_OUTPUTDIR}/conanbuildinfo.pri)
    }
    else {
        for (dep, remakenConanDepsPkg) {
            conanDepInfo = $$split(dep, |)
            name = $$member(conanDepInfo,0)
            sharedLinkMode = $$member(conanDepInfo,1)
            pkgCfgFilePath = $${REMAKEN_CONAN_DEPS_OUTPUTDIR}/$${name}.pc
            !exists($${pkgCfgFilePath})) {# default behavior
                error("    --> [ERROR] " $${pkgCfgFilePath} " doesn't exists")
            } else {
                verboseMessage("    --> [INFO] "  $${pkgCfgFilePath} "exists")
            }

            PKG_CONFIG_PATH_SET_ENVVAR_COMMAND = "export PKG_CONFIG_PATH=$${REMAKEN_CONAN_DEPS_OUTPUTDIR} ;"
            win32{
                PKG_CONFIG_PATH_SET_ENVVAR_COMMAND = "(set PKG_CONFIG_PATH=$${REMAKEN_CONAN_DEPS_OUTPUTDIR}) &&"
            }
            verboseMessage("INCLUDEPATH : $${PKG_CONFIG_PATH_SET_ENVVAR_COMMAND} pkg-config --cflags-only-I $$pkgCfgFilePath")
            verboseMessage("QMAKE_CXXFLAGS : $${PKG_CONFIG_PATH_SET_ENVVAR_COMMAND} pkg-config --cflags-only-other $$pkgCfgFilePath")
            PKGCFG_INCLUDE_PATH = $$system("$${PKG_CONFIG_PATH_SET_ENVVAR_COMMAND} pkg-config --cflags-only-I $$pkgCfgFilePath")

            # disable external/system warnings
            #TODO manage path with -I inside / manage space in PKGCFG_INCLUDE_PATH (split by -I before reconstruct and...)
            contains(DEPENDENCIESCONFIG,externaldeps)|contains(CONFIG,externaldeps)|contains(REMAKENCONFIG,externaldeps) {
               win32{
                    QMAKE_CXXFLAGS += $$replace(PKGCFG_INCLUDE_PATH, -I," /external:I ")
               } else {
                    QMAKE_CXXFLAGS += $$replace(PKGCFG_INCLUDE_PATH, -I, -isystem)
               }
            } else {
                INCLUDEPATH += $$replace(PKGCFG_INCLUDE_PATH, -I, "")
            }

            QMAKE_CXXFLAGS += $$system("$${PKG_CONFIG_PATH_SET_ENVVAR_COMMAND} pkg-config --cflags-only-other $$pkgCfgFilePath")

            equals(sharedLinkMode,"False") {
                pkgCfgLibVars = --libs-only-other --static
            } else {
                pkgCfgLibVars = --libs
            }
            pkgCfgLibVars = --libs #SLETODO always this even in static mode...todo test in shared mode
            verboseMessage("LIBS : $${PKG_CONFIG_PATH_SET_ENVVAR_COMMAND} pkg-config $$pkgCfgLibVars $$pkgCfgFilePath")
            LIBS += $$system("$${PKG_CONFIG_PATH_SET_ENVVAR_COMMAND} pkg-config $$pkgCfgLibVars $$pkgCfgFilePath")
        } # for(var, remakenConanDepsPkg)
        verboseMessage(" ")
        verboseMessage("---- process result after add conan dependencies :")
        verboseMessage("  --> [INFO] pkg-config INCLUDEPATH : ")
        verboseMessage("  "$${INCLUDEPATH})
        verboseMessage("  --> [INFO] pkg-config QMAKE_CXXFLAGS : ")
        verboseMessage("  "$${QMAKE_CXXFLAGS})
        verboseMessage("  --> [INFO] LIBS : " )
        verboseMessage("  "$${LIBS})
        verboseMessage(" ")
    }

    # TODO remove generated '$${REMAKEN_CONAN_DEPS_OUTPUTDIR}' folder
}

message("----------------------------------------------------------------")
message("---- Global processing result ")
message("  --> [INFO] QMAKE_CXXFLAGS : ")
message("  "$${QMAKE_CXXFLAGS})
message("  --> [INFO] INCLUDEPATH : ")
message("  "$${INCLUDEPATH})
message("  --> [INFO] LIBS : " )
message("  "$${LIBS})
QMAKE_CFLAGS += $${QMAKE_CXXFLAGS}
QMAKE_OBJECTIVE_CFLAGS += $${QMAKE_CXXFLAGS}

