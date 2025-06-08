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

  programs.fish.enable = true;
}

