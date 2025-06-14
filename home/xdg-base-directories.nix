{ config, lib, pkgs, userName, ... }:

{
  # comprehensive XDG Base Directory Specification implementation
  # provides complete environment setup with WSL2 compatibility
  # follows freedesktop.org specification version 0.8

  # XDG Base Directory environment variables
  # these form the foundation for all application configuration
  home.sessionVariables = {
    # primary XDG directories as per specification
    XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
    XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
    XDG_STATE_HOME = "${config.home.homeDirectory}/.local/state";
    XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";

    # XDG_RUNTIME_DIR is typically set by systemd/pam
    # but we ensure it's available for WSL2 environments
    XDG_RUNTIME_DIR = "/run/user/1000";  # standard WSL2 user ID

    # system directories for completeness (usually set by system)
    XDG_DATA_DIRS = "/usr/local/share:/usr/share";
    XDG_CONFIG_DIRS = "/etc/xdg";

    # ensure user bin directory is in PATH per XDG spec
    PATH = "${config.home.homeDirectory}/.local/bin:$PATH";
  };

  # create essential XDG directories
  # ensures proper directory structure exists
  home.file = {
    # create XDG base directories with proper permissions
    ".config/.keep".text = "";
    ".local/share/.keep".text = "";
    ".local/state/.keep".text = "";
    ".local/bin/.keep".text = "";
    ".cache/.keep".text = "";

    # create common application subdirectories
    ".config/git/.keep".text = "";
    ".config/fish/.keep".text = "";
    ".config/starship/.keep".text = "";
    ".local/share/applications/.keep".text = "";
    ".local/share/fonts/.keep".text = "";
    ".cache/nix/.keep".text = "";

    # development tool directories
    ".cache/devenv/.keep".text = "";
    ".cache/python/.keep".text = "";
    ".cache/npm/.keep".text = "";
    ".cache/go/.keep".text = "";

    # configuration directories
    ".config/npm/.keep".text = "";
    ".config/docker/.keep".text = "";
    ".config/readline/.keep".text = "";
    ".config/wget/.keep".text = "";
    ".config/curl/.keep".text = "";
    ".config/ssh/.keep".text = "";

    # data directories
    ".local/share/cargo/.keep".text = "";
    ".local/share/go/.keep".text = "";
    ".local/share/gnupg/.keep".text = "";

    # state directories
    ".local/state/bash/.keep".text = "";
    ".local/state/less/.keep".text = "";
  };

  # XDG-compliant application configurations
  # note: this module provides XDG environment setup
  # specific program configurations are handled in other modules

  # additional XDG environment variables for specific tools
  home.sessionVariables = {
    # development tools
    DEVENV_ROOT = "${config.home.homeDirectory}/.cache/devenv";

    # language-specific configurations
    PYTHONUSERBASE = "${config.home.homeDirectory}/.local";
    PYTHONPYCACHEPREFIX = "${config.home.homeDirectory}/.cache/python";

    # node.js and npm
    NPM_CONFIG_USERCONFIG = "${config.home.homeDirectory}/.config/npm/npmrc";
    NPM_CONFIG_CACHE = "${config.home.homeDirectory}/.cache/npm";
    NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.local";

    # rust and cargo
    CARGO_HOME = "${config.home.homeDirectory}/.local/share/cargo";

    # go language
    GOPATH = "${config.home.homeDirectory}/.local/share/go";
    GOCACHE = "${config.home.homeDirectory}/.cache/go";

    # docker
    DOCKER_CONFIG = "${config.home.homeDirectory}/.config/docker";

    # less pager - XDG support since version 590
    LESSHISTFILE = "${config.home.homeDirectory}/.local/state/less/history";

    # readline library
    INPUTRC = "${config.home.homeDirectory}/.config/readline/inputrc";

    # wget
    WGETRC = "${config.home.homeDirectory}/.config/wget/wgetrc";

    # curl
    CURL_HOME = "${config.home.homeDirectory}/.config/curl";

    # gnupg
    GNUPGHOME = "${config.home.homeDirectory}/.local/share/gnupg";

    # ssh - note: ssh itself doesn't support XDG, but we can set for scripts
    SSH_CONFIG_DIR = "${config.home.homeDirectory}/.config/ssh";
  };



  # XDG configuration files for tools that support them
  xdg.configFile = {
    # npm configuration
    "npm/npmrc".text = ''
      # npm XDG configuration
      cache=${config.home.homeDirectory}/.cache/npm
      prefix=${config.home.homeDirectory}/.local
    '';

    # wget configuration
    "wget/wgetrc".text = ''
      # wget XDG configuration
      hsts-file = ${config.home.homeDirectory}/.cache/wget/hsts
    '';

    # readline configuration
    "readline/inputrc".text = ''
      # readline XDG configuration
      # enable vi mode and other enhancements
      set editing-mode vi
      set show-mode-in-prompt on
      set vi-ins-mode-string \1\e[6 q\2
      set vi-cmd-mode-string \1\e[2 q\2
    '';
  };

  # ensure proper permissions for XDG_RUNTIME_DIR equivalent
  # WSL2 doesn't always have proper systemd setup
  home.activation.createXdgRuntimeDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # ensure runtime directory exists with proper permissions
    if [ ! -d "/run/user/1000" ]; then
      $DRY_RUN_CMD mkdir -p "/tmp/user-runtime-1000"
      $DRY_RUN_CMD chmod 700 "/tmp/user-runtime-1000"
      # note: in production WSL2, this should be handled by systemd
    fi
  '';

  # XDG MIME type associations (optional but recommended)
  xdg.mimeApps = {
    enable = true;
    # this creates ~/.config/mimeapps.list following XDG spec
  };

  # XDG user directories (optional integration)
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    # this creates ~/.config/user-dirs.dirs following XDG spec
  };
}
