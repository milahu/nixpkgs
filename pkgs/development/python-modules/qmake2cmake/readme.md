# qmake2cmake

## usage

see examples in

* pkgs/development/python-modules/pyqt/6.x.nix
* pkgs/development/python-modules/pyqtwebengine/6.x.nix

## debugging

```nix
stdenv.mkDerivation {
  cmakeFlags = [ "--debug-output" ];
  makeFlags = [ "-d" ];
  # debug qmake2cmake
  QMAKE2CMAKE_DEBUG_DUMP_FILES = "1"; # *.pro CMakeLists.txt (TODO: cmake_install.cmake)
  #PYQT_BUILDER_DEBUG_DUMP_MAKE_FILES = "1"; # Makefile
  #SIP_DEBUG_DUMP_FILES = "1"; # *.cpp *.h
}
```
