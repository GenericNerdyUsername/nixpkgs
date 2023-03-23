{ buildPythonPackage
, cmake
, fetchFromGitHub
, fontconfig
, lib
, libclang
, libcxx
, libglvnd
, llvm
, ninja
, opencascade-occt
, python
, rapidjson
, stdenv
, tcl
, tk
, vtk
, writeText

  # For the scripts in preconfigure
, clang-bindings
, click
, jinja2
, joblib
, lief
, logzero
, pandas
, path
, pybind11
, pyparsing
, schema
, toml
, toposort
, tqdm
}:

let
  binary = buildPythonPackage rec {
    pname = "cadquery-ocp-bin";
    version = "7.7.0.0";
    format = "other";

    src = fetchFromGitHub {
      owner = "cadquery";
      repo = "ocp";
      rev = version;
      fetchSubmodules = true;
      hash = "sha256-ymwsXjedBj34IhrfTF9l+xBFQ/e1gkA+HgGtYGbLlDA=";
    };

    patches = [ ./new_pandas.patch ];

    nativeBuildInputs = [
      cmake
      ninja
      llvm.dev
      libclang.dev

      # For the scripts in preconfigure
      clang-bindings
      click
      jinja2
      joblib
      lief
      logzero
      pandas
      path
      pybind11
      pyparsing
      schema
      toml
      toposort
      tqdm
    ];

    buildInputs = [
      fontconfig
      opencascade-occt
      pybind11
      rapidjson
      tcl
      tk
      vtk
    ];

    preConfigure = ''
      echo "Updating list of symbols"
      ln -s ${opencascade-occt} ./lib_linux
      python3 -m dump_symbols .
      cp symbols_mangled_linux.dat pywrap/symbols_mangled_linux.dat
      rm {.,pywrap}/symbols_mangled_{win,mac}.dat

      echo "Generating bindings"
      PYTHONPATH="$PYTHONPATH:$(realpath ./pywrap)"
      python3 -m bindgen \
        -n $NIX_BUILD_CORES \
        -i ${vtk}/include/vtk \
        -i ${rapidjson}/include \
        -i ${libglvnd.dev}/include \
        -i ${libcxx.dev}/include/c++/v1 \
        -i ${stdenv.cc.libc.dev}/include \
        -i ${libclang.lib}/lib/clang/${libclang.version}/include \
        -l ${libclang.lib}/lib/libclang.so \
        all ocp.toml Linux
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/${python.sitePackages}
      cp /build/source/build/OCP/OCP.* $out/${python.sitePackages}

      runHook postInstall
    '';

    pythonImportsCheck = [ "OCP" ];
  };

in
buildPythonPackage rec {
  name = "cadquery-ocp";
  version = "7.7.0a1";
  # Get the version number from the releases of https://github.com/cadquery/ocp-build-system

  unpackPhase =
    let
      fakeSetupPy =
        writeText "cadquery-ocp-fake-setup.py" ''
          from setuptools import setup

          setup(
              name="cadquery-ocp",
              version="${version}"
          )
        '';
    in
    "cp ${fakeSetupPy} setup.py";

  propagatedBuildInputs = [ binary ];

  passthru.binary = binary;

  meta = with lib; {
    description = "Python wrapper for OCCT generated using pywrap";
    homepage = "https://github.com/CadQuery/OCP";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
