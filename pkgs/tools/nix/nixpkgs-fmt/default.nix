{ lib, rustPlatform, fetchFromGitHub }:

let
  # 2021-09-13
  rev = "c7f66ec1b969ed118231fdf7f596c5ed2c2cfe49";
  sha256 = "5VPeqRvNhRxTv07NSvxQSXvtuGnrjWmmwss0PGhFzTI=";
  cargoSha256 = "czsY37GblIbQdP+B8cRQlpIpvHdG37oVxdo9HlL+m6s=";
in

rustPlatform.buildRustPackage rec {
  pname = "nixpkgs-fmt";
  version = "1.2.0-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = pname;
    inherit rev sha256;
  };

  inherit cargoSha256;

  meta = with lib; {
    description = "Nix code formatter for nixpkgs";
    homepage = "https://nix-community.github.io/nixpkgs-fmt";
    license = licenses.asl20;
    maintainers = with maintainers; [ zimbatm ];
  };
}
