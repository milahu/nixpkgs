{ lib
, stdenvNoCC
, fetchFromGitHub
, fetchpatch
}:

stdenvNoCC.mkDerivation rec {
  name = "kubo-migrator-src";

  src = fetchFromGitHub {
    owner = "ipfs";
    repo = "fs-repo-migrations";
    rev = "fs-repo-11-to-12/v1.0.2";
    hash = "sha256-CG4utwH+/+Igw+SP3imhl39wijlB53UGtkJG5Mwh+Ik=";
  };

  patches = [
    # Make the migrations compatible with Go 1.17 and newer
    (fetchpatch {
      name = "fix-fs-repo-10-to-11.patch";
      url = "https://github.com/ipfs/fs-repo-migrations/pull/163/commits/c3b39a3ccd51e65e1039652235cb6930d3304a08.patch";
      hash = "sha256-YkFtFsYueCd24WsRINq7Q5wvFjoIVAqlN9yy9y6kNrw=";
    })
    (fetchpatch {
      name = "fix-fs-repo-11-to-12.patch";
      url = "https://github.com/ipfs/fs-repo-migrations/pull/163/commits/408f58ffdf9869bcb51cd4d8d99d5aefd65df593.patch";
      hash = "sha256-IkRkwNVDLSU8wWmtFuxM5H0g6Jkkso/i8k5XmjMrLA8=";
    })
  ];

  dontConfigure = true;
  dontBuild = true;
  doCheck = false;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r * .* "$out"
    runHook postInstall
  '';
}
