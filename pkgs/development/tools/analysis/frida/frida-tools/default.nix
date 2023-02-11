{ lib
, stdenv
, fetchFromGitHub
, meson
, cmake
, ninja
, pkg-config
, frida-core
, python3
, nodejs-19_x
, callPackage
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
  ];

  buildInputs = [
    frida-core
    python3 # agents/build.py
    nodejs-19_x # npm, same nodejs version as frida-gum
  ];

  postPatch = ''
    chmod +x agents/build.py
    patchShebangs .
    substituteInPlace agents/build.py \
      --replace 'capture_output=True' 'capture_output=False' \
      --replace 'subprocess.run([npm, "install"]' 'pass #' \

  '';

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
