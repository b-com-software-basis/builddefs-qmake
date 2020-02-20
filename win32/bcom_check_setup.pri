# Author(s) : Stephane Leduc
# NOTE : paramteres and sample values for each param

# Product name - withou quote (added after in this script)
#SETUP_PRODUCTNAME=b<>com *Ultra plugin* BinauralVirtualComponents

# Setup file prefix (used only for nsis OutFile param)
#SETUP_FILEPFX=Setup_b-com_

# Setup filename
#SETUP_FILENAME=UltraPlugin_BinauralVirtualComponents

# Version
#SETUP_VERSION=$${VERSION}

# Unique setup guid (need to be changed!)
#SETUP_GUID=1234

# Install dir - can be defined for custom install or taken with default path for audio plugins
#SETUP_INSTALLDIR=$$shell_quote($$shell_path($$(PROGRAMW6432)/Steinberg/VSTPlugins/))

# Sub install dir (added to install dir) (OPTIONAL - value can be empty)
#SETUP_SUBINSTALLDIR=bcom

# Copy all contents of directory (OPTIONAL - values can be empty)
#SETUP_COPYDIR=$$shell_quote($$shell_path($$_PRO_FILE_PWD_/config/BVC_minimal_config))

# Setup logo Ico - b<>com icon by default, or with a fullpath file (OPTIONAL - values can be empty or not defined then use b<>com ico)
#SETUP_ICO_FILE=logo.ico

# Product manufacturer - (OPTIONAL - values can be empty)
#SETUP_MANUFACTURER=b<>com

# SETUP_NSIS_INFO could be defined for contains
    # CUSTOMIZE_ONINIT - (OPTIONAL) - could be defined for customize .onInit function with a custom CustomizeOnInit function
    # CUSTOMIZE_UNONINIT - (OPTIONAL) - could be defined for customize un.onInit function with a custom CustomizeUnOnInit function
    # CUSTOMIZE_DISPLAY_PAGE_COMPONENTS - (OPTIONAL) - could be defined for display page components
    # CUSTOMIZE_ADDTOPATH - (OPTIONAL) - could be defined for add/remove binary file to system path
    # CUSTOMIZE_ADD_CUSTOM_PAGE - (OPTIONAL) - coul be defined for add custom page(s) before install files page


# global defaults - detect nsis
MAKENSIS_COMMAND = $$system(where makensis)
isEmpty(MAKENSIS_COMMAND) {
    PATH = $$clean_path($$getenv(PROGRAMFILES(X86))/NSIS/makensis.exe)
    exists($${PATH}) {
        MAKENSIS_COMMAND = $${PATH}
    } else {
        error("Unable to find NSIS application : check your windows NSIS installation")
    }
}

# Check mandatory input parameters existence
!defined(SETUP_PRODUCTNAME,var){
    error("SETUP_PRODUCTNAME must be defined in _BundleConfig.pri")
}
!defined(SETUP_FILENAME,var){
    error("SETUP_FILENAME must be defined in _BundleConfig.pri")
}
!defined(SETUP_VERSION,var){
    error("SETUP_VERSION must be defined in _BundleConfig.pri")
}
!defined(SETUP_GUID,var){
    error("SETUP_GUID must be defined in _BundleConfig.pri")
}

if(defined(SETUP_ICO_FILE):!exists($${SETUP_ICO_FILE})) {
    error("$${SETUP_ICO_FILE} doesn't exist")
}
# default ico : b<>com
SETUP_ICO_FILE=$$PWD/nsis/logo.ico

NSISFILE_CONTENT = $$cat($$PWD/nsis/Setup.nsi,lines)
NSISFILE_CONTENT = $$replace(NSISFILE_CONTENT, "/\*@CUSTOM_NSIS_INCLUDE@\*/\"", "\"$$shell_path($$PWD/nsis/)")
!isEmpty(SETUP_NSIS_CUSTOM_FILEPATH):exists($$shell_quote($$shell_path($${SETUP_NSIS_CUSTOM_FILEPATH}))) {
    NSISFILE_CONTENT = $$replace(NSISFILE_CONTENT, ";@CUSTOM_NSIS_SCRIPT@", "!include \""$$shell_path($${SETUP_NSIS_CUSTOM_FILEPATH})"\"")
}
!isEmpty(SETUP_NSIS_CUSTOM_PAGE_DEFINITION_FILEPATH):exists($$shell_quote($$shell_path($${SETUP_NSIS_CUSTOM_PAGE_DEFINITION_FILEPATH}))) {
    NSIS_ADD_CUSTOM_PAGE_CONTENT = $$cat($${SETUP_NSIS_CUSTOM_PAGE_DEFINITION_FILEPATH},lines)
    NSISFILE_CONTENT = $$replace(NSISFILE_CONTENT, ";@CUSTOM_NSIS_ADD_CUSTOM_PAGE@", $${NSIS_ADD_CUSTOM_PAGE_CONTENT})
}
write_file($$OUT_PWD/Setup.nsi, NSISFILE_CONTENT)
QMAKE_DISTCLEAN += $$OUT_PWD/Setup.nsi


# remove/replace forbidden chars
defineReplace(nsisReplaceSpecialCharacter) {
    nsisString = $$ARGS
    nsisString = $$replace(nsisString, "<>", "-")
    nsisString = $$replace(nsisString, "<", "")
    nsisString = $$replace(nsisString, ">", "")
    nsisString = $$replace(nsisString, "/", "")
    nsisString = $$replace(nsisString, "\\", "")
    nsisString = $$replace(nsisString, ":", "")
    nsisString = $$replace(nsisString, "*", "")
    nsisString = $$replace(nsisString, "\?", "")
    nsisString = $$replace(nsisString, "\"", "")
    nsisString = $$replace(nsisString, "|", "")
    return($${nsisString})
}
