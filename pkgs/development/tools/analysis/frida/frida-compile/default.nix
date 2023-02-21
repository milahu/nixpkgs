stdenv.mkDerivation {
  pname = "frida-compile";
  version = "10.2.5";
  outputHash = "sha256-P0ZDniykK+LH43AHLQChRCzY2EUUoyWZ7WZmjqOpfCA=";
  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  buildInputs = [
    nodejs_latest
  ];
  buildCommand = ''
    mkdir $out
    cd $out
    cp ${./package.json} package.json
    cp ${./package-lock.json} package-lock.json
    export HOME=$TMP
    npm ci
    patchShebangs $out
  '';
}
