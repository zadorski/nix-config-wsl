{
  pkgs,
  config,
  lib,
  ...
}:
{
  home = {
    file = {
      ".tmux/tokyonight.tmux".source = config.lib.meta.mkDotfilesSymlink "tmux/.tmux/tokyonight.tmux";
    };
    sessionVariables = {
      # TINTED_TMUX_OPTION_ACTIVE = 1;
      # TINTED_TMUX_OPTION_STATUSBAR = 1;
    };
  };

  home.packages = with pkgs; [
    tmuxPlugins.session-wizard
  ];

  programs.tmux = {
    enable = true;
    sensibleOnTop = false;
    terminal = if pkgs.stdenv.isLinux then "screen-256color" else "tmux-256color";
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = sensible;
        extraConfig =
          # tmux
          ''
            # TODO: remove when https://github.com/nix-community/home-manager/pull/4670 is added
            set -g prefix C-a

            # Theme
            if-shell "test -f ~/.tmux/tokyonight.tmux" "source ~/.tmux/tokyonight.tmux"
          '';
      }
      pain-control
      sessionist-fork
      yank
      # {
      #   plugin = tokyo-night;
      #   extraConfig =
      #     # tmux
      #     ''
      #       set -g @tokyo-night-tmux_window_id_style "none"
      #       set -g @tokyo-night-tmux_show_git 0
      #       set -g @tokyo-night-tmux_show_wbg 0
      #     '';
      # }
      # {
      #   plugin = tinted;
      #   extraConfig =
      #     # tmux
      #     ''
      #       # set -g @tinted-color "base16-tokyo-night-dark"
      #     '';
      # }
      session-wizard
      {
        plugin = easy-motion;
        extraConfig =
          # tmux
          ''
            set -g @easy-motion-verbose "true"
            set -g @easy-motion-default-motion "bd-f"
          '';
      }
      {
        plugin = tmux-thumbs;
        extraConfig =
          # tmux
          ''
            set -g @thumbs-key "F"
          '';
      }
      {
        plugin = extrakto;
        extraConfig =
          # tmux
          ''
            set -g @extrakto_copy_key "tab"
            set -g @extrakto_insert_key "enter"
            set -g @extrakto_fzf_layout "reverse"
            set -g @extrakto_popup_size "50%,50%"
            set -g @extrakto_split_direction "p"
            set -g @extrakto_popup_position "200,100"
          '';
      }
      {
        plugin = window-name;
        extraConfig =
          let
            surround = srd: str: srd + str + srd;
            mkStringList = srd: lst: "[" + (lib.concatMapStringsSep ", " (surround srd) lst) + "]";
            substitute_sets = mkStringList "" [
              "('^(/usr)?/bin/(.+)', '\\\\g<2>')"
              "('/nix/store/\\\\S+/bin/(n?vim?).*', '\\\\g<1>')"
              "('/nix/store/\\\\S+/bin/(.+)', '\\\\g<1>')"
            ];
            dir_programs = mkStringList "'" [
              "git"
            ];
          in
          # tmux
          ''
            set -g @tmux_window_name_substitute_sets "${substitute_sets}"
            set -g @tmux_window_name_dir_programs "${dir_programs}"
          '';
      }
      {
        plugin = fuzzback;
        extraConfig =
          # tmux
          ''
            set -g @fuzzback-bind "/"
            set -g @fuzzback-popup 1
            set -g @fuzzback-popup-size "80%"
          '';
      }
    ];
    extraConfig = builtins.readFile ../../dotfiles/tmux/.tmux.conf;
  };
}
