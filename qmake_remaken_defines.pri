# Author(s) : Loic Touraine

#Note (QT Creator Bug ?): files shown in the project tree are NOT the files used for compiling
!contains(QMAKE_REMAKENDEFINES,"defined") {
    message("Including qmake_remaken_defines")
    QMAKE_REMAKENDEFINES="defined"
    # Check input parameters existence - libs absolute path
    !defined(_REMAKEN_LIBS_ROOT_,var) {
        _REMAKEN_LIBS_ROOT_ = $$_PRO_FILE_PWD_
        warning("_REMAKEN_LIBS_ROOT_ is not defined : libs absolute path defaults to [$$_PRO_FILE_PWD_] value")
    }
}
