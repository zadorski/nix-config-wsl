{ ... }:

{
  # enable Docker for containerized development workflows
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;

    # enable rootless Docker for better security
    # allows running Docker without root privileges
    #rootless = {
    #  enable = true;
    #  setSocketVariable = true;  # automatically set DOCKER_HOST environment variable
    #};
  };
}
