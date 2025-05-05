{ pkgs, ... }:

{
  # enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    openFirewall = true; 
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}