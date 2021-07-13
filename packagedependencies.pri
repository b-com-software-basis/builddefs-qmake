# Author(s) : Loic Touraine, Stephane Leduc

# include additionnal qmake defined functions
include(remaken_functions.pri)

equals(_PRO_FILE_PWD_, $${OUT_PWD}) {
    !contains(PROJECTCONFIG,QTVS) {
        warning("Bad practice : build folder must be different from project folder !")
    }
}

CONFIG(debug,debug|release) {
    OUTPUTDIR = debug
    DEBUGPFX = debug-
    CONANBUILDTYPE = Debug
}

CONFIG(release,debug|release) {
    OUTPUTDIR = release
    CONANBUILDTYPE = Release
}

exists($$_PRO_FILE_PWD_/build/configure_conditions.pri) {
    include($$_PRO_FILE_PWD_/build/configure_conditions.pri)
}

# Check input parameters existence
!defined(DEPENDENCIESCONFIG,var) {
    warning("DEPENDENCIESCONFIG is not defined : defaulting to shared dependencies mode")
    DEPENDENCIESCONFIG = $${LINKMODE}
}

# Check install_recurse parameters existence
contains(DEPENDENCIESCONFIG,install_recurse) {
    # add recurse mode if install_recurse defined
    !contains(DEPENDENCIESCONFIG,recurse) {
        DEPENDENCIESCONFIG += recurse
    }
}

# package dependencies comment info
PKG_COMMENT="//"

#include sub-dependencies recursion function
include(populateSubDependencies.pri)

contains(DEPENDENCIESCONFIG,staticlib)|contains(DEPENDENCIESCONFIG,static) {
    DEPLINKMODE = static
} else {
    DEPLINKMODE = shared
}

# generate packagedependencies[-static].txt file from configure_conditions, DEPLINKMODE
message(" ")
message("----------------------------------------------------------------")
message("STEP => PREPARE - Project dependencies analysis")
message("----------------------------------------------------------------")
packagedepsfiles = $$_PRO_FILE_PWD_/packagedependencies.txt
win32:!android {
    packagedepsfiles += $$_PRO_FILE_PWD_/packagedependencies-win.txt
}
# Common unix platform (macx, linux, android...)
unix {
    packagedepsfiles += $$_PRO_FILE_PWD_/packagedependencies-unix.txt
}
macx:!android {
    packagedepsfiles += $$_PRO_FILE_PWD_/packagedependencies-mac.txt
}
linux:!android {
    packagedepsfiles += $$_PRO_FILE_PWD_/packagedependencies-linux.txt
}
android {
    packagedepsfiles += $$_PRO_FILE_PWD_/packagedependencies-android.txt
}

BCOMPFX = bcom-
for(depfile, packagedepsfiles) {
    !exists($${depfile}) {
        verboseMessage("  -- No " $${depfile} " file to process for " $$TARGET)
    } else {
        message("---- Processing $${depfile} ----" )
        dependencies = $$cat($${depfile})
        for(depLine, dependencies) {
            dependencyMetaInf = $$split(depLine, |)
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
                message("---- Processing $${pkg.name} $${pkg.version} package ----" )
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
                    builddefs_info.commands += $(info "Conditional dependencies defined in packagedependencies information files:")
                    for (condition,pkgLibConditionList) {
                        builddefs_info.commands += $(info "       --> define -D$${condition} to use $${pkg.name} dependency")
                        #message("      --> [INFO] found condition $${condition}")
                        !contains(DEFINES, $${condition}) {
                            pkgConditionsNotFullfilled += $${condition}
                        }
                    }
                    builddefs_info.commands += $(info "")
                }
                repoInfo = $${pkg.repoType}
                !equals(pkg.identifier,$${pkg.repoType}) {
                    repoInfo = $${pkg.identifier}@$${pkg.repoType}
                }
                !isEmpty (pkgConditionsNotFullfilled) {
                    message("  --> [INFO] Dependency $${pkg.name}_$${pkg.version}@$${pkg.repoType} ignored ! Missing compilation flag definition : $${pkgConditionsNotFullfilled}")
                } else {
                    packageInfo = $${pkg.name}
                    equals(pkg.repoType,"conan") {# conan system package handling
                        !equals(pkg.channel,"stable") {
                            packageInfo = $${pkg.name}$$LITERAL_HASH$${pkg.channel}
                        }
                    }
                    verboseMessage("PREPARE=>> " $${packageInfo}|$${pkg.version}|$${libName}|$${repoInfo}|$${pkg.repoUrl}|$${pkg.linkMode}|$${pkg.toolOptions})
                    PKGDEPFILE_CONTENT += $${packageInfo}|$${pkg.version}|$${libName}|$${repoInfo}|$${pkg.repoUrl}|$${pkg.linkMode}|$${pkg.toolOptions}
                }
                verboseMessage(" ")
            } # comment package
            else {
                #message(package in comment : $${pkg.name})
            }
        } # for(var, dependencies)
    } #!exists($${depfile})
} # for(depfile, packagedepsfiles)

PKGDEPFILENAME=packagedependencies.txt
contains(LINKMODE,static) {
    PKGDEPFILENAME=packagedependencies-static.txt
}

write_file($$_PRO_FILE_PWD_/build/$${PKGDEPFILENAME}, PKGDEPFILE_CONTENT)

contains(DEPENDENCIESCONFIG,use_remaken_parser)|contains(CONFIG,use_remaken_parser)|contains(REMAKENCONFIG,use_remaken_parser) {
    message("--> [INFO] Using dependencies from dependenciesBuildInfo.pri generated with remaken")
    include($$_PRO_FILE_PWD_/build/$${OUTPUTDIR}/$${LINKMODE}/dependenciesBuildInfo.pri)
} else {
    message("--> [INFO] Parsing and using dependencies from packagedependencies-parser.pri")
    include (packagedependencies-parser.pri)
}

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
    exists($$_PRO_FILE_PWD_/build/$${PKGDEPFILENAME}) {
        package_files.files = $$_PRO_FILE_PWD_/build/$${PKGDEPFILENAME}
    }
    exists($$OUT_PWD/$${BCOMPFX}$${TARGET}.pc) {
        package_files.files += $$OUT_PWD/$${BCOMPFX}$${TARGET}.pc
    }
    INSTALLS += package_files
}
message("----------------------------------------------------------------")

# manage dependencies install
include (install_dependencies.pri)
