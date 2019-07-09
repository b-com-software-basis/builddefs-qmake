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
                pkgChannel = "stable"
                equals(size(pkgInfoList),2) {
                    pkgChannel = $$member(pkgInfoList,1)
                }
                pkgVersion = $$member(dependencyMetaInf,1)
                libName = $$member(dependencyMetaInf,2)
                pkgTypeInformation = $$member(dependencyMetaInf,3)
                pkgTypeInfoList = $$split(pkgTypeInformation, @)
                pkgCategory = $$member(pkgTypeInfoList,0)
                pkgRepoType = $${pkgCategory}
                equals(size(pkgTypeInfoList),2) {
                    pkgRepoType = $$member(pkgTypeInfoList,1)
                } else {
                   equals(pkgCategory,"bcomBuild")|equals(pkgCategory,"thirdParties") {
                        pkgRepoType = "artifactory"
                    }  # otherwise pkgRepoType = pkgCategory
                }
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
                    message("    ---- No sub-dependencies found ----")
                } else {
                    message("    ---- Sub-dependencies found :" )
                    for(var, outPackageDeps) {
                       message("         ==>"  $${var} )
                    }
                }
                message(" ")
            }
        }
    }
    return($${outPackageDeps})
}
