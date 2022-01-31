{ buildPythonPackage
, python
, fetchurl
, lib
, stdenv
, pyside6
, cmake
, qt6
, llvmPackages_9 # https://bugreports.qt.io/browse/QTBUG-100344
}:

# sphinx-build - not found! doc target disabled

let llvmPackages = llvmPackages_9; in

stdenv.mkDerivation rec {
  pname = "shiboken6";

  inherit (pyside6) version src;

  patches = [
    #./nix_compile_cflags.patch
    # https://bugreports.qt.io/browse/PYSIDE-787
    # sources/shiboken2/ApiExtractor/clangparser/compilersupport.cpp

    ./milahu-debug.patch
  ];

  postPatch = ''
    cd sources/${pname}
  '';

  #CLANG_INSTALL_DIR = llvmPackages.libclang.out;
  CLANG_INSTALL_DIR = llvmPackages.libclang.lib; # /lib/clang/*/include/

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    llvmPackages.libllvm
    llvmPackages.clang-unwrapped
    llvmPackages.libclang # /lib/clang
    llvmPackages.libcxx # include <type_traits>
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
