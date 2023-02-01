{ lib
, stdenv
, autoreconfHook
, meson
, pkg-config
, ninja
, libelf
, zlib
, zstd
, version ? "0.6.0-unstable-2023-01-29"
}:

let
  versions = {
    # note: libdwarf has API-breaks between minor versions
    # git ls-remote --tags https://github.com/davea42/libdwarf-code | grep -v '\^{}$' | sed 's|^.*refs/tags/||'
    "20210528" = {
      rev = "20210528";
      sha256 = "sha256-JHGYEwxmpFu++uac67tJGZ3SXXss5ZAOVR5cI69CaIQ=";
      configureFlags = [ "--enable-shared" "--disable-nonshared" ];
      knownVulnerabilities = [ "CVE-2022-32200" "CVE-2022-39170" ];
    };
    /* not used
    "0.1.1" = {
      rev = "libdwarf-0.1.1";
      sha256 = "sha256-Dox76yivIIJCRe6H1pQV12tqVKMjEQ/GbdaY3m1L7Og=";
      nativeBuildInputs = [ autoreconfHook ];
      configureFlags = [ "--enable-shared" "--disable-nonshared" ];
    };
    "0.2.0" = {
      rev = "libdwarf-0.2.0";
      sha256 = "sha256-1eCub9zincEVXtRLt6P4m2fKNO8x8ZClbRwXEPp36RU=";
      nativeBuildInputs = [ autoreconfHook ];
      configureFlags = [ "--enable-shared" "--disable-nonshared" ];
    };
    # meson support since libdwarf 0.3.3
    "0.3.4" = {
      sha256 = "sha256-8VfHO18o5opEpru1g9U94rhF1HyeMk8W4CvoCLKWFQ4=";
      nativeBuildInputs = [ meson ninja ];
    };
    "0.4.2" = {
      sha256 = "sha256-rh5EfEBbp9rYquv2p/e0/RwjsAuIyaFyPtp6R1ftfPA=";
      nativeBuildInputs = [ meson ninja ];
    };
    "0.5.0" = {
      sha256 = "sha256-wqI4TxEZTDbkuK2hnfBXMqEFpEOshzds390aY3qXT58=";
      nativeBuildInputs = [ meson ninja ];
    };
    */
    # fix 0.5.0: Run-time dependency zstd found: NO (tried pkgconfig)
    # with https://github.com/davea42/libdwarf-code/commit/31c3f298d4d11ec92fde6b5d176007ed20fe3755
    "0.6.0-unstable-2023-01-29" = {
      rev = "ef60bff461a533da09f4ad3e9c1ece1249237ea2";
      sha256 = "sha256-PLZOlYRrP16oO8ALeRoQ9d+Xy5w0Q/SGJ2LMZEFRYME=";
      nativeBuildInputs = [ meson ninja ];
    };
  };

  attrs = versions.${version};
in

stdenv.mkDerivation rec {
  pname = "libdwarf";
  inherit version;

  src = fetchFromGitHub rec {
    owner = "davea42";
    repo = "libdwarf-code";
    rev = attrs.rev or "v${version}";
    sha256 = attrs.sha256 or "";
  };

  nativeBuildInputs = attrs.nativeBuildInputs or [];
  configureFlags = attrs.configureFlags or [];

  buildInputs = [
    pkg-config
    libelf
    zlib
    zstd
  ];

  meta = with lib; {
    description = "library for the DWARF Debugging Information Format";
    homepage = "https://github.com/davea42/libdwarf-code";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ atry milahu ];
    platforms = platforms.unix;
    knownVulnerabilities = attrs.knownVulnerabilities or [];
  };
}
