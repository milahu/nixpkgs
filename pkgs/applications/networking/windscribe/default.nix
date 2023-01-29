{ stdenv
, lib
, fetchFromGitHub
, cmake
, ninja
, wrapQtAppsHook
, qt6
, boost
, openssl
, c-ares
, curl
, protobuf
}:

stdenv.mkDerivation rec {
  pname = "windscribe";
  version = "2.4.11-git";

  src = fetchFromGitHub {
    /*
    # build is not working. uses a custom build system, based on python2 and qmake
    owner = "Windscribe";
    repo = "Desktop-App";
    rev = "v${version}";
    sha256 = "sha256-2aFeF/gT3y1VQhg5ZzqS5iyCxgvOkiYtDOM+woSeMwc=";
    */
    # https://github.com/Windscribe/Desktop-App/pull/80
    owner = "milahu";
    repo = "Windscribe-Desktop-App";
    rev = "559ae951d0cda5f21e96729931747dc1858b5522";
    sha256 = "sha256-RCAgVjdZuj/QUhCCLPUEcimVJd6RYQOKZLivUBZEr28=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    wrapQtAppsHook
  ];

  buildInputs = [
    boost
    openssl
    c-ares
    qt6.qtbase
    curl
    protobuf
    qt6.qtsvg
    qt6.qt5compat
  ];

  meta = with lib; {
    homepage = "https://github.com/Windscribe/Desktop-App";
    description = "Client for windscribe VPN";
    license = licenses.gpl2Only;
    #platforms = [ "x86_64-linux" ]; # all?
    maintainers = with maintainers; [ arphe42 milahu ];
  };
}
