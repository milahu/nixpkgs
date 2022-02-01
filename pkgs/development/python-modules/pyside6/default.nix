{ buildPythonPackage
, python
, pythonPackages
, fetchurl
, lib
, stdenv # gcc
, cmake
, ninja
, qt6
, shiboken6
, llvmPackages_9
, llvmPackages_13
, llvmPackages_10
}:

# TODO refactor: pyside6 + shiboken6

/*
FIXME
https://bugreports.qt.io/browse/PYSIDE-787
(type) is specified in typesystem, but not declared

here:
qt.shiboken: (core) /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6/QtCore/typesystem_core_common.xml:2966: enum 'QAbstractAnimation::DeletionPolicy' is specified in typesystem, but not declared.
qt.shiboken: (core) /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6/QtCore/typesystem_core_common.xml:2967: enum 'QAbstractAnimation::Direction' is specified in typesystem, but not declared.
qt.shiboken: (core) /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6/QtCore/typesystem_core_common.xml:2968: enum 'QAbstractAnimation::State' is specified in typesystem, but not declared.
qt.shiboken: (core) /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6/QtCore/typesystem_core_common.xml:2123: type 'QAbstractEventDispatcher' is specified in typesystem, but not defined. This could potentially lead to compilation errors.
qt.shiboken: (core) /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6/QtCore/typesystem_core_common.xml:2126: type 'QAbstractEventDispatcher::TimerInfo' is specified in typesystem, but not defined. This could potentially lead to compilation errors.
qt.shiboken: (core) /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6/QtCore/typesystem_core_common.xml:1524: type 'QAbstractItemModel' is specified in typesystem, but not defined. This could potentially lead to compilation errors.
qt.shiboken: (core) /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6/QtCore/typesystem_core_common.xml:1525: enum 'QAbstractItemModel::CheckIndexOption' is specified in typesystem, but not declared.
qt.shiboken: (core) /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6/QtCore/typesystem_core_common.xml:1526: enum 'QAbstractItemModel::LayoutChangeHint' is specified in typesystem, but not declared.

Side6/QtCore/typesystem_core_common.xml:2435: enum 'QProcess::ExitStatus' is specified in typesystem, but not declared.
Side6/QtCore/typesystem_core_common.xml:2436: enum 'QProcess::InputChannelMode' is specified in typesystem, but not declared.
Side6/QtCore/typesystem_core_common.xml:2437: enum 'QProcess::ProcessChannel' is specified in typesystem, but not declared.
Side6/QtCore/typesystem_core_common.xml:2438: enum 'QProcess::ProcessChannelMode' is specified in typesystem, but not declared.
Side6/QtCore/typesystem_core_common.xml:2439: enum 'QProcess::ProcessError' is specified in typesystem, but not declared.
Side6/QtCore/typesystem_core_common.xml:2440: enum 'QProcess::ProcessState' is specified in typesystem, but not declared.

Side6/QtCore/typesystem_core_common.xml:581: enum 'Qt::ApplicationState' is specified in typesystem, but not declared.



The "type 'xxx' is specified in typesystem, but not defined. This could potentially lead to compilation errors." messages appear when include paths or include headers are not found by shiboken / libclang code.
Sounds like the build fails to find any qt headers.

The core issue is that the include paths queried from "g++ -E -x c++ - -v </dev/null" are considered system include headers, and shiboken skips parsing most of them for 2 reasons: performance and some STL parsing issues.

The build fails because your Qt headers are within those system include paths, and they are not parsed, thus all the missing type warnings, and failed build.

For the build process to work, currently the Qt headers need to be placed in a location that is not reported by "g++ / clang -E -x c++ - -v </dev/null". In this case somewhere outside /usr/include. Perhaps you can try to symlink the Qt headers to /usr/local/include or some other similar location.





*/

