{ lib, config, pkgs, ... }:

let
  cfg = config.programs.windows-integration;
  windowsLib = cfg._internal.windowsLib;
  windowsPaths = cfg._internal.paths;
  fontConfig = cfg._internal.fonts or {
    family = "CaskaydiaCove Nerd Font, Cascadia Code, Cascadia Mono, Consolas, Courier New, monospace";
    editorSize = 14;
    terminalSize = 11;
  };

  vscodePaths = windowsLib.getVSCodePaths windowsPaths;
  
  # VS Code settings with Catppuccin Mocha theme and WSL integration
  vscodeSettings = {
    # editor appearance with catppuccin mocha
    "workbench.colorTheme" = "Catppuccin Mocha";
    "workbench.iconTheme" = "catppuccin-mocha";
    
    # editor configuration with standardized fonts
    "editor.fontFamily" = fontConfig.family;
    "editor.fontSize" = fontConfig.editorSize;
    "editor.fontLigatures" = true;
    "editor.lineHeight" = 1.5;
    "editor.cursorBlinking" = "smooth";
    "editor.cursorSmoothCaretAnimation" = "on";
    "editor.smoothScrolling" = true;
    
    # editor behavior
    "editor.tabSize" = 2;
    "editor.insertSpaces" = true;
    "editor.detectIndentation" = true;
    "editor.trimAutoWhitespace" = true;
    "editor.formatOnSave" = true;
    "editor.formatOnPaste" = true;
    "editor.codeActionsOnSave" = {
      "source.fixAll" = "explicit";
      "source.organizeImports" = "explicit";
    };
    
    # file handling
    "files.autoSave" = "afterDelay";
    "files.autoSaveDelay" = 1000;
    "files.trimTrailingWhitespace" = true;
    "files.insertFinalNewline" = true;
    "files.trimFinalNewlines" = true;
    
    # WSL integration settings
    "remote.WSL.fileWatcher.polling" = true;
    "remote.WSL.useShellEnvironment" = true;
    "remote.extensionKind" = {
      "ms-vscode.vscode-typescript-next" = [ "workspace" ];
      "ms-python.python" = [ "workspace" ];
      "ms-vscode.cpptools" = [ "workspace" ];
      "rust-lang.rust-analyzer" = [ "workspace" ];
    };
    
    # terminal integration
    "terminal.integrated.defaultProfile.windows" = "PowerShell";
    "terminal.integrated.fontFamily" = fontConfig.family;
    "terminal.integrated.fontSize" = fontConfig.terminalSize;
    "terminal.integrated.profiles.windows" = {
      "PowerShell" = {
        "source" = "PowerShell";
        "icon" = "terminal-powershell";
      };
      "Command Prompt" = {
        "path" = [ "\${env:windir}\\Sysnative\\cmd.exe" "\${env:windir}\\System32\\cmd.exe" ];
        "args" = [];
        "icon" = "terminal-cmd";
      };
      "WSL" = {
        "path" = "wsl.exe";
        "args" = [ "-d" "Ubuntu" ];
        "icon" = "terminal-ubuntu";
      };
    };
    
    # git integration
    "git.enableSmartCommit" = true;
    "git.confirmSync" = false;
    "git.autofetch" = true;
    "git.defaultCloneDirectory" = "~/Projects";
    
    # search and explorer
    "search.exclude" = {
      "**/node_modules" = true;
      "**/bower_components" = true;
      "**/.git" = true;
      "**/.DS_Store" = true;
      "**/tmp" = true;
      "**/dist" = true;
      "**/build" = true;
      "**/.next" = true;
      "**/.nuxt" = true;
      "**/.vscode" = true;
      "**/.direnv" = true;
    };
    
    "files.exclude" = {
      "**/.git" = true;
      "**/.DS_Store" = true;
      "**/node_modules" = true;
      "**/.direnv" = true;
    };
    
    # language-specific settings
    "[javascript]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[typescript]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[json]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[html]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[css]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[python]" = {
      "editor.defaultFormatter" = "ms-python.black-formatter";
    };
    "[rust]" = {
      "editor.defaultFormatter" = "rust-lang.rust-analyzer";
    };
    "[nix]" = {
      "editor.defaultFormatter" = "jnoortheen.nix-ide";
    };
    
    # extension settings
    "extensions.autoUpdate" = true;
    "extensions.ignoreRecommendations" = false;
    
    # performance settings
    "files.watcherExclude" = {
      "**/.git/objects/**" = true;
      "**/.git/subtree-cache/**" = true;
      "**/node_modules/**" = true;
      "**/tmp/**" = true;
      "**/.direnv/**" = true;
    };
    
    # security settings
    "security.workspace.trust.untrustedFiles" = "prompt";
    "security.workspace.trust.banner" = "always";
    
    # telemetry settings (privacy-focused)
    "telemetry.telemetryLevel" = "off";
    "redhat.telemetry.enabled" = false;
  };

  # VS Code keybindings for consistency with WSL environment
  vscodeKeybindings = [
    # terminal shortcuts
    {
      "key" = "ctrl+`";
      "command" = "terminal.focus";
    }
    {
      "key" = "ctrl+shift+`";
      "command" = "workbench.action.terminal.new";
    }
    
    # file navigation
    {
      "key" = "ctrl+p";
      "command" = "workbench.action.quickOpen";
    }
    {
      "key" = "ctrl+shift+p";
      "command" = "workbench.action.showCommands";
    }
    
    # editor shortcuts
    {
      "key" = "ctrl+d";
      "command" = "editor.action.addSelectionToNextFindMatch";
    }
    {
      "key" = "ctrl+shift+l";
      "command" = "editor.action.selectHighlights";
    }
    
    # WSL-specific shortcuts
    {
      "key" = "ctrl+shift+w";
      "command" = "remote-wsl.newWindow";
    }
    {
      "key" = "ctrl+shift+r";
      "command" = "remote-wsl.reopenInWSL";
    }
  ];

  vscodeSettingsJson = builtins.toJSON vscodeSettings;
  vscodeKeybindingsJson = builtins.toJSON vscodeKeybindings;

in

{
  config = lib.mkIf (cfg.enable && cfg.applications.vscode) {
    # create VS Code settings and keybindings files
    home.file = {
      "${vscodePaths.settings}" = {
        source = pkgs.writeText "vscode-settings.json" vscodeSettingsJson;
      } // (if cfg.fileManagement.strategy == "copy" then { recursive = true; } else {})
        // (if cfg.fileManagement.strategy == "template" then { text = vscodeSettingsJson; } else {});

      "${vscodePaths.keybindings}" = {
        source = pkgs.writeText "vscode-keybindings.json" vscodeKeybindingsJson;
      } // (if cfg.fileManagement.strategy == "copy" then { recursive = true; } else {})
        // (if cfg.fileManagement.strategy == "template" then { text = vscodeKeybindingsJson; } else {});
    };

    # create backup scripts and ensure directories
    home.packages = lib.mkIf cfg.fileManagement.backupOriginals [
      (windowsLib.createBackup vscodePaths.settings)
      (windowsLib.createBackup vscodePaths.keybindings)
      (windowsLib.ensureDirectory (builtins.dirOf vscodePaths.settings))
    ];

    # validation warnings
    warnings = lib.optional (!windowsLib.validateWindowsPath (builtins.dirOf vscodePaths.settings))
      "VS Code settings directory not found at ${builtins.dirOf vscodePaths.settings}. VS Code may not be installed.";
  };
}
