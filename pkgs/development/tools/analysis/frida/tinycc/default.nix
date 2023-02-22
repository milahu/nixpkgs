{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, meson
, pkg-config
, ninja
}:

stdenv.mkDerivation rec {
  pname = "frida-tinycc";
  version = "unstable-2022-04-01";

  src = fetchFromGitHub {
    owner = "frida";
    repo = "tinycc";
    rev = "a438164dd4c453ae62c1224b4b7997507a388b3d";
    hash = "sha256-BoTzGr/4z8h7/EqUP9N1Xtg7CCtqT/uKVX8P/lzmDHg=";
  };

  patches = [
    # install runtime header tcclib.h
    # https://github.com/frida/tinycc/pull/7
    (fetchpatch {
      url = "https://github.com/frida/tinycc/pull/7.patch";
      sha256 = "sha256-ROtUm42CNme/uptdWTgszPAiZXJi7HD97WIynt1d4Mw=";
    })
  ];

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
  ];

  meta = with lib; {
    description = "Frida fork of the Tiny C Compiler";
    homepage = "https://github.com/frida/tinycc";
    changelog = "https://github.com/frida/tinycc/blob/${src.rev}/Changelog";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ ];
  };
}
