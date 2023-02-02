{ lib
, stdenv
, fetchFromGitHub
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

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
  ];

  meta = with lib; {
    description = "Tiny C Compiler";
    homepage = "https://github.com/frida/tinycc";
    changelog = "https://github.com/frida/tinycc/blob/${src.rev}/Changelog";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ ];
  };
}
