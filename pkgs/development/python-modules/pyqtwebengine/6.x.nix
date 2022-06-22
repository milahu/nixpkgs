{ lib
, pythonPackages
, pkg-config
, cmake
, qtbase
, qtwebengine
, wrapQtAppsHook
}:

# based on pkgs/development/python-modules/pyqt/6.x.nix

let
  inherit (pythonPackages) buildPythonPackage python isPy27 pyqt6 enum34 sip-pyqt6 pyqt6-builder qmake2cmake;
in buildPythonPackage rec {
  pname = "PyQt6-WebEngine";
  version = "6.3.0";
  format = "pyproject";

  disabled = isPy27;

  src = pythonPackages.fetchPypi {
    pname = "PyQt6_WebEngine";
    inherit version;
    sha256 = "sha256-qyrtvuxU8bz/hy99/CNqoPzktVzTD2CMqJtAjunoFHs=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
    --replace \
    '[tool.sip.project]' \
    '[tool.sip.project]
    sip-include-dirs = ["${pyqt6}/${python.sitePackages}/PyQt6/bindings"]'
  '';

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [
    pkg-config
    qmake2cmake
    cmake
    sip-pyqt6
    qtbase
    qtwebengine
    pyqt6-builder
  ];

  buildInputs = [
    sip-pyqt6
    qtbase
    qtwebengine
  ];

  propagatedBuildInputs = [ pyqt6 ];

  dontWrapQtApps = true;

  # Checked using pythonImportsCheck
  doCheck = false;

  pythonImportsCheck = [
    "PyQt6.QtWebEngineCore"
    "PyQt6.QtWebEngineQuick"
    "PyQt6.QtWebEngineWidgets"
  ];

  # help sip to import /build/PyQt6-6.3.0/project.py
  # to enable parallel configure + codegen
  enableParallelBuilding = true;
  configurePhase = ''
    export PYTHONPATH="$PWD:$PYTHONPATH"
  '';

  passthru = {
    inherit wrapQtAppsHook;
  };

  meta = with lib; {
    description = "Python bindings for Qt6 WebEngine";
    homepage    = "http://www.riverbankcomputing.co.uk";
    license     = licenses.gpl3;
    platforms   = lib.lists.intersectLists qtwebengine.meta.platforms platforms.mesaPlatforms;
    maintainers = with maintainers; [ nrdxp milahu ];
  };
}
