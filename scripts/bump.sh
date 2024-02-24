#!/usr/bin/env nix-shell
#! nix-shell ../shell.nix
#! nix-shell -i bash

set -xeufo pipefail

BUMP_AND_COMMIT="${BUMP_AND_COMMIT:-"0"}"

nix flake update --accept-flake-config -v -L --show-trace

while read -r pkg; do
	nix-update -F "$pkg" || continue
	if [[ "$BUMP_AND_COMMIT" != "0" ]]; then
		git stash push
		pre_version="$(nix eval --raw ".#${pkg}.version")"
		git stash pop
		post_version="$(nix eval --raw ".#${pkg}.version")"
		git add -A
		git commit -m "build(${pkg}): bump version from ${pre_version} to ${post_version}"
	fi
done <<EOF
numbat
dependabot-cli
EOF

nvchecker -c nv/nvchecker.toml
nvcmp -c nv/nvchecker.toml | while read -r pkg fr _ to; do
	nix-update -F "$pkg" --version "$to"
	nvtake -c nv/nvchecker.toml "${pkg}=${to}"
	if [[ "$BUMP_AND_COMMIT" != "0" ]]; then
		git add -A
		git commit -m "build(${pkg}): bump version from ${fr} to ${to}"
	fi
done
