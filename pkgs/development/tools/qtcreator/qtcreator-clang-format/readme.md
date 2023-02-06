# qtcreator-clang-format

build only clang-format of llvm-project



## dependencies

clang/tools/clang-format/CMakeLists.txt

```cmake
set(CLANG_FORMAT_LIB_DEPS
  clangBasic # clang/lib/Basic/CMakeLists.txt:39:add_clang_library(clangBasic
  clangFormat # clang/lib/Format/CMakeLists.txt:3:add_clang_library(clangFormat
  clangRewrite # clang/lib/Rewrite/CMakeLists.txt:5:add_clang_library(clangRewrite
  clangToolingCore # clang/lib/Tooling/Core/CMakeLists.txt:3:add_clang_library(clangToolingCore
  )
```



## error: missing ClangDriverOptions

```
$ eval ${configurePhase:-configurePhase}
  The dependency target "ClangDriverOptions" of target "obj.clangTooling"
  does not exist.
Call Stack (most recent call first):
  cmake/modules/AddClang.cmake:106 (llvm_add_library)
  lib/Tooling/CMakeLists.txt:101 (add_clang_library)
```

### debug

```
$ find clang -name CMakeLists.txt | xargs grep -Hnw ClangDriverOptions | grep add_
clang/include/clang/Driver/CMakeLists.txt:3:add_public_tablegen_target(ClangDriverOptions)
```

### fix

restore this in clang/CMakeLists.txt

```
add_subdirectory(include)
```

remove all except this in clang/include/clang/CMakeLists.txt

```
add_subdirectory(Driver)
```



## error: missing lib/Headers/1

```
$ eval ${buildPhase:-buildPhase}
build flags: -j3
ninja: error: 'lib/Headers/1', needed by 'lib/Headers/arm_sve.h', missing and no known rule to make it
```

### debug

what cmake target provides "lib/Headers/1"?

remove patchPhase, run

```
grep -r ^lib/Headers/1
```

no match!

&rarr; "lib/Headers/1" is not a target

lib/Headers/arm_sve.h is built by
clang/lib/Headers/CMakeLists.txt:

```
  clang_generate_header(-gen-arm-sve-header arm_sve.td arm_sve.h)
```

clang_generate_header is defined in
clang/lib/Headers/CMakeLists.txt:

```
function(clang_generate_header td_option td_file out_file)
  clang_tablegen(${out_file} ${td_option}
  -I ${CLANG_SOURCE_DIR}/include/clang/Basic/
  SOURCE ${CLANG_SOURCE_DIR}/include/clang/Basic/${td_file})
```

clang_tablegen is defined in

```
$ grep -r "function(clang_tablegen"
```

cmake/modules/AddClang.cmake:

```
function(clang_tablegen)
  tablegen(CLANG ${CTG_UNPARSED_ARGUMENTS} ${CLANG_TABLEGEN_ARGUMENTS})
```

tablegen is defined in

```
$ grep -r "function(tablegen"
```

&rarr; no match

hmm, something is missing ...

### fix

this looks good:

```
clang/CMakeLists.txt:
add_subdirectory(utils/TableGen)
```



## error: missing AttrParsedAttrList.inc

