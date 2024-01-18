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

    # Nix maintainer helper tools
    nix-init
    nix-update
  ];
  shellHook = (''
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
              args = [ "--check" ];
              language = "system";
              files = "\\.nix";
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
      ];
    };
  }).shellHook
  );
}
