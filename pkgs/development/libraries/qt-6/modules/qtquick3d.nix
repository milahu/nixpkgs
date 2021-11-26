{ qtModule
, qtbase
, libglvnd, libxkbcommon, vulkan-headers # TODO should be inherited from qtbase
, qtdeclarative # TODO verify qtquick
, qtquicktimeline
, qtshadertools
, openssl
}:

qtModule {
  pname = "qtquick3d";
  qtInputs = [ qtbase qtdeclarative qtquicktimeline qtshadertools ];
  buildInputs = [ openssl openssl.dev libglvnd libxkbcommon vulkan-headers ];
  outputs = [ "out" "dev" "bin" ];

  preConfigure = ''
    export LD_LIBRARY_PATH="${qtdeclarative}/lib:$LD_LIBRARY_PATH"

    # TODO verify
    export QT_ADDITIONAL_PACKAGES_PREFIX_PATH="${qtdeclarative.dev}/lib/cmake"
    export QT_ADDITIONAL_PACKAGES_PREFIX_PATH="${qtquicktimeline.dev}/lib/cmake"
    export QT_ADDITIONAL_PACKAGES_PREFIX_PATH="${qtshadertools.dev}/lib/cmake"
  '';

/* todo?
  # debug: install is failing
  splitBuildInstall = {
    # needed to disable rebuild
    # TODO simpler way? cmake hooks trigger rebuild?
    installPhase = ''
      cmake -P cmake_install.cmake
    '';
  };
*/

}
