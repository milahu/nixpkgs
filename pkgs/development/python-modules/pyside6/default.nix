{ buildPythonPackage
, python
, pythonPackages
, fetchurl
, lib
, stdenv # gcc
, cmake
, ninja
, qt6
, shiboken6
, llvmPackages_9
, llvmPackages_13
, llvmPackages_10
}:

# TODO refactor: pyside6 + shiboken6

let
  # pyside6 requires clang >= 9
  llvmPackages = llvmPackages_13;
  #llvmPackages = llvmPackages_10;

  stdenv = llvmPackages.stdenv; # gcc -> clang

  sha256OfQtVersion = {
    pyside = {
      "6.2.0" = "/tIQtmISmVUzLSYJqQC1uGQxMBNORoI3GyapumB0DQE=";
      "6.2.2" = "cKdMfHyeWvRsrlsZQ7w5oTmcQzKzQtLEgQOhz+mYkag=";
    };
    shibokenWhl = {
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
    sha256 = sha256OfQtVersion.pyside.${version};
  };

  /* TODO whl = wheel? what is this? python...?
  shibokenWhl = fetchurl {
    url = "https://download.qt.io/official_releases/QtForPython/pyside6/shiboken6-${version}-${version}-cp36.cp37.cp38.cp39.cp310-abi3-manylinux1_x86_64.whl";
    sha256 = sha256OfQtVersion.shibokenWhl.${version};
  };
  */

  patches = [
    ./dont_ignore_optional_modules.patch
  ];

  postPatch = ''
    cd sources/${pname}
  '';

  #QT_LOGGING_RULES = "*.debug=true"; # debug

  CLANG_INSTALL_DIR = llvmPackages.libclang.lib; # /lib/clang/*/include/

  cmakeFlags = [
    "-DBUILD_TESTS=OFF"
  ];

  nativeBuildInputs = [ cmake ninja qt6.qmake python ];

  buildInputs = with pythonPackages; [
    packaging
    numpy
  ];

  #ninjaFlags = [ "-j1" ]; # debug: disable parallel build

  propagatedBuildInputs = [ shiboken6 ];

  dontWrapQtApps = true;

  meta = with lib; {
    description = "LGPL-licensed Python bindings for Qt";
    license = licenses.lgpl21;
    homepage = "https://wiki.qt.io/Qt_for_Python";
    maintainers = with maintainers; [ gebner ];
  };
}
