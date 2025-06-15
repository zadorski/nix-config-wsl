{ pkgs, lib, ... }:
{
  # bash configuration - used as login shell for WSL compatibility
  programs.bash = {
    enable = true;
    enableCompletion = true;  # enable tab completion

    # XDG-compliant history file location
    historyFile = "$HOME/.local/state/bash/history";

    # automatically switch to fish for interactive sessions
    # this gives us bash compatibility for login while using fish for interaction
    initExtra = ''
      # ensure XDG state directory exists for bash history
      mkdir -p "$(dirname "$HISTFILE")"

      # devenv integration for bash compatibility (before switching to fish)
      if command -v devenv >/dev/null 2>&1; then
        # source devenv completions if available
        if [ -f ~/.local/share/devenv/completions/devenv.bash ]; then
          source ~/.local/share/devenv/completions/devenv.bash
        fi
      fi

      if [[ $- == *i* ]]; then
        exec ${pkgs.fish}/bin/fish
      fi
    '';
  };

  # fish configuration - modern shell with good defaults
  programs.fish = {
    enable = true;

    # useful abbreviations for common Git commands
    shellAbbrs = {
      g = "git";
      ga = "git add";
      gc = "git commit";
    };

    # fish shell initialization for interactive sessions
    interactiveShellInit = ''
      set -g fish_greeting  # disable fish's default greeting message

      # session management: restore last working directory or default to home
      # store last directory in ~/.config/fish/last_dir for session continuity
      set -l last_dir_file ~/.config/fish/last_dir

      # restore previous session directory if it exists and is valid
      if test -f $last_dir_file
        set -l saved_dir (cat $last_dir_file 2>/dev/null)
        if test -d "$saved_dir"
          cd "$saved_dir"
        else
          # fallback to home directory if saved directory is invalid
          cd ~
        end
      else
        # default to home directory for new sessions
        cd ~
      end

      # save current directory on exit for next session
      function save_last_dir --on-event fish_exit
        pwd > ~/.config/fish/last_dir
      end

      # keychain integration for automatic SSH key loading
      # load SSH keys without repeated passphrase prompts
      if type -q keychain
        # load keychain with common SSH key names
        # supports both GitHub (id_maco) and Azure DevOps (id_rsa) keys
        set -l ssh_keys
        test -f ~/.ssh/id_maco && set -a ssh_keys ~/.ssh/id_maco
        test -f ~/.ssh/id_rsa && set -a ssh_keys ~/.ssh/id_rsa
        test -f ~/.ssh/id_ed25519 && set -a ssh_keys ~/.ssh/id_ed25519

        if test (count $ssh_keys) -gt 0
          # use --noask to defer passphrase prompts until key is actually used
          keychain --quiet --noask --agents ssh $ssh_keys
          if test -f ~/.keychain/(hostname)-fish
            source ~/.keychain/(hostname)-fish
          end
        end
      end

      # initialize Starship prompt for enhanced development experience
      # Starship provides Git status, language versions, and command feedback
      # Configuration is managed in ~/.config/starship.toml via home-manager
      if type -q starship
        starship init fish | source
      end

      # initialize fzf for enhanced file and command searching
      # fzf provides fuzzy finding with catppuccin dark theme integration
      if type -q fzf
        fzf --fish | source
      end
    '';

    # development-focused environment variables
    # curated for productivity without bloating the environment
    shellInit = ''
      # development workflow optimizations
      set -gx EDITOR nvim
      set -gx VISUAL nvim
      set -gx PAGER less

      # git configuration enhancements
      set -gx GIT_EDITOR nvim
      set -gx GIT_PAGER delta

      # docker and container optimizations
      set -gx DOCKER_BUILDKIT 1
      set -gx COMPOSE_DOCKER_CLI_BUILD 1

      # WSL-specific optimizations
      set -gx BROWSER wslview  # use WSL browser integration

      # development directories - create if they don't exist
      test -d ~/dev || mkdir -p ~/dev
      test -d ~/projects || mkdir -p ~/projects

      # fzf configuration for development workflows
      set -gx FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border --margin=1 --padding=1"
      set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"
      set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"

      # bat configuration for consistent syntax highlighting
      set -gx BAT_THEME "Catppuccin-mocha"
      set -gx BAT_STYLE "numbers,changes,header"

      # less configuration for better paging experience
      set -gx LESS "-R -F -X -M"
      set -gx LESSHISTFILE "-"  # disable less history file

      # nix development optimizations
      set -gx NIX_AUTO_RUN 1  # enable automatic nix-shell execution

      # devenv integration - automatically load project environments
      if command -v devenv >/dev/null 2>&1
        # add devenv completions if available
        if test -f ~/.local/share/devenv/completions/devenv.fish
          source ~/.local/share/devenv/completions/devenv.fish
        end
      end
    '';
  };
}
