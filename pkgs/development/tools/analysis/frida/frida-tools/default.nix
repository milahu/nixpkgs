{ lib
, stdenv
, fetchFromGitHub
/*
, fetchurl
, fetchpatch
*/
, meson
, cmake
, ninja
, pkg-config
, frida-core
, python3
, nodejs-19_x
, callPackage
/*
, frida-vala
, frida-glib
, frida-glib-networking
, frida-usrsctp
, frida-v8
, libgee
, json-glib
, libsoup_3
, brotli
, libnice
*/
}:

let
  srcs = builtins.fromJSON (builtins.readFile ../srcs.json);

  # node2nix -d -l package-lock.json
  frida-fs-agent = callPackage ./agents/fs {
    nodejs = nodejs-19_x;
  };

  # node2nix -d -l package-lock.json
  frida-tracer-agent = callPackage ./agents/tracer {
    nodejs = nodejs-19_x;
  };
in

stdenv.mkDerivation rec {
  pname = "frida-tools";
  inherit (srcs) version;
  src = fetchFromGitHub srcs.paths.${pname}.github;

  nativeBuildInputs = [
    meson
    pkg-config
    cmake
    ninja
    #frida-vala
  ];

  buildInputs = [
    frida-core
    python3 # agents/build.py
    nodejs-19_x # npm, same nodejs version as frida-gum
    /*
    frida-gum
    frida-glib
    frida-glib-networking
    frida-usrsctp
    frida-v8
    libgee
    json-glib
    libsoup_3
    brotli
    libnice
    */
  ];

  patches = [
    /*
    # fix build on linux
    # https://github.com/frida/frida-core/pull/454
    (fetchpatch {
      url = "https://github.com/frida/frida-core/commit/d08e9e9ec5ba759e2ba530c077f0d8c66d20ed9a.patch";
      sha256 = "sha256-6ihcR/MOHP0Hbm9BHyGo8rOgyP5XYso/FtGyELSXb1I=";
    })
    */
  ];

  postPatch = ''
    chmod +x agents/build.py
    patchShebangs .
    substituteInPlace agents/build.py \
      --replace 'capture_output=True' 'capture_output=False' \
      --replace 'subprocess.run([npm, "install"]' 'pass #' \

  '';
/*
  # https://github.com/frida/v8/issues/14
  preConfigure = ''
    export PATH=${frida-v8}/bin/linux-x86_64:$PATH
  '';

    mkdir -p src/compiler
    pushd src/compiler

  */

  preBuild = ''
    # agents/build.py -> priv_dir
    mkdir -p agents/fs/fs_agent.js.p
    pushd agents/fs/fs_agent.js.p
    cp -r ${frida-fs-agent.nodeDependencies}/lib/node_modules .
    chmod -R +w node_modules
    #export PATH=$PWD/node_modules/.bin:$PATH
    popd

    # agents/build.py -> priv_dir
    mkdir -p agents/tracer/tracer_agent.js.p
    pushd agents/tracer/tracer_agent.js.p
    cp -r ${frida-tracer-agent.nodeDependencies}/lib/node_modules .
    chmod -R +w node_modules
    #export PATH=$PWD/node_modules/.bin:$PATH
    popd
  '';

/*
    mkdir -p node_modules/@types/frida-gum
    cp ${src-frida-gum-dts} node_modules/@types/frida-gum/index.d.ts
*/

  passthru = {
    inherit frida-fs-agent frida-tracer-agent;
  };

  meta = with lib; {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers";
    homepage = "https://github.com/frida/frida-tools";
    license = licenses.wxWindows;
    maintainers = with maintainers; [ milahu ];
    platforms = platforms.unix;
  };
}
