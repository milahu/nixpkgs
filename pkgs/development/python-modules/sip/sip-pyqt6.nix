{ sip, fetchPypi, ply }:

# separate sip package for pyqt6-builder
# to avoid rebuild of pyqt5

(sip.overridePythonAttrs (old: rec {
  pname = "sip-pyqt6";
  version = "6.6.1";

  src = fetchPypi {
    pname = "sip";
    inherit version;
    sha256 = "sha256-aWxXXHIUQSJwEXHyzHZ/5syHBQ6nVaBJCRUqhQiuEMM=";
  };

  # sip 6.5.1 -> 6.6.1
  propagatedBuildInputs = old.propagatedBuildInputs ++ [ ply ];

  patches = old.patches ++ [
    # cosmetic
    ./fix-unbuffer-make-output.patch
    # cosmetic
    ./feat-print-configure-summary.patch
    # debug helper
    ./debug-dump-generated-files.patch
    # build faster
    # example use: pkgs/development/python-modules/pyqt/6.x.nix
    ./feat-parallel-configure.patch
  ];

  # fix: support absolute filepath in name argument
  # https://www.riverbankcomputing.com/pipermail/pyqt/2022-June/044700.html
  # required to build pyqt6
  postPatch = ''
    sed -i.bak -E \
      's/(prefix_dir) \+ ([a-z_.]+)/os.path.join(\1, \2)/g' \
      sipbuild/distinfo/distinfo.py
  '';
}))
