{ pkgs, ... }:

{
  # development-focused packages for enhanced productivity
  home.packages = with pkgs; [
    # modern CLI tools for development
    bat               # better cat with syntax highlighting
    eza               # better ls with git integration
    delta             # better git diff viewer
    lazygit           # terminal UI for git
    
    # file and text processing
    tree              # directory tree visualization
    tokei             # code statistics
    
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

  # enhanced git configuration for development workflows
  programs.git = {
    delta = {
      enable = true;
      options = {
        # delta configuration for better diff viewing
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
        syntax-theme = "Dracula";
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
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
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

  # enhanced shell aliases for development
  programs.fish = {
    shellAliases = {
      # enhanced file operations
      ls = "eza --icons --git";
      ll = "eza -l --icons --git";
      la = "eza -la --icons --git";
      tree = "eza --tree --icons";
      
      # better cat
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
    };
  };

  # bash aliases for compatibility
  programs.bash = {
    shellAliases = {
      ls = "eza --icons --git";
      ll = "eza -l --icons --git";
      la = "eza -la --icons --git";
      cat = "bat";
      gst = "git status";
    };
  };
}
