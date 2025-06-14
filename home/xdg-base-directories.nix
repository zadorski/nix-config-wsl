{ config, lib, pkgs, userName, ... }:

{
  # comprehensive XDG Base Directory Specification implementation
  # follows NixOS/home-manager best practices and community conventions
  # optimized for WSL2 development workflows with containerization support

  # enable home-manager's built-in XDG support
  # this automatically sets XDG environment variables and creates directories
  xdg = {
    enable = true;

    # explicitly set XDG directories for clarity and WSL2 compatibility
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
    cacheHome = "${config.home.homeDirectory}/.cache";

    # enable XDG user directories (Desktop, Documents, etc.)
    userDirs = {
      enable = true;
      createDirectories = true;
      # this creates ~/.config/user-dirs.dirs following XDG spec
    };

    # enable XDG MIME type associations
    mimeApps = {
      enable = true;
      # this creates ~/.config/mimeapps.list following XDG spec
    };
  };

  # comprehensive environment variables for development tools and WSL2 optimization
  home.sessionVariables = {
    # ensure user bin directory is in PATH per XDG spec
    PATH = "${config.xdg.dataHome}/../bin:$PATH";
    # development tools - use config.xdg paths for consistency
    DEVENV_ROOT = "${config.xdg.cacheHome}/devenv";

    # language-specific configurations using XDG paths
    PYTHONUSERBASE = "${config.xdg.dataHome}/../";  # ~/.local
    PYTHONPYCACHEPREFIX = "${config.xdg.cacheHome}/python";

    # node.js and npm - XDG-compliant configuration
    NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
    NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
    NPM_CONFIG_PREFIX = "${config.xdg.dataHome}/../";  # ~/.local

    # rust and cargo - XDG data directory
    CARGO_HOME = "${config.xdg.dataHome}/cargo";

    # go language - XDG-compliant paths
    GOPATH = "${config.xdg.dataHome}/go";
    GOCACHE = "${config.xdg.cacheHome}/go";

    # docker - XDG configuration directory
    DOCKER_CONFIG = "${config.xdg.configHome}/docker";

    # container development - devcontainer XDG support
    DEVCONTAINER_CONFIG_DIR = "${config.xdg.configHome}/devcontainer";

    # less pager - XDG state directory (version 590+)
    LESSHISTFILE = "${config.xdg.stateHome}/less/history";

    # readline library - XDG configuration
    INPUTRC = "${config.xdg.configHome}/readline/inputrc";

    # wget - XDG configuration
    WGETRC = "${config.xdg.configHome}/wget/wgetrc";

    # curl - XDG configuration directory
    CURL_HOME = "${config.xdg.configHome}/curl";

    # gnupg - XDG data directory
    GNUPGHOME = "${config.xdg.dataHome}/gnupg";

    # ssh - custom variable for scripts (ssh itself doesn't support XDG)
    SSH_CONFIG_DIR = "${config.xdg.configHome}/ssh";

    # WSL2 development optimizations
    # cache directories for better performance on WSL2 filesystem
    TMPDIR = "${config.xdg.cacheHome}/tmp";

    # container runtime optimizations
    BUILDKIT_CACHE_MOUNT_NS = "${config.xdg.cacheHome}/buildkit";
  };

  # XDG configuration files using home-manager's xdg.configFile
  # this is the NixOS-preferred way to manage XDG configuration files
  xdg.configFile = {
    # npm configuration - XDG-compliant setup
    "npm/npmrc".text = ''
      # npm XDG configuration
      cache=${config.xdg.cacheHome}/npm
      prefix=${config.xdg.dataHome}/../
      init-module=${config.xdg.configHome}/npm/config/npm-init.js
    '';

    # wget configuration - XDG-compliant
    "wget/wgetrc".text = ''
      # wget XDG configuration
      hsts-file = ${config.xdg.cacheHome}/wget/hsts
      # use XDG cache for temporary files
      cache = on
    '';

    # readline configuration - enhanced for development
    "readline/inputrc".text = ''
      # readline XDG configuration with development optimizations
      # enable vi mode for better editing
      set editing-mode vi
      set show-mode-in-prompt on
      set vi-ins-mode-string \1\e[6 q\2
      set vi-cmd-mode-string \1\e[2 q\2

      # enhanced completion
      set completion-ignore-case on
      set completion-map-case on
      set show-all-if-ambiguous on
      set show-all-if-unmodified on

      # history search
      "\e[A": history-search-backward
      "\e[B": history-search-forward
    '';

    # docker configuration - development workflow optimization
    "docker/config.json".text = builtins.toJSON {
      # use XDG cache for docker build cache
      buildkit = {
        cache-from = [ "type=local,src=${config.xdg.cacheHome}/docker/buildkit" ];
        cache-to = [ "type=local,dest=${config.xdg.cacheHome}/docker/buildkit,mode=max" ];
      };
      # credential helpers configuration
      credHelpers = {
        "ghcr.io" = "gh";
        "docker.io" = "desktop";
      };
      # experimental features for development
      experimental = "enabled";
    };

    # devcontainer configuration for XDG compliance
    "devcontainer/devcontainer.json".text = builtins.toJSON {
      # ensure devcontainer respects XDG directories
      mounts = [
        "source=${config.xdg.configHome},target=/home/vscode/.config,type=bind,consistency=cached"
        "source=${config.xdg.dataHome},target=/home/vscode/.local/share,type=bind,consistency=cached"
        "source=${config.xdg.cacheHome},target=/home/vscode/.cache,type=bind,consistency=cached"
      ];
      containerEnv = {
        XDG_CONFIG_HOME = "/home/vscode/.config";
        XDG_DATA_HOME = "/home/vscode/.local/share";
        XDG_STATE_HOME = "/home/vscode/.local/state";
        XDG_CACHE_HOME = "/home/vscode/.cache";
      };
    };
  };


  # WSL2-specific XDG optimizations and directory creation
  # ensure essential directories exist for development workflows
  home.activation.createXdgDevelopmentDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # create development-specific XDG subdirectories
    $DRY_RUN_CMD mkdir -p "${config.xdg.cacheHome}"/{devenv,python,npm,go,docker,buildkit,tmp}
    $DRY_RUN_CMD mkdir -p "${config.xdg.configHome}"/{npm,docker,readline,wget,curl,ssh,devcontainer}
    $DRY_RUN_CMD mkdir -p "${config.xdg.dataHome}"/{cargo,go,gnupg,applications,fonts}
    $DRY_RUN_CMD mkdir -p "${config.xdg.stateHome}"/{bash,less}
    $DRY_RUN_CMD mkdir -p "${config.xdg.dataHome}/../bin"

    # ensure proper permissions for sensitive directories
    $DRY_RUN_CMD chmod 700 "${config.xdg.dataHome}/gnupg" 2>/dev/null || true
    $DRY_RUN_CMD chmod 700 "${config.xdg.configHome}/ssh" 2>/dev/null || true

    # WSL2 runtime directory fallback
    if [ ! -d "/run/user/1000" ]; then
      $DRY_RUN_CMD mkdir -p "${config.xdg.cacheHome}/runtime"
      $DRY_RUN_CMD chmod 700 "${config.xdg.cacheHome}/runtime"
      # note: in production WSL2, this should be handled by systemd
    fi

    # create temporary directory with proper permissions
    $DRY_RUN_CMD mkdir -p "${config.xdg.cacheHome}/tmp"
    $DRY_RUN_CMD chmod 755 "${config.xdg.cacheHome}/tmp"
  '';
}
