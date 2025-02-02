{
  description = "WSL flake + vscode remote + fish";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.nix-ld-rs.url = "github:nix-community/nix-ld-rs"; 
  inputs.nix-ld-rs.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixoswsl.url = "github:nix-community/NixOS-WSL";
  inputs.nixoswsl.inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.vscode-server.url = "github:nix-community/nixos-vscode-server";
  inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";
  #inputs.nix-index-database.url = "github:nix-community/nix-index-database";
  #inputs.nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs@{
    nixpkgs,
    nixoswsl,
    home-manager,
    vscode-server,
    #nix-index-database,
    ...
  }: let
    username = "paz";
    system = "x86_64-linux";
    systemname = "crodax";
    stateVersion = "24.05"; # both system and home (do not change)
  in {
    nixosConfigurations.${systemname} = nixpkgs.lib.nixosSystem {
      inherit system;
      #specialArgs = {inherit inputs;};
      modules = [
        nixoswsl.nixosModules.wsl
        vscode-server.nixosModules.default
        #nix-index-database.nixosModules.nix-index
        home-manager.nixosModules.home-manager
        # homemanager inline
        (
          {pkgs, ...}: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            #imports = [
            #  nix-index-database.hmModules.nix-index
            #];
            home-manager.users.${username} = {
              #inherit inputs;
              home.username = username;
              home.homeDirectory = "/home/${username}";
              home.sessionVariables.EDITOR = "micro";    
              home.sessionVariables.SHELL = "/etc/profiles/per-user/${username}/bin/fish"; # set your preferred $SHELL
              home.stateVersion = stateVersion;
              home.packages = with pkgs; [
                alejandra # nix formatter
                nil # nix language server
                micro # text editor
              ];
              home.file = {
                vscode = {
                  target = ".vscode-server/server-env-setup";
                  text = ''
                    # make sure that basic commands are available
                    PATH=$PATH:/run/current-system/sw/bin/
                  '';
                };
              };
              programs = {
                home-manager.enable = true;
                #nix-index.enable = true;
                #nix-index.enableFishIntegration = true;
                #nix-index-database.comma.enable = true;

                starship.enable = true;
                starship.settings = {
                  aws.disabled = true;
                  gcloud.disabled = true;
                  kubernetes.disabled = false;
                  git_branch.style = "242";
                  directory.style = "blue";
                  directory.truncate_to_repo = false;
                  directory.truncation_length = 8;
                  python.disabled = true;
                  ruby.disabled = true;
                  hostname.ssh_only = false;
                  hostname.style = "bold green";
                };

                # disable whatever you don't want
                fzf.enable = true;
                fzf.enableFishIntegration = true;
                lsd.enable = true;
                lsd.enableAliases = true;
                zoxide.enable = true;
                zoxide.enableFishIntegration = true;
                zoxide.options = ["--cmd cd"];
                broot.enable = true;
                broot.enableFishIntegration = true;
                direnv.enable = true;
                direnv.nix-direnv.enable = true;

                ssh.enable = true;
                ssh.matchBlocks = {
                  "git" = {
                    host = "github.com";
                    user = "git";
                    forwardAgent = true;
                    identitiesOnly = true;
                    identityFile = [
                      "~/.ssh/id_maco"
                    ];
                  };
                };

                git = {
                  enable = true;
                  #package = pkgs.unstable.git;
                  delta.enable = true;
                  delta.options = {
                    line-numbers = true;
                    side-by-side = true;
                    navigate = true;
                  };
                  userEmail = ""; #FIXME
                  userName = "";  #FIXME
                  extraConfig = {
                    push = {
                      default = "current";
                      autoSetupRemote = true;
                    };
                    merge = {
                      conflictstyle = "diff3";
                    };
                    diff = {
                      colorMoved = "default";
                    };
                  };
                };

                fish = {
                  enable = true;
                  # add path with your Windows username to the bottom of interactiveShellInit,
                  # either run 'scoop install win32yank' or run 'winget install win32yank' on Windows, 
                  # note that programs installed with `winget` are only symlinked to `%AppData%/Local/Microsoft/WinGet/Links`
                  # if "Developer Mode" is enabled or if the command is run from an admin shell.
                  # source:: https://github.com/microsoft/winget-cli/issues/3498
                  interactiveShellInit = ''
                    ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source

                    ${pkgs.lib.strings.fileContents (pkgs.fetchFromGitHub {
                        owner = "rebelot";
                        repo = "kanagawa.nvim";
                        rev = "de7fb5f5de25ab45ec6039e33c80aeecc891dd92";
                        sha256 = "sha256-f/CUR0vhMJ1sZgztmVTPvmsAgp0kjFov843Mabdzvqo=";
                      }
                      + "/extras/kanagawa.fish")}

                    set -U fish_greeting        
                    fish_add_path --append /mnt/c/Users/${username}/AppData/Local/Microsoft/WinGet/Links
                  '';
                  functions = {
                    refresh = "source $HOME/.config/fish/config.fish";
                    take = ''mkdir -p -- "$1" && cd -- "$1"'';
                    ttake = "cd $(mktemp -d)";
                    show_path = "echo $PATH | tr ' ' '\n'";
                    posix-source = ''
                      for i in (cat $argv)
                        set arr (echo $i |tr = \n)
                        set -gx $arr[1] $arr[2]
                      end
                    '';
                  };
                  shellAbbrs =
                    {
                      gc = "nix-collect-garbage --delete-old";
                    }
                    # navigation shortcuts
                    // {
                      ".." = "cd ..";
                      "..." = "cd ../../";
                      "...." = "cd ../../../";
                      "....." = "cd ../../../../";
                    }
                    # git shortcuts
                    // {
                      gapa = "git add --patch";
                      grpa = "git reset --patch";
                      gst = "git status";
                      gdh = "git diff HEAD";
                      gp = "git push";
                      gph = "git push -u origin HEAD";
                      gco = "git checkout";
                      gcob = "git checkout -b";
                      gcm = "git checkout master";
                      gcd = "git checkout develop";
                      gsp = "git stash push -m";
                      gsa = "git stash apply stash^{/";
                      gsl = "git stash list";
                    };
                  shellAliases = {
                    lvim = "nvim";
                    pbcopy = "/mnt/c/Windows/System32/clip.exe";
                    pbpaste = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command 'Get-Clipboard'";
                    explorer = "/mnt/c/Windows/explorer.exe";
                    code = "/mnt/c/Users/${username}/AppData/Local/Programs/'Microsoft VS Code'/bin/code";
                  };
                  plugins = [
                    {
                      inherit (pkgs.fishPlugins.autopair) src;
                      name = "autopair";
                    }
                    {
                      inherit (pkgs.fishPlugins.done) src;
                      name = "done";
                    }
                    {
                      inherit (pkgs.fishPlugins.sponge) src;
                      name = "sponge";
                    }
                  ];
                };
              };
            };
          }
        )
        # wsl inline
        (
          {pkgs, ...}: {
            wsl = {
              enable = true;
              defaultUser = username;
              # ref:: https://github.com/LGUG2Z/nixos-wsl-starter
              wslConf.automount.root = "/mnt";
              wslConf.interop.appendWindowsPath = false;
              wslConf.network.generateHosts = false;
              startMenuLaunchers = true;              
            };
          }
        )
        # nixos inline
        (
          {pkgs, ...}: {
            system = {
              stateVersion = stateVersion;
            };
            environment.systemPackages = with pkgs; [
              btop
              htop
              wget
              jq
              yq-go
              dnsutils
            ];
            nix = {
              settings.experimental-features = ["nix-command" "flakes"];
              gc.automatic = true;
              gc.options = "--delete-older-than 14d";
            };
            networking.hostName = systemname;
            users.users.${username} = {
              isNormalUser = true;
              shell = pkgs.fish;
              extraGroups = [
                "wheel"
                "docker"
              ];
              hashedPassword = "$6$11niI8PHfcNgMejh$0NdIXjJ0zvRLyLpoZvViN3KvLAGZ3.VlZYlDVPo8hX9CV./Etphn335g8m7uaR/J1OpOYaLsfL5.rYDlwCa6h/";
              # FIXME: add your own ssh public key
              # openssh.authorizedKeys.keys = [
              #   "ssh-rsa ..."
              # ];
            };
            # helpful for `ssh -vT git@github.com` to validate key chain 
            programs.ssh.knownHosts = {
              github = {
                hostNames = ["github.com"];
                publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
              };
            };

            programs.fish.enable = true; # change your shell here if you don't want fish  
            environment.pathsToLink = ["/share/fish"];
            environment.shells = [pkgs.fish];

            environment.enableAllTerminfo = true;

            security.sudo.wheelNeedsPassword = false;
          }
        )
        # vscode remoting inline
        (
          {pkgs, ...}: {
            programs.nix-ld.enable = true; # this is forgivable for WSL
            services.vscode-server.enable = true;
          }
        )
      ];
    };
  };
}
