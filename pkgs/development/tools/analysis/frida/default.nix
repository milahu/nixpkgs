{ lib
, newScope
}:

lib.makeScope newScope (self: with self; {
  frida-fhs-env = callPackage ./frida-fhs-env { };
  frida-core = callPackage ./frida-core { };
  frida-gum = callPackage ./frida-gum { };
  frida-tools = callPackage ./frida-tools { };
  frida-python = callPackage ./frida-python { };
  frida-compile = callPackage ./frida-compile { };

  # frida's forks of dependencies
  v8 = callPackage ./v8 { };
  tinycc = callPackage ./tinycc { };
  glib = callPackage ./glib { };
  glib-networking = callPackage ./glib-networking { };
  vala = callPackage ./vala { };
  usrsctp = callPackage ./usrsctp { };
  quickjs = callPackage ./quickjs { };
  libiconv = callPackage ./libiconv { };
  libsoup = callPackage ./libsoup { };
})

/*
v8 tinycc glib glib-networking vala usrsctp quickjs libiconv libsoup
*/
