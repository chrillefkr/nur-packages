{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-init = {
      url = "github:nix-community/nix-init/v0.3.0";
      #inputs.nixpkgs.follows = "nixpkgs"; # Don't, nix-init build breaks
    };
    nix-pre-commit = {
      url = "github:jmgilman/nix-pre-commit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, ... }@inputs:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      legacyPackages = forAllSystems (system: (import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
      }) // {
        nix-init = inputs.nix-init.outputs.packages."${system}".default;
      });
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
      devShells = forAllSystems (system: {
        default = import ./shell.nix {
          pkgs = import nixpkgs { inherit system; };
          inherit self inputs system;
          nix-init = inputs.nix-init.outputs.packages."${system}".default;
        };
      });
    };
}
