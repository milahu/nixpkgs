{ lib
, buildPythonPackage
, psutil
, prefixed
}:

buildPythonPackage rec {
  pname = "nix-build-profiler";
  version = "0.0.1";

  src = ./src;

  propagatedBuildInputs = [
    psutil
    prefixed
  ];

  meta = with lib; {
    description = "Profile CPU and memory usage of nix-build";
    homepage = "https://github.com/milahu/nix-build-profiler";
    license = licenses.mit;
    maintainers = with maintainers; [ milahu ];
  };
}
