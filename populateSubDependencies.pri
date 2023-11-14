# Author(s) : Loic Touraine, Stephane Leduc

# Detect build toolchain and define REMAKEN_TARGET_ARCH and REMAKEN_TARGET_PLATFORM
include(remaken_arch_define.pri)

defineReplace(populateSubDependencies) {
    # list contains same size!
    packageDepsFilesList = $$1
    parentPkgList = $$2

    # TODO add assert on same size on list

    index =
    # loop on packageDepsFilesList, and use 'index' for manage a index for parentPkgList
    for (depfile, packageDepsFilesList) {
        indexSize = $$size(index)
        parentPkg = $$member(parentPkgList,$$indexSize)
        index+=1
        exists($${depfile}) {
            baseDepFile = $$basename(depfile)
            message("---- Parsing sub-dependencies from " $${depfile} " ----" )
            dependencies = $$cat($${depfile})
            for (dependency, dependencies) {
                #message (dependency $$dependency)
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
                       equals(pkgCategory,"bcomBuild")|equals(pkgCategory,"remakenBuild")|equals(pkgCategory,"thirdParties") {
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

                    pkgTreeItem = $${parentPkg}|$${pkgName}|$${pkgLinkMode}

                    equals(pkgRepoType,"http")|equals(pkgRepoType,"artifactory") | equals(pkgRepoType,"github") | equals(pkgRepoType,"nexus") {
                        deployFolder=$${REMAKENDEPSFOLDER}/$${REMAKEN_TARGET_PLATFORM}/$${pkgName}/$${pkgVersion}
                        !equals(pkgCategory,$${pkgRepoType}) {
                            deployFolder=$${REMAKENDEPSFOLDER}/$${REMAKEN_TARGET_PLATFORM}/$${pkgCategory}/$${pkgName}/$${pkgVersion}
                            !exists($${deployFolder}) { #try old structure for backward compatibility
                                warning("No package found at " $${deployFolder})
                                warning("--> Try with old structure for backward compatibility")
                                deployFolder=$${REMAKENDEPSFOLDER}/$${pkgCategory}/$${REMAKEN_TARGET_PLATFORM}/$${pkgName}/$${pkgVersion}
                            }
                        }
                        !exists($${deployFolder}) {
                            warning("No package found at " $${deployFolder})
                            warning("--> Dependencies source folder should include the target platform information " $${REMAKEN_TARGET_PLATFORM})
                            deployFolder=$${REMAKENDEPSFOLDER}/$${pkgName}/$${pkgVersion}
                            !equals(pkgCategory,$${pkgRepoType}) {
                                deployFolder=$${REMAKENDEPSFOLDER}/$${pkgCategory}/$${pkgName}/$${pkgVersion}
                            }
                            warning("--> Finally try without target platform in $${deployFolder}")
                        }
                        !exists($${deployFolder}) {
                            error("  No package found at " $${deployFolder})
                        }
                        contains(pkgLinkMode,static) {
                            exists($${deployFolder}/packagedependencies-static.txt) {
                                dependencyPkgDepFiles=$${deployFolder}/packagedependencies-static.txt
                            }
                            else {
                                exists($${deployFolder}/packagedependencies.txt) {
                                    dependencyPkgDepFiles=$${deployFolder}/packagedependencies.txt
                                }
                            }
                        }
                        else {
                            exists($${deployFolder}/packagedependencies.txt) {
                                dependencyPkgDepFiles=$${deployFolder}/packagedependencies.txt
                            }
                        }
                    }

                    currentPackageDeps += $${dependencyPkgDepFiles}
                    !isEmpty(dependencyPkgDepFiles) {
                        # subdependency file found => depfile;parentPkg;parentPkg|pkgName|pkgLinkMode (first parent pk g is used for re-call function and specify parent!)
                        outPackageDeps += $${dependencyPkgDepFiles};$${pkgName};$${pkgTreeItem}
                    } else {
                        # no subdependency file found => parentPkg|pkgName|pkgLinkMode
                        outPackageDeps += $${pkgTreeItem}

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
    return ($${outPackageDeps})
}

# return pkgParent dep if static, otherwise empty
defineReplace(getStaticParentPkg) {
    pkg = $$1
    subDepsTree = $$2
    for(var, subDepsTree) {
        depInf = $$split(var, |)
        pkgParent = $$member(depInf,0)
        pkgName = $$member(depInf,1)
        pkgMode = $$member(depInf,2)
        if (equals(pkg,$${pkgName}):equals(pkgMode,"static")) {
            return ($$pkgParent)
        }
    }
    return ()
}
