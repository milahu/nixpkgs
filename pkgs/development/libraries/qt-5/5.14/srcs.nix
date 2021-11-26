# DO NOT EDIT! This file is generated automatically.
# Command: ./maintainers/scripts/fetch-kde-qt.sh pkgs/development/libraries/qt-5/5.14/
{ fetchurl, mirror }:

{
  qt3d = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qt3d-everywhere-src-5.14.2.tar.xz";
      sha256 = "0x6668wjwzcgjzprwmvfiyj76512kp2j8qn93v9idm5pqhf2za4x";
      name = "qt3d-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtactiveqt = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtactiveqt-everywhere-src-5.14.2.tar.xz";
      sha256 = "1aaj86vgb64cq0mqcj4r2jipmk8al4nsa6wll9rrfw98s7aifddm";
      name = "qtactiveqt-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtandroidextras = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtandroidextras-everywhere-src-5.14.2.tar.xz";
      sha256 = "0xjd7h6aspxzsr0xvjz26w8x2x0mmx7814nl1g7n79j9bhmxk3sa";
      name = "qtandroidextras-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtbase = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtbase-everywhere-src-5.14.2.tar.xz";
      sha256 = "12mjsahlma9rw3vz9a6b5h2s6ylg8b34hxc2vnlna5ll429fgfa8";
      name = "qtbase-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtcharts = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtcharts-everywhere-src-5.14.2.tar.xz";
      sha256 = "1drvm15i6n10b6a1acgarig120ppvqh3r6fqqdn8i3blx81m5cmd";
      name = "qtcharts-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtconnectivity = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtconnectivity-everywhere-src-5.14.2.tar.xz";
      sha256 = "0a5wzin635b926b8prdwfazgy1vhyf8m6an64wp2lpkp78z7prmb";
      name = "qtconnectivity-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtdatavis3d = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtdatavis3d-everywhere-src-5.14.2.tar.xz";
      sha256 = "080fkpxg70m3c697wfnkjhca58b7r1xsqd559jzb21985pdh6g3j";
      name = "qtdatavis3d-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtdeclarative = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtdeclarative-everywhere-src-5.14.2.tar.xz";
      sha256 = "0l0nhc2si6dl9r4s1bs45z90qqigs8jnrsyjjdy38q4pvix63i53";
      name = "qtdeclarative-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtdoc = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtdoc-everywhere-src-5.14.2.tar.xz";
      sha256 = "0aqpjflg8g87pvjxxxrj6x5g4xf1a5w5cyb1s0ib4ppkbaswsmas";
      name = "qtdoc-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtgamepad = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtgamepad-everywhere-src-5.14.2.tar.xz";
      sha256 = "00wd3h465waxdghg2vdhs5pkj0xikwjn88l12477dksm8zdslzgp";
      name = "qtgamepad-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtgraphicaleffects = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtgraphicaleffects-everywhere-src-5.14.2.tar.xz";
      sha256 = "03xmwhapv0b2qj661iaqqrvhxc7qiid0acrp6rj85824ha2pyyj8";
      name = "qtgraphicaleffects-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtimageformats = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtimageformats-everywhere-src-5.14.2.tar.xz";
      sha256 = "132g4rlm61pdcpcrclr1rwpbrxn7va4wjfb021mh8pn1cl0wlgkk";
      name = "qtimageformats-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtlocation = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtlocation-everywhere-src-5.14.2.tar.xz";
      sha256 = "1k3m8zhbv04yrqvj7jlnh8f9xczdsmla59j9gcwsqvbg76y0hxy3";
      name = "qtlocation-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtlottie = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtlottie-everywhere-src-5.14.2.tar.xz";
      sha256 = "0y2r52djk17cppgrm5n14pf3zz65bl3n0hq8cc9c3gicr4nkklam";
      name = "qtlottie-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtmacextras = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtmacextras-everywhere-src-5.14.2.tar.xz";
      sha256 = "1rbnhwfjyxzyypjdvlv62nrz73y1yx3cyg7wjhhq59w4djs8f9fi";
      name = "qtmacextras-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtmultimedia = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtmultimedia-everywhere-src-5.14.2.tar.xz";
      sha256 = "1sczzcvk3c5gczz53yvp8ma6gp8aixk5pcq7wh344c9md3g8xkbs";
      name = "qtmultimedia-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtnetworkauth = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtnetworkauth-everywhere-src-5.14.2.tar.xz";
      sha256 = "0pi6p7bq54kzij2p69cgib7n55k69jsq0yqq09yli645s4ym202g";
      name = "qtnetworkauth-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtpurchasing = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtpurchasing-everywhere-src-5.14.2.tar.xz";
      sha256 = "0lg8x7g7dkf95xwxq8b4yw4ypdz68igkscya96xwbklg3q08gc39";
      name = "qtpurchasing-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtquick3d = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtquick3d-everywhere-src-5.14.2.tar.xz";
      sha256 = "0blb90h0vnsg7pj0a3hwq4cwrqd3pwq8zsb4gzshnaqza1nnjh06";
      name = "qtquick3d-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtquickcontrols = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtquickcontrols-everywhere-src-5.14.2.tar.xz";
      sha256 = "0qa4dlhn3iv9yvaic8hw86v6h8rn9sgq8xjfdaym04pfshfyypfm";
      name = "qtquickcontrols-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtquickcontrols2 = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtquickcontrols2-everywhere-src-5.14.2.tar.xz";
      sha256 = "0q0mk2mjlf9ll0gdrdzxy8096s6g9draaqiwrlvdpa7lv14x7xzs";
      name = "qtquickcontrols2-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtquicktimeline = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtquicktimeline-everywhere-src-5.14.2.tar.xz";
      sha256 = "17isi54h3x2xk4ymc8nqgyp3h25cn5x4fjl5jj07ziybk04mv943";
      name = "qtquicktimeline-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtremoteobjects = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtremoteobjects-everywhere-src-5.14.2.tar.xz";
      sha256 = "1mhlws5w0igf5hw0l90p6dz6k7w16dqfbnk2li0zxdmayk2039m6";
      name = "qtremoteobjects-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtscript = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtscript-everywhere-src-5.14.2.tar.xz";
      sha256 = "1zlvg3hc6h70d789g3kv6dxbwswzkskkm00bdgl01grwrdy4izg9";
      name = "qtscript-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtscxml = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtscxml-everywhere-src-5.14.2.tar.xz";
      sha256 = "141pfschv6zmcvvn3pi7f5vb4nf96zpngy80f9bly1sn58syl303";
      name = "qtscxml-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtsensors = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtsensors-everywhere-src-5.14.2.tar.xz";
      sha256 = "0qccpgbhyg9k4x5nni7xm0pyvaqia3zrcd42cn7ksf5h21lwmkxw";
      name = "qtsensors-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtserialbus = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtserialbus-everywhere-src-5.14.2.tar.xz";
      sha256 = "14bahg82jciciqkl74q9hvf3a8kp3pk5v731vp2416k4b8bn4xqb";
      name = "qtserialbus-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtserialport = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtserialport-everywhere-src-5.14.2.tar.xz";
      sha256 = "08ga9a1lwj83872nxablk602z1dq0la6jqsiicvd7m1sfbfpgnd6";
      name = "qtserialport-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtspeech = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtspeech-everywhere-src-5.14.2.tar.xz";
      sha256 = "1nn6kspbp8hfkz1jhzc1qx1m9z7r1bgkdqgi9n4vl1q25yk8x7jy";
      name = "qtspeech-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtsvg = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtsvg-everywhere-src-5.14.2.tar.xz";
      sha256 = "18dmfc8s428fzbk7k5vl3212b25455ayrz7s716nwyiy3ahgmmy7";
      name = "qtsvg-everywhere-src-5.14.2.tar.xz";
    };
  };
  qttools = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qttools-everywhere-src-5.14.2.tar.xz";
      sha256 = "1iakl3hlyg51ri1czmis8mmb257b0y1zk2a2knybd3mq69wczc2v";
      name = "qttools-everywhere-src-5.14.2.tar.xz";
    };
  };
  qttranslations = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qttranslations-everywhere-src-5.14.2.tar.xz";
      sha256 = "19nih9fk33qyvs8241yf840wxdwmka4kc56ikxn37l2xkzpfp210";
      name = "qttranslations-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtvirtualkeyboard = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtvirtualkeyboard-everywhere-src-5.14.2.tar.xz";
      sha256 = "1mv870zdmnprf497hplnh9gnqm2v845ifdsajry7wq9yaqw36krn";
      name = "qtvirtualkeyboard-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtwayland = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtwayland-everywhere-src-5.14.2.tar.xz";
      sha256 = "0al3yypy3fin62n8d1859jh0mn0fbpa161l7f37hgd4gf75365nk";
      name = "qtwayland-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtwebchannel = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtwebchannel-everywhere-src-5.14.2.tar.xz";
      sha256 = "0x7q66994pw6cd0f505bmirw1sssqs740zaw8lyqqqr32m2ch7bx";
      name = "qtwebchannel-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtwebengine = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtwebengine-everywhere-src-5.14.2.tar.xz";
      sha256 = "0iy9lsl6zxlkca6x2p1506hbj3wmhnaipg23z027wfccbnkxcsg1";
      name = "qtwebengine-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtwebglplugin = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtwebglplugin-everywhere-src-5.14.2.tar.xz";
      sha256 = "05rl657848fsprsnabdqb5z363c6drjc32k59223vl351f8ihhgb";
      name = "qtwebglplugin-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtwebsockets = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtwebsockets-everywhere-src-5.14.2.tar.xz";
      sha256 = "116amx4mnv50k0fpswgpr5x8wjny8nbffrjmld01pzhkhfqn4vph";
      name = "qtwebsockets-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtwebview = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtwebview-everywhere-src-5.14.2.tar.xz";
      sha256 = "0jzzcm7z5njkddzfhmyjz4dbbzq8h93980cci4479zc4xq9r47y6";
      name = "qtwebview-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtwinextras = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtwinextras-everywhere-src-5.14.2.tar.xz";
      sha256 = "1wh7v6v6q8rk76ygg0nf31r6gl80ryggcmdc1dy5kj1p3g1in3wq";
      name = "qtwinextras-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtx11extras = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtx11extras-everywhere-src-5.14.2.tar.xz";
      sha256 = "0njlh6d327nll7d8qaqrwr5x15m9yzgyar2j45qigs1f7ah896my";
      name = "qtx11extras-everywhere-src-5.14.2.tar.xz";
    };
  };
  qtxmlpatterns = {
    version = "5.14.2";
    src = fetchurl {
      url = "${mirror}/archive/qt/5.14/5.14.2/submodules/qtxmlpatterns-everywhere-src-5.14.2.tar.xz";
      sha256 = "1dyg1z4349k04yyzn8xbp4f5qjgm60gz6wgzp80khpilcmk8g6i1";
      name = "qtxmlpatterns-everywhere-src-5.14.2.tar.xz";
    };
  };
}
