{
  outputs = { self, nixpkgs, nixos-wsl, home-manager,  ... } @inputs: {
    nixosConfigurations = {
      crodax = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          nixos-wsl.nixosModules.default
          {
            wsl.defaultUser = "paz";
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
            system.stateVersion = "24.05";
            wsl.enable = true;
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;          # it allows the home-manager setup to activate properly inside a `nixos-rebuild build-vm` (helping to avoid `nix-env` like the plague, per https://discourse.nixos.org/t/need-configuration-feedback-and-tips-and-question-about-managing-shell-scripts/17232/3)
            home-manager.users.paz = import ./home.nix;
            #home-manager.extraSpecialArgs = inputs;      # why?
          }
        ];       
      };
    };
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";   
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";   # prefer rolling release
    nixos-wsl.url = "github:nix-community/nixos-wsl/main";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };  
}
