{ pkgs, ... }:
{
  # bash configuration - used as login shell for WSL compatibility
  programs.bash = {
    enable = true;
    enableCompletion = true;  # enable tab completion

    # automatically switch to fish for interactive sessions
    # this gives us bash compatibility for login while using fish for interaction
    initExtra = ''
      if [[ $- == *i* ]]; then
        exec ${pkgs.fish}/bin/fish
      fi
    '';
  };

  # fish configuration - modern shell with good defaults
  programs.fish = {
    enable = true;

    # useful abbreviations for common Git commands
    shellAbbrs = {
      g = "git";
      ga = "git add";
      gc = "git commit";
    };

    # fish shell initialization for interactive sessions
    interactiveShellInit = ''
      set -g fish_greeting  # disable fish's default greeting message

      # initialize Starship prompt for enhanced development experience
      # Starship provides Git status, language versions, and command feedback
      # Configuration is managed in ~/.config/starship.toml via home-manager
      if type -q starship
        starship init fish | source
      end
    '';
  };
}

