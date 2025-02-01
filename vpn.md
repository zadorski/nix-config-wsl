ref:: https://discourse.nixos.org/t/how-to-create-docker-network-in-nixos-configuration-correctly/16945/2?u=zadorski

system.activationScripts.mkVPN = ''
    ${pkgs.docker}/bin/docker network create vpn --subnet 172.20.0.0/16
'';

After all, this snippet must still function even if you never install docker, at least from the perspective of activationScripts.

This is generally a good pattern in the nix world, since it explicitly states the dependencies of your scripts, so you know why they’re there and they aren’t included if the scripts are never used - for system config scripts like this at least. For real scripts write proper derivations and resolve their dependencies :wink:

As for the approach, I prefer the systemd oneshot, simply because it makes it easier to manage, via proper logging and systemctl to toggle things later on. In practice I think both will function, but managing the docker daemon exclusively declaratively is a challenge…

system.activationScripts.mkVPN = let
  docker = config.virtualisation.oci-containers.backend;
  dockerBin = "${pkgs.${docker}}/bin/${docker}";
in ''
  ${dockerBin} network inspect vpn >/dev/null 2>&1 || ${dockerBin} network create vpn --subnet 172.20.0.0/16
'';