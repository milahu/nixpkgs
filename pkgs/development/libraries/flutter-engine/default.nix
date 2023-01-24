{ lib, stdenv, stdenvNoCC, hostPlatform, callPackage, fetchFromGitHub, fetchurl, writeText,
  ninja, gnumake, patchelf, python3, llvmPackages, clang-tools, gcc-unwrapped, libcxx,
  pkg-config, openssh, git, gclient-wrapped }@inputs:
with lib;
let
  # Get this from "flutter doctor"
  version = "857bd6b74c5eb56151bfafe91e7fa6a82b6fee25";
  sha256 = "sha256-+661KBEcyNj1t0h9rp1kM+hv1DdI/pxxnrJtHihnXyc=";

  mkPackage = (import ./package.nix) inputs;
  runtimeModes = builtins.listToAttrs (builtins.map (runtimeMode: {
    name = runtimeMode;
    value = mkPackage {
      inherit runtimeMode version sha256;
    };
  }) [
    "debug"
    "profile"
    "release"
    "jit_release"
  ]);
in stdenvNoCC.mkDerivation {
  pname = "flutter-engine";
  inherit version;

  passthru = runtimeModes // {
    inherit runtimeModes;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/lib/flutter $out/lib/pkgconfig

    ${concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (runtimeMode: pkg: ''
      cp -r -P --no-preserve=ownership,mode ${pkg}/lib/flutter/${runtimeMode} $out/lib/flutter/${runtimeMode}
      substituteAll ${./flutter-engine.pc} $out/lib/pkgconfig/flutter-engine-${runtimeMode}.pc
    '') runtimeModes))}
  '';

  meta = {
    description = "The engine for Flutter";
    homepage = "https://github.com/flutter/engine";
    license = licenses.bsd3;
    maintainers = with maintainers; [ RossComputerGuy ];
  };
}
