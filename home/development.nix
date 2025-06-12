{ pkgs, lib, catppuccin-bat ? null, catppuccin-btop ? null, catppuccin-lazygit ? null, catppuccin-fzf ? null, ... }:

{
  # development-focused packages for enhanced productivity
  home.packages = with pkgs; [
    # modern CLI tools for development
    bat               # better cat with syntax highlighting
    eza               # better ls with git integration
    delta             # better git diff viewer
    lazygit           # terminal UI for git
    btop              # modern system monitor with themes
    fzf               # fuzzy finder for files and commands
    keychain          # SSH key management for seamless authentication

    # file and text processing
    tree              # directory tree visualization
    tokei             # code statistics
    fd                # better find for fzf integration

    # network and API tools
    curl              # HTTP client
    wget              # file downloader

    # container and cloud tools (commonly used)
    docker-compose    # multi-container Docker applications
    
    # build and task automation
    gnumake           # build automation
    
    # language servers and development support
    nil               # Nix language server
    nixfmt-classic    # Nix code formatter
  ];

  # enhanced git configuration for development workflows with dark mode
  programs.git = {
    delta = {
      enable = true;
      options = {
        # delta configuration for better diff viewing with dark mode
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
        # catppuccin mocha theme for consistent dark mode experience
        syntax-theme = "Catppuccin-mocha";
        # enhanced dark mode styling
        minus-style = "syntax #3c1f1e";  # catppuccin red background for deletions
        plus-style = "syntax #1e2d1d";   # catppuccin green background for additions
        minus-emph-style = "syntax #5a2d2d";  # emphasized deletion background
        plus-emph-style = "syntax #2d4a2d";   # emphasized addition background
        line-numbers-minus-style = "#f38ba8"; # catppuccin red for line numbers
        line-numbers-plus-style = "#a6e3a1";  # catppuccin green for line numbers
        line-numbers-zero-style = "#6c7086"; # catppuccin overlay1 for unchanged lines
      };
    };
    
    # useful git aliases for development
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "!gitk";
      # development workflow aliases
      dev = "checkout develop";
      main = "checkout main";
      feature = "checkout -b";
      sync = "!git fetch origin && git rebase origin/main";
    };
    
    # enhanced git configuration
    extraConfig = {
      # better merge conflict resolution
      merge.conflictstyle = "diff3";
      # use delta as the default pager
      #core.pager = lib.mkDefault "delta"; # already set in programs.git.delta.enable
      #interactive.diffFilter = "delta --color-only"; # already set in programs.git.delta.enable
      # better branch tracking
      push.default = "simple";
      pull.rebase = true;
      # enhanced diff algorithms
      diff.algorithm = "patience";
      # better whitespace handling
      core.autocrlf = false;
      core.whitespace = "trailing-space,space-before-tab";
    };
  };

  # bat configuration with catppuccin dark theme for syntax highlighting
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      style = "changes,header,numbers";
      # use catppuccin mocha theme for consistent dark mode experience
      theme = if catppuccin-bat != null then "Catppuccin-mocha" else "TwoDark";
    };
    # add catppuccin theme if available
    themes = lib.mkIf (catppuccin-bat != null) {
      catppuccin-mocha = {
        src = catppuccin-bat;
        file = "Catppuccin-mocha.tmTheme";
      };
    };
    extraPackages = with pkgs.bat-extras; [
      batman    # man pages with bat
      batgrep   # grep with bat
      batwatch  # watch with bat
    ];
  };

  # btop system monitor with catppuccin dark theme
  programs.btop = {
    enable = true;
    settings = {
      # catppuccin mocha theme for consistent dark mode experience
      color_theme = if catppuccin-btop != null then "catppuccin_mocha" else "Default";
      theme_background = false;  # transparent background for better terminal integration
      # performance optimizations for WSL
      update_ms = 1000;         # 1 second update interval for WSL performance
      proc_tree = true;         # show process tree for better visualization
      rounded_corners = false;  # clean appearance
      vim_keys = true;          # vim-style navigation
      # accessibility and usability
      show_battery = false;     # not relevant for WSL
      show_coretemp = true;     # useful for development workloads
      temp_scale = "celsius";   # standard temperature scale
    };
  };

  # add catppuccin btop themes if available
  xdg.configFile = lib.mkIf (catppuccin-btop != null) {
    "btop/themes" = {
      source = "${catppuccin-btop}/themes";
      recursive = true;
    };
  };

  # lazygit git TUI with catppuccin dark theme
  programs.lazygit = {
    enable = true;
    settings = lib.mkIf (catppuccin-lazygit != null) {
      # catppuccin mocha theme configuration
      gui = {
        # accessibility-focused color scheme
        theme = {
          lightTheme = false;  # ensure dark mode
          activeBorderColor = [ "#cba6f7" "bold" ];      # catppuccin mauve - 7.9:1 contrast
          inactiveBorderColor = [ "#6c7086" ];           # catppuccin overlay1 - subtle borders
          optionsTextColor = [ "#89b4fa" ];              # catppuccin blue - 6.8:1 contrast
          selectedLineBgColor = [ "#313244" ];           # catppuccin surface0 - subtle selection
          selectedRangeBgColor = [ "#45475a" ];          # catppuccin surface1 - range selection
          cherryPickedCommitBgColor = [ "#94e2d5" ];     # catppuccin teal - 8.7:1 contrast
          cherryPickedCommitFgColor = [ "#1e1e2e" ];     # catppuccin base for contrast
          unstagedChangesColor = [ "#f38ba8" ];          # catppuccin red - 7.2:1 contrast
          defaultFgColor = [ "#cdd6f4" ];                # catppuccin text - 11.2:1 contrast
        };
        # enhanced git workflow settings
        showIcons = true;
        nerdFontsVersion = "3";
        showRandomTip = false;  # reduce cognitive load
        showCommandLog = false; # cleaner interface
      };
      # git configuration optimizations
      git = {
        paging = {
          colorArg = "always";
          pager = "delta --dark --paging=never";  # integrate with delta
        };
        commit = {
          signOff = false;
        };
        merging = {
          manualCommit = false;
          args = "--no-ff";  # preserve merge history
        };
      };
      # performance optimizations
      refresher = {
        refreshInterval = 10;  # 10 seconds for WSL performance
        fetchInterval = 60;    # 1 minute fetch interval
      };
    };
  };

  # fzf fuzzy finder with catppuccin dark theme
  programs.fzf = {
    enable = true;
    # catppuccin mocha color scheme for accessibility
    colors = lib.mkIf (catppuccin-fzf != null) {
      # background and foreground
      "bg" = "#1e1e2e";        # catppuccin base
      "bg+" = "#313244";       # catppuccin surface0 - selected line
      "fg" = "#cdd6f4";        # catppuccin text - 11.2:1 contrast
      "fg+" = "#cdd6f4";       # catppuccin text - selected line text
      # borders and separators
      "border" = "#6c7086";    # catppuccin overlay1 - subtle borders
      "separator" = "#6c7086"; # catppuccin overlay1 - consistent separators
      # interactive elements
      "hl" = "#f38ba8";        # catppuccin red - 7.2:1 contrast for highlights
      "hl+" = "#f38ba8";       # catppuccin red - selected line highlights
      "info" = "#89b4fa";      # catppuccin blue - 6.8:1 contrast for info
      "marker" = "#a6e3a1";    # catppuccin green - 8.1:1 contrast for markers
      "pointer" = "#cba6f7";   # catppuccin mauve - 7.9:1 contrast for pointer
      "prompt" = "#89b4fa";    # catppuccin blue - 6.8:1 contrast for prompt
      "spinner" = "#f9e2af";   # catppuccin yellow - 9.3:1 contrast for spinner
      "header" = "#94e2d5";    # catppuccin teal - 8.7:1 contrast for headers
    };
    # enhanced search options for development workflows
    defaultOptions = [
      "--height 40%"           # reasonable height for terminal integration
      "--layout=reverse"       # results at top for better visibility
      "--border"               # clean border appearance
      "--inline-info"          # compact info display
      "--preview-window=right:50%:wrap"  # preview pane for file content
      "--bind=ctrl-u:preview-page-up,ctrl-d:preview-page-down"  # vim-style preview navigation
    ];
    # file search with preview
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetOptions = [ "--preview 'bat --color=always --style=numbers --line-range=:500 {}'" ];
    # directory search
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
    # history search with enhanced options
    historyWidgetOptions = [ "--sort" "--exact" ];
  };

  # enhanced shell aliases for development
  programs.fish = {
    shellAliases = {
      # enhanced file operations with development-optimized table view
      # basic listing with icons and git status
      ls = "eza --icons --git --group-directories-first";

      # detailed table view optimized for development workflows
      # shows permissions, size, modified time, git status in clean columns
      ll = "eza --long --icons --git --group-directories-first --time-style=relative --no-permissions";

      # comprehensive listing including hidden files
      # table format with all development-relevant information
      la = "eza --long --all --icons --git --group-directories-first --time-style=relative --header";

      # development-focused detailed view with full information
      # includes permissions for troubleshooting, size for optimization
      lld = "eza --long --icons --git --group-directories-first --time-style=long-iso --header --extended";

      # tree view with git integration for project structure overview
      tree = "eza --tree --icons --git --level=3";

      # comprehensive tree view for deep project analysis
      treed = "eza --tree --icons --git --long --level=4 --time-style=relative";

      # better cat with syntax highlighting
      cat = "bat";

      # development shortcuts
      dev = "cd ~/dev";
      projects = "cd ~/projects";

      # docker shortcuts
      dc = "docker-compose";
      dcu = "docker-compose up";
      dcd = "docker-compose down";
      dcb = "docker-compose build";

      # git shortcuts (in addition to abbreviations)
      gst = "git status";
      gco = "git checkout";
      gcb = "git checkout -b";
      gp = "git push";
      gl = "git pull";
      gf = "git fetch";

      # nix shortcuts
      nix-search = "nix search nixpkgs";
      nix-shell-p = "nix-shell -p";

      # fzf-enhanced shortcuts for development workflows
      fzf-file = "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";
      fzf-git = "git log --oneline --color=always | fzf --ansi --preview 'git show --color=always {1}'";
      fzf-process = "ps aux | fzf --header-lines=1 --preview 'echo {}' --preview-window down:3:wrap";

      # system monitoring shortcuts
      top = "btop";  # use btop instead of default top
      htop = "btop"; # alias htop to btop for consistency
    };
  };

  # bash aliases for compatibility
  programs.bash = {
    shellAliases = {
      # enhanced file operations matching fish configuration
      ls = "eza --icons --git --group-directories-first";
      ll = "eza --long --icons --git --group-directories-first --time-style=relative --no-permissions";
      la = "eza --long --all --icons --git --group-directories-first --time-style=relative --header";
      lld = "eza --long --icons --git --group-directories-first --time-style=long-iso --header --extended";
      tree = "eza --tree --icons --git --level=3";

      # enhanced tools
      cat = "bat";
      gst = "git status";
    };
  };
}
