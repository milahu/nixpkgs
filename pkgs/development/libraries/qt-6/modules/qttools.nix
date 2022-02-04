{ qtModule
, stdenv
, lib
, qtbase
, qtdeclarative
}:

# qttools requires a statically linked clang? https://bugreports.qt.io/browse/PYSIDE-1806

qtModule {
  pname = "qttools";
  qtInputs = [ qtbase qtdeclarative ];
  outputs = [ "out" "dev" "bin" ];

  NIX_CFLAGS_COMPILE = lib.optional stdenv.isDarwin ''-DNIXPKGS_QMLIMPORTSCANNER="${qtdeclarative.dev}/bin/qmlimportscanner"'';
}
