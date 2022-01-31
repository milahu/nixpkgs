{ buildPythonPackage
, python
, pythonPackages
, fetchurl
, lib
, stdenv
, cmake
, ninja
, qt6
, shiboken6
, llvmPackages_9
, llvmPackages_13
}:

let
  #llvmPackages = llvmPackages_9;
  llvmPackages = llvmPackages_13;
  sha256OfQtVersion = {
    pyside6 = {
      "6.2.0" = "/tIQtmISmVUzLSYJqQC1uGQxMBNORoI3GyapumB0DQE=";
      "6.2.2" = "cKdMfHyeWvRsrlsZQ7w5oTmcQzKzQtLEgQOhz+mYkag=";
    };
    shiboken6 = {
      "6.2.0" = "3OO0NNXRvlC4kgeZZHu7I0bf2TMb+SJCUSgIUCAJfLg=";
      "6.2.2" = "HPyU53RhmRr/c+SlbPp1JDKfHVl00Jx+ecwsE6b+eR8=";
    };
  };
in

stdenv.mkDerivation rec {
  pname = "pyside6";
  version = "6.2.2";

  src = fetchurl {
    url = "https://download.qt.io/official_releases/QtForPython/pyside6/PySide6-${version}-src/pyside-setup-opensource-src-${version}.tar.xz";
    sha256 = sha256OfQtVersion.pyside6.${version};
  };

  /*
  shibokenWhl = fetchurl {
    url = "https://download.qt.io/official_releases/QtForPython/pyside6/shiboken6-${version}-${version}-cp36.cp37.cp38.cp39.cp310-abi3-manylinux1_x86_64.whl";
    sha256 = sha256OfQtVersion.shiboken6.${version};
  };
  */

  patches = [
    ./dont_ignore_optional_modules.patch
    # a: optional module X skipped
    # b: optional module X found
  ];

  postPatch = ''
    cd sources/${pname}
  '';

  #CLANG_INSTALL_DIR = llvmPackages.libclang.out;
  #LLVM_INSTALL_DIR = llvmPackages.libclang.lib;
  #CLANG_INSTALL_DIR = llvmPackages.libclang.lib; # /lib/clang

  cmakeFlags = [
    "-DBUILD_TESTS=OFF"
    #"-DPYTHON_EXECUTABLE=${python.interpreter}"
  ];

  # clang 9:
  # /nix/store/0kb2vf3qnvd0cccgn6g98w4lyy7kadh7-qtbase-6.2.2-dev/include/QtCore/qglobal.h:45:12: fatal: 'type_traits' file not found
  # #ifdef __cplusplus
  # #  include <type_traits>
  # -> fails to include libcxx header

  nativeBuildInputs = [ cmake ninja qt6.qmake python ];

  buildInputs = [
    llvmPackages.libllvm
    llvmPackages.clang-unwrapped
    #llvmPackages.libclang.lib # /lib/clang
    llvmPackages.libclang # /lib/clang
    llvmPackages.libcxx.dev # include <type_traits>
    qt6.full
  ] ++ (with pythonPackages; [
    packaging
    numpy
  ]);

  propagatedBuildInputs = [ shiboken6 ];

  dontWrapQtApps = true;

  meta = with lib; {
    description = "LGPL-licensed Python bindings for Qt";
    license = licenses.lgpl21;
    homepage = "https://wiki.qt.io/Qt_for_Python";
    maintainers = with maintainers; [ gebner ];
  };
}
