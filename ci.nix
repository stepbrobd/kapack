# The role of this file is to list which derivations should be built on CI.
# Example usage:
# - nix eval --json -f ci.nix 'pkgs-names-to-build'
# - nix eval --json -f ci.nix 'pkgs-to-build-with-deps'
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

let
  isDerivation = lib.isDerivation;
  isBuildable = p: !(p.meta.broken or false) && p.meta.license.free or true;
  isMaster = n: builtins.match "^.*-master$" n != null;
  wantToBuild = n: v: isDerivation v && isBuildable v && !(isMaster n);
  allInputs = p: builtins.filter (v: v != null) (p.buildInputs ++ p.nativeBuildInputs ++ p.propagatedBuildInputs);
in
lib.fix (self: with self; {
  default = import ./default.nix { inherit debug; };
  pkgs-to-build = lib.filterAttrs wantToBuild default;
  pkgs-names-to-build = builtins.attrNames pkgs-to-build;
  pkgs-to-build-with-deps = lib.mapAttrs (name: value: { derivation = value; inputs = allInputs value; }) pkgs-to-build;
})
