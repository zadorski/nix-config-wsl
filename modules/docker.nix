{ username, ... }:

{
  users.extraGroups.docker.members = [ "${username}" ];
  
  virtualisation.oci-containers.backend = "docker";
  virtualisation.docker = {
    enable = true;
    rootless.enable = true;
    
    daemon.settings = { # config /etc/docker/daemon.json (see https://docs.docker.com/reference/cli/dockerd/#daemon-configuration-file)
      userland-proxy = false;
      features.containerd-snapshotter = true; # enable containerd image store (see https://docs.docker.com/engine/storage/containerd/)
    };
  };
}
