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
    # https://github.com/frida/tinycc/pull/7
    rev = "dcd12ae0654369c59f58b868df6a2633d4435b79";
    hash = "sha256-PB0eeWV344+5b2hFXYRjSGr8JwlIeQ2HysTNg+FOIbQ=";
  };

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
