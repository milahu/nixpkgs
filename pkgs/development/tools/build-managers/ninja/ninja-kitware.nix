{ lib
, ninja
, fetchFromGitHub
}:

(ninja.overrideAttrs (old: {
  pname = "ninja-kitware";
  version = "unstable-2021-05-25";

  src = fetchFromGitHub {
    owner = "Kitware";
    repo = "ninja";
    rev = "51db22c9ece4cb08f6c460b3b0257ce1a6fb5d8e";
    sha256 = "sha256-qan7ysHQ2OEjkcf/sjAYW9APyNTc7Em52fST3oOTs5g=";
  };

  meta = with lib; {
    description = "Kitware branch of ninja for staging features not yet integrated upstream";
    homepage = "https://github.com/Kitware/ninja";
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ milahu ];
  };
}))
