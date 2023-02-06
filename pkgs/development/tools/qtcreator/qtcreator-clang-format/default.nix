{ stdenv
, lib
, fetchurl
, fetchgit
, fetchpatch
, cmake
, qtbase
, qt5compat
, qtdeclarative
, qtquick3d
, qtquicktimeline
, qtserialport
, qtsvg
, qttools
, wrapQtAppsHook
  #, qtwebengine
, llvmPackages # "The currently recommended LLVM/Clang version is 14.0."
, buildLlvmTools
, elfutils
, rustc-demangle
, pkg-config
, withDocumentation ? false
, withClangPlugins ? true
, symlinkJoin
, fixDarwinDylibNames

# trying build without ninja
, python3
}:

let
  /*
    wontfix? patch breaks with clang 15.0.7

    applying patch for clang-format
    patching file include/clang/Format/Format.h
    Hunk #1 succeeded at 21 with fuzz 1 (offset -1 lines).
    Hunk #2 succeeded at 1668 (offset -885 lines).
    Hunk #3 succeeded at 2370 with fuzz 1 (offset -1562 lines).
    patching file lib/Format/Format.cpp
    Hunk #1 succeeded at 532 with fuzz 1 (offset -282 lines).
    Hunk #2 succeeded at 891 with fuzz 2 (offset -388 lines).
    Hunk #3 succeeded at 976 (offset -407 lines).
    patching file lib/Format/UnwrappedLineFormatter.cpp
    Hunk #1 succeeded at 732 (offset -187 lines).
    Hunk #2 FAILED at 961.
    Hunk #3 succeeded at 819 (offset -201 lines).
    Hunk #4 succeeded at 845 (offset -201 lines).
    1 out of 4 hunks FAILED -- saving rejects to file lib/Format/UnwrappedLineFormatter.cpp.rej
    patching file lib/Format/UnwrappedLineParser.cpp
    Hunk #1 succeeded at 3063 with fuzz 2 (offset -1133 lines).
    patching file unittests/Format/FormatTest.cpp
    Hunk #1 succeeded at 393 (offset -134 lines).
  */
  clang-format-patch =
    # TODO: use latest patch from https://code.qt.io/cgit/clang/llvm-project.git/
    # [clang-format] Introduce the flag which allows not to shrink lines
    let
      rev = "218224bce00c69b6f8a396e681c51256fc6f1b99";
    in
    fetchpatch rec {
      name = "${rev}.patch";
      url = "https://code.qt.io/cgit/clang/llvm-project.git/patch/?id=${rev}";
      sha256 = "sha256-iG3DVY7fa8/yMbTpiFu05WlWq0JmIZPVKFFVlxIvMGI=";
    };
  enableManpages = false; # TODO? get value from llvmPackages.clang-unwrapped
in

