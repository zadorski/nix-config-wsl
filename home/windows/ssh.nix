{ lib, config, pkgs, userName, ... }:

let
  cfg = config.programs.windows-wsl-manager;
  envPathFallback = cfg._internal.envPathFallback;
  windowsPaths = cfg._internal.paths;
  
  sshPaths = envPathFallback.getSSHPaths windowsPaths;
  
  # SSH configuration for Windows with WSL key sharing
  sshConfig = ''
    # SSH configuration managed by Nix
    # Generated from nix-config-wsl/home/windows/ssh.nix
    # Shared between WSL and Windows environments
    
    # default settings
    Host *
        AddKeysToAgent yes
        UseKeychain yes
        IdentitiesOnly yes
        ServerAliveInterval 60
        ServerAliveCountMax 3
        
        # security settings
        HashKnownHosts yes
        VisualHostKey yes
        
        # performance settings
        Compression yes
        ControlMaster auto
        ControlPath ~/.ssh/control-%r@%h:%p
        ControlPersist 10m
    
    # GitHub configuration
    Host github.com
        HostName github.com
        User git
        Port 22
        IdentityFile ~/.ssh/id_maco
        IdentitiesOnly yes
        ForwardAgent yes
        
        # GitHub-specific optimizations
        PreferredAuthentications publickey
        PubkeyAuthentication yes
        
    # Azure DevOps configuration
    Host ssh.dev.azure.com
        HostName ssh.dev.azure.com
        User git
        Port 22
        IdentityFile ~/.ssh/id_rsa
        IdentitiesOnly yes
        ForwardAgent yes
        
        # Azure DevOps-specific settings
        PreferredAuthentications publickey
        PubkeyAuthentication yes
        
    # fallback for other hosts
    Host * !ssh.dev.azure.com
        IdentityFile ~/.ssh/id_maco
        IdentitiesOnly yes
        
    # WSL-specific hosts (if needed)
    Host wsl
        HostName localhost
        User ${userName}
        Port 22
        IdentityFile ~/.ssh/id_rsa
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null
  '';

in

