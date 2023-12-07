{
  # uncomment the next line if you want to reference your GitHub/GitLab access tokens and other secrets
  # secrets,
  username,
  hostname,
  pkgs,
  inputs,     # for nix.registry / nix.nixPath
  ...
}: {
  time.timeZone = "Europe/Berlin";

  networking.hostName = "${hostname}";

  systemd.tmpfiles.rules = [
    "d /home/${username}/.config 0755 ${username} users"
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

  # docker config
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;
  virtualisation.docker.autoPrune.enable = true;
  
  # nix general config
  nix.settings.trusted-users = [username];
  # FIXME: use your access tokens from secrets.json here to be able to clone private repos on GitHub and GitLab
  # nix.settings.access-tokens = [
  #   "github.com=${secrets.github_token}"
  #   "gitlab.com=OAuth2:${secrets.gitlab_token}"
  # ];
  nix.settings.accept-flake-config = true;
  nix.settings.auto-optimise-store = true;
  
  # flake related
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''experimental-features = nix-command flakes'';

  # garbage collector
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";
  
  # a more predictable nix-shell (make nix-shell use the same nixppkgs as the system confg flake)
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = [
    "nixpkgs=${inputs.nixpkgs.outPath}"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];
}
