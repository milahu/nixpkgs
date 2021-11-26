# DO NOT EDIT! This file is generated automatically.
# Command: ./maintainers/scripts/fetch-kde-qt.sh pkgs/development/libraries/qt-6/6.2/
{ fetchurl, mirror }:

{
  qt3d = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qt3d-everywhere-src-6.2.1.tar.xz";
      sha256 = "1czfrx1j5a0386w99jysymqgfkmip83f4s6apsnc8n8s3a70w33k";
      name = "qt3d-everywhere-src-6.2.1.tar.xz";
    };
  };
  qt5compat = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qt5compat-everywhere-src-6.2.1.tar.xz";
      sha256 = "1rsx88n1mc7q32lzllfzg92ca2j7m561080yvqb2cg0a8lqw0r9q";
      name = "qt5compat-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtactiveqt = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtactiveqt-everywhere-src-6.2.1.tar.xz";
      sha256 = "1wgd3fsjs6ylv65n6m6ip8qqmyniicr6f8n8r2i9l7hpiriy7x96";
      name = "qtactiveqt-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtbase = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtbase-everywhere-src-6.2.1.tar.xz";
      sha256 = "0ych8a3xn2zbwdyh1yzivm6zj937zfinws263byd69zaqfshfprc";
      name = "qtbase-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtcharts = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtcharts-everywhere-src-6.2.1.tar.xz";
      sha256 = "1256yly1gadw6zz3gwmh1hq18yl8i2fi5ymaws418aiqpmmd2apr";
      name = "qtcharts-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtconnectivity = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtconnectivity-everywhere-src-6.2.1.tar.xz";
      sha256 = "0kkiq9sq04yf9lgwrlk2bkj7ajxfll3v5q95pwh4n4jz1xmkdk4d";
      name = "qtconnectivity-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtdatavis3d = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtdatavis3d-everywhere-src-6.2.1.tar.xz";
      sha256 = "02dhpwarhmxbjw7a2pfvwyf1c9hawnd6h2kdg02qfj9iylfk3kxz";
      name = "qtdatavis3d-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtdeclarative = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtdeclarative-everywhere-src-6.2.1.tar.xz";
      sha256 = "0w9w46byg29lwh3ifm9c21liqm3xx9a9fmh2ldr9dxv5aqd89sss";
      name = "qtdeclarative-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtdoc = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtdoc-everywhere-src-6.2.1.tar.xz";
      sha256 = "1q25wwg2364fsq8p25rk9vgq7bv6k8ncdg1wp72m5p0p4dsba3n3";
      name = "qtdoc-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtimageformats = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtimageformats-everywhere-src-6.2.1.tar.xz";
      sha256 = "1px3pivq41b0rs0d1jyrnv5mka7dvfkphz0i4fhvz23ra4ddqqfz";
      name = "qtimageformats-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtlocation = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtlocation-everywhere-src-6.2.1.tar.xz";
      sha256 = "1bfw172dfgsvzn7sdlfgw46dm8v42ly8mkc58vhifnylcb3r57m9";
      name = "qtlocation-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtlottie = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtlottie-everywhere-src-6.2.1.tar.xz";
      sha256 = "1lxzzar81ni60kc59srd9i22mx3zffw4jgasj2ihx6iwm93np2bg";
      name = "qtlottie-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtmultimedia = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtmultimedia-everywhere-src-6.2.1.tar.xz";
      sha256 = "1l4hk8q56lsyqk73r6w9zas909nicbkn3f6fqdwzckjd3p9llxh7";
      name = "qtmultimedia-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtnetworkauth = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtnetworkauth-everywhere-src-6.2.1.tar.xz";
      sha256 = "17hwdl0rj4pjninj0ms1vpwab1ppais55259mn66vid9jm8gh9w0";
      name = "qtnetworkauth-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtquick3d = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtquick3d-everywhere-src-6.2.1.tar.xz";
      sha256 = "1cm10b0a7xj9jlnqifd8j56fdazp3hapl0wkjlxckld5807cw8j0";
      name = "qtquick3d-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtquicktimeline = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtquicktimeline-everywhere-src-6.2.1.tar.xz";
      sha256 = "0qyy4wipq7f1sh0w6mchij6pglv05sg8ppxqfcjb3xyw5bp73xam";
      name = "qtquicktimeline-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtremoteobjects = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtremoteobjects-everywhere-src-6.2.1.tar.xz";
      sha256 = "17rp1g6gsrf0b1ghs0abzym35wllq4ixxgx173xcmqb3pc1ins3n";
      name = "qtremoteobjects-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtscxml = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtscxml-everywhere-src-6.2.1.tar.xz";
      sha256 = "0rspa1cl7nz5gsjm3ic31vhpb4dn2mjhpps03vf4p3zribv17xng";
      name = "qtscxml-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtsensors = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtsensors-everywhere-src-6.2.1.tar.xz";
      sha256 = "16kk2h99jnf5d1sqc17fyxajkqqdng8xx3ql534gaj18qmrcjmaz";
      name = "qtsensors-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtserialbus = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtserialbus-everywhere-src-6.2.1.tar.xz";
      sha256 = "11cz4dhn9pfjy4h2pdd4y4p91090hawyv615zw3d77nwg2js1rqm";
      name = "qtserialbus-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtserialport = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtserialport-everywhere-src-6.2.1.tar.xz";
      sha256 = "0skpw2a8kzi7gyr8afa5prwk843n763myc9mwzrqhr89sv4z8xzc";
      name = "qtserialport-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtshadertools = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtshadertools-everywhere-src-6.2.1.tar.xz";
      sha256 = "0zh6i2rc64f4pqp3dmm05vp63m62fmvkfvm553c1rcw185r3i39c";
      name = "qtshadertools-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtsvg = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtsvg-everywhere-src-6.2.1.tar.xz";
      sha256 = "1msgi3y5ay0g9vfq8yqspz31kggi2f6rqq8fm4n0a894bh07xql6";
      name = "qtsvg-everywhere-src-6.2.1.tar.xz";
    };
  };
  qttools = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qttools-everywhere-src-6.2.1.tar.xz";
      sha256 = "1yrb66wysdgn9b4kyh2hg1l2xpzi1rx71bziqdfy3rjz7lynv1as";
      name = "qttools-everywhere-src-6.2.1.tar.xz";
    };
  };
  qttranslations = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qttranslations-everywhere-src-6.2.1.tar.xz";
      sha256 = "1iw3j65ny6j9dcv30s4gf9m4l1yjqx97ls95qxznk1d51m90ns1z";
      name = "qttranslations-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtvirtualkeyboard = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtvirtualkeyboard-everywhere-src-6.2.1.tar.xz";
      sha256 = "1zphk3xf1f2f8va0ca981nshx98qz2b1ilbfa8g3n7xlcjzadfk1";
      name = "qtvirtualkeyboard-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtwayland = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtwayland-everywhere-src-6.2.1.tar.xz";
      sha256 = "1mzgaid8968wlg2db2qzlprm2qamd8adasnqdx1qingylv86n7h5";
      name = "qtwayland-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtwebchannel = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtwebchannel-everywhere-src-6.2.1.tar.xz";
      sha256 = "1jg9wk4yfd5lq6pfjhf79q5mzsz62h0dbya0vnnhppp9l3ls4nq3";
      name = "qtwebchannel-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtwebengine = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtwebengine-everywhere-src-6.2.1.tar.xz";
      sha256 = "1dzvrwg6r9riinn9hqmfi21qgydknr69595jnrqiw737p3zkr4qz";
      name = "qtwebengine-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtwebsockets = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtwebsockets-everywhere-src-6.2.1.tar.xz";
      sha256 = "05iqp8d50j074kgmxwlby19af24c3a9zfyzdmfbrd0vax4hlwd13";
      name = "qtwebsockets-everywhere-src-6.2.1.tar.xz";
    };
  };
  qtwebview = {
    version = "6.2.1";
    src = fetchurl {
      url = "${mirror}/official_releases/qt/6.2/6.2.1/submodules/qtwebview-everywhere-src-6.2.1.tar.xz";
      sha256 = "0sjfvbnz562xrh5ydmpn2d3gi40zwcjvchz818jhzrjcyyybpvcs";
      name = "qtwebview-everywhere-src-6.2.1.tar.xz";
    };
  };
}
