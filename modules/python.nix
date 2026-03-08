# Python overlay with weallcode-robot package
final: prev: {
  python3 = prev.python3.override {
    packageOverrides = pyFinal: pyPrev: {
      weallcode-robot = pyPrev.buildPythonPackage rec {
        pname = "weallcode_robot";
        version = "3.1.4";
        src = prev.fetchPypi {
          inherit pname version;
          hash = "sha256-f+CR7eRC3XmBlEh/gPPsC3bDCZZtTvkxaJ56ehhr/8k=";
        };
        propagatedBuildInputs = with pyPrev; [ bleak ];
        doCheck = false;
      };
    };
  };
  python3Packages = final.python3.pkgs;
}
