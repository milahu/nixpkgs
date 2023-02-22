/*
FHS env for debugging the various frida packages

nix-shell . -A frida.env
git clone --depth=1 --recurse-submodules --shallow-submodules https://github.com/frida/frida
make -C frida/ gum-linux-x86_64
make -C frida/ core-linux-x86_64

FIXME fatal error: gnu/stubs-32.h: No such file or directory
*/

{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, meson
, pkg-config
, cmake
, ninja
, glib
#, glib
, glib-networking
, tinycc
, frida-v8
, frida-quickjs
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
, git
, which
, perl
, nodejs
, frida-gum
, buildFHSUserEnv
, glibc_multi
, frida-libiconv
}:

let
  srcs = builtins.fromJSON (builtins.readFile ../srcs.json);
in

stdenv.mkDerivation rec {
  pname = "frida";
  inherit (srcs) version;
  src = fetchFromGitHub srcs.paths.${pname}.github;

/*
overkill
    ${lib.toShellVar "patches" frida-gum.patches}
*/

  patchPhase = ''
    runHook prePatch
    pushd frida-gum
    for patch in ${builtins.concatStringsSep " " frida-gum.patches}; do
      echo frida-gum: applying patch $patch
      patch -p1 < $patch
    done
    echo frida-gum: patching bindings/gumjs/generate-runtime.py
    substituteInPlace bindings/gumjs/generate-runtime.py \
      --replace 'capture_output=True' 'capture_output=False' \
      --replace \
        'frida_compile = output_dir / "node_modules" / ".bin" / make_script_filename("frida-compile")' \
        'frida_compile = Path("${nodePackages.frida-compile}/bin/frida-compile")'
    popd

    substituteInPlace releng/detect-variant.sh \
      --replace 'ldd /bin/ls' 'ldd $(which ls)'

    substituteInPlace releng/setup-env.sh \
    --replace '
      echo "Please install curl or wget: required for downloading prebuilt dependencies." > /dev/stderr
      exit 1
    ' '
      download_command="echo TODO download"
    '

    # dont install build env (toolchain)
    # NOTE: must use tabs for makefile
    substituteInPlace Makefile.linux.mk \
    --replace '
    build/$1-%/lib/pkgconfig/frida-gum-1.0.pc: build/$1-env-%.rc build/.frida-gum-submodule-stamp
    ' '
    build/$1-%/lib/pkgconfig/frida-gum-1.0.pc: build/.frida-gum-submodule-stamp
    ' \
    --replace '
        $$(call meson-setup-for-env,$1,$$*) \
          --prefix $$(FRIDA)/build/$1-$$* \
          --libdir $$(FRIDA)/build/$1-$$*/lib \
    ' '
        meson setup \
    '

    patchShebangs .
    runHook postPatch
  '';

  buildPhase = ''
    runHook preBuild
    make gum-linux-x86_64
    runHook postBuild
  '';

  nativeBuildInputs = [];

  # no effect. wtf?
  #makeTargets = [ "gum-linux-x86_64" ];

  /*
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
  */

  #dontConfigure = true; # force not using meson configure phase

  preBuild = ''
    # force not using hooks. WTF? hooks should ne be used of buildInputs
    # force not using meson configure phase
    export PATH=${meson}/bin:$PATH
    # force not using ninja build phase
    export PATH=${ninja}/bin:$PATH
    export PATH=${cmake}/bin:$PATH
    git init
    git add Makefile
    export HOME=$TMP
    git config --global init.defaultBranch main
    git config --global user.email nixbld@localhost
    git config --global user.name nixbld
    git commit -m init
    # disable ninja line-clearing
    export TERM=dumb
  '';

  buildInputs = [
    /*
    meson
    cmake
    ninja
    */
    pkg-config

    git
    which
    perl
    nodejs

    # undefined reference to gum_quick_script_backend_get_type
    # https://github.com/frida/frida-gum/issues/723
    # quickfix: disable tests
    glib
    #glib
    glib-networking
    capstone_5
    lzma
    libunwind
    libelf
    libdwarf
    gobject-introspection # g-ir-scanner
    glibc_multi # for glib. fix: Compiler provides no native 16-bit integer type. fatal error: gnu/stubs-32.h: No such file or directory
    # FIXME fatal error: gnu/stubs-32.h: No such file or directory
    #libiconv # wontfix: Run-time dependency libiconv found: NO (tried pkgconfig and cmake)
    frida-libiconv # for glib. libiconv with pkgconfig files
  ] ++ lib.optionals enableGumjs [
    tinycc
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
    glib # gio gio-unix
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
    tinycc # libtcc
    sqlite # sqlite3
  ];

  passthru = {
    env = (buildFHSUserEnv {
      name = "frida-env";
    targetPkgs = pkgs: (with pkgs; [

      meson
      cmake
      ninja
      pkg-config

      git
      which
      perl
      nodejs

      # undefined reference to gum_quick_script_backend_get_type
      # https://github.com/frida/frida-gum/issues/723
      # quickfix: disable tests
      glib
      #glib
      glib-networking
      capstone_5
      lzma
      libunwind
      libelf
      libdwarf
      gobject-introspection # g-ir-scanner
    ] ++ lib.optionals enableGumjs [
      tinycc
      frida-v8
      frida-quickjs
      json-glib
      sqlite
      libsoup_3
      python3 # generate-bindings.py

    ]);
    /*
    multiPkgs = pkgs: (with pkgs;
      [ udev
        alsaLib
      ]);
    */
    }).env;
  };

  meta = with lib; {
    description = "instrumentation and introspection library";
    homepage = "https://github.com/frida/frida";
    license = licenses.wxWindows;
    maintainers = with maintainers; [ milahu ];
    platforms = platforms.unix;
  };
}
