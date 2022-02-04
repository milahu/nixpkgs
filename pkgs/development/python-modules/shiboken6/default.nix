{ buildPythonPackage
, python
, fetchurl
, lib
, stdenv # gcc
, pyside6
, cmake
, qt6
, llvmPackages_9 # https://bugreports.qt.io/browse/QTBUG-100344
, llvmPackages_13
, llvmPackages_10
}:



# TODO? clang_parseTranslationUnit2 calls clang but should call clang++ ?
# #include <type_traits>
# clang -> fatal error: 'type_traits' file not found
# clang++ -> ok

# sphinx-build - not found! doc target disabled

let
  #llvmPackages = llvmPackages_9;
  llvmPackages = llvmPackages_13;
  #llvmPackages = llvmPackages_10;

  stdenv = llvmPackages.stdenv; # gcc -> clang
  # gcc stdenv -> error: type_traits file not found
  #   https://bugreports.qt.io/browse/PYSIDE-1802
  # clang stdenv
  #   (type) is specified in typesystem, but not defined. This could potentially lead to compilation errors.
  #     https://bugreports.qt.io/browse/PYSIDE-787
  #   qt.shiboken: (shiboken) No C++ classes found!
  #     https://bugreports.qt.io/browse/PYSIDE-733 -> building with clang is not tested "Are you building PySide2 with clang++ instead of gcc? // Because I don't think that combo was tested at all."
  # https://bugs.gentoo.org/749330
  #   cstddef: fatal error: stddef.h file not found
in

stdenv.mkDerivation rec {
  pname = "shiboken6";

  inherit (pyside6) version src;

  patches = [
    #./nix_compile_cflags.patch
    # https://bugreports.qt.io/browse/PYSIDE-787
    # sources/shiboken2/ApiExtractor/clangparser/compilersupport.cpp

    #./milahu-debug.patch
  ];

  postPatch = ''
    cp ${./apiextractor.cpp} sources/shiboken6/ApiExtractor/apiextractor.cpp
    cp ${./compilersupport.cpp} sources/shiboken6/ApiExtractor/clangparser/compilersupport.cpp
    cp ${./clangparser.cpp} sources/shiboken6/ApiExtractor/clangparser/clangparser.cpp

    cd sources/${pname}

    export QT_LOGGING_RULES="*.debug=true"
  '';

  #CLANG_INSTALL_DIR = llvmPackages.libclang.out;
  #CLANG_INSTALL_DIR = "${llvmPackages.libclang.lib}:${llvmPackages.libcxx.dev}"; # /lib/clang/9.0.1/include/
  CLANG_INSTALL_DIR = llvmPackages.libclang.lib; # /lib/clang/*/include/

  nativeBuildInputs = [ cmake ];

  /*
    nix-locate -r '/bin/clang$'
      llvmPackages_10.clang-unwrapped.out
      clang_10.out
      llvmPackages_10.libcxxClang.out
        # /nix/store/6libmvgdy131yw5z1c4g3gl938c4c4rz-clang-wrapper-10.0.1
        # /nix/store/6libmvgdy131yw5z1c4g3gl938c4c4rz-clang-wrapper-10.0.1/bin/clang
      llvmPackages_10.clangNoLibcxx.out
      llvmPackages_10.clangNoCompilerRt.out
      llvmPackages_10.clangNoLibc.out
      llvmPackages_10.clangUseLLVM.out
  */

  #buildInputs = [
  propagatedBuildInputs = [
    llvmPackages.libclang # ClangConfig.cmake
    llvmPackages.libllvm # LLVMConfig.cmake
    /* messing with llvmPackages.stdenv? -> "gppInternalIncludePaths: runProcess stdOut" shows no include paths
    llvmPackages.libcxxClang # bin/clang
    llvmPackages.libcxx # include <type_traits> -> ${llvmPackages_9.libcxx.dev}/include/c++/v1/type_traits
    */

    # clang 9: qtbase-6.2.2-dev/include/QtCore/qmetatype.h: error: constexpr variable 'len' must be initialized by a constant
    /*
    llvmPackages.libllvm
    llvmPackages.clang-unwrapped
    llvmPackages.libclang # ${llvmPackages_9.libclang.lib}/lib/clang/9.0.1/include
    llvmPackages.libcxx # include <type_traits> -> ${llvmPackages_9.libcxx.dev}/include/c++/v1/type_traits
    */
    # /nix/store/vdfr889lwm84xzgabqhdnm9vwc0xrwy1-libcxx-9.0.1-dev/include/c++/v1/type_traits
    # /nix/store/vb1dk5c3xg9r8q6mdw3cl3qgzm6vgnvd-libcxx-10.0.1-dev/include/c++/v1/
    python

    #qt6.qtbase # TODO test
    # does shiboken need qtbase?
    # bugfix by moving qtbase to /tmp? (or why are qt headers not found?)
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
