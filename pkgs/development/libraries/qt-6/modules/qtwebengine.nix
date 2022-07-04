{ qtModule
, qtdeclarative
, qtwebchannel
, qtpositioning
, qtwebsockets
, bison
, coreutils
, flex
, git
, gperf
, ninja
, samurai # debug
, ninja-kitware # debug
, ninja-tokenpool # debug
, pkg-config
, python3
, which
, nodejs
, qtbase
, srcs # TODO test
, perl
, xorg
, libXcursor
, libXScrnSaver
, libXrandr
, libXtst
, libxshmfence
, libXi
, fontconfig
, freetype
, harfbuzz
, icu
, dbus
, libdrm
, zlib
, minizip
, libjpeg
, libpng
, libtiff
, libwebp
, libopus
, jsoncpp
, protobuf
, libvpx
, srtp
, snappy
, nss
, libevent
, openssl
, alsa-lib
, pulseaudio
, libcap
, pciutils
, systemd
, pipewire
, gn
, cups
, openbsm
, runCommand
, writeScriptBin
, ffmpeg
, lib
, stdenv
, glib
, libxml2
, libxslt
, lcms2
, re2
, libkrb5
, xkeyboard_config
, enableProprietaryCodecs ? true
, fetchFromGitHub
}:

let
  # limit jobs
  # use jest-worker with jobclient
  # call stack: devtools-frontend -> rollup -> terser -> jest-worker
  jest-worker = fetchFromGitHub {
    # requires gnumake-tokenpool (js)
    # https://github.com/milahu/jest-worker/tree/26.6.2
    # https://github.com/facebook/jest/pull/12968
    # nix-prefetch-github milahu jest-worker --rev xxx
    owner = "milahu";
    repo = "jest-worker";
    rev = "ac66dea6168c3ecfcc88f300dffbc807ac9273a5";
    sha256 = "a3TCtjRIKJTKM59G60fLhYiFCCux2JXw/OTUK7i/hRc=";
  };
  gnumake-tokenpool-src = python3.pkgs.gnumake-tokenpool.src;
in

