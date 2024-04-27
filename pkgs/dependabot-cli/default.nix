{ lib
  #, pkgs
  #, docker ? pkgs.docker
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "dependabot-cli";
  version = "1.52.0";

  src = fetchFromGitHub {
    owner = "dependabot";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-wb91otcK1zKWWlGCm1lYoN+Him2w4DROr0DTFCajsZ4=";
  };

  vendorHash = "sha256-vUT+WbABtfCO3flrD43XvPdZzRD8cEJLCtUVHsasquw=";

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
