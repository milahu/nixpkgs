{ lib
, rustPlatform
, fetchFromGitHub
, fetchurl
, cmake
, pkg-config
, openssl
, stdenv
, glibc
, darwin
, nodejs
, graalvm17-ce
, flatbuffers
, wasm-pack
, cargo-watch
, rustfmt
, dejavu_fonts

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

  # TODO move to pkgs.google-fonts.mplus1
  google-fonts-mplus1 = stdenv.mkDerivation {
    # https://github.com/google/fonts/tree/main/ofl/mplus1
    pname = "google-fonts-mplus1";
    version = "unstable-2022-05-23";
    src = fetchurl {
      # MPLUS1[wght].ttf
      #url = "https://github.com/google/fonts/raw/96800fb3e967b900421481008771f14c3717ec52/ofl/mplus1/MPLUS1%5Bwght%5D.ttf";
      url = "https://github.com/google/fonts/raw/96800fb3e967b900421481008771f14c3717ec52/ofl/mplus1/MPLUS1[wght].ttf";
      sha256 = "";
    };
    buildCommand = ''
      mkdir -p $out/share/fonts/truetype
      cp -v $src $out/share/fonts/truetype
    '';
  };

  # TODO move to pkgs.google-fonts.mplus1p
  google-fonts-mplus1p = stdenv.mkDerivation {
    # https://github.com/google/fonts/tree/main/ofl/mplus1p
    pname = "google-fonts-mplus1p";
    version = "unstable-2022-07-29";
    srcs = let files = [
      { path = "MPLUS1p-Black.ttf"; sha256 = ""; }
      { path = "MPLUS1p-Bold.ttf"; sha256 = ""; }
      { path = "MPLUS1p-ExtraBold.ttf"; sha256 = ""; }
      { path = "MPLUS1p-Light.ttf"; sha256 = ""; }
      { path = "MPLUS1p-Medium.ttf"; sha256 = ""; }
      { path = "MPLUS1p-Regular.ttf"; sha256 = ""; }
      { path = "MPLUS1p-Thin.ttf"; sha256 = ""; }
    ]; in (map (f: with f; fetchurl {
      url = "https://github.com/google/fonts/raw/a24c920263576ec723d64c1b26f8afabb841601d/ofl/mplus1p/${path}";
      inherit sha256;
    }) files);
    buildCommand = ''
      mkdir -p $out/share/fonts/truetype
      cp -v $srcs $out/share/fonts/truetype
    '';
  };

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

  /*
    based on the "run" script

    libgcc_s.so.1
    fix error: No such file or directory: libgcc_s.so.1
    lib path found with strace -f -v -s 100
    https://github.com/enso-org/enso/issues/5587

    msdfgen_wasm.js
    fix: Error: Failed to get https://github.com/enso-org/msdfgen-wasm/releases/download/v1.4.1/msdfgen_wasm.js
    https://github.com/enso-org/enso/issues/5586

    Compiling ensogl-text-embedded-fonts v0.1.0
    Error: Failed to get https://github.com/dejavu-fonts/dejavu-fonts//releases/download/version_2_37/dejavu-fonts-ttf-2.37.zip
    TODO use /nix/store/sybg4kcgcy64vbvxb35q07yzfwhh17b8-dejavu-fonts-2.37/share/fonts/truetype/*.ttf
    lib/rust/ensogl/component/text/src/font/embedded/build.rs
    const FILE_NAMES: [&str; 4] =
        ["DejaVuSans.ttf", "DejaVuSans-Bold.ttf", "DejaVuSansMono.ttf", "DejaVuSansMono-Bold.ttf"];
    let out_dir = ide_ci::programs::cargo::build_env::OUT_DIR.get()?;
    deja_vu::download_and_extract_all_fonts(&out_dir).await?;

    lib/rust/ensogl/component/text/src/font/embedded/build.rs
    google_fonts::load(&out_dir, &mut code_gen, "mplus1").await?;
    google_fonts::load(&out_dir, &mut code_gen, "mplus1p").await?;
    TODO add package google-fonts: mplus1 mplus1p
    ${asciidoctor}/lib/ruby/gems/2.7.0/gems/asciidoctor-pdf-1.6.0/data/fonts/mplus1p-regular-fallback.ttf

  */

  buildPhase = ''
    set -x

    mkdir -p $out/lib64
    ln -s -v ${glibc}/lib/libgcc_s.so.1 $out/lib64/libgcc_s.so.1

    substituteInPlace lib/rust/ensogl/component/text/src/font/msdf/build.rs \
      --replace 'let mut stream = ide_ci::io::web::download_reader(PACKAGE.url()?).await?;' "/*" \
      --replace '.with_context(|| format!("Failed to stream download to file {}.", PACKAGE.filename))?;' "*/"
    cp -v --no-preserve=mode ${src-msdfgen-wasm-js} lib/rust/ensogl/component/text/src/font/msdf/msdfgen_wasm.js

    substituteInPlace lib/rust/ensogl/component/text/src/font/embedded/build.rs \
      --replace 'deja_vu::download_and_extract_all_fonts(&out_dir).await?;' ""
    ln -s ${dejavu_fonts}/share/fonts/truetype/*.ttf $out

    ln -s ${google-fonts-mplus1}/share/fonts/truetype/*.ttf $out
    ln -s ${google-fonts-mplus1p}/share/fonts/truetype/*.ttf $out

    if ! \
    OUT_DIR=$out \
    cargo build --profile buildscript --target-dir target/enso-build --package enso-build-cli
    then
      OUT_DIR=$out strace -f -v -s 100 \
      ./target/enso-build/buildscript/build/enso-build-*/build-script-build
    fi

    rm $out/*.ttf
  '';

  meta = with lib; {
    description = "Hybrid visual and textual functional programming";
    homepage = "https://github.com/enso-org/enso";
    changelog = "https://github.com/enso-org/enso/blob/${src.rev}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
