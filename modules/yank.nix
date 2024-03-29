{ config, lib, pkgs, ... }:
let
  cfg = config.programs.yank;
  inherit (lib) mkEnableOption mkOption mkIf;
  inherit (lib.types) nullOr str;
  yank = if builtins.isNull cfg.yankcmd then pkgs.yank else
  pkgs.yank.overrideAttrs {
    makeFlags = [ "YANKCMD=${cfg.yankcmd}" ];
  };
in
{
  options.programs.yank = {
    enable = mkEnableOption "yank";
    yankcmd = mkOption {
      type = nullOr str;
      default = "${pkgs.wl-clipboard}/bin/wl-copy";
      description = "Command which yank runs to copy to clipboard. Examples: xclip (for Xorg), wl-copy (for Wayland), and pbcopy (for MacOS).";
      defaultText = "''${pkgs.wl-clipboard}/bin/wl-copy";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ yank ];
  };
}
