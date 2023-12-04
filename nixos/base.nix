{
  # uncomment the next line if you want to reference your GitHub/GitLab access tokens and other secrets
  # secrets,
  username,
  hostname,
  pkgs,
  ...
}: {
  networking.hostName = "${hostname}";

  systemd.tmpfiles.rules = [
    "d /home/${username}/.config/lvim 0755 ${username} users"
  ];

  programs.zsh.enable = true;
  environment.pathsToLink = ["/share/zsh"];
  environment.shells = [pkgs.zsh];

  environment.enableAllTerminfo = true;

  security.sudo.wheelNeedsPassword = false;

  # keep sealed for inbound connection?
  # services.openssh.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      #"docker"
    ];
    #hashedPassword = "";
    openssh.authorizedKeys.keys = [
      (builtins.readFile ../home/id_paz.pub)
    ];
  };

  home-manager.users.${username} = {
    imports = [
      ../home/paz.nix
    ];
  };

  system.stateVersion = "23.05";

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  nix = {
    settings = {
      trusted-users = [username];
      # FIXME: use your access tokens from secrets.json here to be able to clone private repos on GitHub and GitLab
      # access-tokens = [
      #   "github.com=${secrets.github_token}"
      #   "gitlab.com=OAuth2:${secrets.gitlab_token}"
      # ];

      accept-flake-config = true;
      auto-optimise-store = true;
    };

    package = pkgs.nixFlakes;
    extraOptions = ''experimental-features = nix-command flakes'';

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };
}
