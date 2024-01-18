#!/usr/bin/env nix-shell
#! nix-shell ../shell.nix
#! nix-shell -i bash

set -xeufo pipefail

nix flake update

while read -r pkg; do
	nix-update "$pkg" || true
	nix-update --build "$pkg"
	nix-update --test "$pkg"
done <<EOF
numbat
EOF
