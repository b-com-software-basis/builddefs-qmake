# Author(s) : Loic Touraine
    
defineTest(verboseMessage) {
    contains(DEPENDENCIESCONFIG,verbose)|contains(CONFIG,verbose)|contains(REMAKENCONFIG,verbose) {
        message($$ARGS)
    }
}
