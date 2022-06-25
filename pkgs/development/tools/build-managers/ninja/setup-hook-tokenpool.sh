enableNinjaTokenpool() {
    echoCmd 'enableNinjaTokenpool: adding to ninjaFlags' '--tokenpool-master'
    ninjaFlags+=' --tokenpool-master'
}

if [ -z "${dontUseNinjaTokenpool-}" ]; then
    prePhases+=" enableNinjaTokenpool"
fi
