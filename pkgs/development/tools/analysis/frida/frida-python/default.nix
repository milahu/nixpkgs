{ lib
, stdenv
, fetchFromGitHub
, meson
, cmake
, ninja
, pkg-config
, frida-core
, python3
, libgee
, libsoup_3
, libsysprof-capture
, sqlite
, libpsl
, libnghttp2
}:

let
  srcs = builtins.fromJSON (builtins.readFile ../srcs.json);
in

stdenv.mkDerivation rec {
  pname = "frida-python";
  inherit (srcs) version;
  src = fetchFromGitHub srcs.paths.${pname}.github;

  nativeBuildInputs = [
    meson
    pkg-config
    cmake
    ninja
  ];

  buildInputs = [
    frida-core
    python3
    libgee
    libsoup_3
    # ${libsoup_3.dev}/lib/pkgconfig/libsoup-3.0.pc
    # Requires.private: sysprof-capture-4, sqlite3, libpsl >=  0.20, libbrotlidec, zlib, libnghttp2
    libsysprof-capture
    sqlite
    libpsl
    libnghttp2
  ];

  propagatedBuildInputs = [
    frida-core
    libgee
    libsoup_3
  ];

  mesonFlags = [
      # based on github CI of https://github.com/frida/frida
      "-Doptimization=s"
      "-Db_ndebug=true"
    ];

  meta = with lib; {
    description = "Python bindings for Frida";
    homepage = "https://github.com/frida/frida-python";
    license = licenses.wxWindows;
    maintainers = with maintainers; [ milahu ];
    platforms = platforms.unix;
  };
}
