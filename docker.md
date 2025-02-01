nixos dockerd-rootless + solution 
good investigation for docker native rootless (check tools / approaches)
ref: https://www.richtman.au/blog/rootless-docker-on-wsl2-nixos/
related: https://github.com/arichtman (Cloud and Platform Engineering nerd)


How can I leverage docker and nix together for developer environments on linux and WSL2?
ref:: https://www.reddit.com/r/NixOS/comments/16w7720/how_can_i_leverage_docker_and_nix_together_for/

    there is a nix docker image, basically is a regular installation of the nix package manager in the dockerfile.
    you can use it as inspiration:
    https://hub.docker.com/r/nixos/nix/
    I don't think you will have issue doing what you want, i use dockerized nix at work everyday to : check nix config, build image, build derivation and copy closure :)

    nixos-generators will compile full system docker containers. They do require (as far as I know) privileged permissions when they run. If you do something like I am doing you can build one from the same Nix config as your system config.
    See my dotfiles here
    ref:: https://gitlab.com/usmcamp0811/dotfiles/-/blob/9fd2293d91d8aaabfaf17d3616d5359568001aaa/systems/x86_64-docker/jupyterlab/default.nix
    
        Looks like a great solution! It appears I can also use nixos-generators for just a flake. This opens up a lot of possibilities. Thanks, I'll try it out!



==befare Docker company restrictions==
Install Docker CE in WSL Environment
ref:: https://developer.mamezou-tech.com/en/blogs/2024/10/11/devcontainer/
sudo apt install tree
~/devcontainer_sample$ tree -a
NB: Generate SSH key in WSL environment
- install openssh-client keychain socat xsel 
- generate key if not present
- set up auto agent start 

good investigation for docker desktop (check tools / approaches)
https://github.com/nix-community/NixOS-WSL/issues/235#issuecomment-1937424376

    ref: https://github.com/nix-community/NixOS-WSL/issues/235
    I used a2o/snoopy to monitor the commands Docker Desktop does to WSL instances on the first run and here is the output for Ubuntu.

    Brilliant solution! I was banging my head on the wall for hours. god bless this voodoo magic.
    ref: https://github.com/nix-community/NixOS-WSL/issues/235#issuecomment-1937424376

Nix Docker container with VS Code Remote
ref: https://discourse.nixos.org/t/nix-docker-container-with-vs-code-remote/19065
related: https://dzone.com/articles/vscode-remote-ssh-development-with-nix



Dev Container in der WSL ohne Docker Desktop
https://www.codez.one/devcontainer-in-der-wsl-ohne-docker-desktop/



All three of these options (docker, podman, nixos-containers) use cgroups. nixos-containers are useful because you can just use nix modules in them, but networking is very painful to configure if you want to connect containers together. I’m partial to podman when it comes to oci containers, for the reason @peterhoeg mentions.
ref:: https://discourse.nixos.org/t/use-nix-docker-for-development/18359/3?u=zadorski
    You can have your nixos containers use host networking if you don’t need multiple instances of the same thing running at the same time and thus fight over ports. It’s much easier as it works as if the various services are just running directly outside a container.
    ref:: https://discourse.nixos.org/t/use-nix-docker-for-development/18359/5?u=zadorski

How to create docker network in NixOS configuration correctly?
ref:: https://discourse.nixos.org/t/how-to-create-docker-network-in-nixos-configuration-correctly/16945/2
    activationScripts don’t have access to a $PATH, as far as they are concerned docker isn’t installed (because it’s somewhere in /nix/store and the system hasn’t been activated yet, i.e. the the store hasn’t been made into a system with a PATH).
    ref:: https://discourse.nixos.org/t/how-to-create-docker-network-in-nixos-configuration-correctly/16945/2?u=zadorski

system.activationScripts.mkVPN = ''
    ${pkgs.docker}/bin/docker network create vpn --subnet 172.20.0.0/16
'';