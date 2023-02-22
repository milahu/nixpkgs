{ lib
, libsoup_3
, frida-glib
, frida-glib-networking
}:

libsoup_3.override {
  glib = frida-glib;
  glib-networking = frida-glib-networking;
}
