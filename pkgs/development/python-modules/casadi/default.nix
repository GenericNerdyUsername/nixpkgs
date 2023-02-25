{ buildPythonPackage
, python
, casadi
, cmake
, pkg-config
, swig
, numpy
}:

buildPythonPackage rec {
  pname = "casadi-bindings";
  inherit (casadi) version src meta;
  format = "other";

  patches = [ ./remove-breaking.patch ];

  preConfigure = ''
    substituteInPlace CMakeLists.txt \
      --replace CASADI_DEV_DIR_GOES_HERE '${casadi.dev}/include'
  '';

  postConfigure = ''
    substituteInPlace swig/python/CMakeFiles/_casadi.dir/link.txt \
      --replace '-lcasadi' "-L${casadi}/lib/ -lcasadi"
  '';

  # The METADATA/setup.py file doesn't appear to be anywhere in the source tree
  # If it needs anything more than a version bump, download a wheel from
  # the homepage, extract it, and use the METADATA file in there
  postInstall = ''
    mkdir $out/${python.sitePackages}/casadi-${version}.dist-info
    cp ${./METADATA} $out/${python.sitePackages}/casadi-${version}.dist-info/METADATA
  '';

  # Prevent some things from being installed (pkg-config stuff, for example)
  prefix = "fakepath";

  cmakeFlags = [
    "-Wno-dev"
    "-DPYTHON_PREFIX=${placeholder "out"}/${python.sitePackages}"
    "-DWITH_PYTHON=ON"
    "-DWITH_PYTHON3=ON"

    # Disable everything that isn't python
    "-DWITH_EXAMPLES=OFF"
    "-DWITH_BUILD_SUNDIALS=OFF"
    "-DWITH_BUILD_CSPARSE=OFF"
    "-DWITH_TINYXML=OFF"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    swig
  ];

  propagatedBuildInputs = [
    numpy
  ];

  pythonImportsCheck = [ "casadi" ];
}
