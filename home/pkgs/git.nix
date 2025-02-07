{ config, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      git
      # dependencies
      delta
      difftastic
    ];

    # ref:: https://github.com/petertriho/nix-config
    #file.".gitconfig".source = config.lib.meta.mkDotfilesSymlink "git/.gitconfig";
    #file.".gittemplates".source = config.lib.meta.mkDotfilesSymlink "git/.gittemplates";
  };
}
