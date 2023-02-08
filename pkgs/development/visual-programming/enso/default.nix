{ lib
, rustPlatform
, fetchFromGitHub
, fetchurl
, cmake
, pkg-config
, openssl
, stdenv
, darwin
, nodejs
, graalvm17-ce
, flatbuffers
, wasm-pack
, cargo-watch
, rustfmt

, strace
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

  cargoHash = "sha256-nSOlAQbcNgIG+GBk2MA+7Wq3+tiBEQTt8+DIr7YNhgA=";

  src-msdfgen-wasm-js = let
      version = "1.4.1";
    in
    fetchurl {
      url = "https://github.com/enso-org/msdfgen-wasm/releases/download/v${version}/msdfgen_wasm.js";
      sha256 = "sha256-7p3duSqx3+vlfd1VJghXjVL0Ux9y9+Wt9wiI11XhNE8=";
    };

  patches = [
    ./disable-download-msdfgen-wasm-js.patch
  ];

  # fix: error[E0554]: `#![feature]` may not be used on the stable release channel
  RUSTC_BOOTSTRAP = 1;

  nativeBuildInputs = [
    cmake
    pkg-config
    rustfmt
    strace # debug
  ];

  buildInputs = [
    openssl
    nodejs
    graalvm17-ce
    flatbuffers
    wasm-pack
    cargo-watch
  ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
    CoreFoundation
    DiskArbitration
    Foundation
    Security
  ]);

  dontConfigure = true;

  # based on the "run" script
  #
  # libgcc_s.so.1
  # fix error: No such file or directory: libgcc_s.so.1
  # lib path found with strace -f -v -s 100
  # https://github.com/enso-org/enso/issues/5587
  #
  # msdfgen_wasm.js
  # fix: Error: Failed to get https://github.com/enso-org/msdfgen-wasm/releases/download/v1.4.1/msdfgen_wasm.js
  # https://github.com/enso-org/enso/issues/5586

  buildPhase = ''
    set -x

    cargo build --profile buildscript --target-dir target/enso-build --package enso-build-cli || true

    mkdir -p $out/lib64
    ln -s -v ${glibc}/lib/libgcc_s.so.1 $out/lib64/libgcc_s.so.1

    cp -v --no-preserve=mode ${src-msdfgen-wasm-js} lib/rust/ensogl/component/text/src/font/msdf/msdfgen_wasm.js

    OUT_DIR=$out strace -f -v -s 100 ./target/enso-build/buildscript/build/enso-build-*/build-script-build
  '';

  meta = with lib; {
    description = "Hybrid visual and textual functional programming";
    homepage = "https://github.com/enso-org/enso";
    changelog = "https://github.com/enso-org/enso/blob/${src.rev}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
