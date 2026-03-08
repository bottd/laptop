# Custom packages overlay
final: prev: {
  weallcode-robot = prev.python3Packages.buildPythonPackage rec {
    pname = "weallcode_robot";
    version = "3.1.4";
    src = prev.fetchPypi {
      inherit pname version;
      hash = "sha256-f+CR7eRC3XmBlEh/gPPsC3bDCZZtTvkxaJ56ehhr/8k=";
    };
    propagatedBuildInputs = with prev.python3Packages; [ bleak ];
    doCheck = false;
  };
}
