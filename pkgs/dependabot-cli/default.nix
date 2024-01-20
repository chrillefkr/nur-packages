{ lib
  #, pkgs
  #, docker ? pkgs.docker
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "dependabot-cli";
  version = "1.47.0";

  src = fetchFromGitHub {
    owner = "dependabot";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-3sSZWgeoLXPHh0/lAAqJwgJFgdwPS8xUei1Pval0eQQ=";
  };

  vendorHash = "sha256-ZrmW1z3iaC115Sl8XAFe9TqZoaE+vzUFUFxWvqsBZA8=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/dependabot/cli/cmd/dependabot/internal/cmd.version=${src.rev}"
  ];

  # `doCheck = true;` fails as it tries to run docker
  # And I can't figure out how to skip specific tests
  # So I'll just disable for now
  #nativeCheckInputs = [ docker ];
  doCheck = false;

  postInstall = ''
    mkdir -p ''${out}/share/bash-completions/completions
    ''${out}/bin/dependabot completion bash > ''${out}/share/bash-completions/completions/dependabot.bash
    mkdir -p ''${out}/share/fish/vendor_completions.d
    ''${out}/bin/dependabot completion fish > ''${out}/share/fish/vendor_completions.d/dependabot.fish
    mkdir -p ''${out}/share/zsh/site-functions
    ''${out}/bin/dependabot completion zsh > ''${out}/share/zsh/site-functions/_dependabot
  '';


  meta = with lib; {
    description = "A tool for testing and debugging Dependabot update jobs";
    homepage = "https://github.com/dependabot/cli";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "dependabot";
  };
}
