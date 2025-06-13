{ pkgs, userName, gitEmail, gitHandle, lib, config, ... }:

{
  # import user-level configuration modules
  imports = [
    ./shells.nix      # bash and fish shell configuration
    ./devenv.nix      # development environment and tooling
    ./development.nix # toolchain
    ./windows         # windows native application configurations (optional)
  ];

  # basic home-manager configuration
  home = {
    username = userName;
    homeDirectory = "/home/${userName}";
    stateVersion = "24.05";  # home-manager release for backwards compatibility
  };

  # enable home-manager to manage itself
  programs.home-manager.enable = true;

  programs = {
    git = {
      enable = true;
      userName = gitHandle;
      userEmail = gitEmail;
    };

    ssh = {
      enable = true;
      matchBlocks = {
        "github.com" = {
          host = "github.com";
          user = "git";
          forwardAgent = true;
          identitiesOnly = true;
          identityFile = [ "~/.ssh/id_maco" ];
        };
        "ssh.dev.azure.com" = {
          host = "ssh.dev.azure.com";
          user = "git";
          forwardAgent = true;
          identitiesOnly = true;
          identityFile = [ "~/.ssh/id_rsa" ];
        };
        "* !ssh.dev.azure.com" = {
          identityFile = "~/.ssh/id_maco";
          identitiesOnly = true;
        };
      };
    };
  };

  # user-specific packages (keep minimal: use project-specific tools when possible)
  home.packages = with pkgs; [
    starship  # modern, fast, and customizable prompt for any shell
  ];

  # XDG configuration files
  xdg.configFile."starship.toml" = {
    source = ./starship.toml;
  };

  # Windows integration configuration (optional)
  # uncomment and configure to manage configuration for supported Windows apps

  # programs.windows-integration = {
  #   enable = true;
  #   windowsUsername = userName; # optional, auto-detected from WSL username
  #
  #   applications = {
  #     terminal = true;     # windows terminal with catppuccin mocha theme
  #     powershell = true;   # powershell profile with Starship integration
  #     vscode = true;       # vscode settings synchronization
  #     git = true;          # git configuration synchronization
  #     ssh = true;          # ssh key sharing between WSL and Windows
  #   };
  #
  #   pathResolution = {
  #     method = "dynamic";  # "dynamic" (recommended), "wslpath", "environment", or "manual"
  #   };
  #
  #   fileManagement = {
  #     strategy = "symlink";      # "symlink" (default), "copy", or "template"
  #     backupOriginals = true;    # backup existing Windows configurations
  #   };
  #
  #   fonts = {
  #     enable = true;             # enable font management and installation
  #     primaryFont = "CaskaydiaCove Nerd Font";  # primary font family
  #     autoInstall = true;        # automatically install fonts if missing
  #     sizes = {
  #       terminal = 11;           # font size for terminal applications
  #       editor = 14;             # font size for editor applications
  #     };
  #   };
  # };
}