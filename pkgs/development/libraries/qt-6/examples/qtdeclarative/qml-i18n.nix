{ lib
, stdenv
, qtbase
, qtdeclarative
, qmake
, qttools
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "qtdeclarative-example-qml-i18n";
  inherit (qtdeclarative) version src;
  postPatch = ''
    cd examples/qml/qml-i18n
  '';
  # fix default install location: ${qtbase.out}/examples/
  installPhase = ''
    mkdir -p $out/bin
    cp qml-i18n $out/bin
  '';
  nativeBuildInputs = [
    qmake
    qttools
    wrapQtAppsHook
  ];
  buildInputs = [
    qtbase
    qtdeclarative
  ];
}
