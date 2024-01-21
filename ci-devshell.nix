{ self
, pkgs
, system ? builtins.currentSystem
, nix-pre-commit-lib ? self.inputs.nix-pre-commit.lib."${system}"
, nix-fast-build ? self.outputs.packages."${system}".nix-fast-build
, ...
}:
pkgs.mkShell.override { stdenv = pkgs.stdenvNoCC; } {
  packages = with pkgs; [
    # Ensure reproducible shell interpretation and nix evaluation
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
    nix-update

    # CI
    cachix
    nvchecker
    nix-fast-build
  ];
  shellHook = ''
    [[ ! -a .pre-commit-config.yaml ]] && ln -fs /dev/null .pre-commit-config.yaml # fix nix-pre-commit
    [[ -a .secrets ]] && source .secrets
  '' +
  (nix-pre-commit-lib.mkConfig {
    inherit pkgs;
    config = {
      repos = [
        {
          repo = "local";
          hooks = [
            {
              id = "nixpkgs-fmt";
              entry = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
              language = "system";
              types = [ "nix" ];
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
              args = [ "--edit" ];
              types = [ "nix" ];
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
              pass_filenames = false;
            }
          ];
        }
      ];
    };
  }).shellHook;
}
