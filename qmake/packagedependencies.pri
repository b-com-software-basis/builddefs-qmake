# Author(s) : Loic Touraine, Stephane Leduc

contains(DEPENDENCIESCONFIG,staticlib) {
    DEPLINKMODE = static
} else {
    DEPLINKMODE = shared
}

CONFIG(debug,debug|release) {
    OUTPUTDIR = debug
}

CONFIG(release,debug|release) {
    OUTPUTDIR = release
}

packagedepsfiles = $$_PRO_FILE_PWD_/packagedependencies.txt
win32 {
    packagedepsfiles += $$_PRO_FILE_PWD_/packagedependencies-win.txt
}

macx {
    packagedepsfiles += $$_PRO_FILE_PWD_/packagedependencies-mac.txt
}

BCOMPFX = bcom-
bFoundAtLeastOneStaticDep = 0

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

            deployFolder=$$(BCOMDEVROOT)/$${pkgCategory}/$${pkgName}/$${pkgVersion}
            pkgCfgFilePath = $${deployFolder}/$${BCOMPFX}$${libName}.pc
            !exists($${pkgCfgFilePath}) {# default behavior
                message("--> [WARNING] " $${pkgCfgFilePath} " doesn't exists : adding default values (check your config if it should exists)")
                QMAKE_CXXFLAGS += -I$${deployFolder}/interfaces
                equals(pkgLinkModeOverride,"static") {
                    LIBS += $${deployFolder}/lib/$$QMAKE_TARGET.arch/$$OUTPUTDIR/$${LIBPREFIX}$${libName}.$${LIBEXT}
                    bFoundAtLeastOneStaticDep = 1
                } else {
                    LIBS += $${deployFolder}/lib/$$QMAKE_TARGET.arch/$$OUTPUTDIR -l$${libName}
                }

            } else {
                message("--> [INFO] "  $${pkgCfgFilePath} "exists")
                pkgCfgVars = --define-variable=prefix=$${deployFolder} --define-variable=depdir=$${deployFolder}/lib/dependencies/$$QMAKE_TARGET.arch/$${pkgLinkModeOverride}/$$OUTPUTDIR
                pkgCfgVars += --define-variable=lext=$${LIBEXT}
                pkgCfgVars += --define-variable=libdir=$${deployFolder}/lib/$$QMAKE_TARGET.arch/$${pkgLinkModeOverride}/$$OUTPUTDIR
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
               # message("pkg-config variables for includes : " $$pkgCfgVars)
               # message("pkg-config variables for libs : " $$pkgCfgLibVars)
                QMAKE_CXXFLAGS += $$system(pkg-config --cflags $$pkgCfgVars $$pkgCfgFilePath)
                LIBS += $$system(pkg-config $$pkgCfgLibVars $$pkgCfgFilePath)
            }
        }
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
    PCFILE_CONTENT = $$cat($$_PRO_FILE_PWD_/$${BCOMPFX}$${TARGET}.pc.in,lines)
    PCFILE_CONTENT = $$replace(PCFILE_CONTENT, "@TARGET@", $$TARGET)
    PCFILE_CONTENT = $$replace(PCFILE_CONTENT, "@VERSION@", $$VERSION)
    write_file($$OUT_PWD/$${BCOMPFX}$${TARGET}.pc, PCFILE_CONTENT)
}

package_files.path = $${PROJECTDEPLOYDIR}
exists($$_PRO_FILE_PWD_/packagedependencies.txt) {
    package_files.files = $$_PRO_FILE_PWD_/packagedependencies.txt
}
win32:exists($$_PRO_FILE_PWD_/packagedependencies-win.txt) {
    package_files.files += $$_PRO_FILE_PWD_/packagedependencies-win.txt
}
macx:exists($$_PRO_FILE_PWD_/packagedependencies-mac.txt) {
    package_files.files += $$_PRO_FILE_PWD_/packagedependencies-mac.txt
}
exists($$OUT_PWD/$${BCOMPFX}$${TARGET}.pc) {
    package_files.files += $$OUT_PWD/$${BCOMPFX}$${TARGET}.pc
}

INSTALLS += package_files
