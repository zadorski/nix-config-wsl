# NixOS-WSL Architecture Documentation

## System Architecture Overview

This repository implements a **modular NixOS-WSL flake configuration** designed for Windows Subsystem for Linux development environments. The architecture emphasizes separation of concerns, modularity, and maintainability.

### Core Design Principles
- **Modularity**: Clear separation between system and user configurations
- **Reproducibility**: Flake-based approach ensures consistent builds
- **Maintainability**: Logical organization and clear dependencies
- **Flexibility**: Easy customization and extension

## Flake Structure

### Main Flake Configuration (`flake.nix`)
```nix
{
  description = "WSL NixOS Flake";
  
  outputs = inputs: with inputs; with nixpkgs.lib; {
    nixosConfigurations.nixos = nixosSystem rec {
      modules = [ ./system ];
      system = "x86_64-linux";
      specialArgs = inputs // rec {
        userName = "nixos";
        gitEmail = "678169+${gitHandle}@users.noreply.github.com";
        gitHandle = "zadorski";
        pkgs-stable = import nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    };
  };
}
```

### Input Dependencies
- **nixpkgs**: Primary package source (unstable channel)
- **nixpkgs-stable**: Stable packages for critical components
- **nixos-wsl**: WSL2 integration and compatibility layer
- **home-manager**: User environment management
- **vscode-server**: VS Code Remote Server support
- **nushell-scripts**: Shell enhancement scripts
- **catppuccin-***: Theme packages for consistent styling

### Special Arguments
- **userName**: Default user account name
- **gitEmail/gitHandle**: Git configuration variables
- **pkgs-stable**: Stable package set for reliability
- **inputs**: All flake inputs passed to modules

## Module Organization

### System Configuration (`./system/`)

#### Core System Module (`system/default.nix`)
```nix
{
  imports = [
    ./wsl.nix           # WSL-specific configuration
    ./vscode-server.nix # VS Code Remote Server
    ./nix.nix          # Nix daemon configuration
    ./users.nix        # User management
    ./ssh.nix          # SSH configuration
    ./shells.nix       # Shell configuration
    ./fonts.nix        # Font management
    ./docker.nix       # Container runtime
  ];
  
  system.stateVersion = "24.05";
  environment.systemPackages = with pkgs; [
    # Core development tools
  ];
}
```

#### Module Responsibilities
- **wsl.nix**: WSL2 integration, Windows interoperability
- **users.nix**: User accounts, groups, permissions
- **vscode-server.nix**: VS Code Remote Server configuration
- **nix.nix**: Nix daemon settings, experimental features
- **ssh.nix**: SSH daemon and client configuration
- **shells.nix**: System shell configuration
- **docker.nix**: Container runtime setup
- **fonts.nix**: System font configuration

### Home Manager Configuration (`./home/`)

#### Core Home Module (`home/default.nix`)
```nix
{ pkgs, userName, gitEmail, gitHandle, ... }: {
  imports = [
    ./shells      # Shell configurations
    ./zellij      # Terminal multiplexer
    ./bat.nix     # Better cat
    ./btop.nix    # System monitor
    ./starship.nix # Shell prompt
  ];
  
  home = {
    username = userName;
    homeDirectory = "/home/${userName}";
    stateVersion = "24.05";
  };
  
  programs.home-manager.enable = true;
}
```

