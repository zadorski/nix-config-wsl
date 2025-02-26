{
  config,
  pkgs,
  lib,
  ...
}:
{

  options = {
    dnsmasq = {
      enable = lib.mkEnableOption {
        description = "Enable dnsmasq";
        default = false;
      };
    };
  };

  config = lib.mkIf (config.dnsmasq.enable) {
    services.dnsmasq = {
      enable = true;
      # this address here need to change to something more permanent
      addresses."cluster.internal" = "192.168.107.240";
      bind = "127.0.0.1";
    };
  };
}
