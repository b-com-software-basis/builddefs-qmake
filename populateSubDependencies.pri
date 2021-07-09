# Author(s) : Loic Touraine, Stephane Leduc

# Detect build toolchain and define BCOM_TARGET_ARCH and BCOM_TARGET_PLATFORM
include(bcom_arch_define.pri)

defineReplace(populateSubDependencies) {
    packageDepsFilesList = $$ARGS
    for (depfile, packageDepsFilesList) {
        exists($${depfile}) {
            baseDepFile = $$basename(depfile)
            message("---- Parsing sub-dependencies from " $${depfile} " ----" )
            dependencies = $$cat($${depfile})
            for (dependency, dependencies) {
                dependencyPkgDepFiles=""
                dependencyMetaInf = $$split(dependency, |)
                pkgInformation = $$member(dependencyMetaInf,0)
                pkgInfoList = $$split(pkgInformation, $$LITERAL_HASH)
                pkgName = $$member(pkgInfoList,0)
                pkgInComment = $$str_member(pkgName, 0, 1)
                !equals (pkgInComment, $$PKG_COMMENT) {
                    pkgChannel = "stable"
                    pkgInfoListSize = $$size(pkgInfoList)
                    equals(pkgInfoListSize,2) {
                        pkgChannel = $$member(pkgInfoList,1)
                    }
                    pkgVersion = $$member(dependencyMetaInf,1)
                    pkgLibInformation = $$member(dependencyMetaInf,2)
                    pkgLibConditionList = $$split(pkgLibInformation, %)
                    libName = $$take_first(pkgLibConditionList)
                    pkgTypeInformation = $$member(dependencyMetaInf,3)
                    pkgLinkMode = $$member(dependencyMetaInf,5)
                    pkgTypeInfoList = $$split(pkgTypeInformation, @)
                    pkgCategory = $$member(pkgTypeInfoList,0)
                    pkgRepoType = $${pkgCategory}
                    pkgTypeInfoListSize = $$size(pkgTypeInfoList)
                    equals(pkgTypeInfoListSize,2) {
                        pkgRepoType = $$member(pkgTypeInfoList,1)
                    } else {
                       equals(pkgCategory,"bcomBuild")|equals(pkgCategory,"thirdParties") {
                            pkgRepoType = "artifactory"
                        }  # otherwise pkgRepoType = pkgCategory
                    }
                    # check pkgLinkMode not empty and mandatory equals to static|shared, otherwise set to default DEPLINKMODE
                    equals(pkgLinkMode,"")|equals(pkgLinkMode,"default") {
                        pkgLinkMode = $${DEPLINKMODE}
                    } else {
                        if (!equals(pkgLinkMode,"static"):!equals(pkgLinkMode,"shared"):!equals(pkgLinkMode,"na")){
                            pkgLinkMode = $${DEPLINKMODE}
                        }
                    }
                    verboseMessage("  ---- Processing dependency $${pkgName}_$${pkgVersion}@$${pkgRepoType} repository")
                    equals(pkgRepoType,"artifactory") | equals(pkgRepoType,"github") | equals(pkgRepoType,"nexus") {
                        deployFolder=$${REMAKENDEPSFOLDER}/$${BCOM_TARGET_PLATFORM}/$${pkgName}/$${pkgVersion}
                        !equals(pkgCategory,$${pkgRepoType}) {
                            deployFolder=$${REMAKENDEPSFOLDER}/$${BCOM_TARGET_PLATFORM}/$${pkgCategory}/$${pkgName}/$${pkgVersion}
                            !exists($${deployFolder}) { #try old structure for backward compatibility
                                deployFolder=$${REMAKENDEPSFOLDER}/$${pkgCategory}/$${BCOM_TARGET_PLATFORM}/$${pkgName}/$${pkgVersion}
                            }
                        }
                        !exists($${deployFolder}) {
                            warning("Dependencies source folder should include the target platform information " $${BCOM_TARGET_PLATFORM})
                            deployFolder=$${REMAKENDEPSFOLDER}/$${pkgName}/$${pkgVersion}
                            !equals(pkgCategory,$${pkgRepoType}) {
                                deployFolder=$${REMAKENDEPSFOLDER}/$${pkgCategory}/$${pkgName}/$${pkgVersion}
                            }
                            warning("Defaulting search folder to " $${deployFolder})
                        }
                        !exists($${deployFolder}) {
                            error("No package found at " $${deployFolder})
                        }
                        contains(pkgLinkMode,static) {
                            exists($${deployFolder}/packagedependencies-static.txt) {
                                dependencyPkgDepFiles+=$${deployFolder}/packagedependencies-static.txt
                            }
                            else {
                                dependencyPkgDepFiles+=$${deployFolder}/packagedependencies.txt
                            }
                        }
                        else {
                            exists($${deployFolder}/packagedependencies.txt) {
                                dependencyPkgDepFiles+=$${deployFolder}/packagedependencies.txt
                            }
                        }
                        currentPackageDeps = $${dependencyPkgDepFiles}
                        outPackageDeps += $${dependencyPkgDepFiles}
                    }
                    isEmpty(currentPackageDeps) {
                        message("    ---- No sub-dependencies found ----")
                    } else {
                        message("    ---- Sub-dependencies found :" )
                        for(var, currentPackageDeps) {
                            message("         ==>"  $${var} )
                        }
                    }
                    message(" ")
                } # comment package
                else {
                    #message(package in comment : $${pkg.name})
                }
            } # for(var, dependencies)
        } #!exists($${depfile})
    } # for(depfile, packagedepsfiles)
    return($${outPackageDeps})
}
