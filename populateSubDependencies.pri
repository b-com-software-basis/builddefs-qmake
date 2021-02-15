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
                    pkgConditionsNotFullfilled = ""
                    !isEmpty(pkgLibConditionList) {
                        message("  --> [INFO] Parsing $${pkgName}_$${pkgVersion} compilation flag definitions : $${pkgLibConditionList}")
                        builddefs_info.commands += $(info "Conditional dependencies defined in packagedependencies information files:")
                        for (condition,pkgLibConditionList) {
                            builddefs_info.commands += $(info "       --> define -D$${condition} to use $${pkgName} dependency")
                            #message("      --> [INFO] found condition $${condition}")
                            !contains(DEFINES, $${condition}) {
                                pkgConditionsNotFullfilled += $${condition}
                            }
                        }
                        builddefs_info.commands += $(info "")
                    }
                    !isEmpty (pkgConditionsNotFullfilled) {
                        message("  --> [INFO] Dependency $${pkgName}_$${pkgVersion}@$${pkgRepoType} ignored ! Missing compilation flag definition : $${pkgConditionsNotFullfilled}")
                    } else {
                        verboseMessage("  ---- Processing dependency $${pkgName}_$${pkgVersion}@$${pkgRepoType} repository")
                        equals(pkgRepoType,"artifactory") | equals(pkgRepoType,"github") | equals(pkgRepoType,"nexus") {
                            deployFolder=$${REMAKENDEPSFOLDER}/$${BCOM_TARGET_PLATFORM}/$${pkgName}/$${pkgVersion}
                            !equals(pkgCategory,$${pkgRepoType}) {
                                deployFolder=$${REMAKENDEPSFOLDER}/$${pkgCategory}/$${BCOM_TARGET_PLATFORM}/$${pkgName}/$${pkgVersion}
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
                            exists($${deployFolder}/packagedependencies.txt) {
                                dependencyPkgDepFiles+=$${deployFolder}/packagedependencies.txt
                            }
                            win32:!android {
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
                            macx:!android {
                                exists($${deployFolder}/packagedependencies-mac.txt) {
                                    dependencyPkgDepFiles += $${deployFolder}/packagedependencies-mac.txt
                                }
                            }
                            linux:!android {
                                exists($${deployFolder}/packagedependencies-linux.txt) {
                                    dependencyPkgDepFiles += $${deployFolder}/packagedependencies-linux.txt
                                }
                            }
                            android {
                                exists($${deployFolder}/packagedependencies-android.txt) {
                                    dependencyPkgDepFiles += $${deployFolder}/packagedependencies-android.txt
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
                    } #pkgConditionsNotFullfilled
                } # comment package
                else {
                    #message(package in comment : $${pkg.name})
                }
            } # for(var, dependencies)
        } #!exists($${depfile})
    } # for(depfile, packagedepsfiles)
    return($${outPackageDeps})
}
