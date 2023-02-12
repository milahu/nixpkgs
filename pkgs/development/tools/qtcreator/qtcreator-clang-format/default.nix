{ lib
, stdenv
, fetchurl
, cmake
, llvmPackages
}:

let
  getMajorMinor = s: builtins.concatStringsSep "." (lib.take 2 (lib.splitVersion s));
in

stdenv.mkDerivation rec {
  pname = "qtcreator-clang-format";
  version = let
      version = "15.0.0";
      actual = getMajorMinor version;
      expected = getMajorMinor llvmPackages.llvm.version;
    in
    assert actual != expected ->
      throw "version mismatch: actual=${pname}.version=${actual} expected=llvm.version=${expected}";
    version;

  gitTag = "release_${version}-based";

  src = fetchurl {
      name = "ClangFormat.cpp";
      url = "https://code.qt.io/cgit/clang/llvm-project.git/plain/clang/tools/clang-format/ClangFormat.cpp?h=${gitTag}";
      sha256 = "sha256-6rN0VmUvl3xxqt4lvEzbbTnOpnmkDmNyZDF3mQQiFTc=";
    };

  unpackPhase = ''
    mkdir source
    cd source
    cp --no-preserve=mode $src ClangFormat.cpp
    cp --no-preserve=mode ${./CMakeLists.txt} CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    llvmPackages.clang-unwrapped
    llvmPackages.llvm
  ];

  meta = with lib; {
    description = "qtcreator fork of clang-format";
    longDescription = ''
      [clang-format] Introduce the flag which allows not to shrink lines

      https://reviews.llvm.org/D53072

      Currently there's no way to prevent to lines optimization even
      if you have intentionally put <CR> to split the line.

      In general case it's fine. So I would prefer to have such option
      which you can enable in special cases (for me it's an IDE related use case).

      Revert this change if upstream clang-format offers better solution.
    '';
    homepage = "https://code.qt.io/cgit/clang/llvm-project.git/tree/clang/tools/clang-format?h=${gitTag}";
    inherit (llvmPackages.llvm.meta) license platforms;
    maintainers = [ ];
  };
}
