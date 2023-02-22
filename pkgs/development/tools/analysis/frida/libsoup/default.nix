{ lib
, libsoup_3
, glib
, glib-networking
}:

libsoup_3.override {
  glib = glib;
  glib-networking = glib-networking;
}
