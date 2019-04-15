# Author(s) : Loic Touraine, Stephane Leduc

# Check input parameters existence
!defined(DEPENDENCIESCONFIG,var) {
    warning("DEPENDENCIESCONFIG is not defined : defaulting to shared dependencies mode")
    DEPENDENCIESCONFIG = sharedlib
}

# Detect build toolchain and define BCOM_TARGET_ARCH
include(bcom_arch_define.pri)

contains(DEPENDENCIESCONFIG,staticlib) {
    DEPLINKMODE = static
} else {
    DEPLINKMODE = shared
}

CONFIG(debug,debug|release) {
    OUTPUTDIR = debug
    DEBUGPFX = debug-
}

CONFIG(release,debug|release) {
    OUTPUTDIR = release
}

packagedepsfiles = $$_PRO_FILE_PWD_/packagedependencies.txt
win32 {
    packagedepsfiles += $$_PRO_FILE_PWD_/packagedependencies-win.txt
    vcpkgtriplet = x64-windows
}
# Common unix platform (macx, linux...)
unix {
    packagedepsfiles += $$_PRO_FILE_PWD_/packagedependencies-unix.txt
}
macx {
    packagedepsfiles += $$_PRO_FILE_PWD_/packagedependencies-mac.txt
    vcpkgtriplet = x64-osx
}
linux {
    packagedepsfiles += $$_PRO_FILE_PWD_/packagedependencies-linux.txt
    vcpkgtriplet = x64-linux
}

BCOMPFX = bcom-
bFoundAtLeastOneStaticDep = 0
BCOMDEPSINCLUDEPATH=""

defineReplace(populateSubDependencies) {
    packageDepsFilesList = $$ARGS
    for(depfile, packageDepsFilesList) {
        exists($${depfile}) {
            baseDepFile = $$basename(depfile)
            message("----------------- Parsing sub-dependencies from " $${depfile} " -----------------" )
            dependencies = $$cat($${depfile})
            for(var, dependencies) {
                dependencyPkgDepFiles=""
                dependencyMetaInf = $$split(var, |)
                pkgName = $$member(dependencyMetaInf,0)
                pkgVersion = $$member(dependencyMetaInf,1)
                libName = $$member(dependencyMetaInf,2)
                pkgCategory = $$member(dependencyMetaInf,3)
                pkgRepoUrl = $$member(dependencyMetaInf,4)
                pkgLinkModeOverride = $$member(dependencyMetaInf,5)
                pkgCommandOptions = $$member(dependencyMetaInf,6)
                deployFolder=$${REMAKENDEPSFOLDER}/$${pkgCategory}/$${BCOM_TARGET_PLATFORM}/$${pkgName}/$${pkgVersion}
                write_file($$OUT_PWD/$${TARGET}-$${baseDepFile},var,append)
                !exists($${deployFolder}) {
                    warning("Dependencies source folder should include the target platform information " $${BCOM_TARGET_PLATFORM})
                    deployFolder=$${REMAKENDEPSFOLDER}/$${pkgCategory}/$${pkgName}/$${pkgVersion}
                    warning("Defaulting search folder to " $${deployFolder})
                }
                !exists($${deployFolder}) {
                    error("No package found at " $${deployFolder})
                }
                exists($${deployFolder}/packagedependencies.txt) {
                    dependencyPkgDepFiles+=$${deployFolder}/packagedependencies.txt
                }
                win32 {
                    exists($${deployFolder}/packagedependencies-win.txt) {
                         dependencyPkgDepFiles += $${deployFolder}/packagedependencies-win.txt
                    }
                }
                # Common unix platform (macx, linux...)
                unix {
                    exists($${deployFolder}/packagedependencies-unix.txt) {
                        dependencyPkgDepFiles += $${deployFolder}/packagedependencies-unix.txt
                    }
                }
                macx {
                    exists($${deployFolder}/packagedependencies-mac.txt) {
                        dependencyPkgDepFiles += $${deployFolder}/packagedependencies-mac.txt
                    }
                }
                linux {
                    exists($${deployFolder}/packagedependencies-linux.txt) {
                         dependencyPkgDepFiles += $${deployFolder}/packagedependencies-linux.txt
                    }
                }
                outPackageDeps += $${dependencyPkgDepFiles}
            }
            isEmpty(outPackageDeps) {
                message("----------------- No sub-dependencies found -----------------")
            } else {
                message("----------------- Sub-dependencies found for " $${depfile} " :" )
                message("           |====>"  $${outPackageDeps} )
            }
            message("")
        }
    }
    return($${outPackageDeps})
}

