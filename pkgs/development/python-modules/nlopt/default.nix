{ buildPythonPackage
, fetchFromGitHub
, lib
, autoPatchelfHook
, cmake
, swig
, nlopt
, numpy
}:

buildPythonPackage rec {
  pname = "nlopt-bindings";
  version = "2.7.1";

  src = fetchFromGitHub {
    owner = "DanielBok";
    repo = "nlopt-python";
    rev = version;
    hash = "sha256-xGiZEsSlGDfsWngWlj/zvNmArsMFHG/3uGy8czICJPo=";
  };

  propagatedBuildInputs = [
    numpy
  ];

  nativeBuildInputs = [
    cmake
    swig
  ];

  preConfigure = ''
    rmdir extern/nlopt
    cp -r ${nlopt.src} extern/nlopt
    chmod +w -R extern/nlopt
  '';

  postConfigure = ''
    cd /build/source/
  '';

  pythonImportsCheck = [ "nlopt" ];

  meta = with lib; {
    description = "A library for nonlinear local and global optimization";
    homepage = "https://github.com/stevengj/nlopt/";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ ];
  };
}
