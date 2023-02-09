/*
TODO?
Has header "android/api-level.h" : NO
Fetching value of define "FRIDA_VERSION" :
Checking for function "g_thread_set_callbacks" with dependency glib-2.0: NO
Checking for function "ffi_set_mem_callbacks" with dependency libffi: NO
Run-time dependency gioopenssl found: NO (tried pkgconfig and cmake)
*/

{ lib
, stdenv
, fetchFromGitHub
, meson
#, frida-vala
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
, nodejs-19_x
, frida-v8
, json-glib
, frida-tinycc
, sqlite
, libsoup_3
, glib-networking
, frida-glib-networking
, python3
, nodePackages
, enableGumjs ? true # Build JavaScript bindings
, enableGumpp ? false # Build C++ bindings # NOTE: not tested
}:

let
  srcs = builtins.fromJSON (builtins.readFile ../srcs.json);
in

stdenv.mkDerivation rec {
  pname = "frida-gum";
  inherit (srcs) version;
  src = fetchFromGitHub srcs.paths.${pname}.github;

  patches = [
    # https://github.com/frida/frida-gum/issues/710
    ./patches/0001-use-libdwarf-0.0-libdwarf-20210528.patch
    ./patches/0002-use-libdwarf-0.1.patch
    ./patches/0003-use-libdwarf-0.2.patch
    ./patches/0004-use-libdwarf-0.3.patch
    ./patches/0005-use-libdwarf-0.4-or-later.patch

    # https://github.com/frida/frida-gum/issues/713
    ./patches/0006-fix-loading-unicode-strings.patch
    ./patches/0007-fix-codegen-for-missing-sourcemap.patch
  ];

  # capture_output=False: show output of npm
  postPatch = ''
    patchShebangs .
    substituteInPlace bindings/gumjs/generate-runtime.py \
      --replace 'capture_output=True' 'capture_output=False' \
      --replace \
        'frida_compile = output_dir / "node_modules" / ".bin" / make_script_filename("frida-compile")' \
        'frida_compile = Path("${nodePackages.frida-compile}/bin/frida-compile")' \

  '';

  nativeBuildInputs = [
    meson
  ];

  mesonFlags = []
    ++ lib.optionals enableGumjs [
      "-Dgumjs=enabled"
      "-Dquickjs=disabled"
      "-Dv8=enabled"
    ]
    ++ lib.optionals enableGumpp [
      "-Dgumpp=enabled"
    ]
  ;

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
    # FIXME Run-time dependency gioopenssl found: NO (tried pkgconfig and cmake)
    # https://gitlab.gnome.org/GNOME/glib-networking/-/issues/206
    #glib-networking # gioopenssl
    frida-glib-networking # gioopenssl
  ] ++ lib.optionals enableGumjs [
    frida-v8
    json-glib
    frida-tinycc
    sqlite
    libsoup_3
    python3 # generate-bindings.py
  ];

  propagatedBuildInputs = [
    capstone_5
  ];

  meta = with lib; {
    description = "instrumentation and introspection library";
    homepage = "https://github.com/frida/frida-gum";
    license = licenses.wxWindows;
    maintainers = with maintainers; [ milahu ];
    platforms = platforms.unix;
  };
}
