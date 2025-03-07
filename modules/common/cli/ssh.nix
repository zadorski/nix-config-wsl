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
              "/home/${config.user}/.ssh/id_maco" # explicit path in favor of nix determinism + consider using mkHomeDir
            ];
          };
        };
      };
    };
  };
}
