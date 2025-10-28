{ stdenv
, lib
, fetchFromGitLab
, fetchpatch
, cmake
, perl
, python3
, boost
, fortranSupport ? false
, gfortran
, buildDocumentation ? false
, transfig
, ghostscript
, doxygen
, buildJavaBindings ? false
, openjdk
, buildPythonBindings ? false
, python3Packages
, modelCheckingSupport ? false
, libunwind
, libevent
, elfutils # Inside elfutils: libelf and libdw
, minimalBindings ? false
, debug ? false
, optimize ? (!debug)
, moreTests ? false
, withoutBin ? false
, withoutBoostPropagation ? false
}:

with lib;

let
  optionOnOff = option: if option then "on" else "off";
in

stdenv.mkDerivation rec {
  pname = "simgrid";
  version = "3.28";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "0vylwgd4i89bvhbgfay0wq953324dwfmmr8jp9b4vvlc9m0017r9";
  };

  patches = [
    (fetchpatch {
      name = "fix-smpi-dirs-absolute.patch";
      url = "https://framagit.org/simgrid/simgrid/-/commit/71f01e667577be1076646eb841e0a57bd5388545.patch";
      sha256 = "0x3y324b6269687zfy43ilc48bwrs4nb7svh2mpg88lrz53rky15";
    })
  ];

  propagatedBuildInputs = optionals (!withoutBoostPropagation) [ boost ];
  nativeBuildInputs = [ cmake perl python3 ]
    ++ optionals withoutBoostPropagation [ boost ]
    ++ optionals fortranSupport [ gfortran ]
    ++ optionals buildJavaBindings [ openjdk ]
    ++ optionals buildPythonBindings [ python3Packages.pybind11 ]
    ++ optionals buildDocumentation [ transfig ghostscript doxygen ]
    ++ optionals modelCheckingSupport [ libunwind libevent elfutils ];

  # Make it so that libsimgrid.so will be found when running programs from the build dir.
  preConfigure = ''
    export LD_LIBRARY_PATH="$PWD/build/lib"
  '';

  cmakeBuildType = "Debug";

  cmakeFlags = [
    "-Denable_documentation=${optionOnOff buildDocumentation}"
    "-Denable_java=${optionOnOff buildJavaBindings}"
    "-Denable_python=${optionOnOff buildPythonBindings}"
    "-Denable_msg=${optionOnOff buildJavaBindings}"
    "-Denable_fortran=${optionOnOff fortranSupport}"
    "-Denable_model-checking=${optionOnOff modelCheckingSupport}"
    "-Denable_ns3=off"
    "-Denable_lua=off"
    "-Denable_lib_in_jar=off"
    "-Denable_maintainer_mode=off"
    "-Denable_mallocators=on"
    "-Denable_debug=on"
    "-Denable_smpi=on"
    "-Dminimal-bindings=${optionOnOff minimalBindings}"
    "-Denable_smpi_ISP_testsuite=${optionOnOff moreTests}"
    "-Denable_smpi_MPICH3_testsuite=${optionOnOff moreTests}"
    "-Denable_compile_warnings=off"
    "-Denable_compile_optimizations=${optionOnOff optimize}"
    "-Denable_lto=${optionOnOff optimize}"
  ];

  makeFlags = optional debug "VERBOSE=1";

  # Some Perl scripts are called to generate test during build which
  # is before the fixupPhase, so do this manualy here:
  preBuild = ''
    patchShebangs ..
  '';

  doCheck = true;

  # Prevent the execution of tests known to fail.
  preCheck = ''
    cat <<EOW >CTestCustom.cmake
    SET(CTEST_CUSTOM_TESTS_IGNORE smpi-replay-multiple)
    EOW

    # make sure tests are built in parallel (this can be long otherwise)
    make tests -j $NIX_BUILD_CORES
  '';

  dontStrip = debug;
  postInstall = "" + lib.optionalString withoutBin ''
    rm -rf $out/bin
  '';

  meta = {
    description = "Framework for the simulation of distributed applications";
    longDescription = ''
      SimGrid is a toolkit that provides core functionalities for the
      simulation of distributed applications in heterogeneous distributed
      environments.  The specific goal of the project is to facilitate
      research in the area of distributed and parallel application
      scheduling on distributed computing platforms ranging from simple
      network of workstations to Computational Grids.
    '';
    homepage = https://simgrid.org/;
    license = licenses.lgpl2Plus;
    broken = false;
    maintainers = with maintainers; [ mickours mpoquet ];
    platforms = platforms.all;
  };
}
