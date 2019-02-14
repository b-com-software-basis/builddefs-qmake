# Author(s) : Loic Touraine

include (templatelibconfig.pri)

macx {
    # replace sharedlib LFLAG with bundle one
    QMAKE_LFLAGS_SHLIB -= -dynamiclib
    QMAKE_LFLAGS_SHLIB += -bundle

    # unset soname : useless for a bundle
    QMAKE_LFLAGS_SONAME = ""

    # set global flags for bundle
    QMAKE_CXXFLAGS += -fmessage-length=0 -fdiagnostics-show-note-include-stack -fmacro-backtrace-limit=0 -fpascal-strings
    QMAKE_CXXFLAGS += -Wno-trigraphs -Wno-missing-field-initializers -Wno-missing-prototypes -Wnon-virtual-dtor -Wno-overloaded-virtual
    QMAKE_CXXFLAGS += -Wno-exit-time-destructors -Wno-missing-braces -Wparentheses -Wswitch -Wno-unused-function -Wno-unused-label -Wno-unused-parameter
    QMAKE_CXXFLAGS += -Wunused-variable -Wunused-value -Wno-empty-body -Wno-uninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants
    QMAKE_CXXFLAGS += -Wno-conversion -Wno-constant-conversion -Wno-int-conversion -Wno-bool-conversion -Wno-enum-conversion
    QMAKE_CXXFLAGS += -Wno-shorten-64-to-32 -Wno-newline-eof
    QMAKE_CXXFLAGS += -O0

    bcom_component_binary.path = Contents/MacOS
    bcom_component_binary.files = lib$${TARGET}.$${DYNLIBEXT}
    QMAKE_BUNDLE_BINARY += bcom_component_binary
}

win32 {
    # set target for AAX
    bcom_component_binary.path = Contents
    bcom_component_binary.files = $${TARGET}.$${DYNLIBEXT}
    QMAKE_SETUP_BINARY += bcom_component_binary
}

include (bcom_bundle_rules.prf)
