{ lib
, glib
, fetchFromGitHub
}:

# based on pkgs/development/libraries/glib/default.nix

glib.overrideAttrs (oldAttrs: rec {
  pname = "frida-glib";
  version = "2.75.0-unstable-2022-12-10";

  src = fetchFromGitHub {
    owner = "frida";
    repo = "glib";
    rev = "805e42d63aa17f58b90a57c71f4b1896f154a535";
    hash = "sha256-XSOukzSm8c6XbkafKSWhcxbwJSE71P3tYat6Il+NsDU=";
    # subprojects/gvdb
    fetchSubmodules = true;
  };

  meta = with lib; {
    description = "Frida fork of GLib";
    homepage = "https://github.com/frida/glib";
    changelog = "https://github.com/frida/glib/blob/${src.rev}/NEWS";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ ];
  };
}
