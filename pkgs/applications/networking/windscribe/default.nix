{ stdenv, lib, fetchurl, dpkg
, alsa-lib, atk, cairo, cups, dbus, expat, fontconfig, freetype
, gdk-pixbuf, glib, pango, nspr, nss, gtk3, mesa
, xorg, autoPatchelfHook, systemd, libnotify, libappindicator
, makeWrapper
}:

let deps = [
  alsa-lib
  atk
  cairo
  cups
  dbus
  expat
  fontconfig
  freetype
  gdk-pixbuf
  glib
  pango
  gtk3
  libappindicator
  libnotify
  mesa
  xorg.libX11
  xorg.libXScrnSaver
  xorg.libXcomposite
  xorg.libXcursor
  xorg.libXdamage
  xorg.libXext
  xorg.libXfixes
  xorg.libXi
  xorg.libXrandr
  xorg.libXrender
  xorg.libXtst
  xorg.libxcb
  xorg.libxshmfence
  nspr
  nss
  systemd
];
in
stdenv.mkDerivation rec {
  pname = "windscribe";
  version = "2.4.11";

  src = fetchurl {
    url = "https://github.com/Windscribe/Desktop-App/releases/download/v${version}/windscribe_${version}_amd64.deb";
    sha256 = "sha256-ovQU8gMltPeJi3vXH+FI3eMOEMm4vxVQ+yrlN96rNAE=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];

  buildInputs = deps;

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = "dpkg-deb -x $src .";

  runtimeDependencies = [ (lib.getLib systemd) libnotify libappindicator ];

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

  meta = with lib; {
    homepage = "https://windscribe.net";
    description = "Client for windscribe VPN";
    license = licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ arphe42 ];
  };
}
