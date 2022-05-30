{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "pyqt6-sip";
  version = "13.3.1";

  src = fetchPypi {
    pname = "PyQt6_sip";
    inherit version;
    sha256 = "sha256-1inA451cz9rlZ7krp02S+RgLfFVTX4IlHxoSqQdqngE=";
  };

  # There is no test code and the check phase fails with:
  # > error: could not create 'PyQt6/sip.cpython-39-x86_64-linux-gnu.so': No such file or directory
  doCheck = false;
  pythonImportsCheck = ["PyQt6.sip"];

  meta = with lib; {
    description = "Python bindings for Qt6";
    homepage    = "https://www.riverbankcomputing.com/software/sip/";
    license     = licenses.gpl3Only;
    platforms   = platforms.mesaPlatforms;
    maintainers = with maintainers; [ nrdxp ];
  };
}
