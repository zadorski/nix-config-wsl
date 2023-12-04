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
    wslConf.interop.appendWindowsPath = false;
    wslConf.network.generateHosts = false;
    defaultUser = username;
    startMenuLaunchers = true;

    # enable integration with Docker Desktop (needs to be installed)
    docker-desktop.enable = false;
  };

  # uncomment the next block to make vscode running in Windows "just work" with NixOS on WSL
  # solution adapted from: https://github.com/K900/vscode-remote-workaround
  # more information: https://github.com/nix-community/NixOS-WSL/issues/238 and https://github.com/nix-community/NixOS-WSL/issues/294
  systemd.user = {
    paths.vscode-remote-workaround = {
      wantedBy = ["default.target"];
      pathConfig.PathChanged = "%h/.vscode-server/bin";
    };
    services.vscode-remote-workaround.script = ''
      for i in ~/.vscode-server/bin/*; do
        echo "Fixing vscode-server in $i..."
        ln -sf ${pkgs.nodejs_18}/bin/node $i/node
      done
    '';
  };
}
