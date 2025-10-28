{ lib, inputs, ... }:

let
  inherit (lib) filterPackages importPackagesWith mkDynamicAttrs;
in
{
  perSystem = { pkgs, system, ... }: {
    packages = /* filterPackages system */ (mkDynamicAttrs {
      dir = ../../pkgs;
      fun = name: importPackagesWith (pkgs // { inherit inputs lib; }) (../../pkgs/. + "/${name}") { };
    });
  };
}
