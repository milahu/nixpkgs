{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, meson
, ninja
, pkg-config
, frida-gum
, frida-vala
, cmake
, frida-glib
, libgee
, json-glib
, libsoup_3
, brotli
, frida-glib-networking
, coreutils
, libnice
, usrsctp
, python3
, nodejs-19_x
, nodePackages
, callPackage
, frida-v8
/*
, nodejs
, which
, git
, perl
*/
}:

let
  srcs = builtins.fromJSON (builtins.readFile ../srcs.json);

  frida-compiler-agent = callPackage ./frida-compiler-agent {
    nodejs = nodejs-19_x;
  };

  # cd src/compiler && node2nix -l package-lock.json -d && cp *.nix package* ~/src/nixpkgs/pkgs/development/tools/analysis/frida/frida-core/frida-compiler-agent/
in

#let frida =
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
    ninja
    frida-vala
  ];

  /*
  TODO?
  Has header "android/api-level.h" : NO
  Has header "xlocale.h" : NO
  Checking if "compiling for uClibc" compiles: NO
  */

  buildInputs = [
    pkg-config
    frida-gum
    cmake
    frida-glib
    libgee
    json-glib
    libsoup_3
    brotli
    frida-glib-networking # gioopenssl
    libnice
    usrsctp
    python3 # src/compiler/generate-agent.py
    nodejs-19_x # npm, same nodejs version as frida-gum
    frida-v8
    /*
    which
    git
    python3
    nodejs
    perl
    */
  ];

/*

FIXME

[1/144] Generating src/compiler/frida-compiler-agent with a custom command
FAILED: src/compiler/agent.js src/compiler/snapshot.bin
/build/source/src/compiler/generate-agent.py /build/source/src/compiler /build/source/build/src/compiler linux 64 ''
/bin/sh: /build/source/src/compiler/generate-agent.py: not found

      --replace \
        'frida_compile = output_dir / "node_modules" / ".bin" / make_script_filename("frida-compile")' \
        'frida_compile = Path("${nodePackages.frida-compile}/bin/frida-compile")' \

*/

  postPatch = ''
    patchShebangs .
    substituteInPlace src/compiler/generate-agent.py \
      --replace 'capture_output=True' 'capture_output=False' \
      --replace 'subprocess.run([npm, "install"]' 'pass #' \
      --replace 'with urllib.request.urlopen' '#' \
      --replace '        (output_dir / "node_modules" / "@types" / "frida-gum"' '#' \
      --replace '    shutil.copyfileobj(response, frida_gum_types)' '#' \

  '';

  # https://github.com/frida/v8/issues/14
  preConfigure = ''
    export PATH=${frida-v8}/bin/linux-x86_64:$PATH
  '';

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

  meta = with lib; {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers";
    homepage = "https://github.com/frida/frida-core";
    license = licenses.wxWindows;
    maintainers = with maintainers; [ milahu ];
    platforms = platforms.unix;
  };

  passthru = {
    /*
    tools = frida.overrideAttrs (old: {

    });
    */

  };
}
#; in frida
