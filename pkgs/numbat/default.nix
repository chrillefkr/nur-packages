{ lib
, rustPlatform
, fetchFromGitHub
, stdenv
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "numbat";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "sharkdp";
    repo = "numbat";
    rev = "v${version}";
    hash = "sha256-mwDpdQEIgvdGbcXEtA3TLP1e2yFNRCdcljaOzDEoKjg=";
  };

  cargoHash = "sha256-hGNfB82m2w9wDiPs8PMUExWOBN9ZQ+XVs1v8jhHuVhA=";

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
