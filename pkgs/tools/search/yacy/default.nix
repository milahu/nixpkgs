{ lib
, stdenv
, fetchFromGitHub
, jdk
, ant
}:

stdenv.mkDerivation {
  pname = "yacy";
  # last stable release was in year 2016
  version = "unstable-2022-10-06";
  src = fetchFromGitHub {
    owner = "yacy";
    repo = "yacy_search_server";
    # last commit with passing tests
    rev = "32e6a5f9037dce684853cf358988f59215072ef7";
    hash = "sha256-IxcD9qNKVa0hpZ7WziKwSDtgkOqEly6NuzkVwinSoBQ=";
  };

  nativeBuildInputs = [ jdk ant ];

  buildPhase = "ant";

  # https://github.com/yacy/yacy_search_server
}
