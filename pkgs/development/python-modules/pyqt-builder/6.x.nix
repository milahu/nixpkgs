{ lib
, fetchPypi
, buildPythonPackage
, packaging
, sip-pyqt6
}:

buildPythonPackage rec {
  pname = "pyqt6-builder";
  version = "1.12.2";

  src = fetchPypi {
    pname = "PyQt-builder";
    inherit version;
    sha256 = "f62bb688d70e0afd88c413a8d994bda824e6cebd12b612902d1945c5a67edcd7";
  };

  patches = [
    ./0001-use-cmake-instead-of-qmake.patch
    ./0002-debug-allow-to-dump-Makefile.patch
    ./0003-wrap-string-in-quotes.patch
    ./0004-find-exe-with-_app-suffix.patch
    ./0005-nix-use-NIX_BUILD_CORES-to-build-faster-by-default.patch
    ./0006-nix-use-cmakeFlags.patch
    ./0007-nix-use-makeFlags.patch
  ];

  propagatedBuildInputs = [ packaging sip-pyqt6 ];

  pythonImportsCheck = [ "pyqtbuild" ];

  # There aren't tests
  doCheck = false;

  meta = with lib; {
    description = "PEP 517 compliant build system for PyQt";
    homepage = "https://pypi.org/project/PyQt-builder/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
