# Author(s) : Loic Touraine, Stephane Leduc

# Check input parameters existence
!defined(DEPENDENCIESCONFIG,var) {
    warning("DEPENDENCIESCONFIG is not defined : defaulting to shared dependencies mode")
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

for(depfile, packagedepsfiles) {
    exists($${depfile}) {
        message("----------------- Processing " $${depfile} " -----------------" )
        dependencies = $$cat($${depfile})
        for(var, dependencies) {
            dependencyMetaInf = $$split(var, |)
            pkgName = $$member(dependencyMetaInf,0)
            pkgVersion = $$member(dependencyMetaInf,1)
            libName = $$member(dependencyMetaInf,2)
            pkgCategory = $$member(dependencyMetaInf,3)
            pkgLinkModeOverride = $$member(dependencyMetaInf,5)
            # check pkgLinkModeOverride not empty and mandatory equals to static|shared, otherwise set to default DEPLINKMODE
            equals(pkgLinkModeOverride,"") {
                pkgLinkModeOverride = $${DEPLINKMODE}
            } else {
                if (!equals(pkgLinkModeOverride,"static"):!equals(pkgLinkModeOverride,"shared")){
                    pkgLinkModeOverride = $${DEPLINKMODE}
                }
            }
            # VPCKG package handling
            equals(pkgCategory,"vcpkg") {
                deployFolder=$$(BCOMDEVROOT)/$${pkgCategory}/packages/$${pkgName}_$${vcpkgtriplet}
                !exists($${deployFolder}) {
                    error("No VPCKG package at " $${BCdeployFolderOM_TARGET_PLATFORM})
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
                #equals(pkgLinkModeOverride,"static") {
                #    pkgCfgLibVars += --libs-only-other --static
                #    bFoundAtLeastOneStaticDep = 1
                #} else {
                pkgCfgLibVars += --libs
                #}
            } else {
                equals(pkgCategory,"system") {# local system package handling
                    pkgCfgFilePath = /usr/local/lib/pkgconfig/$${libName}.pc
                    !exists($${pkgCfgFilePath}) {# error
                        pkgCfgFilePath = /usr/lib/pkgconfig/$${libName}.pc
                        !exists($${pkgCfgFilePath}) {#
                            error("--> [ERROR] " $${pkgCfgFilePath} " doesn't exists for package " $${libName})
                        }
                    }
                    message("--> [INFO] "  $${pkgCfgFilePath} "exists")
                    message("--> [INFO] checking local version for package "  $${libName} " : expected version =" $${pkgVersion})
                    localPkgVersion = $$system(pkg-config --modversion $${libName})
                    !equals(pkgVersion,$${localPkgVersion}) {
                         error("--> [ERROR] expected version for " $${libName} " is " $${pkgVersion} ": system's package version is " $${localPkgVersion})
                    } else {
                    message("  |---> [OK] package expected version and local version matched")
                    }
                    pkgCfgVars = $${libName}
                    pkgCfgLibVars = $$pkgCfgVars
                    #static build is not provided for all packages in vcpkg : TODO : howto handle ?
                    #equals(pkgLinkModeOverride,"static") {
                    #    pkgCfgLibVars += --libs-only-other --static
                    #    bFoundAtLeastOneStaticDep = 1
                    #} else {
                    pkgCfgLibVars = "--libs $${libName}"
                    #}
                } else {
                    # custom built package handling
                    deployFolder=$$(BCOMDEVROOT)/$${pkgCategory}/$${BCOM_TARGET_PLATFORM}/$${pkgName}/$${pkgVersion}
                    !exists($${deployFolder}) {
                        warning("Dependencies source folder should include the target platform information " $${BCOM_TARGET_PLATFORM})
                        deployFolder=$$(BCOMDEVROOT)/$${pkgCategory}/$${pkgName}/$${pkgVersion}
                        warning("Defaulting search folder to " $${deployFolder})
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
            }
            # message("pkg-config variables for includes : " $$pkgCfgVars)
            # message("pkg-config variables for libs : " $$pkgCfgLibVars)
            BCOMDEPSINCLUDEPATH += $$system(pkg-config --cflags $$pkgCfgVars $$pkgCfgFilePath)
            # QMAKE_CXXFLAGS += $$system(pkg-config --cflags $$pkgCfgVars $$pkgCfgFilePath)
            LIBS += $$system(pkg-config $$pkgCfgLibVars $$pkgCfgFilePath)
        }
        QMAKE_CXXFLAGS += $${BCOMDEPSINCLUDEPATH}
        message("")
        message("----------------- $${depfile} " process result :" -----------------" )
        message("--> [INFO] QMAKE_CXXFLAGS : ")
        message("     " $${QMAKE_CXXFLAGS})
        message("")
        message("--> [INFO] LIBS : " )
        message("     " $${LIBS})
        message("")
    } else {
        message("No " $${depfile} " file to process for " $$TARGET)
    }
}

win32 {
    # override project configuration if there is at least one static dependency
    # and if hasn't been already override in templateLib|App (for a 'staticlib' lib or 'static' app)
    shared {
        equals(bFoundAtLeastOneStaticDep,1) {
            QMAKE_CXXFLAGS_DEBUG += -MTd
            QMAKE_CXXFLAGS_DEBUG -= -MDd
            QMAKE_CFLAGS_DEBUG += -MTd
            QMAKE_CFLAGS_DEBUG -= -MDd
            QMAKE_CXXFLAGS_RELEASE += -MT
            QMAKE_CXXFLAGS_RELEASE -= -MD
            QMAKE_CFLAGS_RELEASE += -MT
            QMAKE_CFLAGS_RELEASE -= -MD
        }
    }
}


QMAKE_CFLAGS += $${QMAKE_CXXFLAGS}
QMAKE_OBJECTIVE_CFLAGS += $${QMAKE_CXXFLAGS}

exists($$_PRO_FILE_PWD_/$${BCOMPFX}$${TARGET}.pc.in) {
    templatePkgConfigSrc=$$_PRO_FILE_PWD_/$${BCOMPFX}$${TARGET}.pc.in
} else {
    templatePkgConfigSrc=template-pkgconfig.pc.in
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
