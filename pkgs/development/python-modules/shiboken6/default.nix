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

    #./milahu-debug.patch
  ];

  postPatch = ''
    cp ${./compilersupport.cpp} sources/shiboken6/ApiExtractor/clangparser/compilersupport.cpp
    cd sources/${pname}
  '';

  #CLANG_INSTALL_DIR = llvmPackages.libclang.out;
  CLANG_INSTALL_DIR = "${llvmPackages.libclang.lib}:${llvmPackages.libcxx.dev}"; # /lib/clang/9.0.1/include/

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    llvmPackages.libllvm
    llvmPackages.clang-unwrapped
    llvmPackages.libclang # ${llvmPackages_9.libclang.lib}/lib/clang/9.0.1/include
    llvmPackages.libcxx # include <type_traits> -> ${llvmPackages_9.libcxx.dev}/include/c++/v1/type_traits
    # /nix/store/vdfr889lwm84xzgabqhdnm9vwc0xrwy1-libcxx-9.0.1-dev/include/c++/v1/type_traits
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
