{ lib, fetchFromGitHub, fetchpatch, linuxManualConfig, runCommand, writeText, ... }:

# TODO
# nixos module
# modprobe

let
  wsl-config-path = "arch/x86/configs/config-wsl";

  # Stolen and modified from nixpkgs/pkgs/os-specific/linux/kernel/manual-config.nix
  # to include `# $key is not set`, which sets option to null.
  readConfig = configfile: import (runCommand "config.nix" { } ''

    echo "{" > "$out"
    while IFS='=' read key val; do
      regex="^# (CONFIG_[^ ]+) is not set$"
      if [[ "$key" =~ $regex ]]; then
        local key="''${BASH_REMATCH[1]}"
        echo "  $key = null;" >> "$out"
        continue;
      fi
      [ "x''${key#CONFIG_}" != "x$key" ] || continue
      no_firstquote="''${val#\"}";
      echo '  "'"$key"'" = "'"''${no_firstquote%\"}"'";' >> "$out"
    done < "${configfile}"
    echo "}" >> $out
  '').outPath;

  version = "6.1.21.2";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "WSL2-Linux-Kernel";
    rev = "linux-msft-wsl-${version}";
    hash = "sha256-szQ6swi0pFdwh3bF2HiVxbUnu/taw6yYWhBgyx7LFv4=";
    fetchSubmodules = false;
  };

  # Original wsl config file
  configfile = "${src}/${wsl-config-path}";
  # Original wsl config (parsed from file)
  config = readConfig configfile;

  # Merged config with both original wsl and our own additions
  # Null value here means `# $key is not set`.
  intermediateConfig = config // {
    # Added when `make oldconfig` from original source, so I assume upstream linux-msft-wsl
    # has missed to add values to these. Going with default values.
    # Why? I hate the messages from build when it runs make oldconfig.
    CONFIG_SLS = "n";
    CONFIG_GCC_PLUGINS = "y";
    CONFIG_GCC_PLUGIN_LATENT_ENTROPY = "n";
    CONFIG_GCC_PLUGIN_STACKLEAK = "n";
    CONFIG_RANDSTRUCT_NONE = "y";
    CONFIG_RANDSTRUCT_FULL = null;
    CONFIG_RANDSTRUCT_PERFORMANCE = null;
    CONFIG_INIT_STACK_NONE = "y";
    CONFIG_INIT_STACK_ALL_PATTERN = null;
    CONFIG_INIT_STACK_ALL_ZERO = null;

    # These got added when nvidia DRM_KMS_HELPER patch got applied. Default values here:
    CONFIG_DRM_DEBUG_DP_MST_TOPOLOGY_REFS = "n";
    CONFIG_DRM_I2C_CH7006 = "n";
    CONFIG_DRM_I2C_SIL164 = "n";
    CONFIG_DRM_I2C_NXP_TDA998X = "n";
    CONFIG_DRM_I2C_NXP_TDA9950 = "n";

    # To actually enable nvidia driver builds fix
    CONFIG_DRM_KMS_HELPER = "y";

    # KVM optimizations
    # https://boxofcables.dev/kvm-optimized-custom-kernel-wsl2-2022/#tweak-the-default-microsoft-kernel-configuration-for-kvm-guests
    CONFIG_KVM_GUEST = "y";
    CONFIG_ARCH_CPUIDLE_HALTPOLL = "y";
    CONFIG_HYPERV_IOMMU = "y";
    CONFIG_PARAVIRT_CLOCK = "y";
    CONFIG_CPU_IDLE_GOV_HALTPOLL = "y";
    CONFIG_HALTPOLL_CPUIDLE = "y";
    CONFIG_HAVE_ARCH_KCSAN = "n";
    CONFIG_KCSAN = "n";
    CONFIG_PTP_1588_CLOCK_KVM = "y";
  };

  render-config = config:
    let
      inherit (builtins) tryEval concatStringsSep elem toJSON;
      inherit (lib) mapAttrsToList toInt hasPrefix;
      renderValue = value:
        if (tryEval (toInt value)).success then value else
        if elem value [ "y" "n" "m" ] then value else
        if hasPrefix "0x" value then value else
        toJSON value; # probably a string at this point
    in
    concatStringsSep "\n" (mapAttrsToList
      (name: value:
        if builtins.isNull value then ''# ${name} is not set'' else
        ''${name}=${renderValue value}''
      )
      config);

  intermediateConfigFile = writeText "intermediate-config" (render-config intermediateConfig);

  drv = lib.overrideDerivation
    (linuxManualConfig rec {
      inherit src version;
      modDirVersion = "${version}-microsoft-standard-WSL2";

      config = intermediateConfig;
      configfile = intermediateConfigFile;

      kernelPatches = [
        # This one adds CONFIG_DRM_KMS_HELPER regardless of graphics driver added.
        { name = "Nvidia build fix"; patch = ./drm-kms-helper.patch; extraConfig = { }; }

        # Two "fixes" to play nice with running VMware Workstation on top of KVM, in quotes because patch 2 isn't really a fix.
        # KVM: nSVM: TLB_CONTROL / FLUSHBYASID "fixes"
        {
          name = ''Revert "nSVM: Check for reserved encodings of TLB_CONTROL in nested VMCB"'';
          # Doesn't work with current source, so I remade it
          # patch = fetchpatch {
          #   url = "https://lore.kernel.org/all/20231018194104.1896415-2-seanjc@google.com/raw";
          #   hash = "sha256-MXgxZb9CTiW0xAAXIlvD/glMvhaPW9p+7i2fZjKCIk0=";
          # };

          # Here's my manual edit and resulting patch:
          patch = ./revert-174a921b6975ef959dd82ee9e8844067a62e3ec1.patch;
          extraConfig = { };
        }
        {
          name = "KVM: nSVM: Advertise support for flush-by-ASID";
          patch = fetchpatch {
            url = "https://lore.kernel.org/all/20231018194104.1896415-3-seanjc@google.com/raw";
            hash = "sha256-8uT6Kz0XX0Ex7rU39U3BQCJE8OhhXHvwl6KFi8hzwSA=";
          };
          extraConfig = { };
        }
      ];

      # Helps linuxManualConfig to get config from file
      allowImportFromDerivation = true;

      extraMeta = {
        name = "linux-msft-wsl";
        description = "Microsoft WSL2 Linux Kernel";
        homepage = "https://github.com/microsoft/WSL2-Linux-Kernel";
        license = lib.licenses.gpl2Only;
        maintainers = with lib.maintainers; [ ];
      };

    })
    (oldAttrs: rec {
      pname = "${oldAttrs.meta.name}";
      name = "${pname}-${oldAttrs.version}";
    }) // {
    features = {
      #efiBootStub = true;
      ia32Emulation = true;
      #iwlwifi = true;
      #needsCifsUtils = true;
      #netfilterRPFilter = true;
    };
  };

in
drv
