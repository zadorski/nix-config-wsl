{ lib, config, pkgs, ... }:

let
  cfg = config.programs.windows-integration;
  windowsLib = cfg._internal.windowsLib;
  windowsPaths = cfg._internal.paths;
  fontConfig = cfg._internal.fonts or {
    family = "CaskaydiaCove Nerd Font, Cascadia Code, Cascadia Mono, Consolas, Courier New, monospace";
    primaryFont = "CaskaydiaCove Nerd Font";
    terminalSize = 11;
  };
  
  # Windows Terminal settings with Catppuccin Mocha theme
  terminalSettings = {
    "$help" = "https://aka.ms/terminal-documentation";
    "$schema" = "https://aka.ms/terminal-profiles-schema";
    
    # default settings
    defaultProfile = "{2c4de342-38b7-51cf-b940-2309a097f518}"; # Ubuntu WSL
    
    # copy and paste settings
    copyFormatting = "none";
    copyOnSelect = false;
    #defaultProfile = "{2c4de342-38b7-51cf-b940-2309a097f518}";
    
    # startup settings
    launchMode = "default";
    startOnUserLogin = false;
    
    # appearance settings with Catppuccin Mocha
    theme = "dark";
    
    # profiles configuration
    profiles = {
      defaults = {
        # catppuccin mocha color scheme
        colorScheme = "Catppuccin Mocha";
        
        # font configuration with fallback support
        font = {
          face = fontConfig.primaryFont;
          size = fontConfig.terminalSize;
          weight = "normal";
        };
        
        # cursor settings
        cursorShape = "bar";
        cursorColor = "#F5E0DC"; # catppuccin rosewater
        
        # scrollback and history
        historySize = 10000;
        snapOnInput = true;
        
        # window settings
        useAcrylic = false;
        acrylicOpacity = 0.8;
        padding = "8, 8, 8, 8";
      };
      
      list = [
        {
          # WSL Ubuntu profile
          guid = "{2c4de342-38b7-51cf-b940-2309a097f518}";
          name = "Ubuntu";
          source = "Windows.Terminal.Wsl";
          commandline = "wsl.exe -d Ubuntu";
          icon = "ms-appx:///ProfileIcons/{9acb9455-ca41-5af7-950f-6bca1bc9722f}.png";
          startingDirectory = "~";
          
          # WSL-specific optimizations
          antialiasingMode = "grayscale";
          closeOnExit = "graceful";
          
          # environment variables for WSL
          environment = {
            TERM = "xterm-256color";
            COLORTERM = "truecolor";
          };
        }
        
        {
          # PowerShell profile
          guid = "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}";
          name = "Windows PowerShell";
          commandline = "powershell.exe";
          icon = "ms-appx:///ProfileIcons/pwsh.png";
          startingDirectory = "%USERPROFILE%";
        }
        
        {
          # Command Prompt profile
          guid = "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}";
          name = "Command Prompt";
          commandline = "cmd.exe";
          icon = "ms-appx:///ProfileIcons/{0caa0dad-35be-5f56-a8ff-afceeeaa6101}.png";
          startingDirectory = "%USERPROFILE%";
        }
      ];
    };
    
    # color schemes with Catppuccin Mocha (WCAG 2.1 AA compliant)
    schemes = [
      {
        name = "Catppuccin Mocha";
        
        # base colors
        background = "#1E1E2E"; # base
        foreground = "#CDD6F4"; # text
        
        # cursor colors
        cursorColor = "#F5E0DC"; # rosewater
        selectionBackground = "#585B70"; # surface2
        
        # normal colors (0-7)
        black = "#45475A";         # surface1
        red = "#F38BA8";           # red
        green = "#A6E3A1";         # green  
        yellow = "#F9E2AF";        # yellow
        blue = "#89B4FA";          # blue
        purple = "#F5C2E7";        # pink
        cyan = "#94E2D5";          # teal
        white = "#BAC2DE";         # subtext1
        
        # bright colors (8-15)
        brightBlack = "#585B70";   # surface2
        brightRed = "#F38BA8";     # red
        brightGreen = "#A6E3A1";   # green
        brightYellow = "#F9E2AF";  # yellow
        brightBlue = "#89B4FA";    # blue
        brightPurple = "#F5C2E7";  # pink
        brightCyan = "#94E2D5";    # teal
        brightWhite = "#A6ADC8";   # subtext0
      }
    ];
    
    # key bindings optimized for development
    actions = [
      # copy and paste
      { command = { action = "copy"; singleLine = false; }; keys = "ctrl+c"; }
      { command = "paste"; keys = "ctrl+v"; }
      
      # tab management
      { command = "newTab"; keys = "ctrl+t"; }
      { command = { action = "closeTab"; }; keys = "ctrl+w"; }
      { command = { action = "nextTab"; }; keys = "ctrl+tab"; }
      { command = { action = "prevTab"; }; keys = "ctrl+shift+tab"; }
      
      # pane management
      { command = { action = "splitPane"; split = "horizontal"; }; keys = "alt+shift+minus"; }
      { command = { action = "splitPane"; split = "vertical"; }; keys = "alt+shift+plus"; }
      { command = { action = "closePane"; }; keys = "ctrl+shift+w"; }
      
      # navigation
      { command = { action = "moveFocus"; direction = "down"; }; keys = "alt+down"; }
      { command = { action = "moveFocus"; direction = "left"; }; keys = "alt+left"; }
      { command = { action = "moveFocus"; direction = "right"; }; keys = "alt+right"; }
      { command = { action = "moveFocus"; direction = "up"; }; keys = "alt+up"; }
      
      # search
      { command = "find"; keys = "ctrl+f"; }
      
      # font size
      { command = { action = "adjustFontSize"; delta = 1; }; keys = "ctrl+plus"; }
      { command = { action = "adjustFontSize"; delta = -1; }; keys = "ctrl+minus"; }
      { command = { action = "resetFontSize"; }; keys = "ctrl+0"; }
    ];
  };

  terminalSettingsJson = builtins.toJSON terminalSettings;
  
  terminalPath = windowsLib.getWindowsTerminalPath windowsPaths;

in

{
  config = lib.mkIf (cfg.enable && cfg.applications.terminal) {
    # create Windows Terminal settings file
    home.file = {
      "${terminalPath}" = {
        source = pkgs.writeText "windows-terminal-settings.json" terminalSettingsJson;
      } // (if cfg.fileManagement.strategy == "copy" then { recursive = true; } else {})
        // (if cfg.fileManagement.strategy == "template" then { text = terminalSettingsJson; } else {});
    };

    # create backup script for original settings
    home.packages = lib.mkIf cfg.fileManagement.backupOriginals [
      (windowsLib.createBackup terminalPath)
      (windowsLib.ensureDirectory (builtins.dirOf terminalPath))
    ];

    # validation warnings
    warnings = lib.optional (!windowsLib.validateWindowsPath (builtins.dirOf terminalPath))
      "Windows Terminal directory not found at ${builtins.dirOf terminalPath}. Windows Terminal may not be installed.";
  };
}
