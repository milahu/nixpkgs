{ stdenv
, lib
, fetchFromGitHub
, qtbase
, qtsvg
, qttools
, cmake
, wrapQtAppsHook
}:

#let inherit (lib) getDev; in

stdenv.mkDerivation rec {
  pname = "qt6ct";
  version = "2021-12-22";

  src = fetchFromGitHub {
    owner = "trialuser02";
    repo = pname;
    rev = "e41923da5723e310310f183dd28dee64293e00ae";
    sha256 = "1Pclif3CDaDXun0OrWDAQPNTACO9nXu5eNm3AyyDSGE=";
  };

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
    qttools
  ];

  buildInputs = [
    qtbase
    #qtsvg
  ];

  # find bin/qtpaths
  # not working
  preConfigure = ''
    export PATH=$PATH:${qtbase.dev}/bin
    stat ${qtbase.dev}/bin/qtpaths
  '';

  # TODO debug cmake.
  # qtbase-dev/lib/cmake -> wrong location for $out/bin/qtpaths?
  cmakeFlags = [
    "--trace-expand" # debug cmake
  ];

/*
  qmakeFlags = [
    "LRELEASE_EXECUTABLE=${getDev qttools}/bin/lrelease"
    "PLUGINDIR=${placeholder "out"}/${qtbase.qtPluginPrefix}"
  ];
*/

  meta = with lib; {
    description = "Qt6 Configuration Tool";
    homepage = "https://github.com/trialuser02/qt6ct";
    platforms = platforms.linux;
    license = licenses.bsd2;
    maintainers = with maintainers; [ milahu ];
  };
}