{
  config = lib.mkIf (cfg.enable && cfg.applications.ssh) {
    # create SSH configuration and key symlinks for Windows
    home.file = {
      # SSH configuration file
      "${sshPaths.config}" = {
        source = pkgs.writeText "ssh-config" sshConfig;
      } // (if cfg.fileManagement.strategy == "copy" then { recursive = true; } else {})
        // (if cfg.fileManagement.strategy == "template" then { text = sshConfig; } else {});

      # private keys (always use symlink strategy for SSH keys)
      "${sshPaths.sshDir}/id_rsa" = {
        source = "/home/${userName}/.ssh/id_rsa";
      };

      "${sshPaths.sshDir}/id_maco" = {
        source = "/home/${userName}/.ssh/id_maco";
      };

      # public keys (always use symlink strategy for SSH keys)
      "${sshPaths.sshDir}/id_rsa.pub" = {
        source = "/home/${userName}/.ssh/id_rsa.pub";
      };

      "${sshPaths.sshDir}/id_maco.pub" = {
        source = "/home/${userName}/.ssh/id_maco.pub";
      };

      # known hosts (shared, always use symlink strategy)
      "${sshPaths.knownHosts}" = {
        source = "/home/${userName}/.ssh/known_hosts";
      };
    };

    # create backup scripts and ensure directories
    home.packages = lib.mkIf cfg.fileManagement.backupOriginals [
      (envPathFallback.createBackup sshPaths.config)
      (envPathFallback.ensureDirectory sshPaths.sshDir)
      
      # script to set proper SSH key permissions
      (pkgs.writeShellScriptBin "fix-ssh-permissions" ''
        echo "=== Fixing SSH Key Permissions ==="
        
        # WSL SSH directory permissions
        WSL_SSH_DIR="/home/${userName}/.ssh"
        if [ -d "$WSL_SSH_DIR" ]; then
          echo "Setting WSL SSH directory permissions..."
          chmod 700 "$WSL_SSH_DIR"
          chmod 600 "$WSL_SSH_DIR"/* 2>/dev/null || true
          chmod 644 "$WSL_SSH_DIR"/*.pub 2>/dev/null || true
          chmod 644 "$WSL_SSH_DIR"/known_hosts 2>/dev/null || true
          chmod 644 "$WSL_SSH_DIR"/config 2>/dev/null || true
        fi
        
        # Windows SSH directory permissions (if accessible)
        WIN_SSH_DIR="${sshPaths.sshDir}"
        if [ -d "$WIN_SSH_DIR" ]; then
          echo "Setting Windows SSH directory permissions..."
          # Note: Windows permissions are handled differently
          # This is mainly for WSL access to Windows SSH files
          chmod 700 "$WIN_SSH_DIR" 2>/dev/null || true
          chmod 600 "$WIN_SSH_DIR"/* 2>/dev/null || true
          chmod 644 "$WIN_SSH_DIR"/*.pub 2>/dev/null || true
          chmod 644 "$WIN_SSH_DIR"/known_hosts 2>/dev/null || true
          chmod 644 "$WIN_SSH_DIR"/config 2>/dev/null || true
        fi
        
        echo "SSH permissions updated."
      '')
      
      # script to validate SSH configuration
      (pkgs.writeShellScriptBin "validate-ssh-config" ''
        echo "=== SSH Configuration Validation ==="
        
        # check WSL SSH setup
        echo "WSL SSH Configuration:"
        if [ -f "/home/${userName}/.ssh/config" ]; then
          echo "✓ WSL SSH config exists"
        else
          echo "✗ WSL SSH config missing"
        fi
        
        # check Windows SSH setup
        echo ""
        echo "Windows SSH Configuration:"
        if [ -f "${sshPaths.config}" ]; then
          echo "✓ Windows SSH config exists"
        else
          echo "✗ Windows SSH config missing"
        fi
        
        # check SSH keys
        echo ""
        echo "SSH Keys:"
        for key in id_rsa id_maco; do
          if [ -f "/home/${userName}/.ssh/$key" ]; then
            echo "✓ WSL $key exists"
          else
            echo "✗ WSL $key missing"
          fi
          
          if [ -f "${sshPaths.sshDir}/$key" ]; then
            echo "✓ Windows $key exists"
          else
            echo "✗ Windows $key missing"
          fi
        done
        
        # test SSH agent
        echo ""
        echo "SSH Agent:"
        if ssh-add -l >/dev/null 2>&1; then
          echo "✓ SSH agent running with keys:"
          ssh-add -l
        else
          echo "✗ SSH agent not running or no keys loaded"
        fi
        
        # test connections
        echo ""
        echo "Connection Tests:"
        echo "Testing GitHub..."
        ssh -T git@github.com -o ConnectTimeout=5 2>&1 | head -1
        
        echo "Testing Azure DevOps..."
        ssh -T git@ssh.dev.azure.com -o ConnectTimeout=5 2>&1 | head -1
      '')
      
      # script to sync SSH keys between WSL and Windows
      (pkgs.writeShellScriptBin "sync-ssh-keys" ''
        echo "=== Syncing SSH Keys Between WSL and Windows ==="
        
        WSL_SSH_DIR="/home/${userName}/.ssh"
        WIN_SSH_DIR="${sshPaths.sshDir}"
        
        # ensure Windows SSH directory exists
        mkdir -p "$WIN_SSH_DIR"
        
        # sync keys from WSL to Windows
        for file in id_rsa id_rsa.pub id_maco id_maco.pub known_hosts; do
          if [ -f "$WSL_SSH_DIR/$file" ]; then
            echo "Syncing $file..."
            cp "$WSL_SSH_DIR/$file" "$WIN_SSH_DIR/$file"
          fi
        done
        
        # fix permissions
        fix-ssh-permissions
        
        echo "SSH key sync completed."
      '')
    ];

    # validation warnings
    warnings = [
      (lib.mkIf (!envPathFallback.validateWindowsPath sshPaths.sshDir)
        "Windows SSH directory not accessible at ${sshPaths.sshDir}. SSH key sharing may not work properly.")
      (lib.mkIf (!builtins.pathExists "/home/${userName}/.ssh")
        "WSL SSH directory not found. Run 'ssh-keygen' to create SSH keys first.")
    ];
  };
}
