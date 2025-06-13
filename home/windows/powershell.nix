{ lib, config, pkgs, ... }:

let
  cfg = config.programs.windows-integration;
  windowsLib = cfg._internal.windowsLib;
  windowsPaths = cfg._internal.paths;
  
  powershellPaths = windowsLib.getPowerShellPaths windowsPaths;
  
  # PowerShell profile with Starship integration and development tools
  powershellProfile = ''
    # PowerShell profile managed by Nix
    # Generated from nix-config-wsl/home/windows/powershell.nix
    
    # import modules and set execution policy for current user
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    
    # starship prompt initialization
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        Invoke-Expression (&starship init powershell)
    } else {
        Write-Warning "Starship not found in PATH. Install starship for enhanced prompt."
    }
    
    # enhanced PSReadLine configuration for better editing experience
    if (Get-Module -ListAvailable -Name PSReadLine) {
        Import-Module PSReadLine
        
        # set editing mode to emacs (bash-like)
        Set-PSReadLineOption -EditMode Emacs
        
        # history configuration
        Set-PSReadLineOption -HistorySearchCursorMovesToEnd
        Set-PSReadLineOption -MaximumHistoryCount 10000
        Set-PSReadLineOption -PredictionSource History
        
        # catppuccin mocha colors for PSReadLine
        Set-PSReadLineOption -Colors @{
            Command            = '#89B4FA'  # blue
            Number             = '#FAB387'  # peach
            Member             = '#F5C2E7'  # pink
            Operator           = '#94E2D5'  # teal
            Type               = '#F9E2AF'  # yellow
            Variable           = '#CDD6F4'  # text
            Parameter          = '#F2CDCD'  # flamingo
            ContinuationPrompt = '#6C7086'  # overlay1
            Default            = '#CDD6F4'  # text
            Emphasis           = '#F38BA8'  # red
            Error              = '#F38BA8'  # red
            Selection          = '#585B70'  # surface2
            Comment            = '#6C7086'  # overlay1
            Keyword            = '#CBA6F7'  # mauve
            String             = '#A6E3A1'  # green
        }
        
        # key bindings for enhanced navigation
        Set-PSReadLineKeyHandler -Key Tab -Function Complete
        Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteChar
        Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardDeleteWord
        Set-PSReadLineKeyHandler -Key Alt+d -Function DeleteWord
        Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
        Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    }
    
    # environment variables for development
    $env:EDITOR = "code"
    $env:PAGER = "less"
    $env:TERM = "xterm-256color"
    $env:COLORTERM = "truecolor"
    
    # WSL integration functions
    function wsl-here {
        param([string]$Distribution = "Ubuntu")
        wsl -d $Distribution --cd $PWD
    }
    
    function wsl-code {
        param([string]$Path = ".")
        wsl code $Path
    }
    
    # enhanced directory listing with colors
    function ll { Get-ChildItem -Force $args | Format-Table -AutoSize }
    function la { Get-ChildItem -Force -Hidden $args }
    function l { Get-ChildItem $args }
    
    # git aliases for consistency with WSL environment
    function gs { git status $args }
    function ga { git add $args }
    function gc { git commit $args }
    function gp { git push $args }
    function gl { git log --oneline --graph $args }
    function gd { git diff $args }
    function gb { git branch $args }
    function gco { git checkout $args }
    
    # docker aliases (if Docker Desktop is installed)
    function d { docker $args }
    function dc { docker-compose $args }
    function dps { docker ps $args }
    function di { docker images $args }
    
    # network utilities
    function which($name) { Get-Command $name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition }
    function grep($regex, $dir) { 
        if ($dir) {
            Get-ChildItem $dir -Recurse | Select-String -Pattern $regex
        } else {
            $input | Select-String -Pattern $regex
        }
    }
    
    # system information
    function sysinfo {
        Write-Host "=== System Information ===" -ForegroundColor Cyan
        Write-Host "OS: " -NoNewline; (Get-CimInstance Win32_OperatingSystem).Caption
        Write-Host "Version: " -NoNewline; (Get-CimInstance Win32_OperatingSystem).Version
        Write-Host "Architecture: " -NoNewline; $env:PROCESSOR_ARCHITECTURE
        Write-Host "PowerShell: " -NoNewline; $PSVersionTable.PSVersion
        Write-Host "WSL Status: " -NoNewline
        if (Get-Command wsl -ErrorAction SilentlyContinue) {
            Write-Host "Available" -ForegroundColor Green
            wsl --list --verbose
        } else {
            Write-Host "Not Available" -ForegroundColor Red
        }
    }
    
    # development environment setup
    function dev-env {
        Write-Host "=== Development Environment ===" -ForegroundColor Cyan
        
        # check for common development tools
        $tools = @("git", "node", "npm", "python", "docker", "code", "wsl")
        foreach ($tool in $tools) {
            $cmd = Get-Command $tool -ErrorAction SilentlyContinue
            if ($cmd) {
                Write-Host "$tool`: " -NoNewline
                Write-Host "✓ $($cmd.Source)" -ForegroundColor Green
            } else {
                Write-Host "$tool`: " -NoNewline
                Write-Host "✗ Not found" -ForegroundColor Red
            }
        }
    }
    
    # welcome message
    Write-Host ""
    Write-Host "PowerShell Profile Loaded" -ForegroundColor Green
    Write-Host "Managed by nix-config-wsl" -ForegroundColor Cyan
    Write-Host "Type 'sysinfo' for system information" -ForegroundColor Yellow
    Write-Host "Type 'dev-env' to check development tools" -ForegroundColor Yellow
    Write-Host ""
  '';

in

{
  config = lib.mkIf (cfg.enable && cfg.applications.powershell) {
    # create PowerShell profiles for current user and ISE
    home.file = {
      "${powershellPaths.currentUser}" = {
        source = pkgs.writeText "Microsoft.PowerShell_profile.ps1" powershellProfile;
      } // (if cfg.fileManagement.strategy == "copy" then { recursive = true; } else {})
        // (if cfg.fileManagement.strategy == "template" then { text = powershellProfile; } else {});

      "${powershellPaths.currentUserISE}" = {
        source = pkgs.writeText "Microsoft.PowerShellISE_profile.ps1" powershellProfile;
      } // (if cfg.fileManagement.strategy == "copy" then { recursive = true; } else {})
        // (if cfg.fileManagement.strategy == "template" then { text = powershellProfile; } else {});
    };

    # create backup scripts and ensure directories
    home.packages = lib.mkIf cfg.fileManagement.backupOriginals [
      (windowsLib.createBackup powershellPaths.currentUser)
      (windowsLib.createBackup powershellPaths.currentUserISE)
      (windowsLib.ensureDirectory (builtins.dirOf powershellPaths.currentUser))
    ];

    # validation warnings
    warnings = lib.optional (!windowsLib.validateWindowsPath (builtins.dirOf powershellPaths.currentUser))
      "PowerShell profile directory not found at ${builtins.dirOf powershellPaths.currentUser}. PowerShell may not be installed.";
  };
}
