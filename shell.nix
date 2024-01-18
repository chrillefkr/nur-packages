{ pkgs
, inputs
, nix-init ? inputs.nix-init.packages."${system}".default
, system ? builtins.currentSystem
, ...
}:
pkgs.mkShell.override { stdenv = pkgs.stdenvNoCC; } {
  packages = with pkgs; [
    # Ensure same shell interpretation and nix evaluation
    nix
    bash
    git

    # Enforce style, formatting, etc
    pre-commit
    commitizen
    nixpkgs-fmt
    deadnix
    statix

    # Nix maintainer helper tools
    nix-init
    nix-update
    nvchecker
  ];
  shellHook = ''
    [[ ! -a .pre-commit-config.yaml ]] && ln -fs /dev/null .pre-commit-config.yaml # fix nix-pre-commit
  '' +
  (inputs.nix-pre-commit.lib.${system}.mkConfig {
    inherit pkgs;
    config = {
      repos = [
        {
          repo = "local";
          hooks = [
            {
              id = "nixpkgs-fmt";
              entry = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
              #args = [ "--check" ];
              language = "system";
              types = [ "nix" ];
              #files = "\\.nix";
            }
          ];
        }
        {
          repo = "local";
          hooks = [
            {
              id = "commitizen";
              name = "commitizen check";
              entry = "${pkgs.commitizen}/bin/cz check";
              args = [ "--allow-abort" "--commit-msg-file" ];
              stages = [ "commit-msg" ];
              language = "system";
            }
          ];
        }
        {
          repo = "local";
          hooks = [
            {
              id = "deadnix";
              name = "deadnix";
              description = "Scan Nix files for dead code";
              entry = "${pkgs.deadnix}/bin/deadnix";
              #args = [ "--fail" ];
              args = [ "--edit" ];
              types = [ "nix" ];
              #stages = [ "commit-msg" ];
              language = "system";
            }
          ];
        }
        {
          repo = "local";
          hooks = [
            {
              id = "statix";
              name = "statix";
              description = "lints and suggestions for the nix programming language";
              entry = "${pkgs.statix}/bin/statix";
              #args = [ "check" ];
              args = [ "fix" ];
              types = [ "nix" ];
              language = "system";
              #require_serial = true;
              pass_filenames = false;
            }
          ];
        }
      ];
    };
  }).shellHook;
}
