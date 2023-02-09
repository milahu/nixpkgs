{ lib
, stdenv
, fetchFromGitHub
, meson
, pkg-config
, ninja
}:

stdenv.mkDerivation rec {
  pname = "frida-glib";
  version = "unstable-2022-12-10";

  src = fetchFromGitHub {
    owner = "frida";
    repo = "glib";
    rev = "805e42d63aa17f58b90a57c71f4b1896f154a535";
    hash = "sha256-HQ1UXvxMo6Hy8/vGQhO6W2H5rJnoYHgsd8Hdl9XcY0c=";
  };

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
  ];

  meta = with lib; {
    description = "Frida fork of GLib";
    homepage = "https://github.com/frida/glib";
    changelog = "https://github.com/frida/glib/blob/${src.rev}/NEWS";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ ];
  };
}
