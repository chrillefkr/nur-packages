{
  description = "My personal NUR repository";
  nixConfig = {
    extra-substituters = [
      "https://chrillefkr-nur-repo.cachix.org"
    ];
    extra-trusted-public-keys = [
      "chrillefkr-nur-repo.cachix.org-1:trN48icxaeXamJnNupHAKHWfuen58GjSiAiI/wAdSfo="
    ];
  };
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
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    nix-fast-build = {
      url = "github:Mic92/nix-fast-build";
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
      forAllSystems = f: nixpkgs.lib.genAttrs systems f;
    in
    {
      legacyPackages = forAllSystems (system: (import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
      }) // {
        nix-init = inputs.nix-init.outputs.packages."${system}".default;
        inherit (inputs.nix-fast-build.packages."${system}") nix-fast-build;
      });
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
      checks = forAllSystems (system:
        let
          ci = import ./ci.nix {
            pkgs = import nixpkgs { inherit system; };
          };
          attr = builtins.listToAttrs (builtins.map (p: { name = p.pname; value = p; }) ci.cacheOutputs);
        in
        attr);
      nixosModules = import ./modules;
      devShells = forAllSystems (system: {
        default = import ./devshell.nix {
          pkgs = import nixpkgs { inherit system; };
          inherit self inputs system;
          nix-init = inputs.nix-init.outputs.packages."${system}".default;
        };
        ci = import ./ci-devshell.nix {
          pkgs = import nixpkgs { inherit system; };
          inherit self inputs system;
        };
      });
      formatter = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.writeScriptBin "formatter" ''
          ${pkgs.pre-commit}/bin/pre-commit run -a
        '');
    };
}
