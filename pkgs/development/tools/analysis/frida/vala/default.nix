{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, flex
, bison
, libxslt
#, graphviz
, expat
, vala
, meson
, ninja
, patchelf
}:

# based on pkgs/development/compilers/vala/default.nix

vala.overrideAttrs (oldAttrs: rec {
  pname = "frida-vala";
  version = "0.58.0-unstable-2022-11-07";
  abiVersion = lib.concatStringsSep "." (lib.take 2 (lib.splitVersion version));

  src = fetchFromGitHub {
    owner = "frida";
    repo = "vala";
    rev = "62ee2b101a5e5f37ce2a073fdb36e7f6ffb553d1";
    hash = "sha256-czzWYcOo6qkvUNldDBWC2/1ugcaRwD2AnGGdq1ksLAE=";
  };

  outputs = [ "out" ]; # remove output "devdoc"

  patches = [];

  buildInputs = oldAttrs.buildInputs ++ [
    # https://github.com/frida/vala/issues/5
    #graphviz
  ];

  nativeBuildInputs = [
    pkg-config
    flex
    bison
    libxslt
    meson
    ninja
    vala # vala is self-hosted. dont bootstrap vala here
    patchelf
  ]
  ++ lib.optional (stdenv.isDarwin && (lib.versionAtLeast version "0.38")) expat;

  # fix: ./frida-vala/bin/valac: error while loading shared libraries: libvalacodegen.so: cannot open shared object file: No such file or directory
  # TODO better?
  postFixup = ''
    patchelf --add-rpath $out/lib/vala-${abiVersion} $out/bin/valac
  '';

  meta = with lib; {
    description = "Frida fork of the Compiler for GObject type system";
    homepage = "https://github.com/frida/vala";
    changelog = "https://github.com/frida/vala/blob/${src.rev}/ChangeLog.pre-0-4";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ ];
  };
})
