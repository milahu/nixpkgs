{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, fetchpatch
, meson
, ninja
, pkg-config
, frida-gum
, frida-vala
, frida-glib
, frida-glib-networking
, frida-usrsctp
, frida-v8
, cmake
, libgee
, json-glib
, libsoup_3
, brotli
, libnice
, python3
, nodejs-19_x
, callPackage
}:

let
  original-meson = meson;
in

let
  srcs = builtins.fromJSON (builtins.readFile ../srcs.json);

  frida-compiler-agent = callPackage ./frida-compiler-agent {
    nodejs = nodejs-19_x;
  };

  # fix build for default_library=both
  # https://github.com/mesonbuild/meson/issues/6960
  meson = original-meson.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or []) ++ [
      ./meson-vala-fix-generated-paths.patch
      ./meson-fix-attributeerror-sharedlibrary-split.patch
    ];
  });
in

stdenv.mkDerivation rec {
  pname = "frida-core";
  inherit (srcs) version;
  src = fetchFromGitHub srcs.paths.${pname}.github;

  # frida-core/src/compiler/generate-agent.py
  src-frida-gum-dts = fetchurl {
    url = "https://raw.githubusercontent.com/DefinitelyTyped/DefinitelyTyped/86804f3dc1469f041fcec0f945e66eefbd94baeb/types/frida-gum/index.d.ts";
    sha256 = "sha256-oEI8U9jvV/LRYfhH7yJvNwijpYq7ALM5pnl94W+uVsk=";
  };

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
    frida-vala
  ];

  buildInputs = [
    frida-gum
    frida-glib
    frida-glib-networking # gioopenssl
    frida-usrsctp
    frida-v8
    cmake
    libgee
    json-glib
    libsoup_3
    brotli
    libnice
    python3 # src/compiler/generate-agent.py
    nodejs-19_x # npm, same nodejs version as frida-gum
  ];

  # lib/pkgconfig/frida-core-1.0.pc
  # Requires: glib-2.0, gobject-2.0, gio-2.0, json-glib-1.0
  # Requires.private: gmodule-2.0, gee-0.8, libsoup-3.0, frida-gum-1.0, frida-gumjs-inspector-1.0, libbrotlidec, gioopenssl, nice, openssl, usrsctp
  propagatedBuildInputs = [
    frida-glib
    json-glib
    libgee
    libsoup_3
    frida-gum
    #frida-gumjs-inspector
    brotli
    frida-glib-networking # gioopenssl
    libnice
    #openssl
    frida-usrsctp
  ];

  postPatch = ''
    patchShebangs .
    substituteInPlace src/compiler/generate-agent.py \
      --replace 'capture_output=True' 'capture_output=False' \
      --replace 'subprocess.run([npm, "install"]' 'pass #' \
      --replace 'with urllib.request.urlopen' '#' \
      --replace '        (output_dir / "node_modules" / "@types" / "frida-gum"' '#' \
      --replace '    shutil.copyfileobj(response, frida_gum_types)' '#' \

    # https://github.com/frida/frida-core/pull/454
    substituteInPlace src/meson.build \
      --replace \
        "core = library('frida-core', core_sources," \
        "core = static_library('frida-core', core_sources,"

  '';

  # https://github.com/frida/v8/issues/14
  preConfigure = ''
    export PATH=${frida-v8}/bin/linux-x86_64:$PATH
  '';

  mesonFlags = [
    #"-Ddefault_library=both" # build error
    #"-Ddefault_library=static" # ok
  ];

  preBuild = ''
    mkdir -p src/compiler
    pushd src/compiler

    cp -r ${frida-compiler-agent.nodeDependencies}/lib/node_modules .
    chmod -R +w node_modules
    export PATH=$PWD/node_modules/.bin:$PATH

    mkdir -p node_modules/@types/frida-gum
    cp ${src-frida-gum-dts} node_modules/@types/frida-gum/index.d.ts

    popd
  '';

  passthru = {
    inherit frida-compiler-agent;
    inherit meson;
  };

  meta = with lib; {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers";
    homepage = "https://github.com/frida/frida-core";
    license = licenses.wxWindows;
    maintainers = with maintainers; [ milahu ];
    platforms = platforms.unix;
  };
}
