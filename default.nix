{ debug ? false
, pkgs ? import
    (fetchTarball
      (
        let
          inherit ((builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked) rev narHash;
        in
        {
          url = "https://github.com/nixos/nixpkgs/archive/${rev}.tar.gz";
          sha256 = narHash;
        }
      ))
    { system = builtins.currentSystem; }
, lib ? pkgs.lib
, ...
}:

lib.fix (self: with self; {
  glibc-batsky = pkgs.glibc.overrideAttrs (attrs: {
    meta.broken = true;
    patches = attrs.patches ++ [
      ./pkgs/glibc-batsky/clock_gettime.patch
      ./pkgs/glibc-batsky/gettimeofday.patch
    ];
    postConfigure = ''
      export NIX_CFLAGS_LINK=
      export NIX_LDFLAGS_BEFORE=
      export NIX_DONT_SET_RPATH=1
      unset CFLAGS
      makeFlagsArray+=("bindir=$bin/bin" "sbindir=$bin/sbin" "rootsbindir=$bin/sbin" "--quiet")
    '';
  });

  haskellPackages = import ./pkgs/haskellPackages { inherit pkgs; };

  # Moved from old default.nix
  batsched-master = pkgs.callPackage ./pkgs/batsched/master.nix { intervalset = intervalsetlight; inherit debug loguru redox; };

  batexpe-master = pkgs.callPackage ./pkgs/batexpe/master.nix { inherit batexpe; };

  batsim-master = pkgs.callPackage ./pkgs/batsim/master.nix { inherit debug redox; intervalset = intervalsetlight; simgrid = simgrid-light; };
  batsim-docker-master = pkgs.callPackage ./pkgs/batsim/batsim-docker.nix { batsim = batsim-master; };

  pybatsim-master = pkgs.callPackage ./pkgs/pybatsim/master.nix { inherit pybatsim; };

  simgrid-master = pkgs.callPackage ./pkgs/simgrid/master.nix { inherit simgrid; };
  simgrid-light-master = pkgs.callPackage ./pkgs/simgrid/master.nix { simgrid = simgrid-light; };

  # Need to switch from 'buildGoPackage' to 'buildGoModule'
  #batexpe = pkgs.callPackage ./pkgs/batexpe { };

  # batsim-410 = pkgs.callPackage ./pkgs/batsim/batsim410.nix { inherit redox debug; simgrid = simgrid-334light; intervalset = intervalsetlight; };
  # batsim-420 = pkgs.callPackage ./pkgs/batsim/batsim420.nix { inherit redox debug; simgrid = simgrid-334light; intervalset = intervalsetlight; };
  # batsim = batsim-420;
  # batsim-docker = pkgs.callPackage ./pkgs/batsim/batsim-docker.nix { inherit batsim; };

  elastisim = pkgs.callPackage ./pkgs/elastisim { };

  cpp-driver = pkgs.callPackage ./pkgs/cpp-driver { };

  scylladb-cpp-driver = pkgs.callPackage ./pkgs/scylladb-cpp-driver { };

  bacnet-stack = pkgs.callPackage ./pkgs/bacnet-stack { };

  # TODO to remove when alumet package is finalized
  colmet-rs = pkgs.callPackage ./pkgs/colmet-rs { };

  #dcdb = pkgs.callPackage ./pkgs/dcdb { inherit scylladb-cpp-driver bacnet-stack mosquitto-dcdb; };

  ear = pkgs.callPackage ./pkgs/ear { };

  enoslib = pkgs.callPackage ./pkgs/enoslib { inherit iotlabcli iotlabsshcli distem python-grid5000 enoslib-ansible; };

  evalys = pkgs.callPackage ./pkgs/evalys { inherit procset; };

  flower = pkgs.callPackage ./pkgs/flower { inherit iterators; };

  iotlabsshcli = pkgs.callPackage ./pkgs/iotlabsshcli { inherit iotlabcli; };

  melissa = pkgs.callPackage ./pkgs/melissa { };
  melissa-heat-pde = pkgs.callPackage ./pkgs/melissa-heat-pde { inherit melissa; };

  # Need to switch from 'buildGoPackage' to 'buildGoModule'
  #gocovmerge = pkgs.callPackage ./pkgs/gocovmerge { };

  intervalset = pkgs.callPackage ./pkgs/intervalset { };
  intervalsetlight = pkgs.callPackage ./pkgs/intervalset { withoutBoostPropagation = true; };

  # Need to switch from 'buildGoPackage' to 'buildGoModule'
  #kube-batch = pkgs.callPackage ./pkgs/kube-batch { };

  mosquitto-dcdb = pkgs.callPackage ./pkgs/mosquitto-dcdb { };

  nxc = pkgs.callPackage ./pkgs/nxc { inherit execo; };

  oxidisched = pkgs.callPackage ./pkgs/oxidisched { };

  pybatsim-320 = pkgs.callPackage ./pkgs/pybatsim/pybatsim320.nix { inherit procset; };
  pybatsim-321 = pkgs.callPackage ./pkgs/pybatsim/pybatsim321.nix { inherit procset; };
  pybatsim-core-400 = pkgs.callPackage ./pkgs/pybatsim/core400.nix { inherit procset; };
  pybatsim-functional-400 = pkgs.callPackage ./pkgs/pybatsim/functional400.nix { pybatsim-core = pybatsim-core-400; };
  pybatsim = pybatsim-321;
  pybatsim-core = pybatsim-core-400;
  pybatsim-functional = pybatsim-functional-400;

  redox = pkgs.callPackage ./pkgs/redox { };

  rt-tests = pkgs.callPackage ./pkgs/rt-tests { };

  oar = pkgs.callPackage ./pkgs/oar { inherit procset pybatsim remote_pdb oar-plugins; };

  oar-plugins = pkgs.callPackage ./pkgs/oar-plugins { inherit procset pybatsim remote_pdb oar; };

  oar3 = oar;

  oar3-plugins = oar-plugins;

  #oar-with-plugins = oar.override { enablePlugins = true; };
  oar-with-plugins = pkgs.callPackage ./pkgs/oar { inherit procset pybatsim remote_pdb oar-plugins; enablePlugins = true; };


  # simgrid-327 = pkgs.callPackage ./pkgs/simgrid/simgrid327.nix { inherit debug; };
  # simgrid-328 = pkgs.callPackage ./pkgs/simgrid/simgrid328.nix { inherit debug; };
  # simgrid-329 = pkgs.callPackage ./pkgs/simgrid/simgrid329.nix { inherit debug; };
  # simgrid-330 = pkgs.callPackage ./pkgs/simgrid/simgrid330.nix { inherit debug; };
  # simgrid-331 = pkgs.callPackage ./pkgs/simgrid/simgrid331.nix { inherit debug; };
  # simgrid-332 = pkgs.callPackage ./pkgs/simgrid/simgrid332.nix { inherit debug; };
  # simgrid-334 = pkgs.callPackage ./pkgs/simgrid/simgrid334.nix { inherit debug; };
  # simgrid-335 = pkgs.callPackage ./pkgs/simgrid/simgrid335.nix { inherit debug; };
  # simgrid-336 = pkgs.callPackage ./pkgs/simgrid/simgrid336.nix { inherit debug; };
  simgrid-400 = pkgs.callPackage ./pkgs/simgrid/simgrid400.nix { inherit debug; };
  # simgrid-327light = simgrid-327.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; };
  # simgrid-328light = simgrid-328.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; };
  # simgrid-329light = simgrid-329.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; };
  # simgrid-330light = simgrid-330.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; buildPythonBindings = false; };
  # simgrid-331light = simgrid-331.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; buildPythonBindings = false; };
  # simgrid-332light = simgrid-332.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; buildPythonBindings = false; };
  # simgrid-334light = simgrid-334.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; buildPythonBindings = false; };
  # simgrid-335light = simgrid-335.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; buildPythonBindings = false; };
  # simgrid-336light = simgrid-336.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; buildPythonBindings = false; modelCheckingSupport = false; };
  simgrid-400light = simgrid-400.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; buildPythonBindings = false; modelCheckingSupport = false; };
  simgrid = simgrid-400;
  simgrid-light = simgrid-400light;

  slices-cli = pkgs.callPackage ./pkgs/slices-cli { inherit slices-bi-client ssh-known-hosts-edit; };

  # Setting needed for nixos-19.03 and nixos-19.09
  slurm-bsc-simulator =
    if pkgs ? libmysql
    then pkgs.callPackage ./pkgs/slurm-simulator { libmysqlclient = pkgs.libmysql; }
    else pkgs.callPackage ./pkgs/slurm-simulator { };
  slurm-bsc-simulator-v17 = slurm-bsc-simulator;

  #slurm-bsc-simulator-v14 = slurm-bsc-simulator.override { version="14"; };

  slurm-multiple-slurmd = pkgs.slurm.overrideAttrs (oldAttrs: {
    configureFlags = oldAttrs.configureFlags ++ [ "--enable-multiple-slurmd" "--enable-silent-rules" ];
    meta.platforms = pkgs.lib.lists.intersectLists pkgs.rdma-core.meta.platforms
      pkgs.ghc.meta.platforms;
  });

  slurm-front-end = pkgs.slurm.overrideAttrs (oldAttrs: {
    configureFlags = [
      "--enable-front-end"
      "--with-lz4=${pkgs.lz4.dev}"
      "--with-zlib=${pkgs.zlib}"
      "--sysconfdir=/etc/slurm"
      "--enable-silent-rules"
    ];
    meta.platforms = pkgs.lib.lists.intersectLists pkgs.rdma-core.meta.platforms
      pkgs.ghc.meta.platforms;
    meta.broken = true;
  });

  # Need to switch from 'buildGoPackage' to 'buildGoModule'
  #yamldiff = pkgs.callPackage ./pkgs/yamldiff { };
})
