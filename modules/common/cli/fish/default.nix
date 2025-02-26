{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.fish.enable = true;

  home-manager.users.${config.user} = {
    # packages used in abbreviations and aliases
    home.packages = with pkgs; [ curl ];

    programs.fish = {
      enable = true;

      shellAliases = {
        # version of bash which works much better on the terminal
        bash = "${pkgs.bashInteractive}/bin/bash";

        # use eza (exa) instead of ls for fancier output
        ls = "${pkgs.eza}/bin/eza --group";

        # move files to XDG trash on the commandline
        trash = lib.mkIf pkgs.stdenv.isLinux "${pkgs.trash-cli}/bin/trash-put";
      };

      functions = { };

      interactiveShellInit = ''
        fish_vi_key_bindings
        bind yy fish_clipboard_copy
        bind Y fish_clipboard_copy
        bind -M visual y fish_clipboard_copy
        bind -M default p fish_clipboard_paste
        set -g fish_vi_force_cursor
        set -g fish_cursor_default block
        set -g fish_cursor_insert line
        set -g fish_cursor_visual block
        set -g fish_cursor_replace_one underscore
      '';

      loginShellInit = "";

      shellAbbrs = {
        # Directory aliases
        l = "ls -lh";
        lh = "ls -lh";
        ll = "ls -alhF";
        la = "ls -a";
        c = "cd";
        "-" = "cd -";
        mkd = "mkdir -pv";

        # System
        s = "sudo";
        sc = "systemctl";
        scs = "systemctl status";
        sca = "systemctl cat";
        t = "trash";

        # Vim
        v = "vim";
        vl = "vim -c 'normal! `0'";
      };

      shellInit = "";
    };

    home.sessionVariables = {
      fish_greeting = "";
      EDITOR = "vi";
    };

    programs.starship.enableFishIntegration = true;
  };
}
