{ qtModule
, stdenv
, lib
, qtbase
, qtdeclarative
, clang # build QDoc
}:

qtModule {
  pname = "qttools";
  qtInputs = [ qtbase qtdeclarative ];
  buildInputs = [ clang ];
  outputs = [ "out" "dev" "bin" ];

  NIX_CFLAGS_COMPILE = lib.optional stdenv.isDarwin ''-DNIXPKGS_QMLIMPORTSCANNER="${qtdeclarative.dev}/bin/qmlimportscanner"'';
}