/*

(core) clang_parseTranslationUnit2(
  0x0,
  cmd[12]=
    -fPIC
    -Wno-constant-logical-operand
    -std=c++17
    -I/build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6
    -I/nix/store/0kb2vf3qnvd0cccgn6g98w4lyy7kadh7-qtbase-6.2.2-dev/mkspecs/linux-g++
    -I/nix/store/0kb2vf3qnvd0cccgn6g98w4lyy7kadh7-qtbase-6.2.2-dev/include
    -I/nix/store/0kb2vf3qnvd0cccgn6g98w4lyy7kadh7-qtbase-6.2.2-dev/include/QtCore
    -I/nix/store/0kb2vf3qnvd0cccgn6g98w4lyy7kadh7-qtbase-6.2.2-dev/include /build/QtCore_global_QCfFQK.hpp
    "-DQT_ANNOTATE_ACCESS_SPECIFIER(a)=__attribute__((annotate(#a)))"
    "-DQT_ANNOTATE_CLASS(type,...)=static_assert(sizeof(#__VA_ARGS__),#type);"
    -DQSIMD_H
  )

/nix/store/0kb2vf3qnvd0cccgn6g98w4lyy7kadh7-qtbase-6.2.2-dev/include/QtCore/qglobal.h:45:12:
fatal error: 'type_traits' file not found

*/

let
  # pyside6 requires clang >= 9
  #llvmPackages = llvmPackages_9;
  #llvmPackages = llvmPackages_13;
  llvmPackages = llvmPackages_10;
  #stdenv = llvmPackages.stdenv; # gcc -> clang

  sha256OfQtVersion = {
    pyside6 = {
      "6.2.0" = "/tIQtmISmVUzLSYJqQC1uGQxMBNORoI3GyapumB0DQE=";
      "6.2.2" = "cKdMfHyeWvRsrlsZQ7w5oTmcQzKzQtLEgQOhz+mYkag=";
    };
    shiboken6 = {
      "6.2.0" = "3OO0NNXRvlC4kgeZZHu7I0bf2TMb+SJCUSgIUCAJfLg=";
      "6.2.2" = "HPyU53RhmRr/c+SlbPp1JDKfHVl00Jx+ecwsE6b+eR8=";
    };
  };
in

