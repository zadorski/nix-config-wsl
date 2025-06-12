{ ... }:

{
  # enable Docker for containerized development workflows
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;

    # enable rootless Docker for better security and devcontainer compatibility
    # allows running Docker without root privileges
    rootless = {
      enable = true;
      setSocketVariable = true;  # automatically set DOCKER_HOST environment variable
    };
  };

  # optimize Docker for WSL and devcontainer workflows
  environment.etc."docker/daemon.json".text = builtins.toJSON {
    # use overlay2 storage driver for better performance in WSL
    "storage-driver" = "overlay2";
    # enable experimental features for devcontainer support
    "experimental" = true;
    # optimize for development workflows
    "live-restore" = true;
  };
}
