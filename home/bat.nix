{ catppuccin-bat, ...}: {
  # a cat(1) clone with syntax highlighting and Git integration.
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      style = "changes,header";
      theme = "catppuccin-mocha";
    };
    # bat cache --build
    themes = {
      # https://raw.githubusercontent.com/catppuccin/bat/main/Catppuccin-mocha.tmTheme
      catppuccin-mocha = builtins.readFile (catppuccin-bat + "themes/Catppuccin Mocha.tmTheme");
      # https://github.com/Castrozan/.dotfiles/blob/main/nixos/home/programs/common.nix
      #dracula = {
      #  src = pkgs.fetchFromGitHub {
      #    owner = "dracula";
      #    repo = "sublime"; # Bat uses sublime syntax for its themes
      #    rev = "26c57ec282abcaa76e57e055f38432bd827ac34e";
      #    sha256 = "019hfl4zbn4vm4154hh3bwk6hm7bdxbr1hdww83nabxwjn99ndhv";
      #  };
      #  file = "Dracula.tmTheme";
      #};
    };
    extraPackages = with pkgs.bat-extras; [ batman ];
  };
}
