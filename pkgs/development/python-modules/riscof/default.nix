{ lib
, buildPythonPackage
, fetchFromGitHub
, git
, jinja2
, pythonOlder
, riscv-config
, riscv-isac
, python3Packages
, pkgsCross
, callPackage
}:

# TODO BEFORE COMMIT:
# fix first patch
# see if the test data directory is needed or if we can modify the template

buildPythonPackage rec {
  pname = "riscof";
  version = "1.25.3";
  format = "setuptools";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "riscv-software-src";
    repo = "riscof";
    tag = version;
    hash = "sha256-ToI2xI0fvnDR+hJ++T4ss5X3gc4G6Cj1uJHx0m2X7GY=";
  };

  patches = [
    # riscof expects you to use the riscv-gcc toolchain, whos output binaries are name "riscv32/64-unknown-elf"
    # our embedded riscv toolchains are called "riscv32/64-none-elf"
    # this patch replaces uses of the former with the latter
    ./riscv_none_elf.patch
    # sail-riscv changed the name of its output binaries, riscof hasn't been updated to account for that
    # this patch means the paths are read from environment variables (TODO and TODO respectively) which we set further down
    ./sail_riscv_name.patch
    # distutils.dir_util is used to copy some files, but distutils doesn't exist in python 3.12
    # this patch replaces usages of distutils with shutil (which is part of the stdlib)
    # also sets the permission bits correctly
    ./replace_distutils.patch
  ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace "import pip" ""
    substituteInPlace riscof/requirements.txt \
      --replace "GitPython==3.1.17" "GitPython"
  '';

  dependencies = [
    riscv-isac
    riscv-config
    jinja2
  ];

  pythonImportsCheck = [ "riscof" ];

  # No unitests available
  doCheck = false;

  passthru = rec {
    riscvArchTest = fetchFromGitHub rec {
      owner = "riscv-non-isa";
      repo = "riscv-arch-test";
      name = "riscv-arch-test";
      rev = "3.10.0";
      hash = "sha256-nhmKQJGyqbtAt51yDE1YdcD9GSQQv77VmLYpO85j120=";
    };
    tests.spikeAgainstSail = callPackage ./test.nix { inherit riscvArchTest; };
  };

  meta = with lib; {
    description = "RISC-V Architectural Test Framework";
    mainProgram = "riscof";
    homepage = "https://github.com/riscv-software-src/riscof";
    changelog = "https://github.com/riscv-software-src/riscof/blob/${version}/CHANGELOG.md";
    maintainers = with maintainers; [ genericnerdyusername ];
    license = licenses.bsd3;
  };
}
