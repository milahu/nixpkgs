{ lib
, buildPythonPackage
}:

buildPythonPackage rec {
  pname = "gnumake-tokenpool";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "gnumake-tokenpool";
    rev = "5dabefe12144bb91b3bf9b8ec67004282e6f0f18";
    sha256 = "6CfKYQgYSzR/8Nule7gWkwn0W9crqlWcgPIr39LUYsk=";
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
