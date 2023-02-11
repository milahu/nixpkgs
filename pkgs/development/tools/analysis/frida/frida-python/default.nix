{ lib
, stdenv
, fetchFromGitHub
, meson
, cmake
, ninja
, pkg-config
, frida-core
, python3
}:

let
  srcs = builtins.fromJSON (builtins.readFile ../srcs.json);
in

stdenv.mkDerivation rec {
  pname = "frida-python";
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
    python3
  ];

  meta = with lib; {
    description = "Python bindings for Frida";
    homepage = "https://github.com/frida/frida-python";
    license = licenses.wxWindows;
    maintainers = with maintainers; [ milahu ];
    platforms = platforms.unix;
  };
}
