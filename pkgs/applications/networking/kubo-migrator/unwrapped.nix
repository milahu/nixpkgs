{ lib
, buildGoModule
, callPackage
}:

buildGoModule rec {
  pname = "kubo-migrator";
  version = "2.0.2";

  src = callPackage ./src.nix { };

  sourceRoot = "kubo-migrator-src/fs-repo-migrations";

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
