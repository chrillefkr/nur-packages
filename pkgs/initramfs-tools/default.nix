{ pkgs
, fetchgit
, ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "initramfs-tools";
  version = "v0.142";

  src = fetchgit {
    url = "https://salsa.debian.org/kernel-team/initramfs-tools.git";
    rev = "${version}";
    hash = "sha256-6DnqTz1PtJpI/mgojQidWPyja7z27BelsNqa3dlkweE=";
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
}
