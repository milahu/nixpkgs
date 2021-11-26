/*

FIXME
cycle error out -> bin -> out = plugins -> lib -> plugins

*/

{ qtModule
, qtbase
, libglvnd, libxkbcommon, vulkan-headers # TODO should be inherited from qtbase
, qtshadertools
, openssl
, python3

, lib # splitBuildInstall

#, openvg, openvg-headers
# https://bugreports.qt.io/browse/QTBUG-98040

}:

let
  pname = "qtdeclarative";
  version = "6.2.1";
  self = { inherit qtbase; };
  args = { postFixup = ""; };
in

qtModule {
  pname = "qtdeclarative";
  qtInputs = [ qtbase qtshadertools ];
  buildInputs = [ openssl openssl.dev python3 /* openvg.shivavg openvg-headers */ libglvnd libxkbcommon vulkan-headers ];
  outputs = [ "out" "dev" "bin" ];
  # FIXME set QT_ADDITIONAL_PACKAGES_PREFIX_PATH automatically from buildInputs
  preConfigure = ''
    NIX_CFLAGS_COMPILE+=" -DNIXPKGS_QML2_IMPORT_PREFIX=\"$qtQmlPrefix\""
    export QT_ADDITIONAL_PACKAGES_PREFIX_PATH="${qtshadertools.dev}/lib/cmake"
  '';
  configureFlags = [ "-qml-debug" ];
  # TODO build/?
  devTools = [
    "bin/qml"
    "bin/qmlcachegen"
    "bin/qmleasing"
    "bin/qmlimportscanner"
    "bin/qmllint"
    "bin/qmlmin"
    "bin/qmlplugindump"
    "bin/qmlprofiler"
    "bin/qmlscene"
    "bin/qmltestrunner"
  ];

  # debug: install is failing
  splitBuildInstall =
  #if true then null else # disable splitBuildInstall
  let
    # workaround for splitBuildInstall
    pname = "qtdeclarative";
    version = "6.2.1";
    self = { inherit qtbase; };
    args = { postFixup = ""; };
  in
  {

# copy-paste from qtModule.nix
# fix cycle error: cycle detected in build
  postFixup = ''
    if [ -d "''${!outputDev}/lib/pkgconfig" ]; then
        find "''${!outputDev}/lib/pkgconfig" -name '*.pc' | while read pc; do
            sed -i "$pc" \
                -e "/^prefix=/ c prefix=''${!outputLib}" \
                -e "/^exec_prefix=/ c exec_prefix=''${!outputBin}" \
                -e "/^includedir=/ c includedir=''${!outputDev}/include"
        done
    fi

    # TODO refactor. same code in qtbase.nix and qtModule.nix
    echo "patching output paths in cmake files ..."
    moduleNAME="${lib.toUpper pname}"
    outEscaped=$(echo $out | sed 's,/,\\/,g')
    devEscaped=$(echo $dev | sed 's,/,\\/,g')
    if [ -n "$bin" ]; then
    binEscaped=$(echo $bin | sed 's,/,\\/,g') # optional plugins
    else binEscaped=""; fi

    # TODO build the perlRegex string with nix? avoid the bash escape hell
    # or use: read -d "" perlRegex <<EOF ... EOF
    s=""
    s+="s/^# Compute the installation prefix relative to this file\."
    s+="\n.*?set\(_IMPORT_PREFIX \"\"\)\nendif\(\)"
    s+="/# NixOS was here"
    s+="\nset(_''${moduleNAME}_NIX_OUT \"$outEscaped\")"
    s+="\nset(_''${moduleNAME}_NIX_DEV \"$devEscaped\")"
    s+="\nset(_''${moduleNAME}_NIX_BIN \"$binEscaped\")/s;"
    s+="s/\\\''${_IMPORT_PREFIX}\/(\.\/)?include/\\\''${_''${moduleNAME}_NIX_DEV}\/include/g;"
    s+="s/\\\''${_IMPORT_PREFIX}\/(\.\/)?libexec/\\\''${_''${moduleNAME}_NIX_OUT}\/libexec/g;"
    s+="s/\\\''${_IMPORT_PREFIX}\/(\.\/)?lib/\\\''${_''${moduleNAME}_NIX_OUT}\/lib/g;" # must come after libexec
    s+="s/\\\''${_IMPORT_PREFIX}\/(\.\/)?plugins/\\\''${_''${moduleNAME}_NIX_BIN}\/lib\/qt-${version}\/plugins/g;"
    s+="s/\\\''${_IMPORT_PREFIX}\/(\.\/)?bin/\\\''${_''${moduleNAME}_NIX_DEV}\/bin/g;" # qmake ...
    s+="s/\\\''${_IMPORT_PREFIX}\/(\.\/)?mkspecs/\\\''${_''${moduleNAME}_NIX_DEV}\/mkspecs/g;"
    s+="s/\\\''${_IMPORT_PREFIX}\/(\.\/)?qml/\\\''${_''${moduleNAME}_NIX_OUT}\/qml/g;"
    s+="s/set\(_IMPORT_PREFIX\)"
    s+="/set(_''${moduleNAME}_NIX_OUT)"
    s+="\nset(_''${moduleNAME}_NIX_DEV)"
    s+="\nset(_''${moduleNAME}_NIX_BIN)/g;"
    s+="s/\\\''${QtBase_SOURCE_DIR}\/libexec/\\\''${QtBase_BINARY_DIR}\/libexec/g;" # QtBase_SOURCE_DIR = qtbase/$dev

    s+="s/\\\''${QT_BUILD_INTERNALS_RELOCATABLE_INSTALL_PREFIX}\/\\\''${INSTALL_LIBEXECDIR}/$outEscaped\/libexec/g;"
    s+="s/\\\''${QT_BUILD_INTERNALS_RELOCATABLE_INSTALL_PREFIX}\/\\\''${INSTALL_BINDIR}/$devEscaped\/bin/g;"
    s+="s/\\\''${QT_BUILD_INTERNALS_RELOCATABLE_INSTALL_PREFIX}\/\\\''${INSTALL_DOCDIR}/$outEscaped\/share\/doc/g;"
    s+="s/\\\''${QT_BUILD_INTERNALS_RELOCATABLE_INSTALL_PREFIX}\/\\\''${INSTALL_LIBDIR}/$outEscaped\/lib/g;"
    s+="s/\\\''${QT_BUILD_INTERNALS_RELOCATABLE_INSTALL_PREFIX}\/\\\''${INSTALL_MKSPECSDIR}/$devEscaped\/mkspecs/g;"

    # lib/cmake/Qt6/QtBuild.cmake
    s+="s/\\\''${CMAKE_CURRENT_LIST_DIR}\/\.\.\/mkspecs/$devEscaped\/mkspecs/g;"
    # lib/cmake/Qt6/QtPriHelpers.cmake
    s+="s/\\\''${CMAKE_CURRENT_BINARY_DIR}\/mkspecs/$devEscaped\/mkspecs/g;"

    #s+="s/\\\''${QtBase_SOURCE_DIR}\/lib/\\\''${QtBase_BINARY_DIR}\/lib/g;" # TODO?
    perlRegex="$s"

    echo "debug: perlRegex = $perlRegex"
    find $dev/lib/cmake -name '*.cmake' -exec perl -00 -p -i -e "$perlRegex" '{}' \;
    echo "rc of find = $?" # zero when perl returns nonzero?
    # FIXME catch errors from perl: find -> xargs
    echo "patching output paths in cmake files done"

    moveQtDevTools

    if true; then # fix cycle error
    #if false; then # produce cycle error
      mkdir $bin
    else
      if [ -d $out/plugins ]; then
        if [ -z "$bin" ]; then
          echo 'fatal error: qt module has plugins but no "bin" output'
          echo 'listing plugins ...'
          find $out/plugins
          echo 'listing plugins done'
          echo 'todo: in qtModule for ${pname}-${version}, set:'
          echo '  outputs = [ "out" "dev" "bin" ];'
          exit 1
        fi
        echo "moving plugins to $bin/lib/qt-${self.qtbase.version}/plugins"
        mkdir -p $bin/lib/qt-${self.qtbase.version}
        mv $out/plugins $bin/lib/qt-${self.qtbase.version}
      elif [ -n "$bin" ]; then
        echo 'FIXME warning: qt module has no plugins but "bin" output'
        echo 'todo: in qtModule for ${pname}-${version}, remove:'
        echo '  outputs = [ "out" "dev" "bin" ];'
      fi
    fi

    ${args.postFixup or ""}

    echo "verify that all _IMPORT_PREFIX are replaced ..."
    matches="$(find $dev/lib/cmake -name '*.cmake' -exec grep -HnF _IMPORT_PREFIX '{}' \;)"
    if [ -n "$matches" ]; then
      echo "fatal: _IMPORT_PREFIX was not replaced in:"
      echo "$matches"
      exit 1
    fi
    echo "verify that all _IMPORT_PREFIX are replaced done"
  '';

  installPhase = ''
    runHook preInstall
    cd /build/$sourceRoot/build
    cmake -P cmake_install.cmake
    runHook postInstall
  '';

  /*
  # workaround for cycle error
  preDist = ''
    echo "workaround: moving plugins from $bin to $out"
    mv $bin/lib/qt-${qtbase.version}/plugins $out
  '';
  */

  # TODO build/?
  devTools = [
    "build/bin/qml"
    "build/bin/qmlcachegen"
    "build/bin/qmleasing"
    "build/bin/qmlimportscanner"
    "build/bin/qmllint"
    "build/bin/qmlmin"
    "build/bin/qmlplugindump"
    "build/bin/qmlprofiler"
    "build/bin/qmlscene"
    "build/bin/qmltestrunner"
  ];


  };
}
