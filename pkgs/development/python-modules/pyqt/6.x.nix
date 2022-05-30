{ lib
, buildPythonPackage
, isPy27
, fetchPypi
, pkg-config
, dbus
, lndir
, dbus-python
, sip-pyqt6
, pyqt6_sip
, pyqt6-builder
, qmake2cmake
, cmake
, qt6Packages
, withConnectivity ? false
, withMultimedia ? false
, withWebSockets ? false
, withLocation ? false
}:

buildPythonPackage rec {
  pname = "PyQt6";
  version = "6.3.0";
  format = "pyproject";

  disabled = isPy27;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-T9hdyxXqTnNLbk4hb+mmJGd5dh7a8s98DM4aIwOo0xs=";
  };

  outputs = [ "out" "dev" ];

  # debug qmake2cmake
  #QMAKE2CMAKE_DEBUG_DUMP_FILES = "1"; # *.pro CMakeLists.txt (TODO: cmake_install.cmake)
  #PYQT_BUILDER_DEBUG_DUMP_MAKE_FILES = "1"; # Makefile
  #SIP_DEBUG_DUMP_FILES = "1"; # *.cpp *.h

  dontWrapQtApps = true;

  nativeBuildInputs = with qt6Packages; [
    pkg-config
    lndir
    sip-pyqt6
    qtbase
    qmake2cmake
    cmake
    qtsvg
    qtdeclarative
    qtwebchannel
  ]
    ++ lib.optional withConnectivity qtconnectivity
    ++ lib.optional withMultimedia qtmultimedia
    ++ lib.optional withWebSockets qtwebsockets
    ++ lib.optional withLocation qtpositioning;

  buildInputs = with qt6Packages; [
    dbus
    qtbase
    qtsvg
    qtdeclarative
    pyqt6-builder
  ]
    ++ lib.optional withConnectivity qtconnectivity
    ++ lib.optional withWebSockets qtwebsockets
    ++ lib.optional withLocation qtpositioning;

  propagatedBuildInputs = [
    dbus-python
    pyqt6_sip
  ];

  patches = [
    ./pyqt6-fix-find-dbus-python.patch
  ];

  passthru = {
    inherit sip-pyqt6 pyqt6_sip;
    multimediaEnabled = withMultimedia;
    WebSocketsEnabled = withWebSockets;
  };

  # help sip to import /build/PyQt6-6.3.0/project.py
  # to enable parallel configure + codegen
  enableParallelBuilding = true;
  configurePhase = ''
    export PYTHONPATH="$PWD:$PYTHONPATH"
  '';

  # Checked using pythonImportsCheck
  doCheck = false;

  pythonImportsCheck = [
    "PyQt6"
    "PyQt6.QtCore"
    "PyQt6.QtQml"
    "PyQt6.QtWidgets"
    "PyQt6.QtGui"
  ]
    ++ lib.optional withWebSockets "PyQt6.QtWebSockets"
    ++ lib.optional withMultimedia "PyQt6.QtMultimedia"
    ++ lib.optional withConnectivity "PyQt6.QtConnectivity"
    ++ lib.optional withLocation "PyQt6.QtPositioning";

  meta = with lib; {
    description = "Python bindings for Qt6";
    homepage    = "https://riverbankcomputing.com/";
    license     = licenses.gpl3Only;
    platforms   = platforms.mesaPlatforms;
    maintainers = with maintainers; [ nrdxp milahu ];
  };
}
