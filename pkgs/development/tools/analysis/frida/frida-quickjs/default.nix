{ lib
, stdenv
, fetchFromGitHub
, meson
, cmake
, pkg-config
, ninja
}:

stdenv.mkDerivation rec {
  pname = "frida-quickjs";
  version = "unstable-2023-01-26";

  src = fetchFromGitHub {
    owner = "frida";
    repo = "quickjs";
    rev = "65cfe08db6fd51367d02e3d5123896699cc8cf1f";
    hash = "sha256-jwLkb8GR6YzoqsfMos5klOmODbIioQmxu+5GPRbWBqw=";
  };

  nativeBuildInputs = [
    meson
    cmake
    pkg-config
    ninja
  ];

  meta = with lib; {
    description = "Frida fork of the QuickJS Javascript Engine";
    homepage = "https://github.com/frida/quickjs";
    changelog = "https://github.com/frida/quickjs/blob/${src.rev}/Changelog";
    license = licenses.mit;
    maintainers = with maintainers; [ milahu ];
  };
}
