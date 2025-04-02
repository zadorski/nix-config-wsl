args: {
  nixosConfigurations = import ./linux args;
  #darwinConfigurations = import ./macos args;
}