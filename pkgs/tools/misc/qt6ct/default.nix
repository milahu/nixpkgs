{ stdenv
, lib
, fetchurl
, qtbase
, qtsvg
, qttools
, cmake
}:

#let inherit (lib) getDev; in

stdenv.mkDerivation rec {
  pname = "qt6ct";
  version = "2021-12-22";

  src = fetchFromGitHub {
    url = "";
    repo = pname;
    owner = "trialuser02";
    rev = "e41923da5723e310310f183dd28dee64293e00ae";
    sha256 = "sha256-1j0M4W00QnIH2GUx9wpxxbnIUARN1bLcsihVMfQW5JA="; # todo
  };

  nativeBuildInputs = [
    cmake
    #qttools
  ];

  buildInputs = [
    qtbase
    #qtsvg
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
