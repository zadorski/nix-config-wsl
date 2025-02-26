{ ... }:

{
  imports = [
    ./kubernetes.nix
    ./terraform.nix
    ./nix-lang.nix
    ./rust.nix
    ./dotnet.nix
    ./devtools.nix
  ];
}
