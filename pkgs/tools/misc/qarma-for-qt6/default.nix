{ mkDerivation
, lib
, fetchFromGitHub
, wrapQtAppsHook
, qtbase
, qmake2cmake
, cmake
, qt5compat
, pkg-config
, libglvnd, libxkbcommon, vulkan-headers # TODO should be inherited from qtbase
, xlibs # TODO should be inherited from qtbase
}:

mkDerivation rec {
  pname = "qarma";
  version = "2021-11-26";

  src = fetchFromGitHub {
    name = "${pname}-${version}-source";
    owner = "luebking";
    repo = pname;
    rev = "9a8a8e4709e6573c8d4e5316cacaf56a8caba079";
    sha256 = "Df186aapE/F2c+8L90a2WamWkAtTHlD6MmEN1dD7D2o=";
    /*
    TODO update sha256
    test new version
    should fail cos
    https://github.com/luebking/qarma/issues/41#issuecomment-980277988
    */
  };

  # FIXME only needed for qt6
  # set attributes for qt-6/hooks/qmake-hook.sh
  # TODO better. we do not want to set this for every libsForQt6.callPackage target
  inherit (qtbase) qtDocPrefix qtQmlPrefix qtPluginPrefix;

  # TODO https://github.com/luebking/qarma/issues/41
  patches = [
    #./qarma-qt6.patch
  ];

  # TODO https://github.com/luebking/qarma/pull/47
  postPatch = ''
    #sed -i -E 's/(Qt::CTRL) \+ (Qt::Key_Return)/\1 | \2/' Qarma.cpp

    # TODO fix upstream?
    sed -i -E -e "s,(target\.path \+=) /usr/bin,\1 $out/bin," qarma.pro
  '';

  # generate CMakeLists.txt
  preConfigure = ''
    qmake2cmake qarma.pro
  '';

  # debug configure
  #cmakeFlags = [ "-DCMAKE_FIND_DEBUG_MODE=TRUE" "--trace-expand" ];

  # debug build
  #buildFlags = [ "VERBOSE=1" ];

  buildInputs = [
    qtbase qtbase.dev qt5compat qt5compat.dev
    libglvnd libxkbcommon vulkan-headers
    xlibs.libX11.dev # X11/Xlib.h
  ];

  nativeBuildInputs = [ qmake2cmake cmake wrapQtAppsHook pkg-config ];

  meta = with lib; {
    description = "CLI tool to create GUI dialogs with Qt";
    homepage = "https://github.com/luebking/qarma";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ milahu ];
  };
}
