{ lib, stdenvNoCC, targetPlatform, fetchgit }:
with lib;
let
  rev = "25cf78395cd77e11b13c1bd26124e0a586c19166";

  cipd-platform-arch = if targetPlatform.isi686 then "386"
  else if targetPlatform.isS390 && targetPlatform.is64Bit then "s390x"
  else if targetPlatform.isx86_64 then "amd64"
  else "${targetPlatform.parsed.cpu.family}${if targetPlatform.is64Bit then "64" else "32"}${if (targetPlatform.parsed.cpu.family == "mips" or targetPlatform.isPower64) and targetPlatform.isLittleEndian then "le" else "" }";

  cipd-platform-kernel = if targetPlatform.isLinux or targetPlatform.isDarwin or targetPlatform.isWindows then
    (if targetPlatform.isDarwin then "mac" else targetPlatform.parsed.kernel.name)
  else throw "Unsupported kernel ${targetPlatform.parsed.kernel.name}";
in stdenvNoCC.mkDerivation rec {
  pname = "depot_tools";
  version = "git+${rev}";

  src = fetchgit {
    url = "https://chromium.googlesource.com/chromium/tools/depot_tools.git";
    inherit rev;
    sha256 = "sha256-Qn0rqX2+wYpbyfwYzeaFsbsLvuGV6+S9GWrH3EqaHmU=";
  };

  passthru.cipd = {
    # Get from "cipd_client_version" in depot_tools
    version = "git_revision:89ada246fcbf10f330011e4991d017332af2365b";
    # Get from "cipd_client_version.digests" in depot_tools
    hashes = builtins.listToAttrs (map (line:
      let
        segments = builtins.split " +" line;
      in { name = builtins.head segments; value = lib.last segments; })
    (lib.filter (line: !(hasPrefix "#" line || line == "")) (splitString "\n" (''
      aix-ppc64       sha256  bf60b679afae76b7d52f46453dc67af6938438c9c8543b40d49f62eb6edb7376
      linux-386       sha256  7f264198598af2ef9d8878349d33c1940f1f3739e46d986962c352ec4cce2690
      linux-amd64     sha256  2ada6b46ad1cd1350522c5c05899d273f5c894c7665e30104e7f57084a5aeeb9
      linux-arm64     sha256  96eca7e49f6732c50122b94b793c3a5e62ed77bce1686787a8334906791b4168
      linux-armv6l    sha256  06394601130652c5e1b055a7e4605c21fc7c6643af0b3b3cac8d2691491afa81
      linux-mips64    sha256  f3eda6542b381b7aa8f582698498b0e197972c894590ec35f18faa467c868f5c
      linux-mips64le  sha256  74229ada8e2afd9c8e7c58991126869b2880547780d4a197a27c1dfa96851622
      linux-mipsle    sha256  2f3c18ec0ad48cd44a9ff39bb60e9afded83ca43fb9c7a5ea9949f6fdd4e1394
      linux-ppc64     sha256  79425c0795fb8ba12b39a8856bf7ccb853e85def4317aa6413222f307d4c2dbd
      linux-ppc64le   sha256  f9b3d85dde70f1b78cd7a41d2477834c15ac713a59317490a4cdac9f8f092325
      linux-riscv64   sha256  bd695164563a66e8d3799e8835f90a398fbae9a4eec24e876c92d5f213943482
      linux-s390x     sha256  6f501af80541e733fda23b4208a21ea05919c95d236036a2121e6b6334a2792c
      mac-amd64       sha256  41d05580c0014912d6c32619c720646fd136e4557c9c7d7571ecc8c0462733a1
      mac-arm64       sha256  dc672bd16d9faf277dd562f1dc00644b10c03c5d838d3cc3d3ea29925d76d931
      windows-386     sha256  fa6ed0022a38ffc51ff8a927e3947fe7e59a64b2019dcddca9d3afacf7630444
      windows-amd64   sha256  b5423e4b4429837f7fe4d571ce99c068aa0ccb37ddbebc1978a423fd2b0086df
    ''))));
    platform = "${cipd-platform-kernel}-${cipd-platform-arch}";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    cp -r -P --no-preserve=ownership $src $out
  '';

  meta = with lib; {
    description = "Tools for working with Chromium development.";
    homepage = "https://chromium.googlesource.com/chromium/tools/depot_tools";
  };
}
