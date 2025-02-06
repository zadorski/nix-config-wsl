{ inputs, ... }: {

  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "/home/paz/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/secrets.yaml;

    secrets = {
      id_rsa = {
        path = "/home/paz/.ssh/id_rsa";
      };
      id_rsa_pub = {
        path = "/home/paz/.ssh/id_rsa.pub";
      };
      nix_conf_include_access_tokens = { };
    };
  };

  error: attribute 'systemctlPath' missing
  systemd.user.services.mbsync.Unit.After = [ "sops-nix.service" ];

}
