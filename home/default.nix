{ pkgs, userName, gitEmail, gitHandle, ... }: 

{
  # import user-level configuration modules
  imports = [
    ./shells.nix  # bash and fish shell configuration
  ];

  # basic home-manager configuration
  home = {
    username = userName;
    homeDirectory = "/home/${userName}";
    stateVersion = "24.05";  # home-manager release version
  };

  # enable home-manager to manage itself
  programs.home-manager.enable = true;

  programs = {
    # Git configuration for version control
    git = {
      enable = true;
      userName = gitHandle;   # your Git username
      userEmail = gitEmail;   # your Git email address
    };

    ssh = {
      enable = true;
      # basic SSH configuration for Git and remote access
      # add your SSH keys to ~/.ssh/ and configure as needed
      matchBlocks = {
        "github.com" = {
          host = "github.com";
          user = "git";
          forwardAgent = true;
          identitiesOnly = true;
          # uncomment and adjust the identity file path as needed
          # identityFile = [ "~/.ssh/id_ed25519" ];
        };
      };
    };
  };

  # user-specific packages (keep minimal - use project-specific tools when possible)
  home.packages = with pkgs; [ ];
}