{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, blas
, lapack
, ipopt
}:

stdenv.mkDerivation rec {
  pname = "casadi";
  version = "3.5.5";

  separateDebugInfo = true;

  outputs = [ "out" "dev" ];

  src = fetchFromGitHub {
    owner = "casadi";
    repo = pname;
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-7PK+153S9qerdtSMNvp3lWkmS2i3PlI/kjCTEAaWtao=";
  };

  cmakeFlags = [
    "-Wno-dev"
    "-DWITH_EXAMPLES=OFF"
    "-DWITH_COMMON=ON"
    "-DWITH_THREAD=ON"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    ipopt
    lapack.dev
    blas
  ];

  meta = with lib; {
    description = "A tool for nonlinear optimisation and algorithmic differentiation";
    homepage = "https://web.casadi.org";
    license = licenses.lgpl3;
    maintainers = with maintainers; [ ];
  };
}
