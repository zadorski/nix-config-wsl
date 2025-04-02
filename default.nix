{ ... }@inputs:

{
  nixosConfigurations = {
    "crodax" = import ./hosts/wsl.nix (
      inputs
      // {
        hostname = "crodax";
        system = "x86_64-linux";
      }
    );
  };
}
