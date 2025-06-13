{ lib, config, pkgs, ... }:

let
  cfg = config.programs.windows-wsl-manager;
  envPathFallback = cfg._internal.envPathFallback;
  windowsPaths = cfg._internal.paths;
  
  # font configuration with fallback chain
  fontFamily = "${cfg.fonts.primaryFont}, ${lib.concatStringsSep ", " cfg.fonts.fallbackFonts}, monospace";
  
  # CaskaydiaCove Nerd Font download URLs (GitHub releases)
  nerdFontVersion = "v3.1.1";
  nerdFontBaseUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/${nerdFontVersion}";
  cascadiaFontUrl = "${nerdFontBaseUrl}/CascadiaCode.zip";
  
  # Windows font paths
  userFontsPath = "${windowsPaths.localAppData}/Microsoft/Windows/Fonts";
  systemFontsPath = "/mnt/c/Windows/Fonts";
  
  # PowerShell script for font installation
  fontInstallScript = pkgs.writeText "install-fonts.ps1" ''
    # PowerShell script for installing CaskaydiaCove Nerd Font
    # Generated from nix-config-wsl/home/windows/fonts.nix
    
    param(
        [string]$FontUrl = "${cascadiaFontUrl}",
        [string]$UserFontsPath = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts",
        [switch]$Force = $false
    )
    
    Write-Host "=== CaskaydiaCove Nerd Font Installation ===" -ForegroundColor Cyan
    
    # create user fonts directory if it doesn't exist
    if (-not (Test-Path $UserFontsPath)) {
        Write-Host "Creating user fonts directory: $UserFontsPath" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $UserFontsPath -Force | Out-Null
    }
    
    # check if font is already installed
    $fontName = "CaskaydiaCove Nerd Font"
    $installedFonts = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue
    $fontInstalled = $installedFonts.PSObject.Properties | Where-Object { $_.Name -like "*CaskaydiaCove*" }
    
    if ($fontInstalled -and -not $Force) {
        Write-Host "✓ CaskaydiaCove Nerd Font already installed" -ForegroundColor Green
        return
    }
    
    # download font archive
    $tempDir = Join-Path $env:TEMP "nerd-fonts-install"
    $zipPath = Join-Path $tempDir "CascadiaCode.zip"
    
    Write-Host "Creating temporary directory: $tempDir" -ForegroundColor Yellow
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    try {
        Write-Host "Downloading CaskaydiaCove Nerd Font from GitHub..." -ForegroundColor Yellow
        Write-Host "URL: $FontUrl" -ForegroundColor Gray
        
        # use TLS 1.2 for GitHub
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "nix-config-wsl-font-installer")
        $webClient.DownloadFile($FontUrl, $zipPath)
        
        Write-Host "✓ Download completed" -ForegroundColor Green
        
        # extract font files
        Write-Host "Extracting font files..." -ForegroundColor Yellow
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $tempDir)
        
        # find and install font files
        $fontFiles = Get-ChildItem -Path $tempDir -Filter "*.ttf" -Recurse | Where-Object { 
            $_.Name -like "*CaskaydiaCove*" -and $_.Name -notlike "*Windows Compatible*"
        }
        
        if ($fontFiles.Count -eq 0) {
            Write-Error "No CaskaydiaCove font files found in archive"
            return
        }
        
        Write-Host "Found $($fontFiles.Count) font files to install" -ForegroundColor Yellow
        
        # install each font file
        foreach ($fontFile in $fontFiles) {
            $destPath = Join-Path $UserFontsPath $fontFile.Name
            
            Write-Host "Installing: $($fontFile.Name)" -ForegroundColor Yellow
            Copy-Item $fontFile.FullName $destPath -Force
            
            # register font in registry
            $fontRegistryName = $fontFile.BaseName + " (TrueType)"
            $fontRegistryValue = $fontFile.Name
            
            try {
                Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $fontRegistryName -Value $fontRegistryValue -Force
                Write-Host "✓ Registered: $fontRegistryName" -ForegroundColor Green
            } catch {
                Write-Warning "Failed to register font in registry: $($_.Exception.Message)"
            }
        }
        
        # refresh font cache
        Write-Host "Refreshing font cache..." -ForegroundColor Yellow
        try {
            Add-Type -TypeDefinition @"
                using System;
                using System.Runtime.InteropServices;
                public class FontHelper {
                    [DllImport("gdi32.dll")]
                    public static extern int AddFontResource(string lpszFilename);
                    
                    [DllImport("user32.dll")]
                    public static extern int SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
                    
                    public static void RefreshFonts() {
                        const int HWND_BROADCAST = 0xffff;
                        const uint WM_FONTCHANGE = 0x001D;
                        SendMessage((IntPtr)HWND_BROADCAST, WM_FONTCHANGE, IntPtr.Zero, IntPtr.Zero);
                    }
                }
"@
            
            foreach ($fontFile in $fontFiles) {
                $destPath = Join-Path $UserFontsPath $fontFile.Name
                [FontHelper]::AddFontResource($destPath) | Out-Null
            }
            
            [FontHelper]::RefreshFonts()
            Write-Host "✓ Font cache refreshed" -ForegroundColor Green
            
        } catch {
            Write-Warning "Failed to refresh font cache: $($_.Exception.Message)"
            Write-Host "You may need to restart applications to see the new fonts" -ForegroundColor Yellow
        }
        
        Write-Host "✓ CaskaydiaCove Nerd Font installation completed!" -ForegroundColor Green
        Write-Host "Font family name: 'CaskaydiaCove Nerd Font'" -ForegroundColor Cyan
        
    } catch {
        Write-Error "Font installation failed: $($_.Exception.Message)"
        throw
    } finally {
        # cleanup temporary files
        if (Test-Path $tempDir) {
            Write-Host "Cleaning up temporary files..." -ForegroundColor Yellow
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
  '';
  
  # Font validation script
  fontValidationScript = pkgs.writeText "validate-fonts.ps1" ''
    # PowerShell script for validating font installation
    # Generated from nix-config-wsl/home/windows/fonts.nix
    
    Write-Host "=== Font Installation Validation ===" -ForegroundColor Cyan
    
    # check user fonts directory
    $userFontsPath = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    Write-Host "User Fonts Directory: $userFontsPath" -ForegroundColor Gray
    
    if (Test-Path $userFontsPath) {
        Write-Host "✓ User fonts directory exists" -ForegroundColor Green
        $userFontFiles = Get-ChildItem -Path $userFontsPath -Filter "*CaskaydiaCove*" -ErrorAction SilentlyContinue
        Write-Host "CaskaydiaCove files in user directory: $($userFontFiles.Count)" -ForegroundColor Gray
    } else {
        Write-Host "✗ User fonts directory not found" -ForegroundColor Red
    }
    
    # check system fonts directory
    $systemFontsPath = "$env:WINDIR\Fonts"
    Write-Host "System Fonts Directory: $systemFontsPath" -ForegroundColor Gray
    
    if (Test-Path $systemFontsPath) {
        $systemFontFiles = Get-ChildItem -Path $systemFontsPath -Filter "*CaskaydiaCove*" -ErrorAction SilentlyContinue
        Write-Host "CaskaydiaCove files in system directory: $($systemFontFiles.Count)" -ForegroundColor Gray
    }
    
    # check registry entries
    Write-Host "Registry Entries:" -ForegroundColor Gray
    try {
        $userFonts = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue
        $cascadiaFonts = $userFonts.PSObject.Properties | Where-Object { $_.Name -like "*CaskaydiaCove*" }
        
        if ($cascadiaFonts) {
            Write-Host "✓ Found $($cascadiaFonts.Count) CaskaydiaCove registry entries" -ForegroundColor Green
            foreach ($font in $cascadiaFonts) {
                Write-Host "  - $($font.Name): $($font.Value)" -ForegroundColor Gray
            }
        } else {
            Write-Host "✗ No CaskaydiaCove registry entries found" -ForegroundColor Red
        }
    } catch {
        Write-Host "✗ Failed to check registry: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # test font availability in applications
    Write-Host "Font Availability Test:" -ForegroundColor Gray
    try {
        Add-Type -AssemblyName System.Drawing
        $fontFamily = New-Object System.Drawing.FontFamily("CaskaydiaCove Nerd Font")
        Write-Host "✓ CaskaydiaCove Nerd Font is available to applications" -ForegroundColor Green
        Write-Host "  Font Name: $($fontFamily.Name)" -ForegroundColor Gray
    } catch {
        Write-Host "✗ CaskaydiaCove Nerd Font not available to applications" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Gray
        
        # suggest fallback fonts
        Write-Host "Available fallback fonts:" -ForegroundColor Yellow
        $fallbackFonts = @("Cascadia Code", "Cascadia Mono", "Consolas", "Courier New")
        foreach ($fallback in $fallbackFonts) {
            try {
                $testFont = New-Object System.Drawing.FontFamily($fallback)
                Write-Host "  ✓ $fallback" -ForegroundColor Green
            } catch {
                Write-Host "  ✗ $fallback" -ForegroundColor Red
            }
        }
    }
  '';

in

{
  config = lib.mkIf (cfg.enable && cfg.fonts.enable) {
    # expose font configuration for other modules
    programs.windows-wsl-manager._internal.fonts = {
      family = fontFamily;
      primaryFont = cfg.fonts.primaryFont;
      fallbackFonts = cfg.fonts.fallbackFonts;
      terminalSize = cfg.fonts.sizes.terminal;
      editorSize = cfg.fonts.sizes.editor;
    };

    # font installation and validation scripts
    home.packages = [
      # font installation script
      (pkgs.writeShellScriptBin "install-fonts" ''
        echo "=== Installing Windows Fonts from WSL ==="
        
        # check if we're in WSL
        if ! grep -qi microsoft /proc/version 2>/dev/null; then
          echo "✗ This script must be run from WSL"
          exit 1
        fi
        
        # check if PowerShell is available
        if ! command -v powershell.exe >/dev/null 2>&1; then
          echo "✗ PowerShell not available. Please install PowerShell or run from Windows."
          exit 1
        fi
        
        echo "Running PowerShell font installation script..."
        powershell.exe -ExecutionPolicy Bypass -File "${fontInstallScript}" "$@"
      '')
      
      # font validation script
      (pkgs.writeShellScriptBin "validate-fonts" ''
        echo "=== Validating Windows Font Installation ==="
        
        # check WSL environment
        if ! grep -qi microsoft /proc/version 2>/dev/null; then
          echo "✗ This script must be run from WSL"
          exit 1
        fi
        
        # check user fonts directory from WSL
        USER_FONTS_PATH="${userFontsPath}"
        echo "Checking user fonts directory: $USER_FONTS_PATH"
        
        if [ -d "$USER_FONTS_PATH" ]; then
          echo "✓ User fonts directory exists"
          FONT_COUNT=$(find "$USER_FONTS_PATH" -name "*CaskaydiaCove*" -type f 2>/dev/null | wc -l)
          echo "CaskaydiaCove font files found: $FONT_COUNT"
        else
          echo "✗ User fonts directory not found"
        fi
        
        # run PowerShell validation if available
        if command -v powershell.exe >/dev/null 2>&1; then
          echo ""
          echo "Running PowerShell font validation..."
          powershell.exe -ExecutionPolicy Bypass -File "${fontValidationScript}"
        else
          echo "⚠ PowerShell not available for detailed validation"
        fi
      '')
    ];

    # automatic font installation if enabled
    home.activation = lib.mkIf cfg.fonts.autoInstall {
      installWindowsFonts = lib.hm.dag.entryAfter ["writeBoundary"] ''
        echo "Checking Windows font installation..."
        
        # only run if in WSL and PowerShell is available
        if grep -qi microsoft /proc/version 2>/dev/null && command -v powershell.exe >/dev/null 2>&1; then
          # check if fonts are already installed
          if [ ! -d "${userFontsPath}" ] || [ $(find "${userFontsPath}" -name "*CaskaydiaCove*" -type f 2>/dev/null | wc -l) -eq 0 ]; then
            echo "Installing CaskaydiaCove Nerd Font..."
            $DRY_RUN_CMD ${pkgs.writeShellScript "auto-install-fonts" ''
              powershell.exe -ExecutionPolicy Bypass -File "${fontInstallScript}"
            ''}
          else
            echo "✓ CaskaydiaCove Nerd Font already installed"
          fi
        else
          echo "⚠ Skipping font installation (not in WSL or PowerShell unavailable)"
        fi
      '';
    };

    # validation warnings
    warnings = [
      (lib.mkIf (!envPathFallback.isWSLEnvironment)
        "Font management requires WSL environment for Windows font installation.")
      (lib.mkIf (cfg.fonts.autoInstall && !builtins.pathExists "/usr/bin/powershell.exe")
        "Automatic font installation requires PowerShell. Install PowerShell or disable autoInstall.")
    ];
  };
}
