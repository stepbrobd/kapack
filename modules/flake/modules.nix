{
  flake.nixosModules =
    builtins.mapAttrs (name: path: import path) (import ../default.nix);
}
