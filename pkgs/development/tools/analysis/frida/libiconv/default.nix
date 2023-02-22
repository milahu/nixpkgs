{ lib
, stdenv
, fetchFromGitHub
, meson
, pkg-config
, cmake
, ninja
, gperf
, python3
}:

stdenv.mkDerivation rec {
  pname = "frida-libiconv";
  version = "unstable-2022-11-01";

  src = fetchFromGitHub {
    owner = "frida";
    repo = "libiconv";
    rev = "9732614f0ee778d58acccd802ffe907a1b0a3e7a";
    hash = "sha256-j9jP+FPGRld4UKeAF2jOzOOdwi2O4kpkTkOhvcR11gY=";
  };

  postPatch = ''
    patchShebangs .
  '';

  nativeBuildInputs = [
    meson
    pkg-config
    cmake
    ninja
  ];

  buildInputs = [
    gperf
    python3 # build-aux/genversion.py
  ];

  meta = with lib; {
    description = "Frida depends on libiconv on some systems";
    homepage = "https://github.com/frida/libiconv.git";
    changelog = "https://github.com/frida/libiconv/blob/${src.rev}/ChangeLog";
    license = with licenses; [ lgpl21Only gpl3Only ];
    maintainers = with maintainers; [ ];
  };
}
