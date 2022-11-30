# Author(s) : Loic Touraine, Stephane Leduc

REMAKEN_PKGINFO_OUTPUTDIR=$$_PRO_FILE_PWD_/$${REMAKEN_BUILD_RULES_FOLDER}/$${REMAKEN_FULL_PLATFORM}/.pkginfo
# target install
for (install, INSTALLS) {
    equals(install,"target") {
        contains(TEMPLATE, lib)|contains(TEMPLATE,vclib) {
            #lib
            !exists($${REMAKEN_PKGINFO_OUTPUTDIR}/.lib) {
                mkpath($${REMAKEN_PKGINFO_OUTPUTDIR}/.lib)
            }
        }
        contains(TEMPLATE, app)|contains(TEMPLATE,vcapp) {
            !exists($${REMAKEN_PKGINFO_OUTPUTDIR}/.bin) {
                mkpath($${REMAKEN_PKGINFO_OUTPUTDIR}/.bin)
            }
        }
    } else {
        for (install_files, $${install}.files) {
            # include
            !exists($${REMAKEN_PKGINFO_OUTPUTDIR}/.headers) {
                mkpath($${REMAKEN_PKGINFO_OUTPUTDIR}/.headers)
            }
        }
    }
}

defined(PROJECTDEPLOYDIR,var) {
    exists($${REMAKEN_PKGINFO_OUTPUTDIR})
    {
        pkginfo_files.path = $${PROJECTDEPLOYDIR}
        #Nb : empty folder can't be copied directly with target.files then use an extra command
        win32 {
            pkginfo_files.extra = "echo R | xcopy /Y /E $$shell_quote($$shell_path($${REMAKEN_PKGINFO_OUTPUTDIR})) $$shell_quote($$shell_path($${PROJECTDEPLOYDIR}/.pkginfo/))"
        } else {
            pkginfo_files.extra = cp -R $$shell_quote($$shell_path($${REMAKEN_PKGINFO_OUTPUTDIR})) $$shell_quote($$shell_path($${PROJECTDEPLOYDIR}/))
        }
        INSTALLS += pkginfo_files
    }
}

win32 {
    include (win32/qtvs_install_target.pri)
}
