{ pkgs, userName, gitEmail, gitHandle, ...}: {
  imports = [
    ./shells
    ./zellij

    ./bat.nix
    ./btop.nix
    ./starship.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = userName;
    homeDirectory = "/home/${userName}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "23.05";
  };

  # Let Home Manager install and manage itself.
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

    # eza = {
    #   enable = true;
    #   enableAliases = true; # do not enable aliases in nushell!
    #   git = true;
    #   # icons = true;
    # };

    # A command-line fuzzy finder
    fzf = {
      enable = true;
      enableBashIntegration = true;
      # https://github.com/catppuccin/fzf
      # catppuccin-mocha
      colors = {
        "bg+" = "#313244"; 
        "bg" = "#1e1e2e";
        "spinner" = "#f5e0dc";
        "hl" = "#f38ba8";
        "fg" = "#cdd6f4";
        "header" = "#f38ba8";
        "info" = "#cba6f7";
        "pointer" = "#f5e0dc";
        "marker" = "#f5e0dc";
        "fg+" = "#cdd6f4";
        "prompt" = "#cba6f7";
        "hl+" = "#f38ba8";
      };
    };

    # A smarter cd command
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };
  };

  home.packages = with pkgs; [
    # shell
    neofetch
    starship
    krabby

    # qmk
    ffmpeg-full

    # custom scripts
    # check home/shells/bin/
    (pkgs.buildEnv { name = "custom-scripts"; paths = [ ./shells ]; })
  ];
}