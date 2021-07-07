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

contains(DEPENDENCIESCONFIG,use_remaken_parser)|contains(CONFIG,use_remaken_parser)|contains(REMAKENCONFIG,use_remaken_parser) {
    message("--> [INFO] Using dependencies from dependenciesBuildInfo.pri generated with remaken")
    include($$_PRO_FILE_PWD_/build/$${OUTPUTDIR}/dependenciesBuildInfo.pri)
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
    exists($$_PRO_FILE_PWD_/build/packagedependencies.txt) {
        package_files.files = $$_PRO_FILE_PWD_/build/packagedependencies.txt
    }
    exists($$OUT_PWD/$${BCOMPFX}$${TARGET}.pc) {
        package_files.files += $$OUT_PWD/$${BCOMPFX}$${TARGET}.pc
    }
    INSTALLS += package_files
}
message("----------------------------------------------------------------")

# manage dependencies install
include (install_dependencies.pri)
