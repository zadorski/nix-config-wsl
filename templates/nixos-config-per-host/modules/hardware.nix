{ ... }:

{
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ]; # https://wiki.hyprland.org/Nvidia/#suspendwakeup-issues  

  boot.kernel.sysctl."net.ipv4.ip_forward" = true; # ip_forward on the host machine is important for the docker container to be able to perform networking tasks

  hardware.nvidia = {
    powerManagement.enable = true; # enable experimental power management through systemd
    modesetting.enable = true; # enable kernel modesetting when using the NVIDIA proprietary driver

    open = false; # making sure to use the proprietary drivers until the following issue is fixed (see https://github.com/NVIDIA/open-gpu-kernel-modules/issues/472)
  };
}
