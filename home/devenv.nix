{ pkgs, ... }:

{
  # direnv integration for automatic environment loading
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    # direnv configuration for better performance and UX
    config = {
      global = {
        # disable stdin during .envrc evaluation for better performance
        disable_stdin = true;
        # disable timeout warnings for faster loading
        warn_timeout = "0s";
        # disable verbose logging for cleaner output
        log_format = "-";
      };
    };
  };

  # essential development tools for project environments
  home.packages = with pkgs; [
    # task runners and automation
    just              # modern make alternative with better syntax
    pre-commit        # git pre-commit hooks for code quality

    # development utilities
    devenv            # project-specific development environments
    cachix            # binary cache for faster nix builds

    # file and text processing
    fd                # fast find alternative
    ripgrep           # fast grep alternative
    jq                # JSON processor
    yq                # YAML processor

    # network and debugging tools
    httpie            # user-friendly HTTP client
    netcat-gnu        # network debugging

    # version control enhancements
    git-lfs           # git large file storage
    gh                # GitHub CLI for repository management
  ];

  # note: shell integration for devenv is handled in home/shells.nix
  # to avoid configuration conflicts and ensure proper layering
  # devenv completions and integration are configured in the main shell configuration
}
