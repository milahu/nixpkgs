{ lib
, stdenv
, fetchFromGitHub
, texinfo
}:

let quickjs =
stdenv.mkDerivation rec {
  pname = "quickjs";
  version = "2021-03-27";

  src = fetchFromGitHub {
    owner = "bellard";
    repo = pname;
    rev = "b5e62895c619d4ffc75c9d822c8d85f1ece77e5b";
    hash = "sha256-VMaxVVQuJ3DAwYrC14uJqlRBg0//ugYvtyhOXsTUbCA=";
  };

  makeFlags = [ "prefix=${placeholder "out"}" ];
  enableParallelBuilding = true;

  nativeBuildInputs = [
    texinfo
  ];

  postBuild = ''
    (cd doc
     makeinfo *texi)
  '';

  postInstall = ''
    (cd doc
     install -Dt $out/share/doc *texi *info)
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    PATH="$out/bin:$PATH"

    # Programs exit with code 1 when testing help, so grep for a string
    set +o pipefail
    qjs     --help 2>&1 | grep "QuickJS version"
    qjscalc --help 2>&1 | grep "QuickJS version"
    set -o pipefail

    temp=$(mktemp).js
    echo "console.log('Output from compiled program');" > "$temp"
    set -o verbose
    out=$(mktemp) && qjsc         "$temp" -o "$out" && "$out" | grep -q "Output from compiled program"
    out=$(mktemp) && qjsc   -flto "$temp" -o "$out" && "$out" | grep -q "Output from compiled program"
  '';

  meta = with lib; {
    description = "A small and embeddable Javascript engine";
    homepage = "https://bellard.org/quickjs/";
    maintainers = with maintainers; [ stesie AndersonTorres ];
    platforms = platforms.linux;
    license = licenses.mit;
    mainProgram = "qjs";
  };

  passthru = {
    dev = stdenv.mkDerivation {
      name = quickjs.name + "-dev";
      inherit (quickjs) version;
      phases = "buildPhase";
      buildPhase = ''
        mkdir -p $out/lib/pkgconfig

        cat >$out/lib/pkgconfig/quickjs.pc <<'EOF'
        prefix=${quickjs.outPath}
        exec_prefix=''${prefix}
        libdir=''${prefix}/lib
        pkglibdir=''${prefix}/lib/quickjs
        includedir=''${prefix}/include
        pkgincludedir=''${prefix}/include/quickjs

        Name: quickjs
        Description: ${quickjs.meta.description}
        Version: ${quickjs.version}
        Requires.private:
        Libs: -L''${pkglibdir} -lquickjs
        Libs.private:
        Cflags: -I''${pkgincludedir}
        EOF
      '';
    };
  };
}
; in quickjs
