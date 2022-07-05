{ lib
, fetchFromGitHub
, buildPythonPackage
, psutil
, prefixed
, writeText
}:

let
  gnumake-tokenpool = buildPythonPackage rec {
    pname = "gnumake-tokenpool";
    version = "0.0.2";

    # note: gnumake-tokenpool src is also in
    # pkgs/development/libraries/qt-6/modules/qtwebengine.nix
    src = fetchFromGitHub {
      owner = "milahu";
      repo = "gnumake-tokenpool";
      rev = "f2a40df69b0fbe5da400e2d4ba9502a978071d0e";
      sha256 = "VFoZBZGubY1nhbfBpboFFEKEJNMXWNPj3LRF53QVySo=";
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
