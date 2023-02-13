{ lib
, buildPythonApplication
, stdenvNoCC
, mkYarnPackage
, yarn2nix-moretea-debug
, fetchFromGitHub
, fetchPypi
, gdb
, flask-socketio
, flask-compress
, pygdbmi
, pygments
, python-socketio
, eventlet
, python
}:

buildPythonApplication rec {
  pname = "gdbgui";

  baseVersion = "0.15.0.1";
  version = "${baseVersion}-unstable-2022-06-22";

  buildInputs = [ gdb ];

  propagatedBuildInputs = [
    flask-socketio
    flask-compress
    pygdbmi
    pygments
    python-socketio
    eventlet
  ];

  # fix: KeyError: WERKZEUG_SERVER_FD
  # https://github.com/cs01/gdbgui/pull/430
  # cannot apply patch to binary release
  src = fetchFromGitHub {
    owner = "cs01";
    repo = "gdbgui";
    rev = "9138473156116340c2b1c0b72d35dba32b4a3bd6";
    sha256 = "sha256-d8DDfASKIqLGngpsofdi2fskafOX4YbsfQGVt9bj9L4=";
  };

  # TODO? mkYarnModules
  gdbgui-static = yarn2nix-moretea-debug.mkYarnPackage {
    pname = "gdbgui-static";
    inherit version src;

    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;
    yarnNix = ./yarn.nix;

    # mkYarnPackage fails at
    # pkgs/development/tools/yarn2nix-moretea/yarn2nix/default.nix
    # ln -s "deps/${pname}" "node_modules/${pname}"

    prePatch = ''
      ls -A
      #ls -A node_modules
      #mv -v node_modules/gdbgui{,.bak}
      set -x
    '';

    # configurePhase
    # FIXME: ln: failed to create symbolic link 'node_modules/gdbgui/gdbgui': File exists
  };

  postPatch = ''
    echo ${version} > gdbgui/VERSION.txt
    # relax dependencies
    sed -i 's/==.*$//' requirements.txt
  '';

  postInstall = ''
    echo replacing gdbgui/static
    rm -rf $out/${python.sitePackages}/gdbgui/static
    ln -s -v ${gdbgui-static} $out/${python.sitePackages}/gdbgui/static
  '';

  makeWrapperArgs = [ "--prefix PATH : ${lib.makeBinPath [ gdb ]}" ];

  # tests do not work without stdout/stdin
  doCheck = false;

  meta = with lib; {
    description = "A browser-based frontend for GDB";
    homepage = "https://www.gdbgui.com/";
    license = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ yrashk dump_stack ];
  };
}
