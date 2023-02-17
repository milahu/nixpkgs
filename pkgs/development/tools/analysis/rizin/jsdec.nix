{ lib
, stdenv
, fetchFromGitHub
, meson
, pkg-config
, cmake
, ninja
, rizin
, openssl
}:

stdenv.mkDerivation rec {
  pname = "jsdec";
  version = "unstable-2023-01-16";

  src = fetchFromGitHub {
    owner = "rizinorg";
    repo = "jsdec";
    rev = "9516d7c9b555bc77dc32419f5ae6c7f198094d38";
    hash = "sha256-b9GHboLd++k5qMuRV2MsbM78iPo6eHi39pOyF5REbJM=";
  };

  nativeBuildInputs = [
    meson
    pkg-config
    cmake
    ninja
  ];

  buildInputs = [
    rizin
    openssl
  ];

  postPatch = ''
    cd p
  '';

  mesonFlags = [
    "-Djsc_folder=.."
  ];

  meta = with lib; {
    description = "Simple decompiler for Rizin";
    homepage = "https://github.com/rizinorg/jsdec";
    license = with licenses; [ mit bsd3 asl20 ];
    maintainers = with maintainers; [ milahu ];
  };
}
