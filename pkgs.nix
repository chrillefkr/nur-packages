{ pkgs ? import <nixpkgs> { }, ... }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  numbat = pkgs.callPackage ./pkgs/numbat { };
  initramfs-tools = pkgs.callPackage ./pkgs/initramfs-tools { };
  dependabot-cli = pkgs.callPackage ./pkgs/dependabot-cli { buildGoModule = pkgs.buildGo122Module; };
  resticprofile = pkgs.callPackage ./pkgs/resticprofile { };
}
