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
    subDeps = $$populateSubDependencies($${packagedepsfiles})
    for (i, recursionLevels) {
        !isEmpty(subDeps) {
            packagedepsfiles += $${subDeps}
            subDeps = $$populateSubDependencies($${subDeps})
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
    message("----------------------------------------------------------------")
    message(" ")
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
                    remakenConanOptions += $${pkg.name}:shared=$${sharedLinkMode}
                }
                conanOptions = $$split(pkg.toolOptions, $$LITERAL_HASH)
                for (conanOption, conanOptions) {
                    conanOptionInfo = $$split(conanOption, :)
                    conanOptionPrefix = $$take_first(conanOptionInfo)
                    isEmpty(conanOptionInfo) {
                        remakenConanOptions += $${pkg.name}:$${conanOption}
                    }
                    else {
                        remakenConanOptions += $${conanOption}
                    }
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
                pkgCfgFilePath = $${deployFolder}/$${REMAKENPFX}$${DEBUGPFX}$${libName}.pc
                !exists($${pkgCfgFilePath}) {
                    # No specific .pc file for debug mode :
                    # this package is a remaken like standard package with no library debug suffix
                    pkgCfgFilePath = $${deployFolder}/$${REMAKENPFX}$${libName}.pc
                }
                !exists($${pkgCfgFilePath}) {# default behavior
                    message("    --> [WARNING] " $${pkgCfgFilePath} " doesn't exists : adding default values")
                    !exists($${deployFolder}/interfaces) {
                        error("    --> [ERROR] " $${deployFolder}/interfaces " doesn't exists for package " $${libName})
                    }
                    !exists($${deployFolder}/lib/$$REMAKEN_TARGET_ARCH/$${pkg.linkMode}/$$OUTPUTDIR/$${LIBPREFIX}$${libName}.$${LIBEXT}) {
                        error("    --> [ERROR] " $${deployFolder}/lib/$$REMAKEN_TARGET_ARCH/$${pkg.linkMode}/$$OUTPUTDIR/$${LIBPREFIX}$${libName}.$${LIBEXT} " doesn't exists for package " $${libName})
                    }

                    QMAKE_CXXFLAGS += -I$${deployFolder}/interfaces
                    equals(pkg.linkMode,"static") {
                        LIBS += $${deployFolder}/lib/$$REMAKEN_TARGET_ARCH/$${pkg.linkMode}/$$OUTPUTDIR/$${LIBPREFIX}$${libName}.$${LIBEXT}
                    } else {
                        LIBS += $${deployFolder}/lib/$$REMAKEN_TARGET_ARCH/$${pkg.linkMode}/$$OUTPUTDIR -l$${libName}
                    }
                } else {
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
                verboseMessage("    pkg-config variables for libs :")
                verboseMessage("    $$pkgCfgLibVars")
                PKGCFG_CFLAGS += $$system(pkg-config --cflags $$pkgCfgVars $$pkgCfgFilePath)
                LIBS += $$system(pkg-config $$pkgCfgLibVars $$pkgCfgFilePath)
            }
            verboseMessage(" ")
        } # for(var, dependencies)
        verboseMessage("---- process result for $${depfile} :")
        verboseMessage("  --> [INFO] pkg-config CFLAGS : ")
        verboseMessage("  "$${PKGCFG_CFLAGS})
        verboseMessage("  --> [INFO] LIBS : " )
        verboseMessage("  "$${LIBS})
        verboseMessage(" ")
    } #!exists($${depfile})
} # for(depfile, packagedepsfiles)


# separate parameters manually in generated qmake vars
# because 'split' does't run correctly with space in path
gen_suffix=
for(info, PKGCFG_CFLAGS) {
    first2char = $$str_member($$info, 0, 1)
    equals(first2char, "-W") | equals(first2char, "-D") | equals (first2char, "-I") {
        gen_suffix= $${gen_suffix}A
        gen_cflags_$${gen_suffix}=$$info
        LIST_CFLAGVAR += gen_cflags_$${gen_suffix}
    } else {
        gen_cflags_$${gen_suffix}+=$$info
    }
}
# now split -I in INCLUDEPATH and -D in QMAKE_CXX_FLAGS
for (var, LIST_CFLAGVAR) {
    first2char = $$str_member($$eval($${var}), 0, 1)
    equals (first2char, "-I") {
        #manage path with space
        # TODO check with a real path with space
        INCLUDEPATH += $$shell_quote($$replace($$eval(var), -I,))
    } else {
        QMAKE_CXXFLAGS += $$eval($${var})
    }
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
    CONANFILECONTENT+="qmake"
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

    CONFIG += conan_basic_setup
#conan install -o boost:shared=True -s build_type=Release -s cppstd=14 boost/1.68.0@conan/stable
    verboseMessage("conan install $${REMAKEN_CONAN_DEPS_OUTPUTDIR}/conanfile.txt -s $${conanArch} -s compiler.cppstd=$${conanCppStd} -s build_type=$${CONANBUILDTYPE} --build=missing -if $${REMAKEN_CONAN_DEPS_OUTPUTDIR}")
    android {
        system(conan install $${REMAKEN_CONAN_DEPS_OUTPUTDIR}/conanfile.txt -s compiler.cppstd=$${conanCppStd} -s build_type=$${CONANBUILDTYPE} -pr android-clang-$${ANDROID_TARGET_ARCH} --build=missing -if $${REMAKEN_CONAN_DEPS_OUTPUTDIR})
    }
    else {
        system(conan install $${REMAKEN_CONAN_DEPS_OUTPUTDIR}/conanfile.txt -s $${conanArch} -s compiler.cppstd=$${conanCppStd} -s build_type=$${CONANBUILDTYPE} --build=missing -if $${REMAKEN_CONAN_DEPS_OUTPUTDIR})
    }
    include($${REMAKEN_CONAN_DEPS_OUTPUTDIR}/conanbuildinfo.pri)
}
else {
    # TODO remove generated '$${REMAKEN_CONAN_DEPS_OUTPUTDIR}' folder
}
