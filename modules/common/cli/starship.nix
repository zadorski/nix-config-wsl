{
  config,
  pkgs,
  lib,
  ...
}:

{
  home-manager.users.${config.user}.programs.starship = {
    enable = true;
    settings = {
      add_newline = false; # don't print new line at the start of the prompt

      format = lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_commit"
        "$git_status"
        "$hostname"
        "$cmd_duration"
        "$character"
      ];

      right_format = "$nix_shell";

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vicmd_symbol = "[❮](bold green)";
      };

      directory = {
        truncate_to_repo = true;
        truncation_length = 100;
      };

      git_branch = {
        format = "[$symbol$branch]($style)";
      };

      git_commit = {
        format = "( @ [$hash]($style) )";
        only_detached = false;
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        conflicted = "=";
        ahead = "⇡";
        behind = "⇣";
        diverged = "⇕";
        untracked = "⋄";
        stashed = "⩮";
        modified = "∽";
        staged = "+";
        renamed = "»";
        deleted = "✘";
        style = "red";
      };

      hostname = {
        ssh_only = true;
        format = "on [$hostname](bold red) ";
      };

      nix_shell = {
        format = "[$symbol $name]($style)";
        symbol = "❄️";
      };
    };
  };
}
