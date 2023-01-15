/*
  FIXME

  -- The following packages have not been found:

  * Qt6QmlCompilerPlusPrivate
  * litehtml
  * Qt6WebEngineWidgets
  * LibRustcDemangle, Demangling for Rust symbols, written in Rust., <https://github.com/alexcrichton/rustc-demangle>
    Demangling of Rust symbols

  -- The following features have been disabled:

  * Build documentation
  * Build online documentation
  * Build tests
  * Build with sanitize, SANITIZE_FLAGS=''
  * Build with Crashpad
  * Library Nanotrace
  * Build Qbs
  * Native WebKit help viewer, with CONDITION FWWebKit AND FWAppKit AND Qt5_VERSION VERSION_LESS 6.0.0
  * QtWebEngine help viewer, with CONDITION BUILD_HELPVIEWERBACKEND_QTWEBENGINE AND TARGET Qt5::WebEngineWidgets
  * multilanguage-support in qml2puppet, with CONDITION TARGET QtCreator::multilanguage-support
  * Include developer documentation
*/

{ stdenv, lib, fetchurl, fetchgit, fetchpatch
, cmake, qtbase, qt5compat, qtdeclarative, qtquick3d, qtquicktimeline
, qtserialport, qtsvg, qttools, wrapQtAppsHook
#, qtwebengine
, llvmPackages, elfutils, rustc-demangle, perf, pkg-config
, withDocumentation ? false, withClangPlugins ? true
}:

let

/*

TODO build only bin/clang-format with patched clang source

https://code.qt.io/cgit/qt-creator/qt-creator.git/tree/README.md

## Getting LLVM/Clang for the Clang Code Model

The Clang code model uses `Clangd` and the ClangFormat plugin depends on the
LLVM/Clang libraries. The currently recommended LLVM/Clang version is 14.0.

### Clang-Format

The ClangFormat plugin depends on the additional patch

    https://code.qt.io/cgit/clang/llvm-project.git/commit/?h=release_130-based&id=42879d1f355fde391ef46b96a659afeb4ad7814a

While the plugin builds without it, it might not be fully functional.

Note that the plugin is disabled by default.



> The ClangFormat plugin depends on the additional patch

upstream PR:
https://reviews.llvm.org/D53072

history of the patched file:
https://code.qt.io/cgit/clang/llvm-project.git/log/clang/include/clang/Format/Format.h

*/

  # Fetch clang from qt vendor, this contains submodules like this:
  # clang<-clang-tools-extra<-clazy.
  clang-unwrapped-qt = llvmPackages.clang-unwrapped.overrideAttrs (oldAttrs: {
    # file RPATH_CHANGE could not write new RPATH
    cmakeFlags = [ "-DCMAKE_SKIP_BUILD_RPATH=ON" ];
    src = fetchgit {
      url = "https://code.qt.io/clang/clang.git";
      rev = "c12b012bb7465299490cf93c2ae90499a5c417d5";
      sha256 = "0mgmnazgr19hnd03xcrv7d932j6dpz88nhhx008b0lv4bah9mqm0";
    };
    unpackPhase = "";
  });
in

with lib;

stdenv.mkDerivation rec {
  pname = "qtcreator";
  version = "9.0.1";
  baseVersion = builtins.concatStringsSep "." (lib.take 2 (builtins.splitVersion version));
  src = fetchurl {
    url = "https://download.qt.io/official_releases/${pname}/${baseVersion}/${version}/qt-creator-opensource-src-${version}.tar.xz";
    sha256 = "sha256:4e4e881b2635bac07e785c9e889ab9a253ad47a00074e260cbccdb3c0aef189f";
  };

  buildInputs = [
      qtbase qt5compat
      #qtdeclarative qtquick3d qtquicktimeline qtserialport
      #qtsvg qttools elfutils.dev rustc-demangle
      #qtwebengine
    ] ++
    optionals withClangPlugins [
      /*
      llvmPackages.libclang
      #llvmPackages.clang-unwrapped
      clang-unwrapped-qt
      llvmPackages.llvm
      */
    ];

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapQtAppsHook
  ];

  doCheck = true;

/*
  postPatch = ''
    stat src/libs/extensionsystem/pluginmanager.cpp
    cp ${./src/qt-creator-opensource-src-8.0.1/src/libs/extensionsystem/pluginmanager.cpp} src/libs/extensionsystem/pluginmanager.cpp
    cp ${./src/qt-creator-opensource-src-8.0.1/src/plugins/welcome/welcomeplugin.cpp} src/plugins/welcome/welcomeplugin.cpp
  '';
*/

  #buildFlags = optional withDocumentation "docs";

  cmakeBuildType = "Debug";

  #installFlags = [ "INSTALL_ROOT=$(out)" ] ++ optional withDocumentation "install_docs";

  #qtWrapperArgs = [ "--set-default PERFPROFILER_PARSER_FILEPATH ${lib.getBin perf}/bin" ];

  preConfigure = ''
    substituteInPlace src/plugins/plugins.pro \
      --replace '$$[QT_INSTALL_QML]/QtQuick/Controls' '${qtquickcontrols}/${qtbase.qtQmlPrefix}/QtQuick/Controls'
    substituteInPlace src/libs/libs.pro \
      --replace '$$[QT_INSTALL_QML]/QtQuick/Controls' '${qtquickcontrols}/${qtbase.qtQmlPrefix}/QtQuick/Controls'
    '' + lib.optionalString withClangPlugins ''
    # Fix paths for llvm/clang includes directories.
    substituteInPlace src/shared/clang/clang_defines.pri \
      --replace '$$clean_path($${LLVM_LIBDIR}/clang/$${LLVM_VERSION}/include)' '${clang-unwrapped-qt}/lib/clang/8.0.0/include' \
      --replace '$$clean_path($${LLVM_BINDIR})' '${clang-unwrapped-qt}/bin'

    # Fix paths to libclang library.
    substituteInPlace src/shared/clang/clang_installation.pri \
      --replace 'LIBCLANG_LIBS = -L$${LLVM_LIBDIR}' 'LIBCLANG_LIBS = -L${llvmPackages.libclang.lib}/lib' \
      --replace 'LIBCLANG_LIBS += $${CLANG_LIB}' 'LIBCLANG_LIBS += -lclang' \
      --replace 'LIBTOOLING_LIBS = -L$${LLVM_LIBDIR}' 'LIBTOOLING_LIBS = -L${clang-unwrapped-qt}/lib' \
      --replace 'LLVM_CXXFLAGS ~= s,-gsplit-dwarf,' '${lib.concatStringsSep "\n" ["LLVM_CXXFLAGS ~= s,-gsplit-dwarf," "    LLVM_CXXFLAGS += -fno-rtti"]}'
  '';

  preBuild = lib.optionalString withDocumentation ''
    ln -s ${lib.getLib qtbase}/$qtDocPrefix $NIX_QT5_TMP/share
  '';

  postInstall = ''
    substituteInPlace $out/share/applications/org.qt-project.qtcreator.desktop \
      --replace "Exec=qtcreator" "Exec=$out/bin/qtcreator"
  '';

  meta = {
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
