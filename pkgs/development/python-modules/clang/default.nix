{ buildPythonPackage
, fetchPypi
, lib
}:

buildPythonPackage rec {
  pname = "clang";
  version = "14.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-D+JBOG07eAZm4DLYwuSCsdQ0iAGFxoUHGqOLeDF+lp8=";
  };

  meta = with lib; {
    description = "This is the python bindings subdir of llvm clang repository";
    homepage = "https://pypi.org/project/clang/";
    license = licenses.ncsa;
    maintainers = with maintainers; [ ];
  };
}
