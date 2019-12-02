# Author(s) : Loic Touraine, Stephane Leduc

macx{
}

win32 {
    include (win32/qtvs_install_target.pri)
    contains(DEPENDENCIESCONFIG,install)|contains(DEPENDENCIESCONFIG,install_recurse) {
        include (win32/install_dependencies.pri)
    }
}