qtModule rec {
  pname = "qtwebengine";
  qtInputs = [ qtdeclarative qtwebchannel qtwebsockets qtpositioning ];
  nativeBuildInputs = [
    bison
    coreutils
    flex
    git
    gperf
    #ninja
    #samurai
    #ninja-kitware # debug
    ninja-tokenpool # debug
    pkg-config
    (python3.withPackages (ps: with ps; [ html5lib ]))
    which
    #gn # not used?
    nodejs
  ];
  doCheck = true;
  outputs = [ "out" "dev" ];

  #dontUseGnConfigure = true;

  # ninja builds some components with -Wno-format,
  # which cannot be set at the same time as -Wformat-security
  hardeningDisable = [ "format" ];

  patches = [
    ./patches/qtwebengine/0001-task_queue.py-add-jobclient.patch
    ./patches/qtwebengine/0002-build_inspector_overlay.py-fix-inherit-fds.patch
    ./patches/qtwebengine/0003-gn-add-jobclient.patch
    ./patches/qtwebengine/0004-node.py-add-debug.patch
    ./patches/qtwebengine/0005-mojom_parser.py-add-jobclient.patch
  ];

  DEBUG_JOBCLIENT = "1"; # gnumake-tokenpool
  DEBUG_JEST_WORKER = "1"; # src/3rdparty/chromium/third_party/devtools-frontend/src/node_modules/jest-worker/build/index.js
  DEBUG_CHROMIUM_NODE_PY = "1"; # src/3rdparty/chromium/third_party/node/node.py
  DEBUG_MOJOM_PARSER = "1"; # src/3rdparty/chromium/mojo/public/tools/mojom/mojom_parser.py

  # FIXME ninjaFlags are not inherited to child ninjas, for example via MAKEFLAGS
  #ninjaFlags = "-v -d explain";

  postPatch = ''
    # Limit jobs in build of devtools-frontend
    (
      cd src/3rdparty/chromium/third_party/devtools-frontend/src/node_modules

      mv jest-worker/node_modules jest-worker.node_modules
      rm -rf jest-worker
      cp -r ${jest-worker} jest-worker
      chmod -R +w jest-worker
      mv jest-worker.node_modules jest-worker/node_modules

      mkdir @milahu
      cp -r ${gnumake-tokenpool-src} @milahu/gnumake-jobclient
      chmod -R +w @milahu/gnumake-jobclient
      # force debug
      sed -i -E 's/^const debug = .*?;$/const debug = true;/' \
        @milahu/gnumake-jobclient/js/src/tokenpool.js
    )

    for dst in \
      src/3rdparty/chromium/third_party/blink/renderer/bindings/scripts/bind_gen \
      src/3rdparty/chromium/mojo/public/tools/mojom
    do
      (
        cd "$dst"
        cp ${gnumake-tokenpool-src}/py/src/gnumake_tokenpool/jobclient.py gnumake_tokenpool.py
        chmod +w gnumake_tokenpool.py
      )
    done

    # tokenpool-gnu-make-posix.cc etc
    (
      cd src/3rdparty/gn/src/util
      cp ${gnumake-tokenpool-src}/cc/src/tokenpool* .
      chmod +w tokenpool*
    )

    # Patch Chromium build tools
    (
      cd src/3rdparty/chromium;

      # Manually fix unsupported shebangs
      substituteInPlace third_party/harfbuzz-ng/src/src/update-unicode-tables.make \
        --replace "/usr/bin/env -S make -f" "/usr/bin/make -f" || true
      substituteInPlace third_party/webgpu-cts/src/tools/deno \
        --replace "/usr/bin/env -S deno" "/usr/bin/deno" || true
      patchShebangs .
    )

    sed -i -e '/lib_loader.*Load/s!"\(libudev\.so\)!"${lib.getLib systemd}/lib/\1!' \
      src/3rdparty/chromium/device/udev_linux/udev?_loader.cc

    sed -i -e '/libpci_loader.*Load/s!"\(libpci\.so\)!"${pciutils}/lib/\1!' \
      src/3rdparty/chromium/gpu/config/gpu_info_collector_linux.cc

    substituteInPlace src/3rdparty/chromium/ui/events/ozone/layout/xkb/xkb_keyboard_layout_engine.cc \
      --replace "/usr/share/X11/xkb" "${xkeyboard_config}/share/X11/xkb"

    # Patch library paths in sources
    substituteInPlace src/core/web_engine_library_info.cpp \
      --replace "QLibraryInfo::path(QLibraryInfo::DataPath)" "\"$out\"" \
      --replace "QLibraryInfo::path(QLibraryInfo::TranslationsPath)" "\"$out/translations\"" \
      --replace "QLibraryInfo::path(QLibraryInfo::LibraryExecutablesPath)" "\"$out/libexec\""
  '';

  # --replace 'COMMAND Ninja::ninja ' 'COMMAND Ninja::ninja $ENV{NINJAFLAGS} '
  # error: $NINJAFLAGS is not unpacked -> passed as "-j32 -l32" not as -j32 -l32
  # ninja: fatal: invalid -j parameter

  cmakeFlags = [
    "-DQT_FEATURE_qtpdf_build=ON"
    "-DQT_FEATURE_qtpdf_widgets_build=ON"
    "-DQT_FEATURE_qtpdf_quick_build=ON"
    "-DQT_FEATURE_pdf_v8=ON"
    "-DQT_FEATURE_pdf_xfa=ON"
    "-DQT_FEATURE_pdf_xfa_bmp=ON"
    "-DQT_FEATURE_pdf_xfa_gif=ON"
    "-DQT_FEATURE_pdf_xfa_png=ON"
    "-DQT_FEATURE_pdf_xfa_tiff=ON"
    "-DQT_FEATURE_webengine_system_icu=ON"
    "-DQT_FEATURE_webengine_system_libevent=ON"
    "-DQT_FEATURE_webengine_system_libxml=ON"
    "-DQT_FEATURE_webengine_system_ffmpeg=ON"
    # android only. https://bugreports.qt.io/browse/QTBUG-100293
    # "-DQT_FEATURE_webengine_native_spellchecker=ON"
    "-DQT_FEATURE_webengine_sanitizer=ON"
    "-DQT_FEATURE_webengine_webrtc_pipewire=ON"
    "-DQT_FEATURE_webengine_kerberos=ON"
  ] ++ lib.optional enableProprietaryCodecs "-DQT_FEATURE_webengine_proprietary_codecs=ON";

  propagatedBuildInputs = [
    # Image formats
    libjpeg
    libpng
    libtiff
    libwebp

    # Video formats
    srtp
    libvpx

    # Audio formats
    libopus

    # Text rendering
    harfbuzz
    icu

    openssl
    glib
    libxml2
    libxslt
    lcms2
    re2

    libevent
    ffmpeg

    dbus
    zlib
    minizip
    snappy
    nss
    protobuf
    jsoncpp

    # Audio formats
    alsa-lib
    pulseaudio

    # Text rendering
    fontconfig
    freetype

    libcap
    pciutils

    # X11 libs
    xorg.xrandr
    libXScrnSaver
    libXcursor
    libXrandr
    xorg.libpciaccess
    libXtst
    xorg.libXcomposite
    xorg.libXdamage
    libdrm
    xorg.libxkbfile
    libxshmfence
    libXi
    xorg.libXext

    # Pipewire
    pipewire

    libkrb5
  ];

  buildInputs = [
    cups

    # needed for postPatch
    jest-worker
    gnumake-tokenpool-src
  ];

  requiredSystemFeatures = [ "big-parallel" ];

  # NOTE buildPhase ignores NIX_BUILD_CORES
  # and uses all available cpu cores
  #
  # limiting cores by
  #   export NINJAFLAGS="-j32 -l32"
  # causes the build error
  #   internal compiler error: Segmentation fault
  #
  # https://bugreports.qt.io/browse/QTBUG-103573
  #
  # honor NIX_BUILD_CORES in recursive ninja calls
  # https://bugreports.qt.io/browse/QTBUG-95176
  #
  # based on ninjaBuildPhase in
  # pkgs/development/tools/build-managers/ninja/setup-hook.sh
  #
  # this must run before cmake
  # to set NINJAFLAGS for qtwebengine/cmake/Functions.cmake
  #
  /*
  preConfigure = ''
    local buildCores=1

    # Parallel building is enabled by default.
    if [ "''${enableParallelBuilding-1}" ]; then
        buildCores="$NIX_BUILD_CORES"
    fi

    local flagsArray=(
        -j$buildCores -l$NIX_BUILD_CORES
        $ninjaFlags "''${ninjaFlagsArray[@]}"
    )

    # honor NIX_BUILD_CORES in recursive ninja calls
    export NINJAFLAGS="''${flagsArray[@]}"
    #export SAMUFLAGS="$NINJAFLAGS" # error: invalid option -l
    export SAMUFLAGS="-j$buildCores"
    echo "preConfigure: setting NINJAFLAGS: $NINJAFLAGS"
  '';
  */

  postInstall = ''
    # This is required at runtime
    mkdir $out/libexec
    mv $dev/libexec/QtWebEngineProcess $out/libexec
  '';

  meta = with lib; {
    broken = (stdenv.isLinux && stdenv.isAarch64);
    description = "A web engine based on the Chromium web browser";
    platforms = platforms.linux;
    # This build takes a long time; particularly on slow architectures
    # 1 hour on 32x3.6GHz -> maybe 12 hours on 4x2.4GHz
    timeout = 24 * 3600;
  };
}
