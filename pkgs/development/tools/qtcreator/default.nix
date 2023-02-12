{ stdenv
, lib
, fetchurl
, fetchgit
, fetchpatch
, cmake
, qtbase
, qt5compat
, qtdeclarative
, qtquick3d
, qtquicktimeline
#, qtquickcontrols # qt5
, qtserialport
, qtsvg
, qttools
, wrapQtAppsHook
  #, qtwebengine
, llvmPackages # "The currently recommended LLVM/Clang version is 14.0."
, elfutils
, rustc-demangle
, perf
, pkg-config
, withDocumentation ? false
, withClangPlugins ? true
, symlinkJoin
, fixDarwinDylibNames
, callPackage

# trying build without ninja
, python3
}:

let

  /*
    TODO plugins? https://code.qt.io/cgit/ -> Ctrl-F qt-creator

    # TODO clazy?
    # https://code.qt.io/cgit/clang/clazy.git/
    # Fetch clang from qt vendor, this contains submodules like this:
    # clang<-clang-tools-extra<-clazy.
    clang-unwrapped = llvmPackages.clang-unwrapped.overrideAttrs (oldAttrs: {
    # file RPATH_CHANGE could not write new RPATH
    cmakeFlags = [ "-DCMAKE_SKIP_BUILD_RPATH=ON" ];
    src = fetchgit {
      url = "https://code.qt.io/clang/clang.git";
      rev = "c12b012bb7465299490cf93c2ae90499a5c417d5";
      sha256 = "0mgmnazgr19hnd03xcrv7d932j6dpz88nhhx008b0lv4bah9mqm0";
    };
    unpackPhase = "";
    });
  */

  qtcreator-clang-format = callPackage ./qtcreator-clang-format {
    inherit llvmPackages;
  };
in

stdenv.mkDerivation rec {
  pname = "qtcreator";
  version = "9.0.1";
  baseVersion = builtins.concatStringsSep "." (lib.take 2 (builtins.splitVersion version));
  src = fetchurl {
    url = "https://download.qt.io/official_releases/${pname}/${baseVersion}/${version}/qt-creator-opensource-src-${version}.tar.xz";
    sha256 = "sha256:4e4e881b2635bac07e785c9e889ab9a253ad47a00074e260cbccdb3c0aef189f";
  };

  buildInputs = [
    qtbase
    qt5compat
    #qtdeclarative qtquick3d qtquicktimeline qtserialport
    #qtsvg qttools elfutils.dev rustc-demangle
    #qtwebengine
  ]
  ++ lib.optionals withClangPlugins [
    llvmPackages.clang-unwrapped
    llvmPackages.libclang
    llvmPackages.llvm
    qtcreator-clang-format
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapQtAppsHook
  ];

  doCheck = true;

  postPatch = ''
  '' + lib.optionalString withClangPlugins ''
    substituteInPlace src/plugins/beautifier/clangformat/clangformatsettings.cpp \
      --replace \
        'setCommand("clang-format");' \
        'setCommand("${qtcreator-clang-format}/bin/clang-format");'
  '';

  cmakeFlags = [
    # workaround for missing CMAKE_INSTALL_DATAROOTDIR
    # in pkgs/development/tools/build-managers/cmake/setup-hook.sh
    "-DCMAKE_INSTALL_DATAROOTDIR=${placeholder "out"}/share"
  ];

  #buildFlags = optional withDocumentation "docs";

  cmakeBuildType = "Debug";

  #installFlags = [ "INSTALL_ROOT=$(out)" ] ++ optional withDocumentation "install_docs";

  #qtWrapperArgs = [ "--set-default PERFPROFILER_PARSER_FILEPATH ${lib.getBin perf}/bin" ];

/* no such file
  preConfigure = ''
    # Fix paths for llvm/clang includes directories.
    substituteInPlace src/shared/clang/clang_defines.pri \
      --replace '$$clean_path($${LLVM_LIBDIR}/clang/$${LLVM_VERSION}/include)' '${llvmPackages.clang-unwrapped}/lib/clang/8.0.0/include' \
      --replace '$$clean_path($${LLVM_BINDIR})' '${llvmPackages.clang-unwrapped}/bin'
  '' + lib.optionalString withClangPlugins ''
    # Fix paths to libclang library.
    substituteInPlace src/shared/clang/clang_installation.pri \
      --replace 'LIBCLANG_LIBS = -L$${LLVM_LIBDIR}' 'LIBCLANG_LIBS = -L${llvmPackages.libclang.lib}/lib' \
      --replace 'LIBCLANG_LIBS += $${CLANG_LIB}' 'LIBCLANG_LIBS += -lclang' \
      --replace 'LIBTOOLING_LIBS = -L$${LLVM_LIBDIR}' 'LIBTOOLING_LIBS = -L${llvmPackages.clang-unwrapped}/lib' \
      --replace 'LLVM_CXXFLAGS ~= s,-gsplit-dwarf,' '${lib.concatStringsSep "\n" ["LLVM_CXXFLAGS ~= s,-gsplit-dwarf," "    LLVM_CXXFLAGS += -fno-rtti"]}'
  '';
*/

/*
  # TODO qt6? remove?
  preBuild = lib.optionalString withDocumentation ''
    ln -s ${lib.getLib qtbase}/$qtDocPrefix $NIX_QT5_TMP/share
  '';
*/

  postInstall = ''
    substituteInPlace $out/share/applications/org.qt-project.qtcreator.desktop \
      --replace "Exec=qtcreator" "Exec=$out/bin/qtcreator"
  '';

  passthru = {
    inherit qtcreator-clang-format;
  };

  meta = with lib; {
    description = "Cross-platform IDE tailored to the needs of Qt developers";
    longDescription = ''
      Qt Creator is a cross-platform IDE (integrated development environment)
      tailored to the needs of Qt developers. It includes features such as an
      advanced code editor, a visual debugger and a GUI designer.
    '';
    homepage = "https://wiki.qt.io/Qt_Creator";
    license = "LGPL";
    maintainers = [ lib.maintainers.akaWolf ];
    platforms = [ "i686-linux" "x86_64-linux" "aarch64-linux" "armv7l-linux" ];
  };
}
