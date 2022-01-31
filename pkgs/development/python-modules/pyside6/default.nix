{ buildPythonPackage
, python
, fetchurl
, lib
, stdenv
, cmake
, ninja
, qt6
, shiboken6
}:

let
  sha256OfQtVersion = {
    "6.2.0" = "/tIQtmISmVUzLSYJqQC1uGQxMBNORoI3GyapumB0DQE=";
    "6.2.2" = "HPyU53RhmRr/c+SlbPp1JDKfHVl00Jx+ecwsE6b+eR8=";
  };
in

stdenv.mkDerivation rec {
  pname = "pyside6";
  version = "6.2.2";

  src = fetchurl {
    url = "https://download.qt.io/official_releases/QtForPython/pyside6/PySide6-${version}-src/pyside-setup-opensource-src-${version}.tar.xz";
    sha256 = sha256OfQtVersion.${version};
  };

  srcShiboken = fetchurl {
    url = "https://download.qt.io/official_releases/QtForPython/pyside6/shiboken6-${version}-${version}-cp36.cp37.cp38.cp39.cp310-abi3-manylinux1_x86_64.whl";
    sha256 = "3OO0NNXRvlC4kgeZZHu7I0bf2TMb+SJCUSgIUCAJfLg=";
  };

  patches = [
    #./dont_ignore_optional_modules.patch
  ];

  postPatch = ''
    echo postPatch
    ls
    #ls sources
    #stat ${srcShiboken}

    ls
    find . -name setup.py

    #cd sources/${pname}
  '';

  configurePhase = ":";

  buildPhase = ''
    ${python.interpreter} setup.py build
  '';

  installPhase = ''
    ${python.interpreter} setup.py install
  '';

  cmakeFlags = [
    "-DBUILD_TESTS=OFF"
    "-DPYTHON_EXECUTABLE=${python.interpreter}"
  ];

  nativeBuildInputs = [ cmake ninja qt6.qmake python ];
  buildInputs = with qt6; [
    qtbase
    qtmultimedia
    qttools
    # qtlocation
    qtwebsockets
    qtwebengine
    qtwebchannel
    qtcharts
    qtsensors
    qtsvg
  ];
  propagatedBuildInputs = [ shiboken6 ];

  dontWrapQtApps = true;

  meta = with lib; {
    description = "LGPL-licensed Python bindings for Qt";
    license = licenses.lgpl21;
    homepage = "https://wiki.qt.io/Qt_for_Python";
    maintainers = with maintainers; [ gebner ];
  };
}
