{ lib
, fetchFromGitHub
, buildPythonPackage
}:

buildPythonPackage rec {
  pname = "gnumake-tokenpool";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "gnumake-tokenpool";
    rev = "7eba965adfafa429333dd40d7d920085578185ba";
    sha256 = "PpQ4uNClPCMwVoRWDq7PJmGbRCoaTjwEkyJviYLDqMM=";
  };

  pythonImportsCheck = [
    "gnumake_tokenpool"
  ];

  meta = with lib; {
    description = "jobclient and jobserver for the GNU make tokenpool protocol";
    homepage = "https://github.com/milahu/gnumake-tokenpool";
    license = licenses.mit;
    maintainers = with maintainers; [ milahu ];
  };
}
