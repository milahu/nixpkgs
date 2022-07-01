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
    rev = "b8e2a0f2699ed602885c84d6452cb5f420e1355a";
    sha256 = "x53sBNdR5NB/gLjhC6AgMkvZxEG/boijcOKMjcwp5vI=";
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
