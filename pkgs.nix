{ pkgs ? import <nixpkgs> { }, ... }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  initramfs-tools = pkgs.callPackage ./pkgs/initramfs-tools { };
  linux-msft-wsl = pkgs.callPackage ./pkgs/linux-msft-wsl { };
}
