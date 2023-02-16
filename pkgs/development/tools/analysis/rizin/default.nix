{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, libusb-compat-0_1
, readline
, libewf
, perl
, zlib
, openssl
, libuv
, file
, libzip
, lz4
, xxHash
, meson
, python3
, cmake
, ninja
, capstone
, tree-sitter
, libmspack
, lzma
}:

let
  srcs = builtins.fromJSON (builtins.readFile ./srcs.json);
in

stdenv.mkDerivation rec {
  pname = "rizin";
  version = "0.4.1-unstable-2023-02-16";

  src = fetchFromGitHub srcs.rizin.github;

  # TODO move to separate file, share "meson subprojects infra" with other packages
  postUnpack = ''
    pushd $sourceRoot
    ${builtins.concatStringsSep "\n" (
      lib.mapAttrsToList (name: subproject:
        let
          src = fetchFromGitHub subproject.github;
          dst = subproject.directory or name;
        in
        ''
          echo copying subprojects/${dst}
          cp -r --no-preserve=mode ${src} subprojects/${dst}
          ${if !(builtins.hasAttr "patch_directory" subproject) then "" else
            ''
              echo patching subprojects/${dst}
              d="subprojects/packagefiles/${subproject.patch_directory}"
              while read path; do
                if [ -d "$d/$path" ]; then
                  mkdir -p "subprojects/${dst}/$path"
                else
                  cp -P "$d/$path" "subprojects/${dst}/$path"
                fi
              done < <(cd "$d" && find . -printf "%P\n")
            ''
          }
        ''
      ) srcs."rizin/subprojects"
    )}
    popd
  '';

  mesonFlags = [
    "-Dinstall_sigdb=true"
  ];

  nativeBuildInputs = [
    pkg-config
    meson
    (python3.withPackages (pp: with pp; [
      pyyaml
    ]))
    ninja
    cmake
  ];

  # meson's find_library seems to not use our compiler wrapper if static parameter
  # is either true/false... We work around by also providing LIBRARY_PATH
  preConfigure = ''
    LIBRARY_PATH=""
    for b in ${toString (map lib.getLib buildInputs)}; do
      if [[ -d "$b/lib" ]]; then
        LIBRARY_PATH="$b/lib''${LIBRARY_PATH:+:}$LIBRARY_PATH"
      fi
    done
    export LIBRARY_PATH
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace binrz/rizin/macos_sign.sh \
      --replace 'codesign' '# codesign'
  '';

  buildInputs = [
    file
    libzip
    capstone
    readline
    libusb-compat-0_1
    libewf
    perl
    zlib
    lz4
    openssl
    libuv
    tree-sitter
    xxHash
    libmspack
    lzma
  ];

  postPatch = ''
    # find_installation without arguments uses Meson's Python interpreter,
    # which does not have any extra modules.
    # https://github.com/mesonbuild/meson/pull/9904
    substituteInPlace meson.build \
      --replace "import('python').find_installation()" "find_program('python3')"

    # fix: meson.build: ERROR: Automatic wrap-based subproject downloading is disabled
    set -x
    sed -i.bak -E \
      -e "s/(option\('use_sys_[^']+', type: 'feature', value:) 'disabled'/\1 'enabled'/" \
      -e "s/(option\('use_sys_[^']+', type: 'boolean', value:) false/\1 true/" \
      meson_options.txt
    grep -HnE "*" meson_options.txt.bak
    grep -Hn use_sys_ meson_options.txt
    set +x
  '';

  meta = {
    description = "UNIX-like reverse engineering framework and command-line toolset.";
    homepage = "https://rizin.re/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ raskin makefu mic92 ];
    platforms = with lib.platforms; unix;
  };
}
