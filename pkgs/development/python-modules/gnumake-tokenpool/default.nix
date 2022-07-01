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
    rev = "4604c9b5c22fee8654922cb46ff706fec379b994";
    sha256 = "lhiRmRBvgtXbFYo6yfJ99gQdM8p7TG6MSnJAQVoSiVY=";
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