llvmPackages.clang-unwrapped.overrideAttrs (oldAttrs: rec {
  pname = "qtcreator-clang-format";
  version = "15.0.0";

  src = fetchgit {
    # https://code.qt.io/cgit/clang/llvm-project.git/
    url = "https://code.qt.io/clang/llvm-project.git";
    # note: refs/heads != refs/tags
    # git ls-remote https://code.qt.io/clang/llvm-project.git
    rev = "refs/heads/release_${version}-based";
    sha256 = "sha256-/MPeDgGPMUYabw9l1hWFtWO3NPd9g54v/TNP0rjoXyg=";
  };

  nativeBuildInputs = [
    cmake
    # build without ninja
    #ninja # TODO restore
    python3
  ]
  #++ lib.optional enableManpages python3.pkgs.sphinx
  ++ lib.optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;

  #buildInputs = [ libxml2 libllvm ];
  buildInputs = oldAttrs.buildInputs ++ [
    llvmPackages.clang-unwrapped
    #llvmPackages.clang-unwrapped.lib # TODO use headers from  /lib/clang/13.0.0/include/xsaveintrin.h
    #clang-unwrapped-no-clang-format
    # llvm is propagated by clang-unwrapped, so we also must patch llvm
    # not working... original llvm is still propagated
    #llvm-no-clang-format
    # better: copy + patch ClangConfig.cmake and LLVMConfig.cmake files
  ];

  cmakePcfileCheckPhase = "";

  outputs = [ "out" ];

  # TODO make this shorter
  # this is a "subtractive" approach:
  # use the clang sourcetree and remove all unnecessary parts.
  # TODO try an "additive" approach:
  # take only ClangFormat.cpp and CMakeLists.txt
  # and try to build it with libraries and headers
  # from llvm and clang-unwrapped

  /*
    echo "applying patch for clang-format"
    # -p2: patch is for llvm, but sourceRoot is llvm/clang
    patch -p2 < ${clang-format-patch}
  */
  postPatch = (oldAttrs.postPatch or "") + ''
    if false; then
    echo "patching cmake files of llvm and clang"
    mkdir patched-cmake-modules
    cp -r --no-preserve=mode,ownership \
      ${llvmPackages.llvm.dev}/lib/cmake/llvm \
      ${llvmPackages.clang-unwrapped.dev}/lib/cmake/clang \
      patched-cmake-modules/
    find patched-cmake-modules/ -type f -print0 | xargs -0 sed -i 's|clang-format|original-clang-format|g'
    substituteInPlace CMakeLists.txt \
      --replace \
        'if(LLVM_ENABLE_LIBXML2)' \
        'list(PREPEND CMAKE_MODULE_PATH
          "''${CMAKE_CURRENT_SOURCE_DIR}/patched-cmake-modules/llvm"
          "''${CMAKE_CURRENT_SOURCE_DIR}/patched-cmake-modules/clang"
        )
        if(LLVM_ENABLE_LIBXML2)'
    sed -i 's|${llvmPackages.llvm.dev}/include|'$PWD/patched-cmake-modules/llvm'|g' patched-cmake-modules/llvm/*
    sed -i 's|${llvmPackages.clang-unwrapped.dev}/include|'$PWD/patched-cmake-modules/clang'|g' patched-cmake-modules/clang/*
    export CMAKE_INCLUDE_PATH=$(echo $CMAKE_INCLUDE_PATH | tr : $'\n'  | grep -v -e ${llvmPackages.llvm.dev} -e ${llvmPackages.clang-unwrapped.dev} | xargs printf "%s:")
    export CMAKE_PREFIX_PATH=$(echo $CMAKE_PREFIX_PATH | tr : $'\n'  | grep -v -e ${llvmPackages.llvm.dev} -e ${llvmPackages.clang-unwrapped.dev} | xargs printf "%s:")
    fi

    echo "adding dependency libclang"
    cp CMakeLists.txt{,.bak}
    substituteInPlace CMakeLists.txt \
      --replace \
        'link_directories("''${LLVM_LIBRARY_DIR}")' \
        'link_directories("''${LLVM_LIBRARY_DIR}")
        find_package(Clang REQUIRED)
        include_directories(''${CLANG_INCLUDE_DIRS})
        add_definitions(''${CLANG_DEFINITIONS})
        '
    cp tools/clang-format/CMakeLists.txt{,.bak}
    substituteInPlace tools/clang-format/CMakeLists.txt \
      --replace \
        '  ''${CLANG_FORMAT_LIB_DEPS}' \
        '  ''${CLANG_FORMAT_LIB_DEPS} clangTooling'

    echo "removing target clang-tablegen-targets"
    substituteInPlace CMakeLists.txt \
      --replace \
        'get_property(CLANG_TABLEGEN_TARGETS GLOBAL PROPERTY CLANG_TABLEGEN_TARGETS)' \
        'if(false)' \
      --replace \
        'list(APPEND LLVM_COMMON_DEPENDS clang-tablegen-targets)' \
        'endif()'

    #build_headers=false # fast but error: missing target clang-resource-headers
    build_headers=true # slow

    echo "removing all targets except tools/clang-format ..."
    #cp CMakeLists.txt{,.bak}
    #for dir in lib tools include utils/TableGen; do # lib should be provided by libclang
    #for dir in tools include utils/TableGen; do
    for dir in tools; do
      sed -i -E 's|(add_subdirectory)(\('$dir'\))|\1____keep_this____\2|' CMakeLists.txt
    done
    if $build_headers; then
    for dir in lib utils/TableGen; do
      sed -i -E 's|(add_subdirectory)(\('$dir'\))|\1____keep_this____\2|' CMakeLists.txt
    done
    fi
    sed -i 's|add_subdirectory(.*)||' CMakeLists.txt
    sed -i 's|____keep_this____||' CMakeLists.txt
    diff -u --color=always CMakeLists.txt{.bak,} || true
    #rm CMakeLists.txt.bak

    if $build_headers; then
    # debug: add lib/Headers
    pushd lib
    cp CMakeLists.txt{,.bak}
    #for dir in Headers Basic Format Rewrite Tooling Support; do
    for dir in Headers; do
      sed -i -E 's|(add_subdirectory)(\('$dir'\))|\1____keep_this____\2|' CMakeLists.txt
    done
    sed -i 's|add_subdirectory(.*)||' CMakeLists.txt
    sed -i 's|____keep_this____||' CMakeLists.txt
    diff -u --color=always CMakeLists.txt{.bak,} || true
    rm CMakeLists.txt.bak
    popd
    fi

    pushd tools
    cp CMakeLists.txt{,.bak}
    for dir in clang-format; do
      sed -i -E 's|(add_clang_subdirectory)(\('$dir'\))|\1____keep_this____\2|' CMakeLists.txt
    done
    sed -i 's|add_clang_subdirectory(.*)||' CMakeLists.txt
    sed -i 's|____keep_this____||' CMakeLists.txt
    # similar to add_subdirectory(extra)
    sed -i 's|add_llvm_external_project(clang-tools-extra extra)||' CMakeLists.txt
    diff -u --color=always CMakeLists.txt{.bak,} || true
    #rm CMakeLists.txt.bak
    popd

    echo "renaming target clang-format ..."
    pushd tools/clang-format
    #cp CMakeLists.txt{,.bak}
    sed -i -E 's/clang-format(\)|$)/qtcreator-clang-format\1/' CMakeLists.txt
    if false; then
    # produce clang-format binary
    substituteInPlace CMakeLists.txt \
      --replace \
        'set(CLANG_FORMAT_LIB_DEPS' \
        'set_target_properties(qtcreator-clang-format PROPERTIES OUTPUT_NAME clang-format)
        set(CLANG_FORMAT_LIB_DEPS'
    fi
    diff -u --color=always CMakeLists.txt{.bak,} || true
    #rm CMakeLists.txt.bak
    popd
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -v bin/qtcreator-clang-format $out/bin
  '';

  # debug
  preFixup = ''
    set -x
  '';

  cmakeFlags = [
    "-DCLANG_BUILD_TOOLS=ON" # TODO? add this to nixpkgs clang
    /*
    CMake Error at /nix/store/crizhk9d7zi3i34rrbw87vcbvffckm8b-llvm-15.0.7-dev/lib/cmake/llvm/TableGen.cmake:10 (message):
      CLANG_TABLEGEN_EXE not set
    Call Stack (most recent call first):
      cmake/modules/AddClang.cmake:25 (tablegen)
      lib/Headers/CMakeLists.txt:287 (clang_tablegen)
      lib/Headers/CMakeLists.txt:306 (clang_generate_header)
    */
    "-DCLANG_TABLEGEN_EXE=1"

    /*
    CMake Warning (dev) at /nix/store/crizhk9d7zi3i34rrbw87vcbvffckm8b-llvm-15.0.7-dev/lib/cmake/llvm/TableGen.cmake:103 (add_custom_command):
      Policy CMP0116 is not set: Ninja generators transform DEPFILEs from
      add_custom_command().  Run "cmake --help-policy CMP0116" for policy
      details.  Use the cmake_policy command to set the policy and suppress this
      warning.
    Call Stack (most recent call first):
      cmake/modules/AddClang.cmake:25 (tablegen)
      lib/Headers/CMakeLists.txt:287 (clang_tablegen)
      lib/Headers/CMakeLists.txt:341 (clang_generate_header)
    */
    "-DCMAKE_POLICY_DEFAULT_CMP0116=NEW"

    "-DCLANG_INSTALL_PACKAGE_DIR=${placeholder "dev"}/lib/cmake/clang"
    "-DCLANGD_BUILD_XPC=OFF"
    "-DLLVM_ENABLE_RTTI=ON"
  ] ++ lib.optionals enableManpages [
    "-DCLANG_INCLUDE_DOCS=ON"
    "-DLLVM_ENABLE_SPHINX=ON"
    "-DSPHINX_OUTPUT_MAN=ON"
    "-DSPHINX_OUTPUT_HTML=OFF"
    "-DSPHINX_WARNINGS_AS_ERRORS=OFF"
  ] ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "-DLLVM_TABLEGEN_EXE=${buildLlvmTools.llvm}/bin/llvm-tblgen"
    "-DCLANG_TABLEGEN=${buildLlvmTools.libclang.dev}/bin/clang-tblgen"
  ];

})

