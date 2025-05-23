# default system configuration
# samba is set to work with Windows by default
# US Intl keyboard, with Deutsch timezone and time notation
{ lib, config, pkgs, nixpkgs, ... }:
let
  cfg = config.nixos;
in
{
  # interface
  options.nixos =
    with lib;
    let
      mkBoolOption = d: mkEnableOption d // { default = true; };
      mkNonEmptyStrOption =
        description: default:
        mkOption {
          inherit description default;
          type = types.nonEmptyStr;
        };
    in
    {
      # just don't import if you don't want to enable
      enable = mkBoolOption "nixos configuration";

      audio = {
        enable = mkBoolOption "audio support";
        # some intel drivers behave poorly so I left the ability to disable
        usePipewire = mkBoolOption "pipewire for audio";
      };

      # automatically wake-up computer on timer
      autowake = {
        enable = mkEnableOption "auto sleep/wake up timer";
        time = {
          sleep = mkNonEmptyStrOption "time to put to sleep" "22:00";
          wakeup = mkNonEmptyStrOption "time to wake up" "07:00";
        };
      };

      # create a service that will beep after successful boot
      beep.enable = mkEnableOption "make some noise when we boot successfully";

      # repo to use for this device 
      flake = mkNonEmptyStrOption "flake to use when updating, rebuilding" "github:/MadMcCrow/nixos-configuration";

      # flatpak is supposed to be just a simple setting, 
      # but because of impermanence it may require extra-change
      flatpak.enable = mkEnableOption "flatpak software installation";

      # support for locale customizations
      german.enable = mkBoolOption "french locale, paris timeclock, international keyboard config";

      # extra nix option for easier installation of software
      nix = {
        # allow select unfree packages
        unfreePackages = mkOption {
          description = "list of allowed unfree packages";
          type = with lib.types; listOf str;
          default = [ ];
        };
        # overlays to add to nix
        overlays = mkOption {
          description = "list of nixpks overlays";
          type = types.listOf (mkOptionType {
            name = "nixpkgs-overlay";
            check = isFunction;
            merge = mergeOneOption;
          });
          default = [ ];
        };
      };
      # read install.md to install secureboot
      secureboot = {
        enable = mkBoolOption "secureboot for unlocking the luks device";
        # list of pcrs to enroll to,
        # necessary for auto unlock of disks
        # for some reason, 11 (systemd-stub) does not work as intended.
        # https://uapi-group.org/specifications/specs/linux_tpm_pcr_registry/
        pcrs = mkOption {
          description = "list of PCRS to enroll disks to";
          type = types.listOf types.int;
          default = [0 2 7 9];
          };
      };

      # sleep support
      sleep.enable = mkEnableOption "sleep mode support";
    };

  # consider use of mkDefault here
  config = lib.mkIf cfg.enable { 
    
    /*
    boot = {
      bootspec.enable = true;
      initrd = {
        # verbose = false;
        systemd = {
          enable = true; # TPM2 unlock
          network.wait-online.enable = config.nixos.server.enable;
        };
        inherit (config.boot) supportedFilesystems;
        luks = {
          devices =
          (lib.attrsets.optionalAttrs cfg.fileSystems.enable {
            # support encryption and decryption at boot
            "${cfg.fileSystems.root.luks.name}" = {
              device = "/dev/disk/by-partlabel/${cfg.fileSystems.root.partlabel}";
              allowDiscards = true;
              crypttabExtraOpts = [ "tpm2-device=auto" ];
            };
          })
          // (lib.attrsets.mapAttrs (_: v: {
            device = v;
            allowDiscards = true;
            crypttabExtraOpts = [ "tpm2-device=auto" ];
          }) cfg.fileSystems.luks);
        };
      };

      # support only what's necessary during the boot process
      supportedFilesystems = [
        "btrfs"
        "fat32"
      ];

      # clear tmp on boot
      tmp.cleanOnBoot = true;
      # choose correct bootloader :
      #   Lanzaboote currently replaces the systemd-boot module.
      loader.systemd-boot = {
        # enable if we're not using lanzaboote
        enable = lib.mkForce (!cfg.secureboot.enable);
        editor = false; # safety !
        configurationLimit = 5;
      };
      lanzaboote = {
        inherit (cfg.secureboot) enable;
        pkiBundle = "/etc/secureboot";
        configurationLimit = 5;
        editor = false;
      };
      # clean boot process
      plymouth.enable = false; # hide wall-of-text
      consoleLogLevel = 3; # avoid useless errors
    };
    */

    # font and use of keyboard options from the xserver
    console = {
      inherit (config.fonts) packages;
      # font = config.fonts.fontconfig.defaultFonts.monospace;
      font = lib.mkIf cfg.french.enable "Lat2-Terminus16";
      useXkbConfig = true; # use xkbOptions in tty
    };

    # everything needed to deal with encrypted file systems
    environment.defaultPackages = (
      with pkgs;
      config.fonts.packages
      ++ (lib.lists.optionals cfg.secureboot.enable [
        sbctl
        tpm-luks
        tpm2-tss
      ])
      ++ [
        openssl
        ifwifi
        networkmanager
        dnsutils
        nmap
        ltunify # logitech unifying support
      ]
      ++ (lib.lists.optionals cfg.flatpak.enable [
        libportal
        libportal-gtk3
        packagekit
      ])
    );

    /*
    fileSystems =
      let
        btrfsVolume = options: {
          device = "/dev/${cfg.fileSystems.root.lvm.vgroup}/nixos";
          fsType = "btrfs";
          inherit options;
        };
      in
      (lib.attrsets.optionalAttrs cfg.fileSystems.enable {
        # /
        #   root is always tmpfs
        "/" = {
          device = "none";
          fsType = "tmpfs";
          options = [
            "defaults"
            "size=${cfg.fileSystems.tmpfsSize}"
            "mode=755"
          ];
        };

        # /boot
        # Boot is always an Fat32 partition like old times
        "/boot" = {
          device = "/dev/disk/by-partlabel/${cfg.fileSystems.boot.partlabel}";
          fsType = "vfat";
        };

        # /nix
        #   Nix store and files
        #   more compression added to save space
        "/nix" = btrfsVolume [
          "subvol=/nix"
          "lazytime"
          "noatime"
          "compress=zstd:5"
        ];

        # /var/log
        # Logs and variable for running software
        # Limit disk usage with more compression
        # maybe move to /nix/persist ?
        "/var/log" = btrfsVolume [
          "subvol=/log"
          "compress=zstd:6" # higher level, default is 3
        ];

        # /tmp : cleared on boot, but on physical disk to avoid filling up ram
        "/tmp" = btrfsVolume [
          "subvol=/tmp"
          "lazytime"
          "noatime"
          "nodatacow" # no compression, but cleared on boot
        ];

        # /home
        #   TODO : maybe worth having setup elsewhere ?
        "/home" = btrfsVolume [
          "subvol=/home"
          "lazytime"
          "noatime"
          "compress=zstd"
        ];
      })
      // (lib.attrsets.mapAttrs'
        (n: v: {
          name = v;
          value = {
            device = "/nix/persist/${n}";
            options = [ "bind" ];
            neededForBoot = true;
            noCheck = true;
          };
        })
        (
          {
            "secureboot" = "/etc/secureboot";
            "ssh" = "/etc/ssh";
          }
          // cfg.fileSystems.persists
          // (lib.attrsets.optionalAttrs cfg.flatpak.enable {
            "flatpak" = "/var/lib/flatpak";
          })
        )
      );
    */

    # add all of our favorites fonts
    fonts = {
      fontDir.enable = true;
      packages = with pkgs; [
        noto-fonts
        open-sans
        roboto
        ubuntu_font_family
        jetbrains-mono
        nerdfonts
        terminus-nerdfont
        powerline-fonts
        fira-code-nerdfont
      ];
      fontconfig = {
        defaultFonts.monospace = map lib.getName [ pkgs.jetbrains-mono ];
        useEmbeddedBitmaps = true;
      };
    };

    hardware = {
      # disable pulseaudio if using pipewire 
      pulseaudio.enable = cfg.audio.enable && !cfg.audio.usePipewire;
    };

    # nix needs a lot of settings
    nix = {
      nixPath = [ "nixpkgs=flake:nixpkgs" ];
      registry.nixpkgs.flake = nixpkgs;
      package = pkgs.nix;
      settings = {
        # only sudo and root
        allowed-users = [ "@wheel" ];
        # enable flakes and commands
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        # binary caches
        substituters = [
          "https://nix-community.cachix.org"
          "https://cache.nixos.org/"
          "https://nixos-configuration.cachix.org"
        ];
        # ssh keys of binary caches
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nixos-configuration.cachix.org-1:dmaMl2SX7/VRV1qAQRntZaNEkRyMcuqjb7H+B/2jlF0="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        # detect files in the store that have identical contents,
        # and replaces them with hard links to a single copy
        auto-optimise-store = true;
      };

      # garbage collection
      gc = {
        automatic = true;
        dates = "daily";
        persistent = true;
      };
      optimise.automatic = true;
      optimise.dates = [ "daily" ];
      # serve nix store over ssh (the whole network can help each other)
      sshServe.enable = true;
    };

    nixpkgs = {
      # predicate from list
      config.allowUnfreePredicate =
        pkg: builtins.elem (lib.getName pkg) cfg.unfreePackages;
      # each functions gets its pkgs from here :
      config.packageOverrides =
        pkgs:
        (lib.mkMerge (
          builtins.mapAttrs (_: value: (value pkgs)) cfg.overrides
        ));
    };

    programs.nh = {
      enable = true;
      clean.enable = !config.nix.gc.automatic;
      clean.extraArgs = "--keep-since 4d --keep 3";
      # flake = "/home/user/my-nixos-config";
    };

    services = {
      # avahi for mdns :
      avahi = rec {
        enable = true;
        nssmdns4 = true;
        ipv6 = true;
        ipv4 = true;
        openFirewall = true;
        publish = {
          enable = true;
          domain = true;
          workstation = true;
          userServices = true;
          addresses = true;
          hinfo = true;
        };
        # may prevent to detect samba shares
        domainName = lib.mkIf (
          config.networking.domain != null
        ) config.networking.domain; # defaults to "local";
        browseDomains = [ domainName ];
      };

      # scrub-ba-dub-dub
      btrfs.autoScrub = {
        enable = true;
        interval = "weekly";
        fileSystems = [
          "/nix"
          "/var/log"
          "/home" # maybe remove this when we move home
        ];
      };

      # thin provisioning for lvm
      lvm.boot.thin.enable = true;

      # remote shell via ssh
      openssh = {
        enable = true;
        # require public key authentication for better security
        settings = {
          KbdInteractiveAuthentication = false;
          PasswordAuthentication = false;
        };
        #permitRootLogin = "yes";
      };

      # audio setup through pipewire
      pipewire = lib.mkIf (cfg.audio.enable && cfg.audio.usePipewire) {
        enable = true;
        package = pkgs.pipewire;
        # use pipewire for all audio streams
        audio.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      # settings to detect and mount samba shares from windows
      samba-wsdd.workgroup = "WORKGROUP";

      # sync to those european servers
      timesyncd.servers = lib.mkIf cfg.german.enable [
        "de.pool.ntp.org"
        "europe.pool.ntp.org"
      ];

      # keyboard settings for xserver
      xserver.xkb = lib.mkIf cfg.french.enable {
        layout = "us";
        variant = "intl";
        options = "eurosign:e";
      };
    };

    #
    security = {
      # lockKernelModules = true; # maybe too much !
      # Prevent kernel tampering
      protectKernelImage = true;
      # allow users to login via ssh
      pam.sshAgentAuth.enable = true;
      # required by pulseaudio and recommended for pipewire 
      rtkit.enable = cfg.audio.enable;
      # disable the sudo warnings about calling sudo
      # (it will get wiped every reboot)
      sudo.extraConfig = "Defaults        lecture = never";
      # add support for TPM2 
      tpm2 = {
        enable = true;
        pkcs11.enable = true;
      };
    };

    # enable or disable sleep/suspend
    systemd = {
      # TODO: make sleep a thing 
      targets = {
        sleep.enable = cfg.sleep.enable or cfg.autowake.enable;
        suspend.enable = cfg.sleep.enable;
        hibernate.enable = cfg.sleep.enable;
        hybrid-sleep.enable = cfg.sleep.enable;
      };

      # TODO: maybe add persist folders 
      tmpfiles.rules = [ ];

      services = {
        # beeps when we reach multi-user :
        "beep" = lib.mkIf cfg.beep.enable {
          after = [ "systemd-user-sessions.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = lib.getExe pkgs.beep;
          };
        };
        # wake up the computer at a certain time :
        "autowake" = lib.mkIf cfg.autowake.enable {
          restartIfChanged = false;
          stopIfChanged = false;

          startAt = cfg.autowake.time.sleep;
          # put to sleep until wake time :
          script = ''
            NEXT=$(systemd-analyze calendar "${cfg.autowake.time.wakeup}" | sed -n 's/\W*Next elapse: //p')
            AS_SECONDS=$(date +%s -d "$NEXT")
            echo "will wakeup on $(NEXT)"
            rtcwake -s $(AS_SECONDS)
          '';
        };
      };

      # faster boot
      network.wait-online.enable = true;
    };

    /*
    # some swap hardware 
    swapDevices = lib.lists.optionals cfg.fileSystems.swap.enable [
      {
        label = "swap";
        device = lib.mkForce "/dev/${cfg.fileSystems.root.lvm.vgroup}/swap";
        randomEncryption = lib.mkIf (!cfg.fileSystems.root.luks.enable) {
          enable = true;
          allowDiscards = true;
        };
      }
    ];
    */

    networking = {
      # unique identifier for machines
      hostId =
        with builtins;
        elemAt (elemAt (split "(.{8})" (
          hashString "md5" config.networking.hostName
        )) 1) 0;
      # use dhcp for addresses. static adresses are given by the rooter
      useDHCP = lib.mkForce true;
      enableIPv6 = true;
      dhcpcd.persistent = true;
      # nm is more convenient for now
      networkmanager.enable = true;
    };

    # language formats :
    i18n = lib.mkIf cfg.french.enable {
      defaultLocale = "en_US.UTF-8";
      supportedLocales = map (x: x + "/UTF-8") [
        "en_US.UTF-8"
        "de_DE.UTF-8"
        "C.UTF-8"
      ];
      # set all the variable
      extraLocaleSettings = {
        # LC_ALL   = us-utf8;
        # LANGUAGE = us-utf8;
        LC_TIME = "de_DE.UTF-8"; # use a reasonable date format
      };
    };

    # time zone stuff
    time.timeZone = lib.mkIf cfg.german.enable "Europe/Berlin";
    location.provider = lib.mkDefault "geoclue2";

    # same GID for all SSH users
    users.groups.ssl-cert.gid = 119;

    # disable documentation (don't download, online is always up to date)
    documentation.nixos.enable = false;
  };
}