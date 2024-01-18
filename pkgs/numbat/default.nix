{ lib
, rustPlatform
, fetchFromGitHub
, stdenv
, darwin
}:

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
  };
}
