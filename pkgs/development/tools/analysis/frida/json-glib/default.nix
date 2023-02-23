{ lib
, fetchFromGitHub
, glib
, gobject-introspection
, original-json-glib
}:

(original-json-glib.override {
  inherit glib gobject-introspection;
}).overrideAttrs (oldAttrs: {
  version = "unstable-2022-11-16";
  src = fetchFromGitHub {
    owner = "frida";
    repo = "json-glib";
    rev = "fd29bf6dda9dcf051d2d98838e3086566bf91411";
    hash = "sha256-aVJ9rWfkN0MZ+lelO4tfLCgn3RGF1txcsDK072DnuLk=";
  };
  patches = [];
  outputs = [ "out" "dev" "devdoc" ]; #  "installedTests"
  mesonFlags = [
    #"-Dinstalled_test_prefix=${placeholder "installedTests"}"
  ];
})
