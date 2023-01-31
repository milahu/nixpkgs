{ capstone
, fetchFromGitHub
}:

capstone.overrideAttrs (old: rec {
  version = "5.0-rc2";
  src = fetchFromGitHub {
    owner = "capstone-engine";
    repo = "capstone";
    rev = version;
    sha256 = "sha256-nB7FcgisBa8rRDS3k31BbkYB+tdqA6Qyj9hqCnFW+ME=";
  };
})
