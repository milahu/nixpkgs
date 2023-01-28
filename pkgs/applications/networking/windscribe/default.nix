{ stdenv
, lib
, alsa-lib
, atk
, boost
, cairo
, cups
, dbus
, expat
, fontconfig
, freetype
, gdk-pixbuf
, glib
, pango
, nspr
, nss
, gtk3
#, qt6
, qt5
, mesa
, xorg
, autoPatchelfHook
, systemd
, libnotify
, libappindicator
, makeWrapper
, fetchFromGitHub
, wrapGAppsHook
, python3
, wrapQtAppsHook
}:

let
  deps = [
    alsa-lib
    atk
    cairo
    boost
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    pango
    gtk3
    #qt6.qtbase
    qt5.qtbase
    libappindicator
    libnotify
    mesa
    nspr
    nss
    systemd
    #python # error: pathspec-0.10.1 not supported for interpreter python2.7
    python3
  ] ++ (with xorg; [
    libX11
    libXScrnSaver
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    libxcb
    libxshmfence
  ]) ++ (with python3.pkgs; [
    # tools/requirements.txt
    colorama
    glob2
    pyyaml
  ]);
in
stdenv.mkDerivation rec {
  pname = "windscribe";
  version = "2.4.11";

  src = fetchFromGitHub {
    owner = "Windscribe";
    repo = "Desktop-App";
    rev = "v${version}";
    sha256 = "sha256-2aFeF/gT3y1VQhg5ZzqS5iyCxgvOkiYtDOM+woSeMwc=";
  };

  postPatch = ''
    echo removing binary files
    rm -rfv backend/windows/ installer/windows/
    find . '(' -name '*.exe' -or -name '*.dll' ')' | xargs rm -v
    grep -rIL . | grep -v -E '.(png|jpg|tiff|ico|icns|ttf)$' | xargs rm -v
  '';

  /*
    echo migrating scripts to python3
    2to3 -w -n .
  */

  nativeBuildInputs = [
    #autoPatchelfHook
    #makeWrapper
    #wrapGAppsHook
    wrapQtAppsHook
  ];

  buildInputs = deps;

  #dontBuild = true;
  #dontConfigure = true;

  #runtimeDependencies = [ (lib.getLib systemd) libnotify libappindicator ];

  # this is just a complex wrapper for qmake
  /*
    pushd tools
    python3 build_all.py
    popd
  */

  buildPhase = ''
    pushd backend/linux/helper
    qmake # generate Makefile
    make
    popd
  '';

  /*
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share $out/opt/windscribe $out/bin $out/etc

    mv usr/share/* $out/share/
    mv usr/local/windscribe $out/opt/
    mv etc/windscribe $out/etc/

    ln -s $out/opt/windscribe/Windscribe $out/bin
    ln -s $out/opt/windscribe/windscribe-cli $out/bin

    wrapProgram $out/opt/windscribe/Windscribe

    sed -i "s|Exec.*$|Exec=$out/bin/Windscribe $U|" $out/share/applications/windscribe.desktop

    runHook postInstall
  '';
  */

  meta = with lib; {
    homepage = "https://github.com/Windscribe/Desktop-App";
    description = "Client for windscribe VPN";
    license = licenses.gpl2Only;
    #platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ arphe42 ];
  };
}
