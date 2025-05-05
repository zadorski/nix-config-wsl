{ config, username, sops-nix, ... }:

{
  imports = [ 
    sops-nix.nixosModules.sops 
  ];

  sops.defaultSopsFile = ./encrypted.yaml;
  sops.age.keyFile = "/home/${username}/.config/sops/age/keys.txt"; # this is using an age key that is expected to already be in the filesystem
  
  #sops.secrets."example-key" = { }; # this is the actual specification of the secrets
  #sops.secrets."deepseek-api-key" = {
  #  owner = "${username}";
  #};

  #environment.variables = { # set system-wide environment variables (need system reboot)
  #  DEEPSEEK_API_KEY = "${builtins.readFile config.sops.secrets.deepseek-api-key.path}";
  #};
}