contains(DEPENDENCIESCONFIG,recurse) {
    # generate output files that will contain complete dependencies informations from recursion
    for (depFile, packagedepsfiles) {
        baseDepFile = $$basename(depFile)
        write_file($$OUT_PWD/$${TARGET}-$${baseDepFile})
        QMAKE_CLEAN += $$OUT_PWD/$${TARGET}-$${baseDepFile}
    }

    recursionLevels = 0 1 2 3 4 5 6 7 8 9
    #    packagedepsfiles
    subDeps = $$populateSubDependencies($${packagedepsfiles})
     for (i, recursionLevels) {
        !isEmpty(subDeps) {
            packagedepsfiles += $${subDeps}
	    subDeps = $$populateSubDependencies($${subDeps})
	}
    }

    message("----------------- Complete dependencies list for project " $${TARGET} " :" )
    targetDepFiles=$$files($$OUT_PWD/$${TARGET}-packagedependencies*.txt)
    for (depfile, targetDepFiles) {
        message( $${depfile} ":")
        dependencies = $$cat($${depfile})
        for(var, dependencies) {
           message( $$var)
        }
    }
    message("-------------------------------------------------------------------------------------")
    message("")
}

for(depfile, packagedepsfiles) {
    exists($${depfile}) {
        message("----------------- Processing " $${depfile} " -----------------" )
        dependencies = $$cat($${depfile})
        for(var, dependencies) {
            dependencyMetaInf = $$split(var, |)
            pkgInformation = $$member(dependencyMetaInf,0)
            pkgInfoList = $$split(pkgInformation, $$LITERAL_HASH)
            pkgName = $$member(pkgInfoList,0)
            pkgChannel = "stable"
            equals(size(pkgInf),2) {
                pkgChannel = $$member(pkgInfoList,1)
            }
            pkgVersion = $$member(dependencyMetaInf,1)
            libName = $$member(dependencyMetaInf,2)
            pkgTypeInformation = $$member(dependencyMetaInf,3)
            pkgTypeInfoList = $$split(pkgTypeInformation, @)
            pkgCategory = $$member(pkgTypeInfoList,0)
            pkgRepoType = $${pkgCategory}
            equals(size(pkgTypeInf),2) {
                pkgRepoType = $$member(pkgTypeInfoList,1)
            } else {
               equals(pkgCategory,"bcomBuild")|equals(pkgCategory,"thirdParties") {
                    pkgRepoType = "b-com"
                }  # otherwise pkgRepoType = pkgCategory
            }
            pkgUrl=$$member(dependencyMetaInf,4)
            pkgLinkModeOverride = $$member(dependencyMetaInf,5)
            pkgCommandOptions = $$member(dependencyMetaInf,6)
            message("--> [INFO] Processing dependency for "  $${pkgRepoType} " repository")
            # check pkgLinkModeOverride not empty and mandatory equals to static|shared, otherwise set to default DEPLINKMODE
            equals(pkgLinkModeOverride,"")|equals(pkgLinkModeOverride,"default") {
                pkgLinkModeOverride = $${DEPLINKMODE}
            } else {
                if (!equals(pkgLinkModeOverride,"static"):!equals(pkgLinkModeOverride,"shared"):!equals(pkgLinkModeOverride,"na")){
                    pkgLinkModeOverride = $${DEPLINKMODE}
                }
            }
            # VPCKG package handling
            equals(pkgRepoType,"vcpkg") {
                deployFolder=$${REMAKENDEPSFOLDER}/$${pkgRepoType}/packages/$${pkgName}_$${vcpkgtriplet}
                !exists($${deployFolder}) {
                    error("No VPCKG package at "  $${REMAKENDEPSFOLDER}/$${pkgRepoType}/packages/$${pkgName}_$${vcpkgtriplet})
                }
                # TODO : check package version with installed one !
                LIBFOLDER=lib
                equals(OUTPUTDIR,"debug") {
                    LIBFOLDER="debug/lib"
                }
                pkgCfgFilePath = $${deployFolder}/$${LIBFOLDER}/pkgconfig/$${libName}.pc
                !exists($${pkgCfgFilePath}) {# error
                    error("--> [ERROR] " $${pkgCfgFilePath} " doesn't exists for VCPKG package " $${pkgName}_$${vcpkgtriplet})
                }
                message("--> [INFO] "  $${pkgCfgFilePath} "exists")
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
            equals(pkgRepoType,"system") {# local system package handling
                pkgCfgFilePath = /usr/local/lib/pkgconfig/$${libName}.pc
                !exists($${pkgCfgFilePath}) {# error
                    pkgCfgFilePath = /usr/lib/pkgconfig/$${libName}.pc
                    !exists($${pkgCfgFilePath}) {#
                        error("--> [ERROR] " $${pkgCfgFilePath} " doesn't exists for package " $${libName})
                    }
                }
                message("--> [INFO] "  $${pkgCfgFilePath} " exists")
                message("--> [INFO] checking local version for package "  $${libName} " : expected version =" $${pkgVersion})
                localPkgVersion = $$system(pkg-config --modversion $${libName})
                !equals(pkgVersion,$${localPkgVersion}) {
                     error("--> [ERROR] expected version for " $${libName} " is " $${pkgVersion} ": system's package version is " $${localPkgVersion})
                } else {
                message("  |---> [OK] package expected version and local version matched")
                }
                pkgCfgVars = $${libName}
                pkgCfgLibVars = $$pkgCfgVars
                #static build ?? debug builds ???
                pkgCfgLibVars = "--libs $${libName}"
            }
            equals(pkgRepoType,"conan") {# conan system package handling
                remakenConanDeps += $${pkgName}/$${pkgVersion}@$${pkgCategory}/$${pkgChannel}
                sharedLinkMode = False
                equals(pkgLinkModeOverride,shared) {
                    sharedLinkMode = True
                }
                !equals(pkgLinkModeOverride,na) {
                   remakenConanOptions += $${pkgName}:shared=$${sharedLinkMode}
                }
            }
            equals(pkgRepoType,"b-com")|equals(pkgRepoType,"github") {
                # custom built package handling
                deployFolder=$${REMAKENDEPSFOLDER}/$${pkgCategory}/$${BCOM_TARGET_PLATFORM}/$${pkgName}/$${pkgVersion}
                !exists($${deployFolder}) {
                    warning("Dependencies source folder should include the target platform information " $${BCOM_TARGET_PLATFORM})
                    deployFolder=$${REMAKENDEPSFOLDER}/$${pkgCategory}/$${pkgName}/$${pkgVersion}
                    warning("Defaulting search folder to " $${deployFolder})
                }
                remakenInfoFilePath = $${deployFolder}/$${libName}-$${pkgVersion}_$${REMAKEN_INFO_SUFFIX}
                !exists($${remakenInfoFilePath}) {
                    warning("No information file found for " $${libName}-$${pkgVersion}_$${REMAKEN_INFO_SUFFIX} " found.")
                    warning("Package "  $${pkgName} " was built with an older version of builddefs. Please upgrade the package builddefs' to the latest version ! ")
                } else {
                    message("--> [INFO] "  $${remakenInfoFilePath} " exists : checking build consistency")
                    win32 {
                        REMAKENINFOFILE_CONTENT = $$cat($${remakenInfoFilePath},lines)
                        WINRT = $$find(REMAKENINFOFILE_CONTENT, runtime=.*)
                        usestaticwinrt {
                            contains(WINRT,.*dynamicCRT) {
                                error("--> [ERROR] Inconsistent configuration :  it is prohibited to mix shared runtime linked dependency with the static windows runtime (prohibited since VS2017, bad practice before). Either remove 'usestaticwinrt' from your build configuration (remove the line 'CONFIG += usestaticwinrt') , or use a static runtime build of " $${pkgName})
                            }
                        }
                        else {
                            contains(WINRT,.*staticCRT) {
                                error("--> [ERROR] Inconsistent configuration :  it is prohibited to mix static runtime linked dependency with the shared windows runtime (prohibited since VS2017, bad practice before). Either add 'usestaticwinrt' to your build configuration (add the line 'CONFIG += usestaticwinrt'), or use a dynamic runtime build of " $${pkgName})
                             }
                        }
                    }
                }
                pkgCfgFilePath = $${deployFolder}/$${BCOMPFX}$${DEBUGPFX}$${libName}.pc
                !exists($${pkgCfgFilePath}) {
                    # No specific .pc file for debug mode :
                    # this package is a bcom like standard package with no library debug suffix
                    pkgCfgFilePath = $${deployFolder}/$${BCOMPFX}$${libName}.pc
                }
                !exists($${pkgCfgFilePath}) {# default behavior
                    message("--> [WARNING] " $${pkgCfgFilePath} " doesn't exists : adding default values (check your config if it should exists)")
                   # QMAKE_CXXFLAGS += -I$${deployFolder}/interfaces
                    BCOMDEPSINCLUDEPATH += $${deployFolder}/interfaces
                    equals(pkgLinkModeOverride,"static") {
                        LIBS += $${deployFolder}/lib/$$BCOM_TARGET_ARCH/$$OUTPUTDIR/$${LIBPREFIX}$${libName}.$${LIBEXT}
                        bFoundAtLeastOneStaticDep = 1
                    } else {
                        LIBS += $${deployFolder}/lib/$$BCOM_TARGET_ARCH/$$OUTPUTDIR -l$${libName}
                    }

                } else {
                    message("--> [INFO] "  $${pkgCfgFilePath} "exists")
                    pkgCfgVars = --define-variable=prefix=$${deployFolder} --define-variable=depdir=$${deployFolder}/lib/dependencies/$$BCOM_TARGET_ARCH/$${pkgLinkModeOverride}/$$OUTPUTDIR
                    pkgCfgVars += --define-variable=lext=$${LIBEXT}
                    pkgCfgVars += --define-variable=libdir=$${deployFolder}/lib/$$BCOM_TARGET_ARCH/$${pkgLinkModeOverride}/$$OUTPUTDIR
                    !win32 {
                        pkgCfgVars += --define-variable=pfx=$${LIBPREFIX}
                    }
                    else {
                        pkgCfgVars += --define-variable=pfx=$$shell_quote("\'\'")
                    }
                    pkgCfgLibVars = $$pkgCfgVars
                    equals(pkgLinkModeOverride,"static") {
                        pkgCfgLibVars += --libs-only-other --static
                        bFoundAtLeastOneStaticDep = 1
                    } else {
                        pkgCfgLibVars += --libs
                    }
                }
            }
	    equals(pkgRepoType,"b-com")|equals(pkgRepoType,"system") {
            # message("pkg-config variables for includes : " $$pkgCfgVars)
            # message("pkg-config variables for libs : " $$pkgCfgLibVars)
            BCOMDEPSINCLUDEPATH += $$system(pkg-config --cflags $$pkgCfgVars $$pkgCfgFilePath)
            # QMAKE_CXXFLAGS += $$system(pkg-config --cflags $$pkgCfgVars $$pkgCfgFilePath)
            LIBS += $$system(pkg-config $$pkgCfgLibVars $$pkgCfgFilePath)
	    }
        }
        QMAKE_CXXFLAGS += $${BCOMDEPSINCLUDEPATH}
        message("|")
        message("----------------- $${depfile} " process result :" -----------------" )
        message("--> [INFO] QMAKE_CXXFLAGS : ")
        message("     " $${QMAKE_CXXFLAGS})
        message("|")
        message("--> [INFO] LIBS : " )
        message("     " $${LIBS})
        message("|")
    } else {
        message("No " $${depfile} " file to process for " $$TARGET)
    }
}

QMAKE_CFLAGS += $${QMAKE_CXXFLAGS}
QMAKE_OBJECTIVE_CFLAGS += $${QMAKE_CXXFLAGS}

exists($$_PRO_FILE_PWD_/$${BCOMPFX}$${TARGET}.pc.in) {
    templatePkgConfigSrc=$$_PRO_FILE_PWD_/$${BCOMPFX}$${TARGET}.pc.in
} else {
    templatePkgConfigSrc=template-pkgconfig.pc.in
}

# Manage conan dependencies
!isEmpty(remakenConanDeps) {
    !exists($$_PRO_FILE_PWD_/build) {
        mkpath($$_PRO_FILE_PWD_/build)
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
    write_file($$_PRO_FILE_PWD_/build/conanfile.txt, CONANFILECONTENT)
    contains(CONFIG,c++11) {
        conanCppStd=11
    }
    contains(CONFIG,c++14) {
        conanCppStd=14
    }
    contains(CONFIG,c++1z)|contains(CONFIG,c++17) {
        conanCppStd=17
    }
    CONFIG += conan_basic_setup
#conan install -o boost:shared=True -s build_type=Release -s cppstd=14 boost/1.68.0@conan/stable
    system(conan install $$_PRO_FILE_PWD_/build/conanfile.txt -s cppstd=$$conanCppStd --build=missing -if $$_PRO_FILE_PWD_/build)
    include($$_PRO_FILE_PWD_/build/conanbuildinfo.pri)
}

message("--> [INFO] using file "  $${templatePkgConfigSrc} " as pkgconfig template source")
PCFILE_CONTENT = $$cat($${templatePkgConfigSrc},lines)
PCFILE_CONTENT = $$replace(PCFILE_CONTENT, "@TARGET@", $$TARGET)
PCFILE_CONTENT = $$replace(PCFILE_CONTENT, "@VERSION@", $$VERSION)
write_file($$OUT_PWD/$${BCOMPFX}$${TARGET}.pc, PCFILE_CONTENT)
QMAKE_DISTCLEAN += $$OUT_PWD/$${BCOMPFX}$${TARGET}.pc


# TODO : place in an other file - separate finding and copy dependencies
# PROJECTDEPLOYDIR only defined for lib
defined(PROJECTDEPLOYDIR,var) {
    package_files.path = $${PROJECTDEPLOYDIR}
    exists($$_PRO_FILE_PWD_/packagedependencies.txt) {
        package_files.files = $$_PRO_FILE_PWD_/packagedependencies.txt
    }
    win32:exists($$_PRO_FILE_PWD_/packagedependencies-win.txt) {
        package_files.files += $$_PRO_FILE_PWD_/packagedependencies-win.txt
    }
    unix:exists($$_PRO_FILE_PWD_/packagedependencies-unix.txt) {
        package_files.files += $$_PRO_FILE_PWD_/packagedependencies-unix.txt
    }
	macx:exists($$_PRO_FILE_PWD_/packagedependencies-mac.txt) {
        package_files.files += $$_PRO_FILE_PWD_/packagedependencies-mac.txt
    }
	linux:exists($$_PRO_FILE_PWD_/packagedependencies-linux.txt) {
        package_files.files += $$_PRO_FILE_PWD_/packagedependencies-linux.txt
    }
    exists($$OUT_PWD/$${BCOMPFX}$${TARGET}.pc) {
        package_files.files += $$OUT_PWD/$${BCOMPFX}$${TARGET}.pc
    }

    INSTALLS += package_files
}
