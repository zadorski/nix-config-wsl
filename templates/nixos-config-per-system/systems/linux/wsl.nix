{ self, config, pkgs, lib, nixos-wsl, nixos-hardware, home-manager, hostRoles, ... }:
let
  hostSpec = {
    user = "paz";
    host = "crodax";
    state = "24.05";
  };
in
{
  imports =    
    [ nixos-wsl.nixosModules.default ] 
    #++ with nixos-hardware.nixosModules; [ common-gpu-intel common-cpu-intel ] 
    ++ (hostRoles [ "linux" ]);

  config = {
    networking.hostName = hostSpec.host;
    system.stateVersion = hostSpec.state;

    nixos = {
      beep.enable = true; # make a sound when ready
      # sleep at night 
      #autowake = {
      #  time.sleep = "21:30";
      #  time.wakeup = "07:30";
      #};
      german.enable = true; # no need if a server
    };

    wsl.enable = true;
    wsl.defaultUser = hostSpec.user;
    
    nix.settings.experimental-features = ["nix-command" "flakes"];
    
    virtualisation.containerd.enable = true;
    programs.bash.shellAliases = { nerdctl = "sudo nerdctl"; }; 
    security.sudo.extraRules = [{
      commands = [
        { command = "${pkgs.nerdctl}/bin/nerdctl"; options = [ "NOPASSWD" ]; }
      ];
    }];    
  };
}