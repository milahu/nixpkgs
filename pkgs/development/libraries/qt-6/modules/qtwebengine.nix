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
, nix-build-profiler # debug
}:

let
  # build this in a separate derivation to limit job count
  # pkgs/development/tools/build-managers/gn/default.nix
  gn' = gn.overrideAttrs (old: {
    version = "qt-${srcs.qtwebengine.version}";
    src = srcs.qtwebengine.src;
    sourceRoot = "qtwebengine-everywhere-src-${srcs.qtwebengine.version}/src/gn";
    postPatch = ''
      # limit job count
      substituteInPlace CMakeLists.txt \
        --replace 'COMMAND Ninja::ninja ' 'COMMAND Ninja::ninja $ninjaFlags '
    '';

    /*
        --replace 'COMMAND Ninja::ninja ' 'COMMAND Ninja::ninja $NINJAFLAGS '

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
      echo "preConfigure: setting NINJAFLAGS: $NINJAFLAGS"
    '';
    */
  });
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
    #ninja # ninja is still found by cmake. why??
    samurai
    pkg-config
    (python3.withPackages (ps: with ps; [ html5lib ]))
    which
    #gn # not used?
    gn'
    nodejs
    nix-build-profiler # debug
  ];
  doCheck = true;
  outputs = [ "out" "dev" ];

  dontUseGnConfigure = true;

  # ninja builds some components with -Wno-format,
  # which cannot be set at the same time as -Wformat-security
  hardeningDisable = [ "format" ];

  postPatch = ''
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

    # limit job count
    substituteInPlace src/gn/CMakeLists.txt \
      --replace 'COMMAND Ninja::ninja ' 'COMMAND Ninja::ninja $NINJAFLAGS '
  '';

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
