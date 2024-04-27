{ lib
, rustPlatform
, rustc
, fetchFromGitHub
, stdenv
, darwin
}:
let
  # package `anstream v0.6.4` cannot be built because it requires rustc 1.70.0 or newer
  # atm, nixpkgs 23.05 uses rustc 1.69.0, and 23.11 uses 1.73.0
  minimum-rustc = "1.70.0";
  rustc-too-old = (builtins.compareVersions rustc.version minimum-rustc) < 0;
in
rustPlatform.buildRustPackage rec {
  pname = "numbat";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "sharkdp";
    repo = "numbat";
    rev = "v${version}";
    hash = "sha256-/XUDtyOk//J4S9NoRP/s5s6URkdzePhW7UQ4FxDgmhs=";
  };

  cargoHash = "sha256-uM4LmD78ZHAzx5purTO+MUstaSrR+j2LuSDUBI2tl3s=";

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  meta = with lib; {
    description = "A statically typed programming language for scientific computations with first class support for physical dimensions and units";
    homepage = "https://github.com/sharkdp/numbat";
    license = with licenses; [ asl20 mit ];
    maintainers = with maintainers; [ ];
    mainProgram = "numbat";
    broken = if rustc-too-old then lib.warn "Need rustc ${minimum-rustc} or newer to build ${pname}. Consider upgrading nixpkgs to 23.11 or later" true else false;
  };
}
