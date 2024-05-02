{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "resticprofile";
  version = "0.26.0";

  src = fetchFromGitHub {
    owner = "creativeprojects";
    repo = "resticprofile";
    rev = "v${version}";
    hash = "sha256-3H14pe5RwV9zEKV5c+NKPPf2pLg43xkL902lljIMYyw=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-Qi7uhMXaWqI4NmYi+XTR15SyiUGhRiXPZmVud6aTM4s=";

  ldflags = [ "-s" "-w" ];

  # Tries to test things with ioreg etc.
  # TODO filter out specific tests
  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -m755 -D ''${NIX_BUILD_TOP}/go/bin/resticprofile $out/bin/resticprofile
    runHook postInstall
  '';

  meta = with lib; {
    description = "Configuration profiles manager and scheduler for restic backup";
    homepage = "https://github.com/creativeprojects/resticprofile";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "resticprofile";
  };
}
