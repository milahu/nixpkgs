{ lib
, newScope
, fetchFromGitHub
, glib
, usrsctp
, vala
}:

/*
FIXME override "glib = self.glib" for all inputs of this scope
example: frida-core -> libsoup_3 -> glib
*/

lib.makeScope newScope (self: let inherit (self) callPackage; in {
  frida-core = callPackage ./frida-core { };
  frida-gum = callPackage ./frida-gum { };
  frida-tools = callPackage ./frida-tools { };
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
  glib-networking = callPackage ./glib-networking { };
  vala = callPackage ./vala {
    originalVala = vala;
  };
  usrsctp = callPackage ./usrsctp {
    originalUsrsctp = usrsctp;
  };
  quickjs = callPackage ./quickjs { };
  libiconv = callPackage ./libiconv { };
  libsoup = callPackage ./libsoup { };
})

/*
v8 tinycc glib glib-networking vala usrsctp quickjs libiconv libsoup
*/
