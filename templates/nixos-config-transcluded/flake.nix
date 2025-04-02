# credits:: https://github.com/Samunition/weasel.nix/blob/master/flake.nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixos-wsl, home-manager, ... }: 
  let 
    user = "paz";
    host = "crodax";
    state = "24.05";
  in
  {
    nixosConfigurations = {
      ${host} = nixpkgs.lib.nixosSystem { 
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          {
            networking.hostName = host;
            system.stateVersion = state;
            wsl.enable = true;
	          wsl.defaultUser = user;
            nix.settings.experimental-features = ["nix-command" "flakes"];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${user} = ./home.nix;            
          }
          { 
            virtualisation.containerd.enable = true;
            programs.bash.shellAliases = { nerdctl = "sudo nerdctl"; }; 
            security.sudo.extraRules = [{
              commands = [
                { command = "${nixpkgs.pkgs.nerdctl}/bin/nerdctl"; options = [ "NOPASSWD" ]; }
              ];
            }];
          }
        ];
      };
    };
  };
}
