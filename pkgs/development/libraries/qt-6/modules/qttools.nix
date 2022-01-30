{ qtModule
, stdenv
, lib
, qtbase
, qtdeclarative
, clang_13 # build QDoc. clang>=8
, pkg-config # find clang
}:

qtModule {
  pname = "qttools";
  qtInputs = [ qtbase qtdeclarative ];
  buildInputs = [ clang_13 ];
  nativeBuildInputs = [ pkg-config ];
  outputs = [ "out" "dev" "bin" ];

  postConfigure = ''
    echo clang_13 = ${clang_13}
    echo "todo debug: Could NOT find Clang"
    exit 1
  '';

  cmakeFlags = [
    "--trace-expand" # debug cmake
  ];

  NIX_CFLAGS_COMPILE = lib.optional stdenv.isDarwin ''-DNIXPKGS_QMLIMPORTSCANNER="${qtdeclarative.dev}/bin/qmlimportscanner"'';
}
