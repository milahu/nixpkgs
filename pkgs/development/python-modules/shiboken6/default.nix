{ buildPythonPackage
, python
, fetchurl
, lib
, stdenv # gcc
, pyside6
, cmake
, qt6
, llvmPackages_13
, llvmPackages_10 # shiboken6/doc/gettingstarted.rst: libclang: recommended: version 10 for 6.0+.
}:

# sphinx-build - not found! doc target disabled

let
  llvmPackages = llvmPackages_13;
  #llvmPackages = llvmPackages_10;
  stdenv = llvmPackages.stdenv;
in

stdenv.mkDerivation rec {
  pname = "shiboken6";

  inherit (pyside6) version src;

  patches = [
    ./nix_compile_cflags.patch
  ];

  postPatch = ''
    cd sources/${pname}
  '';

  #QT_LOGGING_RULES = "*.debug=true"; # debug

  CLANG_INSTALL_DIR = llvmPackages.libclang.lib; # /lib/clang/*/include/

  nativeBuildInputs = [ cmake ];

  #buildInputs = [
  propagatedBuildInputs = [
    llvmPackages.libclang # ClangConfig.cmake
    llvmPackages.libllvm # LLVMConfig.cmake
    python
    qt6.qtbase
  ];

  cmakeFlags = [
    "-DBUILD_TESTS=OFF"
  ];

  dontWrapQtApps = true;

  postInstall = ''
    rm $out/bin/shiboken_tool.py
  '';

  meta = with lib; {
    description = "Generator for the pyside6 Qt bindings";
    license = with licenses; [ gpl2 lgpl21 ];
    homepage = "https://wiki.qt.io/Qt_for_Python";
    maintainers = with maintainers; [ gebner ];
    broken = stdenv.isDarwin;
  };
}
