{ qtModule
, fetchFromGitHub
, qtdeclarative
, qtwebchannel
, qtpositioning
, qtwebsockets
, bison
, coreutils
, flex
, git
, gperf
, ninja-tokenpool
, pkg-config
, python3
, which
, nodejs
, qtbase
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
, nix-build-profiler # debug jobclient patches
}:

let
  # add jobclients to limit cpu usage to NIX_BUILD_CORES
  # jest-worker with jobclient
  # call stack: devtools-frontend -> rollup -> terser -> jest-worker
  jest-worker = fetchFromGitHub {
    # requires gnumake-tokenpool
    # https://github.com/milahu/jest-worker/tree/26.6.2
    # https://github.com/facebook/jest/pull/12968
    owner = "milahu";
    repo = "jest-worker";
    rev = "a846fbb511d72ff2439123b3e9a6104524e1d7d2";
    sha256 = "Gon76s+F/REm2/5ZvuhaeDVRILKf8xVtvyh1jmLxlWE=";
  };

  gnumake-tokenpool = fetchFromGitHub {
    owner = "milahu";
    repo = "gnumake-tokenpool";
    rev = "1bfc3aaa47fe6f230fff5df0014db549cec18620";
    sha256 = "fsqDRMq7JH1zGBqsJGSllJpNATuaoAbWo1ZrpK9y9k8=";
  };
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
    ninja-tokenpool
    pkg-config
    (python3.withPackages (ps: with ps; [ html5lib ]))
    which
    nodejs
    nix-build-profiler # debug jobclient patches
  ];
  doCheck = true;
  outputs = [ "out" "dev" ];

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

  # debug jobclient patches
  DEBUG_JOBCLIENT = "1"; # gnumake-tokenpool
  DEBUG_JEST_WORKER = "1"; # src/3rdparty/chromium/third_party/devtools-frontend/src/node_modules/jest-worker/build/index.js
  DEBUG_CHROMIUM_NODE_PY = "1"; # src/3rdparty/chromium/third_party/node/node.py
  DEBUG_MOJOM_PARSER = "1"; # src/3rdparty/chromium/mojo/public/tools/mojom/mojom_parser.py

  postPatch = ''
    # Add jobclient to javascript build tools
    (
      cd src/3rdparty/chromium/third_party/devtools-frontend/src/node_modules

      mv jest-worker/node_modules jest-worker.node_modules
      rm -rf jest-worker
      cp -r ${jest-worker} jest-worker
      chmod -R +w jest-worker
      mv jest-worker.node_modules jest-worker/node_modules

      cp -r ${gnumake-tokenpool}/js/src/gnumake-tokenpool .
      chmod -R +w gnumake-tokenpool
    )

    # Add jobclient to python build tools
    for dst in \
      src/3rdparty/chromium/third_party/blink/renderer/bindings/scripts/bind_gen \
      src/3rdparty/chromium/mojo/public/tools/mojom
    do
      (
        cd "$dst"
        cp -r ${gnumake-tokenpool}/py/src/gnumake_tokenpool .
        chmod -R +w gnumake_tokenpool
      )
    done

    # Add jobclient to C++ build tools
    (
      cd src/3rdparty/gn/src/util
      cp -r ${gnumake-tokenpool}/cc/src/* .
      chmod -R +w *
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
