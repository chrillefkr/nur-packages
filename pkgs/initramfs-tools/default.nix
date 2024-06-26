{ lib
, stdenvNoCC
, fetchFromGitLab
}:

stdenvNoCC.mkDerivation rec {
  pname = "initramfs-tools";
  version = "0.143";

  src = fetchFromGitLab {
    domain = "salsa.debian.org";
    owner = "kernel-team";
    repo = "initramfs-tools";
    rev = "v${version}";
    hash = "sha256-dZ6l2qRlvn49Mat5342vHaNpWy5TxCsdUX7WesmLqZQ=";
  };

  outputs = [ "out" ];
  buildPhase = "";
  installPhase = ''
    mkdir -p $out/bin $out/share/man{5,7,8} $out/share/bash-completion/completions
    cp lsinitramfs mkinitramfs unmkinitramfs update-initramfs $out/bin
    cp initramfs.conf.5 update-initramfs.conf.5 $out/share/man5
    cp initramfs-tools.7 $out/share/man7
    cp lsinitramfs.8 mkinitramfs.8 unmkinitramfs.8 update-initramfs.8 $out/share/man8
    #cp bash_completion.d/update-initramfs $out/share/bash-completion/completions
  '';

  meta = with lib; {
    description = "Initramfs-tools";
    homepage = "https://salsa.debian.org/kernel-team/initramfs-tools";
    #license = unknown, none?
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