#### Module Responsibilities
- **shells/**: Shell-specific configurations (bash, nushell)
- **zellij/**: Terminal multiplexer configuration
- **Application configs**: Individual application settings
- **User packages**: User-specific package installations

## Data Flow and Dependencies

### Configuration Flow
```
flake.nix
├── inputs (external dependencies)
├── specialArgs (shared variables)
└── nixosSystem
    ├── system/ (NixOS modules)
    │   ├── Core system services
    │   ├── WSL integration
    │   └── User management
    └── home-manager
        └── home/ (User configurations)
            ├── Application configs
            └── User packages
```

### Dependency Relationships
1. **Flake Inputs** → **System Modules** → **Services/Packages**
2. **Special Args** → **Module Parameters** → **Configuration Values**
3. **System Config** → **Home Manager** → **User Environment**

## WSL Integration Architecture

### WSL-Specific Components
```nix
# WSL Module Structure
{
  imports = [ nixos-wsl.nixosModules.wsl ];
  
  wsl = {
    enable = true;
    defaultUser = userName;
    startMenuLaunchers = true;
    nativeSystemd = true;
  };
}
```

### Windows Integration Points
- **File System**: `/mnt/c` Windows drive mounting
- **Networking**: WSL2 network bridge configuration
- **Certificates**: Windows certificate store integration
- **Interoperability**: Windows executable access from WSL

### Performance Considerations
- **I/O Performance**: Minimize cross-filesystem operations
- **Memory Usage**: Efficient package selection
- **Startup Time**: Optimized service dependencies
- **Resource Sharing**: Proper Windows/Linux resource coordination

## Home Manager Integration

### System-Home Boundary
```nix
# System Level (system/users.nix)
users.users."${userName}" = {
  isNormalUser = true;
  extraGroups = [ "wheel" "docker" ];
};

# Home Level (home/default.nix)
home = {
  username = userName;
  homeDirectory = "/home/${userName}";
};
```

### Configuration Separation
- **System**: Services, hardware, system packages, security
- **Home**: Applications, dotfiles, user packages, themes

### Shared Data Flow
- **Special Args**: Passed from flake to both system and home
- **User Variables**: Consistent across system and home configs
- **Package Sets**: Shared nixpkgs and stable package sources

## Module Interaction Patterns

### Import Hierarchy
```
flake.nix
└── system/default.nix
    ├── wsl.nix
    ├── users.nix (includes home-manager)
    │   └── home/default.nix
    │       ├── shells/
    │       ├── applications/
    │       └── *.nix
    └── other-system-modules.nix
```

### Configuration Propagation
1. **Flake** defines inputs and special arguments
2. **System modules** configure NixOS services and packages
3. **Home manager** receives special arguments and configures user environment
4. **Application modules** use shared configuration values

### Override Patterns
```nix
# System-level override
services.openssh.settings.Port = lib.mkForce 2222;

# Home-level override
programs.git.userName = lib.mkOverride 50 "Custom Name";

# Conditional configuration
config = lib.mkIf config.services.development.enable {
  # development-specific configuration
};
```

## Extension Points

### Adding New System Modules
1. Create module file in `system/`
2. Add import to `system/default.nix`
3. Follow module template and coding standards
4. Test with `nix flake check`

### Adding Home Configurations
1. Create configuration in `home/`
2. Add import to `home/default.nix`
3. Use special arguments for consistency
4. Test user environment changes

### Custom Package Integration
```nix
# Custom package overlay
nixpkgs.overlays = [
  (final: prev: {
    myPackage = prev.callPackage ./packages/my-package.nix {};
  })
];
```

## Build and Deployment

### Build Process
1. **Flake Evaluation**: Parse flake.nix and resolve inputs
2. **Module Resolution**: Process all imported modules
3. **Configuration Merge**: Combine all module configurations
4. **Package Building**: Build required packages and dependencies
5. **System Generation**: Create system configuration

### Deployment Commands
```bash
# Build and switch to new configuration
nixos-rebuild switch --flake .#nixos

# Build without switching (testing)
nixos-rebuild build --flake .#nixos

# Update flake inputs
nix flake update

# Check configuration validity
nix flake check
```

### Rollback Capability
- **Generation Management**: NixOS maintains configuration generations
- **Rollback Command**: `nixos-rebuild switch --rollback`
- **Boot Menu**: GRUB entries for previous generations
- **Home Manager**: Separate generation management for user configs

## Security Architecture

### Permission Model
- **System Services**: Run with appropriate service users
- **User Isolation**: Home manager configurations isolated per user
- **Group Membership**: Controlled through system configuration
- **Sudo Rules**: Explicit sudo configuration in system modules

### Certificate Management
```nix
# Corporate certificate integration
security.pki.certificateFiles = [
  "/mnt/c/path/to/corporate-cert.crt"
];
```

### Secrets Management
- **No Secrets in Nix Store**: Never commit secrets to repository
- **External Management**: Use SOPS, age, or external secret stores
- **Runtime Configuration**: Load secrets at runtime, not build time

---

*This architecture documentation provides the foundation for understanding and extending the NixOS-WSL configuration system.*
