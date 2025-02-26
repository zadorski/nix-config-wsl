{ config, pkgs, ... }:

{
  config = {
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [
        age # encryption
        delta # fancy diffs
        dig # dns lookup
        fd # find
        htop # show system processes
        killall # force quit
        inetutils # includes telnet, whois
        jless # json viewer
        jo # json output
        jq # json manipulation
        qrencode # generate qr codes
        rsync # copy foldersj
        ripgrep # grep
        sd # sed
        tree # view directory hierarchy
        unzip # extract zips
        dua # file sizes (du)
        du-dust # disk usage tree (ncdu)
        duf # basic disk information (df)
      ];
    };
  };
}
