ninjaTokenpoolBuildPhase() {
    runHook preBuild

    local buildCores=1

    # Parallel building is enabled by default.
    if [ "${enableParallelBuilding-1}" ]; then
        buildCores="$NIX_BUILD_CORES"
    fi

    local flagsArray=(
        -j$buildCores -l$NIX_BUILD_CORES
        $ninjaFlags "${ninjaFlagsArray[@]}"
    )

    # debug
    (
        set +e
        set -x
        stat build.ninja
        ls -l
    )

    echoCmd 'build flags' "${flagsArray[@]}"
    (
        set -x
        TERM=dumb ninja --tokenpool-master "${flagsArray[@]}"
    )

    runHook postBuild
}

if [ -z "${dontUseNinjaBuild-}" -a -z "${buildPhase-}" ]; then
    buildPhase=ninjaTokenpoolBuildPhase
fi

ninjaTokenpoolInstallPhase() {
    runHook preInstall

    # shellcheck disable=SC2086
    local flagsArray=(
        $ninjaFlags "${ninjaFlagsArray[@]}"
        ${installTargets:-install}
    )

    echoCmd 'install flags' "${flagsArray[@]}"
    (
        set -x
        TERM=dumb ninja --tokenpool-master "${flagsArray[@]}"
    )

    runHook postInstall
}

if [ -z "${dontUseNinjaInstall-}" -a -z "${installPhase-}" ]; then
    installPhase=ninjaTokenpoolInstallPhase
fi

ninjaTokenpoolCheckPhase() {
    runHook preCheck

    if [ -z "${checkTarget:-}" ]; then
        if ninja -t query test >/dev/null 2>&1; then
            checkTarget=test
        fi
    fi

    if [ -z "${checkTarget:-}" ]; then
        echo "no test target found in ninja, doing nothing"
    else
        local buildCores=1

        if [ "${enableParallelChecking-1}" ]; then
            buildCores="$NIX_BUILD_CORES"
        fi

        local flagsArray=(
            -j$buildCores -l$NIX_BUILD_CORES
            $ninjaFlags "${ninjaFlagsArray[@]}"
            $checkTarget
        )

        echoCmd 'check flags' "${flagsArray[@]}"
        (
            set -x
            TERM=dumb ninja --tokenpool-master "${flagsArray[@]}"
        )
    fi

    runHook postCheck
}

if [ -z "${dontUseNinjaCheck-}" -a -z "${checkPhase-}" ]; then
    checkPhase=ninjaTokenpoolCheckPhase
fi
