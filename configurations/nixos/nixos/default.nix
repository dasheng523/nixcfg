# See /modules/nixos/* for actual settings
# This file is just *top-level* configuration.
{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self nixos-wsl;
in
{
  imports = [
    self.nixosModules.default
    # self.nixosModules.gui
    nixos-wsl.nixosModules.wsl
  ];

  networking.hostName = "homedev";
}
