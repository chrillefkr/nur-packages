#!/usr/bin/env nix-shell
#! nix-shell ./shell.nix
#! nix-shell -i "make -f"

.PHONY: all
all:
	@# use bash to prevent nix-shell invocation
	bash scripts/bump.sh
	pre-commit run
	nix-fast-build --option accept-flake-config true --skip-cached --flake ".#checks.$$(nix eval --raw --impure --expr builtins.currentSystem)" --out-link result
	cachix push chrillefkr-nur-repo result*

.PHONY: act
act:
	[ -f .secrets ] || echo "Maybe put cachix authentication token environment variable in `./.secrets` ?"
	act -s GITHUB_TOKEN="$$(gh auth token)"


