{ lib
, buildGoModule
, buildGoModule2
, fetchFromGitHub
, fetchpatch
} @ pkgs:

let
  buildGoModule = pkgs.buildGoModule;
  #buildGoModule = pkgs.buildGoModule2; # TODO prototype
in

buildGoModule rec {
  pname = "kubo-migrator";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "ipfs";
    repo = "fs-repo-migrations";
    rev = "fs-repo-12-to-13/v1.0.0";
    hash = "sha256-QQone7E2Be+jVfnrwqQ1Ny4jo6mSDHhaY3ErkNdn2f8=";
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

  modRoot = "fs-repo-migrations";

  vendorHash = "sha256-/DqkBBtR/nU8gk3TFqNKY5zQU6BFMc3N8Ti+38mi/jk=";

  doCheck = false;

  meta = with lib; {
    description = "Migrations for the filesystem repository of Kubo clients";
    homepage = "https://github.com/ipfs/fs-repo-migrations";
    license = licenses.mit;
    maintainers = with maintainers; [ Luflosi elitak ];
    mainProgram = "fs-repo-migrations";
  };
}
