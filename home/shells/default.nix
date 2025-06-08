{ pkgs, ... }:
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      if [[ $- == *i* ]]; then
        exec ${pkgs.fish}/bin/fish
      fi
    '';
  };

  programs.fish = {
    enable = true;
    shellAbbrs = { # Example: common abbreviations
      g = "git";
      ga = "git add";
      gc = "git commit";
    };
    # recommended settings for a good interactive experience
    interactiveShellInit = ''
      set -g fish_greeting # suppress fish's default greeting
      if type -q starship
        starship init fish | source
      end
    '';
  };
}

