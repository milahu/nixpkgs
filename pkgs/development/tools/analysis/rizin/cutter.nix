{ fetchFromGitHub, lib, mkDerivation
# nativeBuildInputs
, qmake, pkg-config, cmake
# Qt
, qtbase, qtsvg, qtwebengine, qttools
# buildInputs
, rizin
, python3
, wrapQtAppsHook
}:

mkDerivation rec {
  pname = "cutter";
  version = "2.1.2-unstable-2023-02-15";

  src = fetchFromGitHub {
    owner = "rizinorg";
    repo = "cutter";
    rev = "235b75f3ed1e2f1310bef889256188579777eced";
    sha256 = "sha256-Z9pgbQBFboTE37M8nbq8JclwHXbBuV0xCW8S9SSNGew=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake qmake pkg-config python3 wrapQtAppsHook ];
  propagatedBuildInputs = [ python3.pkgs.pyside2 ];
  buildInputs = [ qtbase qttools qtsvg qtwebengine rizin python3 ];

  cmakeFlags = [
    "-DCUTTER_USE_BUNDLED_RIZIN=OFF"
    "-DCUTTER_ENABLE_PYTHON=ON"
    "-DCUTTER_ENABLE_PYTHON_BINDINGS=ON"
  ];

  preBuild = ''
    qtWrapperArgs+=(--prefix PYTHONPATH : "$PYTHONPATH")
  '';

  meta = with lib; {
    description = "Free and Open Source Reverse Engineering Platform powered by rizin";
    homepage = src.meta.homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ mic92 dtzWill ];
  };
}
