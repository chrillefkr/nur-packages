#!/usr/bin/env nix-shell
#! nix-shell ../shell.nix
#! nix-shell -i bash

set -xeufo pipefail

nix flake update --accept-flake-config -v -L --show-trace

while read -r pkg; do
	nix-update -F "$pkg" || continue
done <<EOF
numbat
dependabot-cli
EOF

nvchecker -c nv/nvchecker.toml
nvcmp -c nv/nvchecker.toml | while read -r pkg fr _ to; do
	nix-update -F "$pkg" --version "$to"
	nvtake -c nv/nvchecker.toml "${pkg}=${to}"
done
