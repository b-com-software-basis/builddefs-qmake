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

for(depfile, packagedepsfiles) {
    exists($${depfile}) {
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

            message($${libName} " is used with " $${pkgLinkModeOverride} linkmode)
            win32:equals(pkgLinkModeOverride, "shared") {
                deployFolder=$$(BCOMDEVROOT)/$${pkgCategory}/$${pkgName}/$${pkgVersion}
                pkgCfgFilePath = $${deployFolder}/$${BCOMPFX}$${libName}.pc
                !exists($${pkgCfgFilePath}) {# default behavior
                    message($${pkgCfgFilePath} "doesn't exist - take default behavior")
                    win32:equals(pkgLinkModeOverride, "shared") {
                        # Deployment - Copy shared submodules dependencies
                        QMAKE_POST_LINK += $${QMAKE_COPY} $$shell_quote($$shell_path($${deployFolder}/lib/$$BCOM_TARGET_ARCH/$$OUTPUTDIR/$${LIBPREFIX}$${libName}.$${DYNLIBEXT})) $$shell_quote($$shell_path($$OUT_PWD/))
                    }

                } else {
                    message($${pkgCfgFilePath} "exists")
                    pkgCfgSharedLibVars = --define-variable=prefix=$${deployFolder} --define-variable=depdir=$${deployFolder}/lib/dependencies/$$BCOM_TARGET_ARCH/$${pkgLinkModeOverride}/$$OUTPUTDIR
                    pkgCfgSharedLibVars += --define-variable=libdir=$${deployFolder}/lib/$$BCOM_TARGET_ARCH/$${pkgLinkModeOverride}/$$OUTPUTDIR
                    pkgCfgSharedLibVars += --define-variable=lext=$${DYNLIBEXT} --libs-only-other --static
                    !win32 {
                        pkgCfgSharedLibVars += --define-variable=pfx=$${LIBPREFIX}
                    }
                    else {
                        pkgCfgSharedLibVars += --define-variable=pfx=$$shell_quote("\'\'")
                    }

                    message("pkg-config variables for post link: " $$pkgCfgSharedLibVars)
                    # Deployment - Copy shared submodules dependencies
                    QMAKE_POST_LINK += $${QMAKE_COPY} $$shell_quote($$shell_path($$system(pkg-config $$pkgCfgSharedLibVars $$pkgCfgFilePath))) $$shell_quote($$shell_path($$OUT_PWD/))
                }
                message("QMAKE_POST_LINK : " $${QMAKE_POST_LINK})
                message("")
            }
        }
    } else {
        message("No " $${depfile} " file to process for " $$TARGET)
    }
}
