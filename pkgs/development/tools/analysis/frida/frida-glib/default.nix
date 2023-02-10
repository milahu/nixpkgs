{ lib
, stdenv
, glib
, fetchFromGitHub
}:

# based on pkgs/development/libraries/glib/default.nix

/*
FIXME
https://github.com/frida/glib/issues/10
glib/gmem.c:81:3: error: ignoring return value of 'posix_memalign'
*/

glib.overrideAttrs (oldAttrs: rec {
  pname = "frida-glib";
  version = "2.75.0-unstable-2022-12-10";

  src = fetchFromGitHub {
    owner = "frida";
    repo = "glib";
    /*
    rev = "805e42d63aa17f58b90a57c71f4b1896f154a535";
    hash = "sha256-XSOukzSm8c6XbkafKSWhcxbwJSE71P3tYat6Il+NsDU=";
    */
    # fix: error: ignoring return value of posix_memalign
    # https://github.com/frida/glib/issues/10
    rev = "6bb81f198823f47c571da5700158eb841ec26e16";
    hash = "sha256-Et4BwBDTcaulI78ZTt+igY9DsFSi/fKoCABLad8s3u4=";

    # subprojects/gvdb
    fetchSubmodules = true;
  };

  # TODO add patches?
  patches = [];

  postPatch = (oldAttrs.postPatch or "") + ''
    chmod +x tools/gen-visibility-macros.py
    patchShebangs tools/gen-visibility-macros.py
  '';

  mesonFlags = [
    # Avoid the need for gobject introspection binaries in PATH in cross-compiling case.
    # Instead we just copy them over from the native output.
    #"-Dgtk_doc=${lib.boolToString buildDocs}"
    "-Dnls=enabled"
    # ERROR: Unknown options: "devbindir"
    #"-Ddevbindir=${placeholder "dev"}/bin"
  ] ++ lib.optionals (!stdenv.isDarwin) [
    "-Dman=true"                # broken on Darwin
  ];

  meta = with lib; {
    description = "Frida fork of GLib";
    homepage = "https://github.com/frida/glib";
    changelog = "https://github.com/frida/glib/blob/${src.rev}/NEWS";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ ];
  };
})