```
$ eval ${buildPhase:-buildPhase}
[ 31%] Building CXX object lib/Basic/CMakeFiles/obj.clangBasic.dir/Attributes.cpp.o
In file included from /tmp/tmp.laufIvQQzj/clang-qt/clang-src-15.0.7/clang/include/clang/Basic/Attributes.h:12,
                 from /tmp/tmp.laufIvQQzj/clang-qt/clang-src-15.0.7/clang/lib/Basic/Attributes.cpp:1:
/tmp/tmp.laufIvQQzj/clang-qt/clang-src-15.0.7/clang/include/clang/Basic/AttributeCommonInfo.h:57:10: fatal error: clang/Sema/AttrParsedAttrList.inc: No such file or directory
   57 | #include "clang/Sema/AttrParsedAttrList.inc"
      |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

```
$ grep -r AttrParsedAttrList.inc
include/clang/Sema/CMakeLists.txt:clang_tablegen(AttrParsedAttrList.inc -gen-clang-attr-parsed-attr-list
include/clang/Basic/AttributeCommonInfo.h:#include "clang/Sema/AttrParsedAttrList.inc"
```

### fix

add include/clang/Sema



## error: missing clangSupport

```
[ 33%] Linking CXX executable ../../bin/clang-tblgen
/nix/store/178vvank67pg2ckr5ic5gmdkm3ri72f3-binutils-2.39/bin/ld: cannot find -lclangSupport: No such file or directory
```

### debug

```
grep -r clangSupport | grep add_
lib/Support/CMakeLists.txt:add_clang_library(clangSupport
```

### fix

add lib/Support



## error: missing DiagnosticCommonKinds.inc

```
[ 42%] Copying clang's openmp_wrappers/cmath...
In file included from /tmp/tmp.laufIvQQzj/clang-qt/clang-src-15.0.7/clang/include/clang/Basic/Diagnostic.h:17,
                 from /tmp/tmp.laufIvQQzj/clang-qt/clang-src-15.0.7/clang/include/clang/Basic/SourceManager.h:37,
                 from /tmp/tmp.laufIvQQzj/clang-qt/clang-src-15.0.7/clang/lib/Rewrite/HTMLRewrite.cpp:15:
/tmp/tmp.laufIvQQzj/clang-qt/clang-src-15.0.7/clang/include/clang/Basic/DiagnosticIDs.h:73:10: fatal error: clang/Basic/DiagnosticCommonKinds.inc: No such file or directory
   73 | #include "clang/Basic/DiagnosticCommonKinds.inc"
      |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
compilation terminated.
```

### debug

```
$ grep -r DiagnosticCommonKinds.inc
```

no match

```
grep -r DiagnosticCommonKinds
include/clang/Basic/DiagnosticCommonKinds.td://==--- DiagnosticCommonKinds.td - common diagnostics ---------------------===//
include/clang/Basic/Diagnostic.td:include "DiagnosticCommonKinds.td"
```

### fix

add include/clang/Basic




## error: missing TypeNodes.inc

```
[ 80%] Building CXX object lib/Tooling/Inclusions/CMakeFiles/obj.clangToolingInclusions.dir/StandardLibrary.cpp.o
In file included from /tmp/tmp.laufIvQQzj/clang-qt/clang-src-15.0.7/clang/include/clang/AST/DeclarationName.h:16,
                 from /tmp/tmp.laufIvQQzj/clang-qt/clang-src-15.0.7/clang/include/clang/AST/DeclBase.h:18,
                 from /tmp/tmp.laufIvQQzj/clang-qt/clang-src-15.0.7/clang/include/clang/AST/Decl.h:19,
                 from /tmp/tmp.laufIvQQzj/clang-qt/clang-src-15.0.7/clang/include/clang/Tooling/Inclusions/StandardLibrary.h:18,
                 from /tmp/tmp.laufIvQQzj/clang-qt/clang-src-15.0.7/clang/lib/Tooling/Inclusions/StandardLibrary.cpp:9:
/tmp/tmp.laufIvQQzj/clang-qt/clang-src-15.0.7/clang/include/clang/AST/Type.h:139:10: fatal error: clang/AST/TypeNodes.inc: No such file or directory
  139 | #include "clang/AST/TypeNodes.inc"
      |          ^~~~~~~~~~~~~~~~~~~~~~~~~
```

### fix

add include/clang/AST

... and while were at it, add all include/clang/*



## error: missing libclang-cpp.so

```
[ 94%] Linking CXX executable ../../bin/clang-format
/nix/store/178vvank67pg2ckr5ic5gmdkm3ri72f3-binutils-2.39/bin/ld: cannot find -lclang-cpp: No such file or directory
collect2: error: ld returned 1 exit status
make[2]: *** [tools/clang-format/CMakeFiles/clang-format.dir/build.make:98: bin/clang-format] Error 1
make[1]: *** [CMakeFiles/Makefile2:6088: tools/clang-format/CMakeFiles/clang-format.dir/all] Error 2
```

### debug

we dont want to build libclang-cpp.so

not building clang is the whole point of this exercise

```
$ nix-locate libclang-cpp.so
llvmPackages.libclang.lib
llvmPackages.clang-unwrapped.lib
```



TODO using libclang-cpp.so in a cmake project

something like

```
find_package(libclang)
target_link_libraries(clang-format libclang::libclang-cpp)
```

https://stackoverflow.com/questions/55921707/setting-path-to-clang-library-in-cmake

LLVM is already included, so we only need clang

```cmake
find_package(Clang REQUIRED)
include_directories(${CLANG_INCLUDE_DIRS})
add_definitions(${CLANG_DEFINITIONS})

add_llvm_executable(myTool main.cpp)
set_property(TARGET myTool PROPERTY CXX_STANDARD 11)
target_link_libraries(myTool PRIVATE clangTooling)
```



## error: target exists

after adding dependency libclang

```
CMake Error at CMakeLists.txt:551 (add_custom_target):
  add_custom_target cannot create target "clang-tablegen-targets" because
  another target with the same name already exists.  The existing target is a
  custom target created in source directory
  "/tmp/tmp.laufIvQQzj/clang-qt/clang-src-15.0.7/clang".  See documentation
  for policy CMP0002 for more details.
```

### fix

remove target tablegen



## error: missing target clang-resource-headers

```
CMake Error at cmake/modules/AddClang.cmake:163 (add_dependencies):
  The dependency target "clang-resource-headers" of target "clang-format-qt"
  does not exist.
Call Stack (most recent call first):
  tools/clang-format/CMakeLists.txt:3 (add_clang_tool)
```

### fix

build with headers

= add lib/Headers + add utils/TableGen

TODO: use compiled headers
llvmPackages_13.clang-unwrapped.lib
/lib/clang/13.0.0/include/xsaveintrin.h




## error: missing clang-15.0.7-dev

error in fixupPhase

```
post-installation fixup
shrinking RPATHs of ELF executables and libraries in /nix/store/kqy4b7hxqmgkbmdbyzk3rzka48b5f97z-clang-15.0.7
shrinking /nix/store/kqy4b7hxqmgkbmdbyzk3rzka48b5f97z-clang-15.0.7/bin/clang-format
shrinking /nix/store/kqy4b7hxqmgkbmdbyzk3rzka48b5f97z-clang-15.0.7/bin/clang-tblgen
checking for references to /build/ in /nix/store/kqy4b7hxqmgkbmdbyzk3rzka48b5f97z-clang-15.0.7...
patching script interpreter paths in /nix/store/kqy4b7hxqmgkbmdbyzk3rzka48b5f97z-clang-15.0.7
strip is /nix/store/iiq295j1z4q1sxmdbrl2j8ma3l5ns4wr-gcc-wrapper-11.3.0/bin/strip
stripping (with command strip and flags -S) in  /nix/store/kqy4b7hxqmgkbmdbyzk3rzka48b5f97z-clang-15.0.7/bin
strip is /nix/store/iiq295j1z4q1sxmdbrl2j8ma3l5ns4wr-gcc-wrapper-11.3.0/bin/strip
strip is /nix/store/iiq295j1z4q1sxmdbrl2j8ma3l5ns4wr-gcc-wrapper-11.3.0/bin/strip
strip is /nix/store/iiq295j1z4q1sxmdbrl2j8ma3l5ns4wr-gcc-wrapper-11.3.0/bin/strip
find: '/nix/store/mplv7v5f340ix8w5y910znkvzrp17lkk-clang-15.0.7-dev': No such file or directory
```

### debug

```nix
{
  preFixup = ''
    set -x
  '';
```

```
++ _eval cmakePcfileCheckPhase
++ declare -F cmakePcfileCheckPhase
++ cmakePcfileCheckPhase
++ IFS=
++ read -rd '' file
+++ find /nix/store/fzmq3c6dhm896bz3dm7qqf6pbzpadcv1-clang-15.0.7-dev -iname '*.pc' -print0
find: '/nix/store/fzmq3c6dhm896bz3dm7qqf6pbzpadcv1-clang-15.0.7-dev': No such file or directory
```

### fix

disable cmakePcfileCheckPhase

```nix
{
  cmakePcfileCheckPhase = "";
```



## error: no output lib

```
error: builder for '/nix/store/g87yw4h149q3fypvyyh2cnzicz7xg019-clang-15.0.7.drv' failed to produce output path for output 'lib' at '/nix/store/g87yw4h149q3fypvyyh2cnzicz7xg019-clang-15.0.7.drv.chroot/nix/store/r4i2j6kc0xxhd54s55c51mywc2xpzhz4-clang-15.0.7-lib'
```

### fix

```nix
{
  outputs = [ "out" ];
```



## notes

ideally we would store the internal build files in clang-unwrapped.dev

files like

```
[  0%] Copying clang's mm_malloc.h...

[  0%] Copying clang's builtins.h...

[  0%] Copying clang's __clang_cuda_builtin_vars.h...
[  0%] Copying clang's __clang_cuda_cmath.h...
[  1%] Copying clang's __clang_cuda_complex_builtins.h...
[  1%] Copying clang's __clang_cuda_device_functions.h...
[  1%] Copying clang's __clang_cuda_intrinsics.h...
[  1%] Copying clang's __clang_cuda_libdevice_declares.h...
[  1%] Copying clang's __clang_cuda_math.h...
[  1%] Copying clang's __clang_cuda_math_forward_declares.h...
[  1%] Built target obj.clangSupport
[  2%] Copying clang's __clang_cuda_runtime_wrapper.h...
[  2%] Copying clang's __clang_cuda_texture_intrinsics.h...
[  2%] Copying clang's cuda_wrappers/algorithm...


[  9%] Copying clang's __wmmintrin_aes.h...
[  9%] Copying clang's __wmmintrin_pclmul.h...
[  9%] Copying clang's adxintrin.h...
[  9%] Copying clang's ammintrin.h...
[  9%] Copying clang's amxintrin.h...

Options.inc
libclangSupport.a

bin/clang-tblgen

[ 28%] Building arm_neon.h...
[ 28%] Building arm_mve.h...
[ 28%] Building arm_sve.h...
[ 29%] Building arm_bf16.h...
[ 29%] Building arm_cde.h...
[ 29%] Copying clang's arm_cmse.h...
[ 29%] Copying clang's arm_neon_sve_bridge.h...
[ 29%] Copying clang's arm64intr.h...
[ 29%] Copying clang's armintr.h...


[ 31%] Building Attrs.inc...
[ 31%] Building AttrImpl.inc...
[ 31%] Building AttrTextNodeDump.inc...
[ 31%] Building AttrNodeTraverse.inc...
[ 31%] Building AttrVisitor.inc...
[ 31%] Building StmtNodes.inc...

[ 36%] Building arm_neon.inc...
[ 36%] Building arm_fp16.inc...
[ 36%] Building arm_mve_builtins.inc...
[ 37%] Building arm_mve_builtin_cg.inc...
[ 37%] Building arm_mve_builtin_sema.inc...

[ 41%] Copying clang's float.h...
[ 42%] Copying clang's inttypes.h...
[ 42%] Copying clang's iso646.h...
[ 42%] Built target clang-tablegen-targets
[ 42%] Copying clang's limits.h...
[ 42%] Copying clang's module.modulemap...
[ 42%] Generating VCSVersion.inc
[ 42%] Copying clang's stdalign.h...

[ 80%] Building CXX object lib/Format/CMakeFiles/obj.clangFormat.dir/QualifierAlignmentFixer.cpp.o
[ 80%] Building CXX object lib/Basic/CMakeFiles/obj.clangBasic.dir/OperatorPrecedence.cpp.o
[ 80%] Building CXX object lib/Basic/CMakeFiles/obj.clangBasic.dir/ProfileList.cpp.o
[ 80%] Built target obj.clangToolingCore
```
