{ lib, config, pkgs, ... }:

let
  cfg = config.programs.windows-wsl-manager;
  envPathFallback = cfg._internal.envPathFallback;
  windowsPaths = cfg._internal.paths;
  fontConfig = cfg._internal.fonts or {
    family = "CaskaydiaCove Nerd Font, Cascadia Code, Cascadia Mono, Consolas, Courier New, monospace";
    editorSize = 14;
    terminalSize = 11;
  };

  vscodePaths = envPathFallback.getVSCodePaths windowsPaths;
  
  # comprehensive VSCode settings for optimal Nix-based WSL development environment
  # optimized for multi-language development with enhanced LSP integration
  vscodeSettings = {
    # === EDITOR APPEARANCE AND THEMING ===
    # catppuccin mocha theme for consistent dark mode experience
    "workbench.colorTheme" = "Catppuccin Mocha";
    "workbench.iconTheme" = "catppuccin-mocha";
    "workbench.preferredDarkColorTheme" = "Catppuccin Mocha";
    "workbench.preferredLightColorTheme" = "Catppuccin Latte";

    # === EDITOR CONFIGURATION ===
    # font configuration with ligature support for better code readability
    "editor.fontFamily" = fontConfig.family;
    "editor.fontSize" = fontConfig.editorSize;
    "editor.fontLigatures" = true;
    "editor.lineHeight" = 1.5;
    "editor.letterSpacing" = 0.5;

    # cursor and animation settings for smooth experience
    "editor.cursorBlinking" = "smooth";
    "editor.cursorSmoothCaretAnimation" = "on";
    "editor.smoothScrolling" = true;
    "editor.cursorStyle" = "line";
    "editor.cursorWidth" = 2;

    # editor behavior optimizations
    "editor.wordWrap" = "bounded";
    "editor.wordWrapColumn" = 120;
    "editor.rulers" = [ 80 120 ];
    "editor.renderWhitespace" = "boundary";
    "editor.renderControlCharacters" = true;
    "editor.renderLineHighlight" = "all";
    "editor.showFoldingControls" = "mouseover";
    "editor.foldingStrategy" = "indentation";
    "editor.foldingHighlight" = true;
    
    # === EDITOR BEHAVIOR AND PRODUCTIVITY ===
    # indentation and formatting
    "editor.tabSize" = 2;
    "editor.insertSpaces" = true;
    "editor.detectIndentation" = true;
    "editor.trimAutoWhitespace" = true;
    "editor.formatOnSave" = true;
    "editor.formatOnPaste" = true;
    "editor.formatOnType" = true;
    "editor.codeActionsOnSave" = {
      "source.fixAll" = "explicit";
      "source.organizeImports" = "explicit";
      "source.removeUnusedImports" = "explicit";
    };

    # bracket matching and auto-closing for better code editing
    "editor.bracketPairColorization.enabled" = true;
    "editor.guides.bracketPairs" = "active";
    "editor.guides.bracketPairsHorizontal" = "active";
    "editor.autoClosingBrackets" = "always";
    "editor.autoClosingQuotes" = "always";
    "editor.autoSurround" = "languageDefined";
    "editor.matchBrackets" = "always";

    # minimap configuration for code navigation
    "editor.minimap.enabled" = true;
    "editor.minimap.size" = "proportional";
    "editor.minimap.showSlider" = "mouseover";
    "editor.minimap.renderCharacters" = false;
    "editor.minimap.maxColumn" = 120;

    # === FILE HANDLING ===
    # auto-save and file management for seamless development
    "files.autoSave" = "afterDelay";
    "files.autoSaveDelay" = 1000;
    "files.trimTrailingWhitespace" = true;
    "files.insertFinalNewline" = true;
    "files.trimFinalNewlines" = true;
    "files.eol" = "\n";  # enforce unix line endings for WSL compatibility
    
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
    
    # === GIT INTEGRATION ===
    # enhanced git configuration for development workflows
    "git.enableSmartCommit" = true;
    "git.confirmSync" = false;
    "git.autofetch" = true;
    "git.autofetchPeriod" = 180;  # 3 minutes
    "git.defaultCloneDirectory" = "~/Projects";
    "git.openRepositoryInParentFolders" = "always";
    "git.suggestSmartCommit" = false;
    "git.enableCommitSigning" = false;  # can be enabled per-project
    "git.decorations.enabled" = true;
    "git.timeline.enabled" = true;
    "git.timeline.showAuthor" = true;
    "git.showProgress" = true;
    "git.verboseCommit" = true;
    
    # === FILE TREE OPTIMIZATION ===
    # explorer settings for better navigation and organization
    "explorer.confirmDelete" = false;
    "explorer.confirmDragAndDrop" = false;
    "explorer.sortOrder" = "type";
    "explorer.sortOrderLexicographicOptions" = "upper";
    "explorer.fileNesting.enabled" = true;
    "explorer.fileNesting.expand" = false;
    "explorer.fileNesting.patterns" = {
      "*.ts" = "\${capture}.js";
      "*.js" = "\${capture}.js.map, \${capture}.min.js, \${capture}.d.ts";
      "*.jsx" = "\${capture}.js";
      "*.tsx" = "\${capture}.ts";
      "tsconfig.json" = "tsconfig.*.json";
      "package.json" = "package-lock.json, yarn.lock, pnpm-lock.yaml, bun.lockb";
      ".gitignore" = ".gitattributes, .gitmodules, .gitmessage, .mailmap, .git-blame*";
      "readme.*" = "authors, backers*, changelog*, citation*, code_of_conduct*, codeowners, contributing*, contributors, copying, credits, governance.md, history.md, license*, maintainers, readme*, security.md, sponsors*";
      "Cargo.toml" = "Cargo.lock";
      "flake.nix" = "flake.lock";
      "devenv.nix" = "devenv.lock, .devenv.flake.nix";
    };

    # comprehensive search exclusions for development environments
    "search.exclude" = {
      # package managers and dependencies
      "**/node_modules" = true;
      "**/bower_components" = true;
      "**/.pnpm" = true;
      "**/vendor" = true;

      # version control
      "**/.git" = true;
      "**/.svn" = true;
      "**/.hg" = true;

      # build artifacts and caches
      "**/dist" = true;
      "**/build" = true;
      "**/target" = true;
      "**/.next" = true;
      "**/.nuxt" = true;
      "**/.cache" = true;
      "**/tmp" = true;
      "**/temp" = true;

      # development environment artifacts
      "**/.direnv" = true;
      "**/.devenv" = true;
      "**/result" = true;
      "**/result-*" = true;

      # IDE and editor files
      "**/.vscode" = true;
      "**/.idea" = true;

      # OS artifacts
      "**/.DS_Store" = true;
      "**/Thumbs.db" = true;

      # language-specific artifacts
      "**/__pycache__" = true;
      "**/*.pyc" = true;
      "**/.pytest_cache" = true;
      "**/.mypy_cache" = true;
      "**/.tox" = true;
      "**/coverage" = true;
      "**/.nyc_output" = true;
    };

    # file exclusions for cleaner explorer view
    "files.exclude" = {
      # version control (keep minimal for explorer)
      "**/.git" = true;

      # OS artifacts
      "**/.DS_Store" = true;
      "**/Thumbs.db" = true;

      # common development artifacts
      "**/node_modules" = true;
      "**/.direnv" = true;
      "**/.devenv" = true;
      "**/result" = true;
      "**/result-*" = true;

      # temporary files
      "**/*.tmp" = true;
      "**/*.temp" = true;
    };
    
    # === MULTI-LANGUAGE DEVELOPMENT SUPPORT ===
    # comprehensive language-specific configurations with LSP integration

    # nix language configuration (primary focus for this environment)
    "[nix]" = {
      "editor.defaultFormatter" = "jnoortheen.nix-ide";
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
      "editor.formatOnSave" = true;
      "editor.codeActionsOnSave" = {
        "source.fixAll" = "explicit";
      };
    };

    # javascript/typescript configuration
    "[javascript]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.tabSize" = 2;
      "editor.codeActionsOnSave" = {
        "source.fixAll.eslint" = "explicit";
        "source.organizeImports" = "explicit";
      };
    };
    "[typescript]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.tabSize" = 2;
      "editor.codeActionsOnSave" = {
        "source.fixAll.eslint" = "explicit";
        "source.organizeImports" = "explicit";
      };
    };
    "[javascriptreact]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.tabSize" = 2;
    };
    "[typescriptreact]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.tabSize" = 2;
    };

    # python configuration
    "[python]" = {
      "editor.defaultFormatter" = "ms-python.black-formatter";
      "editor.tabSize" = 4;
      "editor.insertSpaces" = true;
      "editor.codeActionsOnSave" = {
        "source.fixAll" = "explicit";
        "source.organizeImports" = "explicit";
      };
    };

    # rust configuration
    "[rust]" = {
      "editor.defaultFormatter" = "rust-lang.rust-analyzer";
      "editor.tabSize" = 4;
      "editor.insertSpaces" = true;
      "editor.formatOnSave" = true;
    };

    # go configuration
    "[go]" = {
      "editor.defaultFormatter" = "golang.go";
      "editor.tabSize" = 4;
      "editor.insertSpaces" = false;  # go prefers tabs
      "editor.formatOnSave" = true;
      "editor.codeActionsOnSave" = {
        "source.organizeImports" = "explicit";
      };
    };

    # shell scripting configuration
    "[shellscript]" = {
      "editor.defaultFormatter" = "foxundermoon.shell-format";
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
    };
    "[fish]" = {
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
    };

    # markup and data formats
    "[json]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.tabSize" = 2;
    };
    "[jsonc]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.tabSize" = 2;
    };
    "[yaml]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.tabSize" = 2;
    };
    "[toml]" = {
      "editor.defaultFormatter" = "tamasfe.even-better-toml";
      "editor.tabSize" = 2;
    };
    "[html]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.tabSize" = 2;
    };
    "[css]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.tabSize" = 2;
    };
    "[scss]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.tabSize" = 2;
    };
    "[markdown]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.tabSize" = 2;
      "editor.wordWrap" = "on";
      "editor.quickSuggestions" = {
        "comments" = "off";
        "strings" = "off";
        "other" = "off";
      };
    };
    
    # === LSP AND EXTENSION CONFIGURATIONS ===
    # comprehensive language server protocol configurations

    # nix language server configuration
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "nil";
    "nix.serverSettings" = {
      "nil" = {
        "diagnostics" = {
          "ignored" = [ "unused_binding" "unused_with" ];
        };
        "formatting" = {
          "command" = [ "nixfmt" ];
        };
      };
    };

    # python language server configuration
    "python.defaultInterpreterPath" = "/usr/bin/python3";
    "python.linting.enabled" = true;
    "python.linting.pylintEnabled" = false;
    "python.linting.flake8Enabled" = true;
    "python.formatting.provider" = "black";
    "python.analysis.typeCheckingMode" = "basic";
    "python.analysis.autoImportCompletions" = true;

    # typescript/javascript language server configuration
    "typescript.preferences.quoteStyle" = "single";
    "typescript.suggest.autoImports" = true;
    "typescript.updateImportsOnFileMove.enabled" = "always";
    "javascript.preferences.quoteStyle" = "single";
    "javascript.suggest.autoImports" = true;
    "javascript.updateImportsOnFileMove.enabled" = "always";

    # rust language server configuration
    "rust-analyzer.check.command" = "clippy";
    "rust-analyzer.cargo.features" = "all";
    "rust-analyzer.procMacro.enable" = true;
    "rust-analyzer.inlayHints.bindingModeHints.enable" = true;
    "rust-analyzer.inlayHints.closingBraceHints.minLines" = 10;

    # go language server configuration
    "go.useLanguageServer" = true;
    "go.formatTool" = "goimports";
    "go.lintTool" = "golangci-lint";
    "go.vetOnSave" = "package";

    # extension management
    "extensions.autoUpdate" = true;
    "extensions.ignoreRecommendations" = false;
    "extensions.autoCheckUpdates" = true;
    
    # === PERFORMANCE OPTIMIZATION FOR WSL2 ===
    # comprehensive file watcher exclusions for better WSL performance
    "files.watcherExclude" = {
      # version control
      "**/.git/objects/**" = true;
      "**/.git/subtree-cache/**" = true;
      "**/.git/logs/**" = true;

      # package managers and dependencies
      "**/node_modules/**" = true;
      "**/.pnpm/**" = true;
      "**/bower_components/**" = true;
      "**/vendor/**" = true;

      # build artifacts and caches
      "**/dist/**" = true;
      "**/build/**" = true;
      "**/target/**" = true;
      "**/.next/**" = true;
      "**/.nuxt/**" = true;
      "**/.cache/**" = true;
      "**/tmp/**" = true;
      "**/temp/**" = true;

      # development environment artifacts
      "**/.direnv/**" = true;
      "**/.devenv/**" = true;
      "**/result" = true;
      "**/result-*" = true;

      # language-specific caches
      "**/__pycache__/**" = true;
      "**/.pytest_cache/**" = true;
      "**/.mypy_cache/**" = true;
      "**/.tox/**" = true;
      "**/coverage/**" = true;
      "**/.nyc_output/**" = true;

      # nix store (large and frequently changing)
      "**/nix/store/**" = true;
      "**/.nix-profile/**" = true;
      "**/.nix-defexpr/**" = true;
    };

    # editor performance optimizations
    "editor.suggest.snippetsPreventQuickSuggestions" = false;
    "editor.suggest.localityBonus" = true;
    "editor.acceptSuggestionOnCommitCharacter" = false;
    "editor.acceptSuggestionOnEnter" = "on";
    "editor.quickSuggestionsDelay" = 10;

    # search performance optimizations
    "search.smartCase" = true;
    "search.useGlobalIgnoreFiles" = true;
    "search.useParentIgnoreFiles" = true;
    "search.followSymlinks" = false;
    "search.maxResults" = 20000;
    
    # === WORKSPACE AND LAYOUT OPTIMIZATION ===
    # workbench layout and behavior
    "workbench.startupEditor" = "welcomePageInEmptyWorkbench";
    "workbench.editor.enablePreview" = false;
    "workbench.editor.enablePreviewFromQuickOpen" = false;
    "workbench.editor.closeOnFileDelete" = true;
    "workbench.editor.highlightModifiedTabs" = true;
    "workbench.editor.limit.enabled" = true;
    "workbench.editor.limit.value" = 10;
    "workbench.editor.limit.perEditorGroup" = true;
    "workbench.activityBar.visible" = true;
    "workbench.statusBar.visible" = true;
    "workbench.sideBar.location" = "left";
    "workbench.panel.defaultLocation" = "bottom";
    "workbench.panel.opensMaximized" = "never";

    # breadcrumbs for better navigation
    "breadcrumbs.enabled" = true;
    "breadcrumbs.filePath" = "on";
    "breadcrumbs.symbolPath" = "on";
    "breadcrumbs.symbolSortOrder" = "position";

    # problems panel configuration
    "problems.decorations.enabled" = true;
    "problems.showCurrentInStatus" = true;

    # === SECURITY AND PRIVACY ===
    # security settings for development environment
    "security.workspace.trust.untrustedFiles" = "prompt";
    "security.workspace.trust.banner" = "always";
    "security.workspace.trust.startupPrompt" = "once";
    "security.workspace.trust.emptyWindow" = true;

    # telemetry settings (privacy-focused)
    "telemetry.telemetryLevel" = "off";
    "redhat.telemetry.enabled" = false;
    "dotnetAcquisitionExtension.enableTelemetry" = false;
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
      (envPathFallback.createBackup vscodePaths.settings)
      (envPathFallback.createBackup vscodePaths.keybindings)
      (envPathFallback.ensureDirectory (builtins.dirOf vscodePaths.settings))
    ];

    # validation warnings
    warnings = lib.optional (!envPathFallback.validateWindowsPath (builtins.dirOf vscodePaths.settings))
      "VS Code settings directory not found at ${builtins.dirOf vscodePaths.settings}. VS Code may not be installed.";
  };
}
