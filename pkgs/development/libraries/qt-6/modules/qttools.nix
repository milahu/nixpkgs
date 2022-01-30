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

  NIX_CFLAGS_COMPILE = lib.optional stdenv.isDarwin ''-DNIXPKGS_QMLIMPORTSCANNER="${qtdeclarative.dev}/bin/qmlimportscanner"'';
}
