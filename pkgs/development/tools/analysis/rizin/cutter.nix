{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, qmake
, pkg-config
, cmake
, qtbase
, qt5compat
, qtsvg
, qtwebengine
, qttools
, rizin
, python3
, qt6Packages
, wrapQtAppsHook
, git
}:

stdenv.mkDerivation rec {
  pname = "cutter";
  version = "2.1.2-unstable-2023-02-15";

  src = fetchFromGitHub {
    owner = "rizinorg";
    repo = "cutter";
    rev = "235b75f3ed1e2f1310bef889256188579777eced";
    sha256 = "sha256-Z9pgbQBFboTE37M8nbq8JclwHXbBuV0xCW8S9SSNGew=";
    fetchSubmodules = true;
  };

  patches = [
    # fix build with qt6 and python
    # https://github.com/rizinorg/cutter/pull/2952+
    /*

    */
    (fetchpatch {
      url = "https://github.com/rizinorg/cutter/commit/1452f5c44e2b4317d44346365611050f4da8b98d.patch";
      sha256 = "sha256-+by5rludEO19iY/5DuY9RUQs9O5JbF6tRwTX6qzu9gI=";
    })
    (fetchpatch {
      url = "https://github.com/rizinorg/cutter/commit/6e7cb58ff0b666d3bc2806e7b9408281fd2b5184.patch";
      sha256 = "sha256-GfK81s+VzZwliTRKHKNlXsXAr4fpbqZr1h+MpYfdDxU=";
    })
    (fetchpatch {
      url = "https://github.com/rizinorg/cutter/commit/3de84f1f545c0921cdc01bf364b560a83322f1f0.patch";
      sha256 = "sha256-HjiUks11oyGBMc8syaYN4xd46Axy3lTElzy4g0H7h5Y=";
    })
    (fetchpatch {
      url = "https://github.com/rizinorg/cutter/commit/06b0834bb78415504810c2670deb892f76047eff.patch";
      sha256 = "sha256-0r5eZvj+AJOC39Yy5jgM6RhXX3NyV6rl/G+DvkpP+AM=";
    })
    ./cutter-debug-prints.patch
    ./cutter-fix-RAW_RIZIN_INCLUDE_DIRS-debug.patch
    ./cutter-fix-debug-prints.patch
    ./cutter-use-rz_core_INCLUDE_DIRS-and-fix-debug-prints.patch
  ];

  #  source ${./patchphase-git-patch.sh}
  postUnpack = ''
  '';

  prePatch = ''
    ls -l src/bindings/bindings.xml*
  '';

  postPatch = ''
    if [ -e src/bindings/bindings.xml ]; then
      echo bindings.xml was not renamed to bindings.xml.in by 06b0834bb78415504810c2670deb892f76047eff.patch
      echo workaround for broken patch command in stdenv
      ls -l src/bindings/bindings.xml*
      mv -v src/bindings/bindings.xml* src/bindings/bindings.xml.in
    fi

    # build faster
    rm -rf src/translations/*

    cp -v ${./cutter-CMakeLists.txt} CMakeLists.txt
    cp -v ${./cutter-PythonManager.cpp} src/common/PythonManager.cpp
    cp -v ${./cutter-Translations.cmake} cmake/Translations.cmake
  '';

  nativeBuildInputs = [
    cmake
    qmake
    pkg-config
    python3
    wrapQtAppsHook
  ];

  propagatedBuildInputs = [
    python3.pkgs.pyside6
    rizin # runtime dep?
    #sigdb? CUTTER_ENABLE_SIGDB
    /*
option(CUTTER_PACKAGE_RZ_GHIDRA "Compile and install rz-ghidra during install step." OFF)
option(CUTTER_PACKAGE_RZ_LIBSWIFT, "Compile and install rz-libswift demangler during the install step." OFF)
option(CUTTER_PACKAGE_RZ_LIBYARA, "Compile and install rz-libyara during the install step." OFF)
option(CUTTER_PACKAGE_JSDEC "Compile and install jsdec during install step." OFF)

Rizin_INCLUDE_DIRS is not set with old rizin version
only rz_core_INCLUDE_DIRS is set
-> try new rizin version

    */
  ];

  buildInputs = [
    python3.pkgs.pyside6
    qtbase
    qt5compat
    qttools
    qtsvg
    qtwebengine
    rizin
    python3
    qt6Packages.kdeFrameworks.syntax-highlighting
  ];

  cmakeFlags = [
    "-DCUTTER_USE_BUNDLED_RIZIN=OFF"
    "-DCUTTER_ENABLE_PYTHON=ON"
    "-DCUTTER_ENABLE_PYTHON_BINDINGS=ON"
    "-DCUTTER_QT6=ON"

    #"--trace-expand"
  ];

/*
-- - Bundled rizin: OFF
-- - Python: ON
-- - Python Bindings: ON
-- - KSyntaxHighlighting: OFF (KSyntaxHighlighting not found)
-- - Graphviz: FALSE
-- - Downloads dependencies: OFF
-- - Enable Packaging: OFF
-- - Package Dependencies: OFF
-- - Package RzGhidra: OFF
-- - Package RzLibSwift:
-- - Package RzLibYara:
-- - Package JSDec: OFF
-- - QT6: ON
*/

  preBuild = ''
    qtWrapperArgs+=(--prefix PYTHONPATH : "$PYTHONPATH")
  '';

  meta = with lib; {
    description = "Free and Open Source Reverse Engineering Platform powered by rizin";
    homepage = "https://github.com/rizinorg/cutter";
    license = licenses.gpl3;
    maintainers = with maintainers; [ mic92 dtzWill ];
  };
}
