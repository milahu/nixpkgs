{ lib
, newScope
, fetchFromGitHub
, glib
, usrsctp
, vala
, libnice
, libsoup_3
, glib-networking
, json-glib
}:

lib.makeScope newScope (self: let inherit (self) callPackage; in {
  frida-core = callPackage ./frida-core {
    inherit (self) glib json-glib;
  };
  frida-gum = callPackage ./frida-gum {
    inherit (self) glib json-glib;
  };
  frida-tools = callPackage ./frida-tools {
    inherit (self) glib json-glib;
  };
  frida-python = callPackage ./frida-python { };
  frida-compile = callPackage ./frida-compile { };

  # debug
  frida-fhs-env = callPackage ./frida-fhs-env { };

  # frida's forks of dependencies
  v8 = callPackage ./v8 { };
  tinycc = callPackage ./tinycc { };
  glib = callPackage ./glib {
    originalGlib = glib;
  };
  glib-networking = callPackage ./glib-networking {
    inherit (self) glib json-glib;
  };
  json-glib = callPackage ./json-glib {
    original-json-glib = json-glib;
    inherit (self) glib;
  };
  vala = callPackage ./vala {
    originalVala = vala;
  };
  usrsctp = callPackage ./usrsctp {
    originalUsrsctp = usrsctp;
  };
  quickjs = callPackage ./quickjs { };

  # libiconv with pkgconfig files
  libiconv = callPackage ./libiconv { };

  # override glib in dependencies
  # ( cd nixpkgs && nix why-depends --all .#fridaPackages.frida-tools .#glib )
  # ( cd nixpkgs && nix why-depends --all .#fridaPackages.frida-tools .#glib-networking )
  libsoup_3 = libsoup_3.override {
    inherit (self) glib glib-networking;
  };
  libnice = libnice.override {
    inherit (self) glib;
  };
})
