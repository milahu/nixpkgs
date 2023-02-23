/*
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
, pkgs
}:
*/

{ pkgs }:

let
  frida-pkgs = pkgs.extend (final: prev: {
    #firefox = prev.firefox.override { ... };
    #myBrowser = final.firefox;
    glib = final.callPackage ./glib {
      originalGlib = prev.glib;
    };
    glib-networking = final.callPackage ./glib-networking {
      #inherit (self) glib json-glib;
    };
    json-glib = final.callPackage ./json-glib {
      original-json-glib = prev.json-glib;
      ##inherit (self) glib;
    };
    vala = final.callPackage ./vala {
      originalVala = prev.vala;
    };
    gobject-introspection = (prev.gobject-introspection.override {
      inherit (final) glib gobject-introspection-unwrapped;
    }).overrideAttrs (oldAttrs: rec {
      # https://gitlab.gnome.org/GNOME/gobject-introspection
      version = "1.75.6";
      src = final.fetchFromGitLab {
        domain = "gitlab.gnome.org";
        owner = "GNOME";
        repo = "gobject-introspection";
        rev = version;
        sha256 = "sha256-mCXH0M1xL5Red9JfpdTxhqWmNJ0NCr2lwKeC/guFMQ8=";
      };
    });
    gobject-introspection-unwrapped = (prev.gobject-introspection-unwrapped.override {
      inherit (final) glib;
    }).overrideAttrs (oldAttrs: rec {
      # https://gitlab.gnome.org/GNOME/gobject-introspection
      version = "1.75.6";
      src = final.fetchFromGitLab {
        domain = "gitlab.gnome.org";
        owner = "GNOME";
        repo = "gobject-introspection";
        rev = version;
        sha256 = "sha256-mCXH0M1xL5Red9JfpdTxhqWmNJ0NCr2lwKeC/guFMQ8=";
      };
    });
  });
in

with frida-pkgs;

lib.makeScope newScope (self: let inherit (self) callPackage; in {
  inherit glib glib-networking json-glib vala gobject-introspection;
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
