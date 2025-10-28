{
  outputs = inputs: inputs.parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;

    flake.nixosModules =
      builtins.mapAttrs (name: path: import path) (import ./modules);

    perSystem = { lib, pkgs, ... }: {
      packages = import ./nur.nix { inherit pkgs; };

      formatter = pkgs.writeShellScriptBin "formatter" ''
        ${lib.getExe pkgs.nixpkgs-fmt} .
      '';
    };
  };

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.parts.url = "github:hercules-ci/flake-parts";
  inputs.parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  inputs.systems.url = "github:nix-systems/default";
}
