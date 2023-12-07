{
  # uncomment the next line if you want to reference your GitHub/GitLab access tokens and other secrets
  # secrets,
  username,
  #hostname,
  pkgs,
  ...
}: {
  # check how WSL is secured from other users
  security.sudo.wheelNeedsPassword = false;

  # keep WSL sealed for inbound connection?
  # services.openssh.enable = true;

  # WSL specific for clipboard 
  environment.systemPackages = [
    (import ../nixos/win32yank.nix {inherit pkgs;})
  ];
  
  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    wslConf.interop.appendWindowsPath = false;      # NB: setting "appendWindowsPath" adds everything to your $PATH in NixOS which can cause slowdowns for certain CLI tools (use shell aliases instead to access explorer or code)
    wslConf.network.generateHosts = false;
    defaultUser = username;
    startMenuLaunchers = true;

    # enable integration with Docker Desktop (needs to be installed)
    docker-desktop.enable = false;
  };
}
