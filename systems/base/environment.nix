{ pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      #vim-custom
      micro
      nano
    ];
    variables.EDITOR = "micro";
  };
}
