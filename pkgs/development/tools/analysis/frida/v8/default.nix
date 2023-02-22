# NOTE: v8-mksnapshot binary is in $out/bin/linux-x86_64/v8-mksnapshot-linux-x86_64
# workaround: export PATH=${frida-v8}/bin/linux-x86_64:$PATH

{ lib
, stdenv
, fetchFromGitHub
, meson
, pkg-config
, ninja
, zlib
}:

stdenv.mkDerivation rec {
  pname = "frida-v8";
  version = "unstable-2022-11-02";

  src = fetchFromGitHub {
    owner = "frida";
    repo = "v8";
    rev = "bda4a1a3ccc6231a389caebe309fc20fd7cf1650";
    hash = "sha256-Ust8RNhuqOUtHzb8bGrlvcjp2M0rfEP2MwS8NwsZJKE=";
  };

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
    zlib
  ];

  meta = with lib; {
    description = "Frida fork of the V8 JavaScript Engine";
    homepage = "https://github.com/frida/v8";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
}
