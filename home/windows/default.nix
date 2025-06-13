{ lib, config, pkgs, userName, ... }:

let
  cfg = config.programs.windows-integration;
  windowsLib = import ./lib.nix { inherit lib pkgs; };
  dynamicWindowsLib = import ./dynamic-lib.nix { inherit lib pkgs; };
in

{
  # import windows application configuration modules
  imports = [
    ./environment.nix # dynamic windows environment detection
    ./fonts.nix       # font management and installation
    ./terminal.nix    # windows terminal configuration
    ./powershell.nix  # powershell profile management
    ./vscode.nix      # vs code settings synchronization
    ./git.nix         # git configuration synchronization
    ./ssh.nix         # ssh key sharing between wsl and windows
  ];

  # configuration options for windows integration
  options.programs.windows-integration = {
    enable = lib.mkEnableOption "Windows native application configuration management";
    
    windowsUsername = lib.mkOption {
      type = lib.types.str;
      default = userName;
      description = "Windows username for path resolution (defaults to WSL username)";
    };

    applications = {
      terminal = lib.mkEnableOption "Windows Terminal configuration";
      powershell = lib.mkEnableOption "PowerShell profile management";
      vscode = lib.mkEnableOption "VS Code settings synchronization";
      git = lib.mkEnableOption "Git configuration synchronization";
      ssh = lib.mkEnableOption "SSH key sharing";
    };

    fonts = {
      enable = lib.mkEnableOption "Font management and installation";

      primaryFont = lib.mkOption {
        type = lib.types.str;
        default = "CaskaydiaCove Nerd Font";
        description = "Primary font family for Windows applications";
      };

      fallbackFonts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "Cascadia Code" "Cascadia Mono" "Consolas" "Courier New" ];
        description = "Fallback font chain when primary font is unavailable";
      };

      autoInstall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Automatically install fonts if not present";
      };

      sizes = {
        terminal = lib.mkOption {
          type = lib.types.int;
          default = 11;
          description = "Font size for terminal applications";
        };

        editor = lib.mkOption {
          type = lib.types.int;
          default = 14;
          description = "Font size for editor applications";
        };
      };
    };

    pathResolution = {
      method = lib.mkOption {
        type = lib.types.enum [ "dynamic" "wslpath" "environment" "manual" ];
        default = "dynamic";
        description = "Method for resolving Windows paths";
      };

      manualPaths = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Manual path overrides when automatic resolution fails";
        example = {
          userProfile = "/mnt/c/Users/username";
          appData = "/mnt/c/Users/username/AppData/Roaming";
          localAppData = "/mnt/c/Users/username/AppData/Local";
        };
      };
    };

    fileManagement = {
      strategy = lib.mkOption {
        type = lib.types.enum [ "symlink" "copy" "template" ];
        default = "symlink";
        description = "Strategy for managing Windows configuration files";
      };
      
      backupOriginals = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to backup original Windows configuration files";
      };
    };

    # internal options for sharing data between modules (not user-configurable)
    _internal = lib.mkOption {
      type = lib.types.attrs;
      internal = true;
      default = {};
      description = "Internal data shared between Windows integration modules";
    };
  };

  # configuration implementation
  config = lib.mkIf cfg.enable {
    # validate windows environment
    assertions = [
      {
        assertion = windowsLib.isWSLEnvironment;
        message = "Windows integration requires WSL environment";
      }
      {
        assertion = cfg.pathResolution.method != "manual" || cfg.pathResolution.manualPaths != {};
        message = "Manual path resolution requires manualPaths to be configured";
      }
    ];

    # expose windows path utilities for other modules
    programs.windows-integration._internal = {
      inherit windowsLib;
      inherit dynamicWindowsLib;
      paths = if cfg.pathResolution.method == "dynamic" then
        dynamicWindowsLib.getDynamicWindowsPaths cfg.windowsUsername
      else
        windowsLib.getWindowsPaths cfg.windowsUsername cfg.pathResolution;
    };

    # create validation script for windows integration
    home.packages = lib.mkIf cfg.enable [
      (pkgs.writeShellScriptBin "validate-windows-integration" ''
        echo "=== Windows Integration Validation ==="
        echo "WSL Environment: ${if windowsLib.isWSLEnvironment then "✓" else "✗"}"
        echo "Windows Username: ${cfg.windowsUsername}"
        echo "Path Resolution Method: ${cfg.pathResolution.method}"

        ${lib.optionalString (cfg.pathResolution.method == "dynamic") ''
          echo ""
          echo "=== Dynamic Environment Detection ==="
          if [ -f "$HOME/.config/nix-windows-env" ]; then
            echo "✓ Windows environment file exists"
            source "$HOME/.config/nix-windows-env"
            echo "Windows Username: $WIN_USERNAME"
            echo "Windows User Profile: $WIN_USERPROFILE"
            echo "Windows AppData: $WIN_APPDATA"
            echo "Windows LocalAppData: $WIN_LOCALAPPDATA"
            echo "Windows Drive Mount: $WIN_DRIVE_MOUNT"
          else
            echo "✗ Windows environment file not found"
            echo "Run 'detect-windows-environment' to generate it"
          fi
        ''}

        ${lib.optionalString (cfg.pathResolution.method == "wslpath") ''
          if command -v wslpath >/dev/null 2>&1; then
            echo "wslpath command: ✓"
            echo "Windows User Profile: $(wslpath -w ~)"
          else
            echo "wslpath command: ✗"
          fi
        ''}
        
        echo ""
        echo "=== Enabled Applications ==="
        echo "Windows Terminal: ${if cfg.applications.terminal then "✓" else "✗"}"
        echo "PowerShell: ${if cfg.applications.powershell then "✓" else "✗"}"
        echo "VS Code: ${if cfg.applications.vscode then "✓" else "✗"}"
        echo "Git: ${if cfg.applications.git then "✓" else "✗"}"
        echo "SSH: ${if cfg.applications.ssh then "✓" else "✗"}"
        echo "Font Management: ${if cfg.fonts.enable then "✓" else "✗"}"
      '')
    ];

    # warning for users about windows integration
    warnings = lib.optional (cfg.enable && !windowsLib.isWSLEnvironment) 
      "Windows integration is enabled but WSL environment not detected. Some features may not work correctly.";
  };
}
