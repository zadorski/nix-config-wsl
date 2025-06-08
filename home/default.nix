{ pkgs, userName, gitEmail, gitHandle, ... }: {
  imports = [
    ./shells
  ];

  home = {
    username = userName;
    homeDirectory = "/home/${userName}";
    stateVersion = "24.05";
  };

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
        "git" = {
          host = "github.com";
          user = "git";
          forwardAgent = true;
          identitiesOnly = true;
          identityFile = [
            "~/.ssh/id_maco"
          ];
        };
      };
    };
  };

  home.packages = with pkgs; [ ];
}