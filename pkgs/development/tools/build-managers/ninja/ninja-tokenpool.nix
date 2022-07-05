{ lib
, ninja
, fetchFromGitHub
}:

(ninja.overrideAttrs (old: {
  pname = "ninja-tokenpool";
  version = "unstable-2022-02-13";

  src = fetchFromGitHub {
    owner = "stefanb2";
    repo = "ninja";
    rev = "15bc8f783b63e9bf91080d9b9d6c83468f012f97";
    sha256 = "sha256-cxtmBptmqxFyEXpgFNs7extyDfZBrJKMy1hsIqzruIc=";
  };

  setupHook = ./setup-hook-tokenpool.sh;

  meta = with lib; {
    description = "ninja build system with jobserver and jobclient";
    longDescription = ''
      run `ninja --tokenpool-master` to start the main build process
    '';
    homepage = "https://github.com/stefanb2/ninja/tree/topic-tokenpool-master";
    # via https://github.com/ninja-build/ninja/issues/1139#issuecomment-461750356
    # see also https://gitlab.kitware.com/cmake/cmake/-/issues/21597
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ milahu ];
  };
}))
