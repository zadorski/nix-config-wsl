{ pkgs, userName, gitEmail, gitHandle, ...}: {
  imports = [
    ./shells
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = userName;
    homeDirectory = "/home/${userName}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "24.05";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = gitHandle;
    userEmail = gitEmail;
  };

  programs.ssh.enable = true;

  home.packages = [ ];
}