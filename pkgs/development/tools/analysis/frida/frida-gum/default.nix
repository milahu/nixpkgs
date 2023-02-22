{ lib
, stdenv
, stdenvNoCC
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
, frida-quickjs
, frida-compile
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
, libffi
# TODO is this actually optional? seems like these are required for frida-core, frida-python, frida-tools
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
  ];

  # capture_output=False: show output of npm
  postPatch = ''
    patchShebangs .
    ${if enableGumjs then ''
    echo javascript bindings are enabled. patching frida-compile to ${frida-compile.nodeDependencies}/lib/node_modules/.bin/frida-compile
    substituteInPlace bindings/gumjs/generate-runtime.py \
    --replace 'capture_output=True' 'capture_output=False' \
    --replace '
        if not frida_compile.exists():
            pkg_files = [output_dir / "package.json", output_dir / "package-lock.json"]
    ' '
        if not frida_compile.exists():
            raise Exception(f"frida-compile not found in {frida_compile}")
    '

    # node_modules must be in this path
    # frida-compile does not work as global install
    # https://github.com/frida/frida-compile/issues/63
    mkdir -p build/bindings/gumjs
    ln -sr ${frida-compile.nodeDependencies}/lib/node_modules build/bindings/gumjs/node_modules
    '' else ""}
  '';

  nativeBuildInputs = [
    meson
    pkg-config
    cmake
    ninja
  ];

  # TODO disable
  mesonBuildType = "debug";

  mesonFlags = [
      # based on github CI of https://github.com/frida/frida
      "-Ddefault_library=static"
      "-Doptimization=s"
      "-Db_ndebug=true"
      #"-Djailbreak=auto"
      "-Ddatabase=enabled"
      #"-Dfrida_objc_bridge=auto"
      #"-Dfrida_swift_bridge=auto"
      #"-Dfrida_java_bridge=auto"
      "-Dtests=enabled"
      #"-Dtests=disabled"
      # FIXME tests break
      # blame "-Dquickjs=disabled"?
      # undefined reference to gum_quick_script_backend_get_type
      # https://github.com/frida/frida-gum/issues/723
    ]
    ++ lib.optionals enableGumjs [
      "-Dgumjs=enabled"
      #"-Dquickjs=enabled"
      #"-Dquickjs=disabled"
      #"-Dv8=enabled"
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
    frida-quickjs
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
    frida-quickjs
  ];

  meta = with lib; {
    description = "instrumentation and introspection library";
    homepage = "https://github.com/frida/frida-gum";
    license = licenses.wxWindows;
    maintainers = with maintainers; [ milahu ];
    platforms = platforms.unix;
  };
}
