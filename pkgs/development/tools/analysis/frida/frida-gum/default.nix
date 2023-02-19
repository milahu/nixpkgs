{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, meson
, pkg-config
, cmake
, ninja
, frida-glib
#, glib
, frida-glib-networking
, frida-tinycc
, frida-v8
, capstone_5
, lzma
, gobject-introspection
, libunwind
, libelf
, libdwarf
, json-glib
, sqlite
, libsoup_3
, python3
, nodePackages
, libffi
, enableGumjs ? true # Build JavaScript bindings
, enableGumpp ? true # Build C++ bindings
}:

let
  srcs = builtins.fromJSON (builtins.readFile ../srcs.json);
in

stdenv.mkDerivation rec {
  pname = "frida-gum";
  inherit (srcs) version;
  src = fetchFromGitHub srcs.paths.${pname}.github;

  patches = [
    # make it build with latest libdwarf
    # https://github.com/frida/frida-gum/pull/711
    ./patches/0001-use-libdwarf-0.0-libdwarf-20210528.patch
    ./patches/0002-use-libdwarf-0.1.patch
    ./patches/0003-use-libdwarf-0.2.patch
    ./patches/0004-use-libdwarf-0.3.patch
    ./patches/0005-use-libdwarf-0.4-or-later.patch

    # make it build with fixed frida-tinycc https://github.com/frida/tinycc/pull/7
    # https://github.com/frida/frida-gum/pull/720
    (fetchpatch {
      url = "https://github.com/frida/frida-gum/commit/1f888c8f451c72f20c612f2b193d5ab4442c3840.patch";
      sha256 = "sha256-2AAW9rV8+4okALRcV57S4clfDGnqQ8+VsmA9RQkfxTc=";
    })
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
    pkg-config
    cmake
    ninja
  ];

  mesonFlags = [
      # based on github CI of https://github.com/frida/frida
      "-Ddefault_library=static"
      "-Doptimization=s"
      "-Db_ndebug=true"
      "-Djailbreak=auto"
      "-Ddatabase=enabled"
      "-Dfrida_objc_bridge=auto"
      "-Dfrida_swift_bridge=auto"
      "-Dfrida_java_bridge=auto"
      #"-Dtests=enabled" # FIXME tests break with frida-glib
      # undefined reference to gum_quick_script_backend_get_type
      # https://github.com/frida/frida-gum/issues/723
    ]
    ++ lib.optionals enableGumjs [
      "-Dgumjs=enabled"
      "-Dquickjs=disabled"
      "-Dv8=enabled"
    ]
    ++ lib.optionals enableGumpp [
      "-Dgumpp=enabled"
    ];

  buildInputs = [
    # undefined reference to gum_quick_script_backend_get_type
    # https://github.com/frida/frida-gum/issues/723
    # quickfix: disable tests
    frida-glib
    #glib
    frida-glib-networking
    capstone_5
    lzma
    libunwind
    libelf
    libdwarf
    gobject-introspection # g-ir-scanner
  ] ++ lib.optionals enableGumjs [
    frida-tinycc
    frida-v8
    json-glib
    sqlite
    libsoup_3
    python3 # generate-bindings.py
  ];

  propagatedBuildInputs = [
    capstone_5
    libunwind
    libelf
    libdwarf
    frida-glib # gio gio-unix
    # dont propagate glib
    # this would break frida-core:
    # undefined reference to g_thread_garbage_collect
    # undefined reference to gio_prepare_to_fork
    # undefined reference to glib_prepare_to_fork
    #glib # gio gio-unix
  ] ++ lib.optionals enableGumjs [
    frida-v8
    json-glib
    libffi
    frida-tinycc # libtcc
    sqlite # sqlite3
  ];

  meta = with lib; {
    description = "instrumentation and introspection library";
    homepage = "https://github.com/frida/frida-gum";
    license = licenses.wxWindows;
    maintainers = with maintainers; [ milahu ];
    platforms = platforms.unix;
  };
}
