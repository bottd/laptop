# Python overlay with weallcode-robot package
final: prev: {
  python3 = prev.python3.override {
    packageOverrides = pyFinal: pyPrev: {
      weallcode-robot = pyPrev.buildPythonPackage rec {
        pname = "weallcode_robot";
        version = "3.1.4";
        pyproject = true;
        src = prev.fetchPypi {
          inherit pname version;
          hash = "sha256-f+CR7eRC15gZRIf+gPPsC3bDCWbU75MWifnnoRhr/8k=";
        };
        build-system = [ pyPrev.poetry-core ];
        dependencies = with pyPrev; [ bleak textual ];
        doCheck = false;
        pythonRelaxDeps = true;
      };
    };
  };
  python3Packages = final.python3.pkgs;
}
