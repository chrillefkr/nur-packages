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
}
