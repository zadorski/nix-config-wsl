{ pkgs, ... }:

{
  virtualisation.docker.enable = true;
  #virtualisation.docker.enableNvidia = true; # enable nvidia-docker
  virtualisation.docker.enableOnBoot = true;  # start dockerd on boot: this is required for containers which are created with the `--restart=always` flag to work    
}