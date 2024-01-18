{ config, lib, pkgs, ... }:
let
  cfg = config.programs.yank;
  inherit (lib) mkEnableOption mkOption mkIf;
  inherit (lib.types) str;
  yank = pkgs.yank.overrideAttrs {
    makeFlags = [ "YANKCMD=${cfg.yankcmd}" ];
  };
in
{
  options.programs.yank = {
    enable = mkEnableOption "yank";
    yankcmd = mkOption {
      type = str;
      default = "${pkgs.wl-copy}/bin/wl-copy";
      description = "Command which yank runs to copy to clipboard. Examples: xclip (for Xorg), wl-copy (for Wayland), and pbcopy (for MacOS).";
      defaultText = "''${pkgs.wl-copy}/bin/wl-copy";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ yank ];
  };
}
