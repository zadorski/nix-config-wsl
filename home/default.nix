{ pkgs, userName, gitEmail, gitHandle, ... }: 

{
  # import user-level configuration modules
  imports = [
    ./shells.nix      # bash and fish shell configuration
    ./devenv.nix      # development environment and tooling
    ./development.nix # toolchain
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
}