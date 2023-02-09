# glib-networking with libgioopenssl.a and lib/pkgconfig/ and include/

{ lib
, stdenv
, fetchFromGitHub
, meson
, pkg-config
, cmake
, ninja
, glib
, pcre
, pcre2
, utillinux
, libselinux
, libsepol
, libproxy
, gsettings-desktop-schemas
, gnutls
, openssl
}:

stdenv.mkDerivation rec {
  #pname = "frida-glib-networking-static"; # TODO?
  pname = "frida-glib-networking";
  version = "unstable-2022-12-12";

  src = fetchFromGitHub {
    owner = "frida";
    repo = "glib-networking";
    rev = "54a06f8399cac1fbdddd130790475a45a8124304";
    hash = "sha256-NN9bvX2syB6gwLQuEitR+T8h582j/YbbwB+Q7tJE2U4=";
  };

  nativeBuildInputs = [
    meson
    pkg-config
    cmake
    ninja
  ];

  buildInputs = [
    glib
    libproxy
    gsettings-desktop-schemas
    gnutls
    openssl
  ];

  propagatedBuildInputs = [
    glib
    pcre
    pcre2
    utillinux # mount
    libselinux
    libsepol
    openssl
  ];

  mesonFlags = [
    # build only static libraries. fix: undefined reference to g_io_module_openssl_register
    "-Ddefault_library=static"
    "-Dopenssl=enabled"
    "-Denvironment_proxy=enabled"
  ];

  meta = with lib; {
    description = "Frida fork of Network-related giomodules for glib";
    homepage = "https://github.com/frida/glib-networking";
    changelog = "https://github.com/frida/glib-networking/blob/${src.rev}/NEWS";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ ];
  };
}
