 # Author(s) : Loic Touraine


!contains (QMAKE_EXTRA_TARGETS, builddefs_info) {
BUILDDEFS_INFO_COMMAND = $(info "----------  builddefs-qmake options description  ----------")
BUILDDEFS_INFO_COMMAND += $(info "FRAMEWORK defines a common package name for several libraries. ")
BUILDDEFS_INFO_COMMAND += $(info "       --> Often defined as $$TARGET when the package matches the library.")
BUILDDEFS_INFO_COMMAND += $(info "")

BUILDDEFS_INFO_COMMAND += $(info "CONFIG defines how to build the current target")
BUILDDEFS_INFO_COMMAND += $(info "       --> [static | staticlib] builds the target as a static library")
BUILDDEFS_INFO_COMMAND += $(info "       --> [shared | dll] builds the target as a static library")
BUILDDEFS_INFO_COMMAND += $(info "")

BUILDDEFS_INFO_COMMAND += $(info "PROJECTCONFIG [QTVS]")
BUILDDEFS_INFO_COMMAND += $(info "")

QMAKE_EXTRA_TARGETS += builddefs_info
BUILDDEFS_INFO_COMMAND += $(info "DEPENDENCIESCONFIG defines how to search and which dependencies to use")
BUILDDEFS_INFO_COMMAND += $(info "       --> [sharedlib | shared] search and use dependencies as shared libraries")
BUILDDEFS_INFO_COMMAND += $(info "       --> [staticlib | static] search and use dependencies as static libraries")
BUILDDEFS_INFO_COMMAND += $(info "       --> [recursive | recurse] search dependencies recursively from other remaken packagedependencies information files")
BUILDDEFS_INFO_COMMAND += $(info "       --> [install] install first level shared dependencies with the target")
BUILDDEFS_INFO_COMMAND += $(info "       --> [install_recurse] search dependencies recursively (see [recursive]) and install all shared dependencies with the target")
BUILDDEFS_INFO_COMMAND += $(info "")
builddefs_info.commands = $$BUILDDEFS_INFO_COMMAND

}