stdenv.mkDerivation rec {
  pname = "pyside6";
  version = "6.2.2";

  src = fetchurl {
    url = "https://download.qt.io/official_releases/QtForPython/pyside6/PySide6-${version}-src/pyside-setup-opensource-src-${version}.tar.xz";
    sha256 = sha256OfQtVersion.pyside6.${version};
  };

  /*
  shibokenWhl = fetchurl {
    url = "https://download.qt.io/official_releases/QtForPython/pyside6/shiboken6-${version}-${version}-cp36.cp37.cp38.cp39.cp310-abi3-manylinux1_x86_64.whl";
    sha256 = sha256OfQtVersion.shiboken6.${version};
  };
  */

  patches = [
    ./dont_ignore_optional_modules.patch
    # a: optional module X skipped
    # b: optional module X found
    #../shiboken6/milahu-debug.patch
  ];

  postPatch = ''
    cd sources/${pname}

    export QT_LOGGING_RULES="*.debug=true"
  '';

  #CLANG_INSTALL_DIR = llvmPackages.libclang.out;
  #LLVM_INSTALL_DIR = llvmPackages.libclang.lib;
  #CLANG_INSTALL_DIR = llvmPackages.libclang.lib; # /lib/clang
  #CLANG_INSTALL_DIR = "${llvmPackages.libclang.lib}:${llvmPackages.libcxx.dev}"; # /lib/clang
  CLANG_INSTALL_DIR = llvmPackages.libclang.lib; # /lib/clang/*/include/
  # /nix/store/r2hc62469m060alj70a86vyminlhbcsz-clang-9.0.1-lib/lib/clang/9.0.1/include/
  # /nix/store/r0zab6w8bwf93id0pq9pkwf3iw441zs7-clang-9.0.1-lib/lib/clang/9.0.1/include/

  # -- CLANG: /nix/store/n1ngp19bmngn7rdfqsf9vipwzx9y8vh3-clang-9.0.1-dev/lib/cmake/clang, /nix/store/r0zab6w8bwf93id0pq9pkwf3iw441zs7-clang-9.0.1-lib/lib/libclang.so.9 detected
  # qt.shiboken: (shiboken) CLANG builtins includes directory: /nix/store/r0zab6w8bwf93id0pq9pkwf3iw441zs7-clang-9.0.1-lib/lib/clang/9.0.1/include # ok
  # qt.shiboken: (shiboken) No C++ classes found!

  cmakeFlags = [
    "-DBUILD_TESTS=OFF"
    #"-DPYTHON_EXECUTABLE=${python.interpreter}"
  ];

  # clang 9:
  # /nix/store/0kb2vf3qnvd0cccgn6g98w4lyy7kadh7-qtbase-6.2.2-dev/include/QtCore/qglobal.h:45:12: fatal: 'type_traits' file not found
  # #ifdef __cplusplus
  # #  include <type_traits>
  # -> fails to include libcxx header

  nativeBuildInputs = [ cmake ninja qt6.qmake python ];

  buildInputs = [
    /*
    llvmPackages.libllvm
    llvmPackages.clang-unwrapped
    #llvmPackages.libclang.lib # /lib/clang
    llvmPackages.libclang # /lib/clang
    llvmPackages.libcxx # include <type_traits>
    #qt6.full
    qt6.qtbase
    */
  ] ++ (with pythonPackages; [
    packaging
    numpy
  ]);

  /*
    [21/796] Running generator for QtCore...

    FAILED:

    PySide6/QtCore/mjb_rejected_classes.log
    PySide6/QtCore/PySide6/QtCore/qabstractanimation_wrapper.cpp
    ...
    /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/build/PySide6/QtCore/PySide6/QtCore/qtcore_module_wrapper.cpp

    cd /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6/QtCore &&
    /nix/store/6anj1k4zwcij4db8q2n2rrdjp4pk1gla-shiboken6-6.2.2/bin/shiboken6
    --generator-set=shiboken
    --enable-parent-ctor-heuristic
    --enable-pyside-extensions
    --enable-return-value-heuristic
    --use-isnull-as-nb_nonzero
    --include-paths=
      /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6
      :
      /nix/store/0kb2vf3qnvd0cccgn6g98w4lyy7kadh7-qtbase-6.2.2-dev/mkspecs/linux-g++
      :
      /nix/store/0kb2vf3qnvd0cccgn6g98w4lyy7kadh7-qtbase-6.2.2-dev/include
      :
      /nix/store/0kb2vf3qnvd0cccgn6g98w4lyy7kadh7-qtbase-6.2.2-dev/include/QtCore
      :
      /nix/store/0kb2vf3qnvd0cccgn6g98w4lyy7kadh7-qtbase-6.2.2-dev/include
    --typesystem-paths=
      /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/build/PySide6
      :
      /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6
      :
      /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6/QtCore
    --output-directory=
      /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/build/PySide6/QtCore
    --license-file=
      /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6/QtCore/../licensecomment.txt
    --api-version=6.2
    /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/build/PySide6/QtCore_global.h
    /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6/QtCore/typesystem_core.xml




  (core) clang_parseTranslationUnit2(
    0x0,
    cmd[90]=
      -nostdinc
      -isystem/nix/store/0kb2vf3qnvd0cccgn6g98w4lyy7kadh7-qtbase-6.2.2-dev/include
      -isystem/nix/store/lb4ycs5dzn51shbmx2dflzflawhslaf8-libxml2-2.9.12-dev/include
      -isystem/nix/store/pnjapywqwhbi7y8462bc858y0k2j00dn-zlib-1.2.11-dev/include
      -isystem/nix/store/mxdbs4zvyh81g3x34j5sbls8kwkylxi0-libxslt-1.1.34-dev/include
      -isystem/nix/store/pm7hm97hs8fifq04csfg2cy3wi71biwf-openssl-1.1.1m-dev/include
      -isystem/nix/store/kj4j94q3px94ssxhjjq0dnxsw0qqdzmp-sqlite-3.37.2-dev/include
      -isystem/nix/store/8178hw0bl0m1vnrl846yyxywfai7f83v-unixODBC-2.3.9/include
      -isystem/nix/store/942ikm6nv8jhiwwn4w52gk1gzp24lqc2-harfbuzz-3.1.2-dev/include
      -isystem/nix/store/n6nhv2l4y435bh1zzlzy2rhq8lxwpacl-graphite2-1.3.14/include
      -isystem/nix/store/axhjqvzv3g0352g2w594ydpg2afa4y91-icu4c-70.1-dev/include
      -isystem/nix/store/kmqb8fhk9a8gcdyrpypp62hk8kbmclxs-libjpeg-turbo-2.1.2-dev/include
      -isystem/nix/store/2vr2yxg867xdxwnbn1bd8wkdz8d4pd7q-libpng-apng-1.6.37-dev/include
      -isystem/nix/store/w4dipb1q80f31v85bj1bs8mz96dq6vwp-pcre2-10.37-dev/include
      -isystem/nix/store/qfqd6mdpah4k4szmnm0i1xyz0zy7hrdd-pcre-8.45-dev/include
      -isystem/nix/store/xajbiwdsb81lp01zy13rcallwh2v1qz4-libproxy-0.4.17-dev/include
      -isystem/nix/store/id2ybgx9pmypn6pgkc36a23619v5sm62-freetype-2.11.1-dev/include
      -isystem/nix/store/xfdqky3mjmfym1a81chi2fmzv108lwq3-bzip2-1.0.6.0.2-dev/include
      -isystem/nix/store/b240s484a72h47jvsm5nbq319vprry58-fontconfig-2.13.94-dev/include
      -isystem/nix/store/awg4fi8jdcxmaz3sxj5l1di8dvs3b14p-xorgproto-2021.5/include
      -isystem/nix/store/5wm3ldyih10y7nfc2lspa6njbj2zimz1-libX11-1.7.2-dev/include
      -isystem/nix/store/zdafglyl2g65m1dvzkg4ciw60d92nmyr-libxcb-1.14-dev/include
      -isystem/nix/store/1lfv0dni0pp3qx9h4cknzrcxzjdz8vyw-libXt-1.2.1-dev/include
      -isystem/nix/store/87m5dv59gr7h2fkd9h69izy7wcaq1i1y-libSM-1.2.3-dev/include
      -isystem/nix/store/g08ikn9lvpbl2iq1wp3hbis82f1aznra-libICE-1.0.10-dev/include
      -isystem/nix/store/06w2phx9jzcabs9w69296vd89c61k16r-libXft-2.3.4-dev/include
      -isystem/nix/store/k7m6ji8jrrcxpyw4lhlr4zkwpb0dvs1r-libXrender-0.9.10-dev/include
      -isystem/nix/store/m8c62mfh7svp6qn3n0qp3yivnzcczpg5-libXext-1.3.4-dev/include
      -isystem/nix/store/ja5wbj0i2nfdibc3pp1m6wfizvdx7yrm-libXau-1.0.9-dev/include
      -isystem/nix/store/z5w4biv2fm08fvn2b7xh5lb8rjx93i7l-libXdmcp-1.1.3-dev/include
      -isystem/nix/store/55vaa2c3kzwn0lx7wc0bg1ng6sk3plr3-libXtst-1.2.3/include
      -isystem/nix/store/fnhdq2zmzd4j5ikbbzp32va98ajrxmz0-xcb-util-cursor-0.1.3-dev/include
      -isystem/nix/store/b6760lg2yqaqwirm21v90hq7cylnr44h-zstd-1.5.1-dev/include
      -isystem/nix/store/wwj2vkgzzd7vrdkkg975r2d323f60p59-double-conversion-3.1.6/include
      -isystem/nix/store/7fblcddxfbljhjjc8wa274s9vrv2v56m-util-linux-2.37.2-dev/include
      -isystem/nix/store/3nr4iq24z5h0k5ixx90663k6vdzfqcwc-systemd-249.7-dev/include
      -isystem/nix/store/akq4i9zrp9pd7idvbd6bz5rsxl0j1nag-libb2-0.98.1/include
      -isystem/nix/store/mimdlzdmialwa7mkhb46dnwrfxdlk6ak-md4c-0.4.8/include
      -isystem/nix/store/jzs13d99h4n9i9lwk5645cckprg309qj-mtdev-1.1.6/include
      -isystem/nix/store/v9ykbamm5scrakaxam4ag7z6y32xfbff-lksctp-tools-1.0.17/include
      -isystem/nix/store/w368x6mr9ch9pzv45l8zzzh40hkya58x-libselinux-3.3-dev/include
      -isystem/nix/store/37wvbljzidsna3zpp7mhc404w9am0yiz-libsepol-3.3-dev/include
      -isystem/nix/store/aljn24r8lpv43d55lr1k1z3jdak2gndn-lttng-ust-2.13.1/include
      -isystem/nix/store/9qlkfpsl6x61d13nciqx0k6x2a4p804h-liburcu-0.13.0/include
      -isystem/nix/store/rsc62ilgfy3s7ylpdvwhvfj1sz8s5npp-vulkan-headers-1.2.198.0/include
      -isystem/nix/store/awiw2i3iawks20zy5nd89bc8pvc07bkl-libthai-0.1.29-dev/include
      -isystem/nix/store/msl4z3pzcsbj1wrvq6rr6xhf190hmpfb-libdrm-2.4.109-dev/include
      -isystem/nix/store/gwka9jlag0dz0yq3cxpcxfv8zlk12zwn-libdatrie-2019-12-20-dev/include
      -isystem/nix/store/h0il0b2gc3krrkapxyx0gxsjhz246mk4-libepoxy-1.5.9-dev/include
      -isystem/nix/store/4w60ljyy4a341xkdk1bc3hwq286clklw-mariadb-connector-odbc-3.1.14/include
      -isystem/nix/store/76wqgvlmrhdv6jfyqj20rc8kvqx2d48h-dbus-1.12.20-dev/include
      -isystem/nix/store/whncbd95yf70d4dr6cxhpvw7bhb5f7p3-expat-2.4.2-dev/include
      -isystem/nix/store/rfp0srhcnbg7gfji53bxgq7gj3ihirzj-glib-2.70.2-dev/include
      -isystem/nix/store/23m4wsd74p1y1ygnq5m9xpmcdpzdxr3l-libffi-3.4.2-dev/include
      -isystem/nix/store/dgfsb2gr8z7c7fncw7w8igqgskisksgf-gettext-0.21/include
      -isystem/nix/store/q2iyd8wcijx165pjdqb2m182yqcsniil-glibc-iconv-2.33/include
      -isystem/nix/store/6ymqcwp9p4iprsyrj467r74jpx1z6sfs-libXcomposite-0.4.5-dev/include
      -isystem/nix/store/cjywpw97hgih9knw104kyzfjcn7xsvph-libXfixes-6.0.0-dev/include
      -isystem/nix/store/aadvbh5xjbddk88500wiirm4p8sxclkh-libXi-1.8-dev/include
      -isystem/nix/store/3kykrngc8gz2j2hq35cwsyamar5ppbf3-libxkbcommon-1.3.1-dev/include
      -isystem/nix/store/i0wswrd8ss8f8s2y9nrh5vcwxl9wlkcx-xcb-util-0.4.0-dev/include
      -isystem/nix/store/k9hklw55qi63ljab6yzw0jw7m24xqkv6-xcb-util-image-0.4.0-dev/include
      -isystem/nix/store/76hphv23zh8kqrd4irjh661vs163b5zg-xcb-util-keysyms-0.4.0-dev/include
      -isystem/nix/store/70mpipic0dqp0vwx0iv9xq2lns8j1jj1-xcb-util-renderutil-0.3.9-dev/include
      -isystem/nix/store/q47cwj9syhnzfs5fh0zx8w42nag2k091-xcb-util-wm-0.4.1-dev/include
      -isystem/nix/store/lpi7vw1zsyjakzyzlkxcyinprycqnbng-libGL-1.4.0-dev/include
      -isystem/nix/store/i6vabb4div9iy6lsl642d86k1q8riasn-python3-3.9.9/include
      -isystem/nix/store/fxzhmc5zgws2la9c21p577m8hmzbjisb-compiler-rt-libc-13.0.0-dev/include
      -isystem/nix/store/5lzxpdzrg7j47vvjrv3ryfz2amwvwnch-llvm-13.0.0-dev/include
      -isystem/nix/store/03aqjxlvv0zhnzai2c1vxj63sd4v0v2k-ncurses-6.3-dev/include
      -isystem/nix/store/9zig5f1s1745lj2f1k68wz129087y3ww-clang-13.0.0-dev/include
      -isystem/nix/store/6kcmnjb8gjl4mg1ssjwwg8agw3di6dmd-libcxx-13.0.0-dev/include
      -isystem/nix/store/6anj1k4zwcij4db8q2n2rrdjp4pk1gla-shiboken6-6.2.2/include
      -isystem/nix/store/9m0k71s1ddhsp5l84wlpk9yhcmh5n1wx-gcc-10.3.0/include/c++/10.3.0
      -isystem/nix/store/9m0k71s1ddhsp5l84wlpk9yhcmh5n1wx-gcc-10.3.0/include/c++/10.3.0/x86_64-unknown-linux-gnu
      -isystem/nix/store/9m0k71s1ddhsp5l84wlpk9yhcmh5n1wx-gcc-10.3.0/lib64/gcc/x86_64-unknown-linux-gnu/10.3.0/../../../../include/c++/10.3.0/backward
      -isystem/nix/store/jdnmdqrrjphi8n85d9d8im9ym30dkd68-clang-wrapper-13.0.0/resource-root/include
      -isystem/nix/store/93z3gj6kl0qvdm1mzwb5vaxlz7i481lz-glibc-2.33-62-dev/include
      -fPIC
      -Wno-constant-logical-operand
      -std=c++17
      -I/build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6
      -I/nix/store/0kb2vf3qnvd0cccgn6g98w4lyy7kadh7-qtbase-6.2.2-dev/mkspecs/linux-g++
      -I/nix/store/0kb2vf3qnvd0cccgn6g98w4lyy7kadh7-qtbase-6.2.2-dev/include
      -I/nix/store/0kb2vf3qnvd0cccgn6g98w4lyy7kadh7-qtbase-6.2.2-dev/include/QtCore
      -I/nix/store/0kb2vf3qnvd0cccgn6g98w4lyy7kadh7-qtbase-6.2.2-dev/include
      /build/QtCore_global_gTRBLZ.hpp
      "-DQT_ANNOTATE_ACCESS_SPECIFIER(a)=__attribute__((annotate(#a)))"
      "-DQT_ANNOTATE_CLASS(type,...)=static_assert(sizeof(#__VA_ARGS__),#type);"
      -DQSIMD_H
    )


    (core) [1463ms] Generating class model (1)...                               [OK]
    (core) [1463ms] Generating enum model (0)...                                [OK]
    (core) [1463ms] Generating namespace model (1)...                           [OK]
    (core) [1463ms] Resolving typedefs (63)...
    qt.shiboken: (core) template baseclass 'QCborStreamReader::StringResult<QByteArray>' of 'QCborStringResultByteArray' is not known
    qt.shiboken: (core) template baseclass 'QCborStreamReader::StringResult<QString>' of 'QCborStringResultString' is not known
                                                                                [WARNING]
    (core) [1464ms] Fixing class inheritance...                                 [OK]
    (core) [1464ms] Detecting inconsistencies in class model...                 [OK]
    (core) [1464ms] Detecting inconsistencies in typesystem (538)...
    qt.shiboken: (core) /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6/QtCore/typesystem_core_common.xml:2965: type 'QAbstractAnimation' is specified in typesystem, but not defined. This could potentially lead to compilation errors.
    qt.shiboken: (core) /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6/QtCore/typesystem_core_common.xml:2966: enum 'QAbstractAnimation::DeletionPolicy' is specified in typesystem, but not declared.
    qt.shiboken: (core) /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6/QtCore/typesystem_core_common.xml:2967: enum 'QAbstractAnimation::Direction' is specified in typesystem, but not declared.
    qt.shiboken: (core) /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6/QtCore/typesystem_core_common.xml:2968: enum 'QAbstractAnimation::State' is specified in typesystem, but not declared.
    qt.shiboken: (core) /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/PySide6/QtCore/typesystem_core_common.xml:2123: type 'QAbstractEventDispatcher' is specified in typesystem, but not defined. This could potentially lead to compilation errors.
    ...
                                                                                [WARNING]
    (core) [1467ms] Checking inconsistencies in function modifications...       [OK]
    (core) [1467ms] Writing log files...                                        [OK]
    (core) [1467ms] Running Source generator...                                 qt.shiboken: (core) ~FileOut file /build/pyside-setup-opensource-src-6.2.2/sources/pyside6/build/PySide6/QtCore/PySide6/QtCore/qtcorehelper_qmutexlocker_wrapper.cpp not written.

    Internal Error: Class "QMutex" for "QtCoreHelper::QMutexLocker::QMutexLocker(QMutex * m)" not found!
  */

  ninjaFlags = [ "-j1" ]; # debug: disable parallel build

  propagatedBuildInputs = [ shiboken6 ];

  dontWrapQtApps = true;

  meta = with lib; {
    description = "LGPL-licensed Python bindings for Qt";
    license = licenses.lgpl21;
    homepage = "https://wiki.qt.io/Qt_for_Python";
    maintainers = with maintainers; [ gebner ];
  };
}
