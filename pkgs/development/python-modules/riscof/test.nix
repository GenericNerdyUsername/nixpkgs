{ riscvArchTest
, sail-riscv
, python3Packages
, writeText
, lib
, stdenv
, fusesoc
, verilator
, runCommand
, riscof
, spike
, dtc
, pkgsCross
}:

let
  rv32CC = pkgsCross.riscv32-embedded.buildPackages.gcc;
  rv64CC = pkgsCross.riscv64-embedded.buildPackages.gcc;

  configFile = writeText "config.ini" ''
    [RISCOF]
    ReferencePlugin=sail_cSim
    ReferencePluginPath=${riscof}/lib/python${riscof.pythonModule.pythonVersion}/site-packages/riscof/Templates/setup/sail_cSim
    DUTPlugin=spike_parallel
    DUTPluginPath=${./test_data}

    [spike_parallel]
    pluginpath = ${./test_data}
    ispec = ${./test_data}/spike_parallel_isa.yaml
    pspec = ${./test_data}/spike_parallel_platform.yaml
    exe = ${spike}/bin/spike

    [sail_cSim]
    pluginpath=${riscof}/lib/python${riscof.pythonModule.pythonVersion}/site-packages/riscof/Templates/setup/sail_cSim
    PATH=${sail-riscv}/bin
  '';


in
runCommand "riscof_test"
{
  nativeBuildInputs = [ riscof sail-riscv spike dtc ];
  buildInputs = [ rv32CC rv64CC ];
}
  ''
    riscof run \
               --no-browser \
               --config=${configFile} \
               --suite=${riscvArchTest}/riscv-test-suite \
               --env=${riscvArchTest}/riscv-test-suite/env
    cp -r riscof_work $out
    # Sometimes riscof can error but without giving a nonzero exit code.
    # This checks that the report was actually made
    test -f $out/report.html
  ''
