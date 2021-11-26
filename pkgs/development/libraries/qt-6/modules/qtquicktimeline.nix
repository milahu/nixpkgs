{ qtModule
, qtbase

, libglvnd, libxkbcommon, vulkan-headers
# TODO should be inherited from qtbase

, qtdeclarative
}:

qtModule {
  pname = "qtquicktimeline";
  qtInputs = [ qtbase qtdeclarative ];
  buildInputs = [ libglvnd libxkbcommon vulkan-headers ];
  outputs = [ "out" "dev" ];
  # FIXME set QT_ADDITIONAL_PACKAGES_PREFIX_PATH automatically from buildInputs
  preConfigure = ''
    export QT_ADDITIONAL_PACKAGES_PREFIX_PATH="${qtdeclarative.dev}/lib/cmake"
  '';
  cmakeFlags = [
    #"-DCMAKE_FIND_DEBUG_MODE=TRUE" "--trace-expand"
    #"--debug-output"
  ];
}
