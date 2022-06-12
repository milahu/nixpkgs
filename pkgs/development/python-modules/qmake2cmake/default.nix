/*
nix-shell -E 'with import <nixpkgs> { }; python3Packages.callPackage ./default.nix { }'
*/

{ lib
, fetchPypi
, fetchFromGitHub
, buildPythonPackage
, packaging
, portalocker
, sympy
, networkx
, xdg
, pytest
}:

buildPythonPackage rec {
  pname = "qmake2cmake";
  version = "1.0.1-unstable-2022-06-24";

  src = fetchFromGitHub {
    # https://github.com/milahu/qmake2cmake/tree/fix-for-pyqt-builder
    owner = "milahu";
    repo = "qmake2cmake";
    rev = "611a3738860b1997d279f077814b3c59949f50fb";
    sha256 = "sha256-8J+5U+hyAy7Po2eGpaq9qEe8omgRxv5dpUNFFq+YbLo=";
  };

  /*
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-5h5891RDGgisv5VJUBSepbZq/3c4CnsPdTk2iJ3rKmg=";
  };
  */

  propagatedBuildInputs = [
    packaging
    portalocker
    sympy
    networkx
    xdg
  ];

  checkInputs = [
    pytest
  ];

  pythonImportsCheck = [ "qmake2cmake" ];

    meta = with lib; {
      description = "Tool to convert qmake .pro files to CMakeLists.txt	";
      homepage = "https://code.qt.io/cgit/qt/qmake2cmake.git/";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [ milahu ];
    };
}
