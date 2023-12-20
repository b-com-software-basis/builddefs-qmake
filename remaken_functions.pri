# Author(s) : Loic Touraine, Stephane Leduc
    
defineTest(verboseMessage) {
    contains(DEPENDENCIESCONFIG,verbose)|contains(CONFIG,verbose)|contains(REMAKENCONFIG,verbose) {
        message($$ARGS)
    }
}

defineTest(checkPkgconfigInstalled) {
    win32 {
        # Check if pkg-config is installed on Windows
        PKGCONFIG_BIN = $$system(where pkg-config)

        isEmpty(PKGCONFIG_BIN) {
            error("pkg-config not found, please install it - for instance with \"choco install pkgconfiglite\"")
        }
    } else {
        # Check if pkg-config is installed unixes
        PKGCONFIG_BIN = $$system(which pkg-config)
        isEmpty(PKGCONFIG_BIN) {
            error("pkg-config not found, please install it - for intance with \"apt install pkg-config\"")
        }
    }
}