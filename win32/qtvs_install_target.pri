# Author(s) : Loic Touraine, Stephane Leduc

# echo R for manage Path instead file!
REMAKEN_XCOPY= echo R | xcopy /Y /Q

QTVS_OUTPUTDIR =
# debug_and_release_target change output dir when debug_and_release is set)
contains (CONFIG, debug_and_release_target)
{
    CONFIG(debug,debug|release) {
        QTVS_OUTPUTDIR = debug/
    }

    CONFIG(release,debug|release) {
        QTVS_OUTPUTDIR = release/
    }
}

# bat init
contains(PROJECTCONFIG,QTVS) {
    message("---------------------------------------------------")
    message("---- Install $${TEMPLATE} (with Qt VS tools post build) ----" )

    INSTALL_PROJECT_FILE=$$OUT_PWD/$${TARGET}-Install$${TEMPLATE}-$${OUTPUTDIR}.bat

    # bat header
    BAT_HEADER_COMMAND = "@echo off"
    write_file($${INSTALL_PROJECT_FILE},BAT_HEADER_COMMAND)

    # bat target install
    for (install, INSTALLS) {
        # specific for target (no target.files!)
        equals(install,"target") {
            contains(TEMPLATE, lib)|contains(TEMPLATE,vclib) {
                BAT_INSTALLPROJECT_COMMAND = "$${REMAKEN_XCOPY} $$system_path($${OUT_PWD}/$${QTVS_OUTPUTDIR}$${LIBPREFIX}$${TARGET}.$${LIBEXT}) $$shell_quote($$shell_path($${TARGETDEPLOYDIR}/))"
                write_file($${INSTALL_PROJECT_FILE},BAT_INSTALLPROJECT_COMMAND, append)
                !staticlib {
                    BAT_INSTALLPROJECT_COMMAND = "$${REMAKEN_XCOPY} $$system_path($${OUT_PWD}/$${QTVS_OUTPUTDIR}$${LIBPREFIX}$${TARGET}.$${DYNLIBEXT}) $$shell_quote($$shell_path($${TARGETDEPLOYDIR}/))"
                    write_file($${INSTALL_PROJECT_FILE},BAT_INSTALLPROJECT_COMMAND, append)
                }
            }
            CONFIG(debug,debug|release){
                BAT_INSTALLPROJECT_COMMAND = "$${REMAKEN_XCOPY} $$system_path($${OUT_PWD}/$${QTVS_OUTPUTDIR}$${LIBPREFIX}$${TARGET}.pdb) $$shell_quote($$shell_path($${TARGETDEPLOYDIR}/))"
                write_file($${INSTALL_PROJECT_FILE},BAT_INSTALLPROJECT_COMMAND, append)
            }
            contains(TEMPLATE, app)|contains(TEMPLATE,vcapp) {
                BAT_INSTALLPROJECT_COMMAND = "$${REMAKEN_XCOPY} $$system_path($${OUT_PWD}/$${QTVS_OUTPUTDIR}$${LIBPREFIX}$${TARGET}.$${APPEXT}) $$shell_quote($$shell_path($${TARGETDEPLOYDIR}/))"
                write_file($${INSTALL_PROJECT_FILE},BAT_INSTALLPROJECT_COMMAND, append)
            }
        } else {
            for (install_files, $${install}.files) {
                for (install_path, $${install}.path) {
                    BAT_INSTALLPROJECT_COMMAND = "$${REMAKEN_XCOPY} $$system_path($$install_files) $$shell_quote($$shell_path($$install_path))"
                    write_file($${INSTALL_PROJECT_FILE},BAT_INSTALLPROJECT_COMMAND, append)
                }
            }
        }
    }
    exists($${INSTALL_PROJECT_FILE}) {
        !equals(QMAKE_POST_LINK,"") {
            QMAKE_POST_LINK += &&
        }
        QMAKE_POST_LINK += call $${INSTALL_PROJECT_FILE}
    }
    message("---------------------------------------------------")
}



