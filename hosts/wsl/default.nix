{ pkgs, ... }: {

  wsl = {
    enable = true;
    defaultUser = "paz";
    nativeSystemd = true;
    interop.register = true;

    wslConf = {
      automount.root = "/mnt";
      user.default = "paz";
    };
  };

}
