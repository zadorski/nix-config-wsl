{ lib, config, pkgs, gitEmail, gitHandle, ... }:

let
  cfg = config.programs.windows-integration;
  windowsLib = cfg._internal.windowsLib;
  windowsPaths = cfg._internal.paths;
  
  gitPaths = windowsLib.getGitPaths windowsPaths;
  
  # Git configuration synchronized between WSL and Windows
  gitConfig = ''
    # Git configuration managed by Nix
    # Generated from nix-config-wsl/home/windows/git.nix
    # Synchronized between WSL and Windows environments
    
    [user]
        name = ${gitHandle}
        email = ${gitEmail}
    
    [core]
        # handle line endings properly for cross-platform development
        autocrlf = input
        eol = lf
        
        # use VS Code as default editor (works in both WSL and Windows)
        editor = code --wait
        
        # better diff and merge tools
        pager = delta
        
        # file permissions (important for WSL-Windows compatibility)
        filemode = false
        
        # handle unicode filenames
        precomposeunicode = true
        quotepath = false
    
    [init]
        defaultBranch = main
    
    [pull]
        rebase = true
    
    [push]
        default = simple
        autoSetupRemote = true
    
    [fetch]
        prune = true
    
    [rebase]
        autoStash = true
        autoSquash = true
    
    [merge]
        tool = vscode
        conflictstyle = diff3
    
    [mergetool "vscode"]
        cmd = code --wait $MERGED
        trustExitCode = false
    
    [diff]
        tool = vscode
        colorMoved = default
        algorithm = histogram
    
    [difftool "vscode"]
        cmd = code --wait --diff $LOCAL $REMOTE
    
    # delta configuration for better diffs
    [delta]
        navigate = true
        light = false
        side-by-side = true
        line-numbers = true
        syntax-theme = Catppuccin-mocha
        
    [interactive]
        diffFilter = delta --color-only
    
    # credential management for Windows
    [credential]
        helper = manager-core
    
    # WSL-specific credential helper fallback
    [credential "https://github.com"]
        helper = 
        helper = !/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe
    
    [credential "https://dev.azure.com"]
        useHttpPath = true
        helper = 
        helper = !/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe
    
    # aliases for productivity
    [alias]
        # status and info
        st = status
        s = status --short
        
        # add and commit
        a = add
        aa = add --all
        c = commit
        cm = commit -m
        ca = commit --amend
        can = commit --amend --no-edit
        
        # branch management
        b = branch
        ba = branch -a
        bd = branch -d
        bD = branch -D
        
        # checkout and switch
        co = checkout
        cob = checkout -b
        sw = switch
        swc = switch -c
        
        # log and history
        l = log --oneline
        lg = log --oneline --graph
        ll = log --oneline --graph --all
        lp = log --patch
        
        # diff
        d = diff
        dc = diff --cached
        ds = diff --stat
        
        # push and pull
        p = push
        pf = push --force-with-lease
        pl = pull
        
        # remote
        r = remote
        rv = remote -v
        
        # stash
        st = stash
        stp = stash pop
        stl = stash list
        
        # reset
        unstage = reset HEAD --
        uncommit = reset --soft HEAD~1
        
        # utilities
        ignore = "!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi"
        cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d"
        
        # WSL-Windows path helpers
        wslpath = "!f() { wslpath \"$1\"; }; f"
        winpath = "!f() { wslpath -w \"$1\"; }; f"
    
    # URL rewrites for SSH access
    [url "git@github.com:"]
        insteadOf = https://github.com/
    
    [url "git@ssh.dev.azure.com:v3/"]
        insteadOf = https://dev.azure.com/
    
    # file handling for different platforms
    [filter "lfs"]
        clean = git-lfs clean -- %f
        smudge = git-lfs smudge -- %f
        process = git-lfs filter-process
        required = true
    
    # performance optimizations
    [gc]
        auto = 256
    
    [pack]
        threads = 0
    
    [index]
        preloadindex = true
    
    [status]
        submoduleSummary = true
    
    [submodule]
        recurse = true
    
    # security settings
    [transfer]
        fsckobjects = true
    
    [fetch]
        fsckobjects = true
    
    [receive]
        fsckObjects = true
    
    # Windows-specific settings
    [core]
        # handle Windows paths properly
        ignorecase = true
        
        # symlink handling for WSL-Windows compatibility
        symlinks = false
    
    # conditional includes for environment-specific settings
    [includeIf "gitdir:/mnt/c/"]
        path = ~/.gitconfig-windows
    
    [includeIf "gitdir:~/"]
        path = ~/.gitconfig-wsl
  '';

  # Windows-specific git configuration
  gitConfigWindows = ''
    # Windows-specific Git configuration
    [core]
        autocrlf = true
        symlinks = false
        
    [credential]
        helper = manager-core
  '';

  # WSL-specific git configuration  
  gitConfigWSL = ''
    # WSL-specific Git configuration
    [core]
        autocrlf = input
        symlinks = true
        
    [credential]
        helper = /mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe
  '';

in

{
  config = lib.mkIf (cfg.enable && cfg.applications.git) {
    # create git configuration files for Windows and WSL
    home.file = {
      "${gitPaths.globalConfig}" = {
        source = pkgs.writeText "gitconfig" gitConfig;
      } // (if cfg.fileManagement.strategy == "copy" then { recursive = true; } else {})
        // (if cfg.fileManagement.strategy == "template" then { text = gitConfig; } else {});

      "${windowsPaths.userProfile}/.gitconfig-windows" = {
        source = pkgs.writeText "gitconfig-windows" gitConfigWindows;
      } // (if cfg.fileManagement.strategy == "copy" then { recursive = true; } else {})
        // (if cfg.fileManagement.strategy == "template" then { text = gitConfigWindows; } else {});

      "${windowsPaths.userProfile}/.gitconfig-wsl" = {
        source = pkgs.writeText "gitconfig-wsl" gitConfigWSL;
      } // (if cfg.fileManagement.strategy == "copy" then { recursive = true; } else {})
        // (if cfg.fileManagement.strategy == "template" then { text = gitConfigWSL; } else {});
    };

    # create backup scripts and ensure directories
    home.packages = lib.mkIf cfg.fileManagement.backupOriginals [
      (windowsLib.createBackup gitPaths.globalConfig)
      (windowsLib.ensureDirectory (builtins.dirOf gitPaths.globalConfig))
      
      # script to validate git configuration
      (pkgs.writeShellScriptBin "validate-git-config" ''
        echo "=== Git Configuration Validation ==="
        
        # check WSL git config
        echo "WSL Git Configuration:"
        git config --list --show-origin | grep -E "(user\.|core\.|credential\.)"
        
        # check Windows git config (if accessible)
        if [ -f "${gitPaths.globalConfig}" ]; then
          echo ""
          echo "Windows Git Configuration:"
          cat "${gitPaths.globalConfig}" | grep -E "^\s*(name|email|autocrlf|editor)" || true
        fi
        
        # test credential helper
        echo ""
        echo "Credential Helper Test:"
        git config --get credential.helper || echo "No credential helper configured"
        
        # test line ending configuration
        echo ""
        echo "Line Ending Configuration:"
        git config --get core.autocrlf || echo "autocrlf not set"
        git config --get core.eol || echo "eol not set"
      '')
    ];

    # validation warnings
    warnings = lib.optional (!windowsLib.validateWindowsPath (builtins.dirOf gitPaths.globalConfig))
      "Git configuration directory not found at ${builtins.dirOf gitPaths.globalConfig}. Git may not be installed on Windows.";
  };
}
