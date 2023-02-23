{ lib
, stdenv
, fetchFromGitHub
, meson
, pkg-config
, cmake
, ninja
}:

stdenv.mkDerivation rec {
  pname = "json-glib";
  version = "unstable-2022-11-16";

  src = fetchFromGitHub {
    owner = "frida";
    repo = "json-glib";
    rev = "fd29bf6dda9dcf051d2d98838e3086566bf91411";
    hash = "sha256-aVJ9rWfkN0MZ+lelO4tfLCgn3RGF1txcsDK072DnuLk=";
  };

  nativeBuildInputs = [
    meson
    pkg-config
    cmake
    ninja
  ];

  meta = with lib; {
    description = "Frida fork of json-glib";
    homepage = "https://github.com/frida/json-glib";
    changelog = "https://github.com/frida/json-glib/blob/${src.rev}/NEWS";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ ];
  };
}
