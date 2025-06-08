{ pkgs, config, ... }: {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    # Launch Fish by default when Bash starts
    initExtra = "fish";
  };

  programs.fish = {
    enable = true;
    # plugins = [ # Example: add plugins if desired later
    #   { name = "plugin-name"; src = pkgs.fetchFromGitHub { ... }; }
    # ];
    # shellAbbrs = { # Example: common abbreviations
    #   g = "git";
    #   ga = "git add";
    #   gc = "git commit";
    # };
    # Recommended settings for a good interactive experience
    interactiveShellInit = ''
      set -g fish_greeting # Suppress fish's default greeting
      # Consider adding starship init if starship is desired
      # if type -q starship
      #   starship init fish | source
      # end
    '';
  };

  # Nushell configuration removed
}
