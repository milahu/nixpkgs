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
      rev = "1bfc3aaa47fe6f230fff5df0014db549cec18620";
      sha256 = "fsqDRMq7JH1zGBqsJGSllJpNATuaoAbWo1ZrpK9y9k8=";
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
