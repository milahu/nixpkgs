{ lib, stdenv, fetchFromGitHub, cmake, ncurses, python3, python3Packages, gcc }:

let
configurePhaseDrv =
stdenv.mkDerivation rec {
  pname = "ninvaders";
  version = "0.1.2";
  name = "${pname}-${version}-configurePhase";

  src = fetchFromGitHub {
    owner = "sf-refugees";
    repo = pname;
    rev = "v${version}";
    sha256 = "1wmwws1zsap4bfc2439p25vnja0hnsf57k293rdxw626gly06whi";
  };

  nativeBuildInputs = [
    cmake
    python3
    python3Packages.compiledb
  ];
  buildInputs = [ ncurses ];

  configurePhase = ''
    cd /build; mkdir build; cd build

    mkdir -p .cmake/api/v1/query
    touch .cmake/api/v1/query/codemodel-v2

    # CMakeLists.txt -> Makefile
    cmake ../$sourceRoot

    mv .cmake/api/v1/reply/index-*.json .cmake/api/v1/reply/index.json
    # probably the files in reply/ are not reproducible, but we could patch them

    # Makefile -> compile_commands.json
    compiledb -n make

    cp -r /build $out
    printf "%s" "$sourceRoot" >$out/sourceRoot.txt
  '';

  dontBuild = true;
  dontCheck = true;
  dontInstall = true;
  dontDist = true;
};
in

let
drv2 = rec {
  sourceRoot = builtins.readFile "${configurePhaseDrv}/sourceRoot.txt";
  sourcePath = /* lib.traceValSeq */ "${configurePhaseDrv}/${sourceRoot}";

  configureResultDir = "${configurePhaseDrv}/build";
  compileCommands = /* lib.traceValSeq */ (builtins.fromJSON (builtins.readFile "${configureResultDir}/compile_commands.json"));

  compileObjects = lib.imap0 compileObjectOfCommand compileCommands;

  compileObjectOfCommand = commandIdx: command: (stdenv.mkDerivation {
    # avoid using configurePhaseDrv pname and version?
    # re-use the compile-object across different versions (and pnames)
    #name = "${configurePhaseDrv.pname}-${configurePhaseDrv.version}-obj${builtins.toString commandIdx}";
    name = "compileobject-${builtins.baseNameOf command.file}";

    # FIXME use only the needed inputs. avoid recompile when buildInputs change
    inherit (configurePhaseDrv) buildInputs;

    nativeBuildInputs = [ gcc ]; # note: no cmake
    src = configurePhaseDrv.out;
    buildCommand = ''
      ln -s $src/source /build/source
      mkdir /build/build
      ln -s $src/build/CMakeFiles /build/build/

      cd /build/build
      argsRaw=(${lib.escapeShellArgs command.arguments})

      # debug
      if false; then
      echo "command.directory = ${command.directory}"
      echo "command.file = ${command.file}"
      echo "command.arguments = ''${argsRaw[@]}"
      fi

      args=()
      for a in "''${argsRaw[@]}"; do
        if (echo "$a" | grep -E '^CMakeFiles/([^/]+\.dir)' >/dev/null); then
          args+=("$(echo "$a" | sed -E "s,^CMakeFiles/([^/]+\.dir),$out/\1,")")
          outDir="$(echo "$a" | sed -E "s,^CMakeFiles/([^/]+\.dir)/.*$,\1,")"
          outPath="$out/$outDir"
          if [ ! -d "$outPath" ]; then mkdir -p "$outPath"; fi
        else
          args+=("$a")
        fi
      done
      echo "''${args[@]}"
      "''${args[@]}"
    '';
  });

  cmakeReplyDir = "${configureResultDir}/.cmake/api/v1/reply";
  cmakeIndex = builtins.fromJSON (builtins.readFile "${cmakeReplyDir}/index.json");
  cmakeCodemodel = builtins.fromJSON (builtins.readFile "${cmakeReplyDir}/${cmakeIndex.reply.codemodel-v2.jsonFile}");
  # TODO multiple configurations?
  cmakeConfiguration = (builtins.elemAt cmakeCodemodel.configurations 0);
  #cmakeConfiguration.directories[0].jsonFile
  #cmakeConfiguration.projects[0].name == "ninvaders"
  targets = builtins.map (target: builtins.fromJSON (builtins.readFile "${cmakeReplyDir}/${target.jsonFile}")) cmakeConfiguration.targets;
};
in

stdenv.mkDerivation {
  inherit (configurePhaseDrv) pname version;
  src = configurePhaseDrv.out;

  buildCommand = ''
    cp -r $src/* /build; chmod -R +w /build

    objList=()
    ${lib.concatMapStringsSep "\n" (obj: ''objList+=("${obj}")'') drv2.compileObjects}
    for o in "''${objList[@]}"; do
      echo "obj $o"
      cp -rs $o/* /build/build/CMakeFiles
    done

    mkdir -p $out/bin
    cd /build/build
    for targetDir in CMakeFiles/*.dir;
    do
      targetName=''${targetDir%.dir}
      targetName=''${targetName##*/}

      linkCommand="$(cat "$targetDir/link.txt")"
      echo "linking $targetName"
      echo "$linkCommand"
      $linkCommand

      cp -v $targetName $out/bin
    done
  '';
}
