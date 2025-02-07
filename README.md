# NixOS-WSL flake with sane modular configuration

## Inspiration 
https://github.com/petertriho/nix-config
- for those helpers and conditionals blended into modules without comprehensive lib hard to dive into
- one-liner `inherits (config) user homePath` pulling vars from different places


im confused why this isnt pushed onto people more. all the headaches i have seem to be solved by just using snowfall lib
ref:: https://www.youtube.com/watch?v=ARjAsEJ9WVY

Stuff like flake-utils-plus and digga are too overengineered for my taste, and tend to make me feel like I’m relying on black magic; my current config uses digga, but I’m trying to migrate away from it for that reason.
ref:: https://www.reddit.com/r/NixOS/comments/xtq2tb/comment/iqrikti/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button


check README
https://gitea.mathebau.de/Fachschaft/nixConfig/src/commit/1ab6e5d86835fec123c1a4c7d120cbfab1ede00a

ref:: https://vtimofeenko.com/posts/practical-nix-flake-anatomy-a-guided-tour-of-flake.nix/
ref:: https://vtimofeenko.com/posts/flake-parts-writing-custom-flake-modules/
check README for flake.parts justification 
https://github.com/VTimofeenko/monorepo-machine-config

If you want to save a bit of boilerplate on overlays – I’d suggest checking out flake.parts 33. Takes a bit of reading to get started, but saves a lot of time in the long run.
ref:: https://discourse.nixos.org/t/nixos-home-manager-config-where-both-use-flakes/41410/4?u=zadorski

## Learning path

0. Init a basic flake:
   nix flake init && nix flake lock

1. nan-tu minimal WSL

2. sascha koenig
nix flake init -t https://code.m3tam3re.com/m3tam3re/nix-flake-templates/archive/master.tar.gz#nixos-standard


1. Youtube VimJoyer flakes intro (also recommended by Zaney)

2. Youtube How to structure without flake utils

3. Youtube Zaney why I do not use flakes?

4. ZaneyOS gitlab.com
https://gitlab.com/Zaney/zaneyos
```bash
cp -r hosts/default hosts/<your-desired-hostname>
nixos-generate-config --show-hardware-config > hosts/<your-desired-hostname>/hardware.nix

NIX_CONFIG="experimental-features = nix-command flakes" 
sudo nixos-rebuild switch --flake .#hostname
```


https://github.com/szaffarano/nix-dotfiles/blob/master/README.md
# use a ramfs to not store the key in the disk
Generate an age recipient using the above public key (using the ssh-to-age tool)
Update the .sops.yaml configuration file adding the age recipient.

## Follow-up
Also, general commentary: I tend to prefer using home-manager.useUserPackages = true; because it allows the home-manager setup to activate properly inside a nixos-rebuild build-vm, and also because I just avoid nix-env like the plague.
ref: https://discourse.nixos.org/t/need-configuration-feedback-and-tips-and-question-about-managing-shell-scripts/17232/3?u=zadorski


### resholveScriptBin
resholve can ~generally meet the need of doing this without having to inline it all (i.e., retain editor highlighting, ability to run the script outside of a Nix-managed system, etc.–at least if you aren’t building the script conditionally based on the Nix eval).
ref: https://github.com/utdemir/dotfiles-nix/blob/main/scripts/default.nix
