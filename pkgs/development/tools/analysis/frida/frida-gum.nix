/*
TODO?
Fetching value of define "FRIDA_VERSION" :
Has header "android/api-level.h" : NO
Checking for function "g_thread_set_callbacks" with dependency glib-2.0: NO
Checking for function "ffi_set_mem_callbacks" with dependency libffi: NO
Run-time dependency gioopenssl found: NO (tried pkgconfig and cmake)
*/

{ lib
, stdenv
, fetchFromGitHub
, meson
, vala
, pkg-config
, cmake
, ninja
, glib
, capstone_5
, lzma
, gobject-introspection
, libunwind
, libelf
, libdwarf
#, gioopenssl
}:

let
  common = import ./common.nix { inherit fetchFromGitHub; };
in

stdenv.mkDerivation rec {
  pname = "frida-gum";
  inherit (common) version;
  src = common.srcs.${pname};

  patches = [
    # https://github.com/frida/frida-gum/issues/710
    ./patches/frida-gum/0001-use-libdwarf-0.0-libdwarf-20210528.patch
    ./patches/frida-gum/0002-use-libdwarf-0.1.patch
    ./patches/frida-gum/0003-use-libdwarf-0.2.patch
    ./patches/frida-gum/0004-use-libdwarf-0.3.patch
    ./patches/frida-gum/0005-use-libdwarf-0.4-or-later.patch
  ];

  nativeBuildInputs = [
    meson
  ];

  buildInputs = [
    pkg-config
    cmake
    ninja
    glib
    capstone_5
    lzma
    libunwind
    libelf
    libdwarf
    gobject-introspection # g-ir-scanner
    #gioopenssl
  ];

  meta = with lib; {
    description = "instrumentation and introspection library";
    homepage = "https://github.com/frida/frida-gum";
    license = licenses.wxWindows;
    maintainers = with maintainers; [ milahu ];
    platforms = platforms.unix;
  };

  passthru = {
    inherit libdwarf;
  };
}
