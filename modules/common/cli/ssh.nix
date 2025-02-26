{ config, pkgs, ... }:

{
  config = {
    home-manager.users.${config.user} = {
      programs.ssh = {
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
  };
}
