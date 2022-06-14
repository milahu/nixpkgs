{ lib
, buildPythonPackage
, wrapQtAppsHook
, pyqt6
, qt6Packages
}:

buildPythonPackage rec {
  pname = "pyqt6-test";
  version = "1.0.0";

  propagatedBuildInputs = with qt6Packages; [
    pyqt6
    qtbase
    # fix: qtPluginPrefix: parameter null or not set
    # TODO better error message in qt module hook script
    qtdeclarative
  ];

  unpackPhase = ''
    cp ${./pyqt6-test.py} ${pname}.py

    cat >setup.py <<EOF
    from setuptools import setup

    #with open('requirements.txt') as f:
    #    install_requires = f.read().splitlines()
    install_requires = ["pyqt6"]

    setup(
      name='${pname}',
      version='${version}',
      install_requires=install_requires,
      scripts=[
        '${pname}.py',
      ],
      entry_points={
        # example: file some_module.py -> function main
        #'console_scripts': ['someprogram=some_module:main']
      },
    )
    EOF
  '';

  nativeBuildInputs = [
    wrapQtAppsHook
  ];

  postFixup = ''
    wrapQtApp $out/bin/${pname}.py
  '';

  doCheck = false;
}
