{ lib
, buildPythonPackage
, psutil
, prefixed
, writeText
}:

let
  gnumake-tokenpool = buildPythonPackage rec {
    pname = "gnumake-tokenpool";
    version = "0.0.1";

    # note: gnumake-tokenpool src is also in
    # pkgs/development/libraries/qt-6/modules/qtwebengine.nix
    src = fetchFromGitHub {
      owner = "milahu";
      repo = "gnumake-tokenpool";
      rev = "4eb559ae323bef153cbe1d0a5e3496b377fb7856";
      sha256 = "v3UqPi4fCnN86xmp4eOSz8IXNH70E8Kvvq6HVOiCiwk=";
    };

    meta = with lib; {
      description = "jobclient and jobserver for the GNU make tokenpool protocol";
      homepage = "https://github.com/milahu/gnumake-tokenpool";
      license = licenses.mit;
      maintainers = with maintainers; [ milahu ];
    };
  };
in

buildPythonPackage rec {
  pname = "nix-build-profiler";
  version = "0.0.1";

  src = ./src;

  propagatedBuildInputs = [
    psutil
    prefixed
    gnumake-tokenpool
  ];

  setupHook = writeText "setup-hook.sh" ''
    startNixBuildProfiler() {
      echo "Starting nix-build-profiler"
      nix-build-profiler &
    }
    prePhases+=" startNixBuildProfiler"
  '';

  meta = with lib; {
    description = "Profile CPU and memory usage of nix-build";
    longDescription = ''
      Usage:

      ```nix
      mkDerivation {
        nativeBuildInputs = [ nix-build-profiler ];
      }
      ```
    '';
    homepage = "https://github.com/milahu/nix-build-profiler";
    license = licenses.mit;
    maintainers = with maintainers; [ milahu ];
  };
}
