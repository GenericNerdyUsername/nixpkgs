{ lib
, buildPythonPackage
, pythonOlder
, pythonAtLeast
, fetchFromGitHub
, cadquery-ocp
, casadi-bindings
, ezdxf
, multimethod
, nlopt-bindings
, nptyping
, path
, setuptools-scm
, typish
, stdenv
, Cocoa
}:

buildPythonPackage rec {
  pname = "cadquery";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "CadQuery";
    repo = pname;
    rev = version;
    hash = "sha256-KzwPD+bhCHFiLVAVLn9cLsVke/N3PTh7d2pAzuPeHKI=";
  };

  # pythonRelaxDepsHook doesn't work bc it only modifies the dependencies of the wheel, not setup.py directly
  postUnpack = ''
    substituteInPlace source/setup.py \
      --replace nptyping 'nptyping", #'
  '';

  buildInputs = lib.optional stdenv.isDarwin [ Cocoa ];

  propagatedBuildInputs = [
    cadquery-ocp
    casadi-bindings
    ezdxf
    multimethod
    nlopt-bindings
    nptyping
    nptyping
    path
    typish
  ];

  nativeBuildInputs = [
    setuptools-scm
  ];

  disabled = pythonOlder "3.8" || pythonAtLeast "3.11";

  meta = with lib; {
    description = "Parametric scripting language for creating and traversing CAD models";
    homepage = "https://github.com/CadQuery/cadquery";
    license = licenses.asl20;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
