{ pkgs, hostSpec, ... }: 
{
  config = {
    home.stateVersion = hostSpec.state;
    home.packages = with pkgs; [
      neovim
      tmux
      git
      nerdctl
    ];
  };
}