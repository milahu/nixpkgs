{ buildPythonPackage
, python
, fetchurl
, lib
, stdenv
, pyside6
, cmake
, qt6
, llvm
, libclang
, llvmPackages
, llvmPackages_13 # ok
#, llvmPackages_8 # error
, llvmPackages_9 # test
}:

# sphinx-build - not found! doc target disabled

stdenv.mkDerivation rec {
  pname = "shiboken6";

  inherit (pyside6) version src;

  patches = [
    #./nix_compile_cflags.patch
  ];

  postPatch = ''
    cd sources/${pname}
  '';

  #CLANG_INSTALL_DIR = llvmPackages.libclang.out;

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    #llvm
    #libclang
    # too old?
    # pyside-setup-opensource-src-6.2.2/sources/shiboken6/ApiExtractor/clangparser/clangbuilder.cpp:330:10:
    # error: 'CXCursor_ExceptionSpecificationKind_NoThrow' was not declared in this scope;
    # did you mean 'CXCursor_ExceptionSpecificationKind_None'?

    #llvmPackages_13.libllvm llvmPackages_13.clang-unwrapped
    # ok

    #llvmPackages_8.libllvm llvmPackages_8.clang-unwrapped
    # /build/pyside-setup-opensource-src-6.2.2/sources/shiboken6/ApiExtractor/clangparser/clangbuilder.cpp:330:10: error: 'CXCursor_ExceptionSpecificationKind_NoThrow' was not declared in this scope; did you mean 'CXCursor_ExceptionSpecificationKind_None'?

    llvmPackages_9.libllvm llvmPackages_9.clang-unwrapped

    #llvmPackages.libclang
    python
    qt6.qtbase
  ];

  cmakeFlags = [
    "-DBUILD_TESTS=OFF"
  ];

  dontWrapQtApps = true;

  postInstall = ''
    rm $out/bin/shiboken_tool.py
  '';

  meta = with lib; {
    description = "Generator for the pyside6 Qt bindings";
    license = with licenses; [ gpl2 lgpl21 ];
    homepage = "https://wiki.qt.io/Qt_for_Python";
    maintainers = with maintainers; [ gebner ];
    broken = stdenv.isDarwin;
  };
}
