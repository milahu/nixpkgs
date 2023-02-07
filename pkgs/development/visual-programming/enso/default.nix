{ lib
, rustPlatform
, fetchFromGitHub
, cmake
, pkg-config
, openssl
, stdenv
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "enso";
  version = "2022.6.1"; # 2022-12-06

  src = fetchFromGitHub {
    owner = "enso-org";
    repo = "enso";
    rev = version;
    hash = "sha256-YM+l+96n55nbZak019gtha++XllBV1jRiXOnSaTo+2o=";
  };

  # fix? error[E0554]: `#![feature]` may not be used on the stable release channel
  RUSTC_BOOTSTRAP = "1";

  cargoHash = "sha256-nSOlAQbcNgIG+GBk2MA+7Wq3+tiBEQTt8+DIr7YNhgA=";

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    openssl
  ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
    CoreFoundation
    DiskArbitration
    Foundation
    Security
  ]);

  meta = with lib; {
    description = "Hybrid visual and textual functional programming";
    homepage = "https://github.com/enso-org/enso";
    changelog = "https://github.com/enso-org/enso/blob/${src.rev}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
