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
, python3
, nodejs-19_x
, callPackage
*/
}:

let
  srcs = builtins.fromJSON (builtins.readFile ../srcs.json);
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
    python3 # src/compiler/generate-agent.py
    nodejs-19_x # npm, same nodejs version as frida-gum
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

/*
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
  */

  meta = with lib; {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers";
    homepage = "https://github.com/frida/frida-tools";
    license = licenses.wxWindows;
    maintainers = with maintainers; [ milahu ];
    platforms = platforms.unix;
  };
}
