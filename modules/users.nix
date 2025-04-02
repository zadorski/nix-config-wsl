{ pkgs, hostname, username, ... }:

{  
  nix.settings.trusted-users = [ username ];
  
  users.users."${username}" = {
    name = username;
    description = username;
    home = "/home/${username}";
    shell = pkgs.nushell;
  };
}
