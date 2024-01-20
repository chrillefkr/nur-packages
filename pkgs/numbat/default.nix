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
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "sharkdp";
    repo = "numbat";
    rev = "v${version}";
    hash = "sha256-zMgZ/QmpZaB+4xdxVBE3C8CWS/aNCDuowDWOg65PhTo=";
  };

  cargoHash = "sha256-x6SMQoiDf0GoyOJGP8S69wJnY/nCvo6Bq5KQyrgY+Gs=";

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
