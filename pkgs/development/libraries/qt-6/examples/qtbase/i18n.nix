{ lib
, stdenv
, qtbase
, qmake
, qttools
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "qtbase-example-i18n";
  inherit (qtbase) version src;
  prePatch = ''
    cd examples/widgets/tools/i18n
  '';
  # tries install to ${qtbase.out}/examples/
  installPhase = ''
    mkdir -p $out/bin
    cp i18n $out/bin
  '';
  nativeBuildInputs = [
    qmake
    qttools
    wrapQtAppsHook
  ];
  buildInputs = [
    qtbase
  ];
}
