# NixOS-WSL Coding Standards

## Overview

This document defines coding standards and best practices for the NixOS-WSL flake configuration repository. All AI agents and human contributors must follow these guidelines to ensure consistent, maintainable, and high-quality Nix code.

## Nix Language Standards

### File Formatting
- **Indentation**: 2 spaces (no tabs)
- **Line Length**: Maximum 100 characters
- **Line Endings**: Unix (LF)
- **Trailing Whitespace**: Remove all trailing whitespace
- **Final Newline**: Always end files with a newline

### Code Style
```nix
# Good: Consistent formatting and clear structure
{ pkgs, lib, config, ... }:

{
  imports = [
    ./module1.nix
    ./module2.nix
  ];

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
```

### Attribute Sets
- **Alignment**: Align attribute names when practical
- **Spacing**: Single space around `=` and `:` operators
- **Trailing Commas**: Use trailing commas in multi-line lists
- **Nested Sets**: Indent nested attribute sets consistently

```nix
# Good: Proper attribute set formatting
services = {
  nginx = {
    enable = true;
    virtualHosts."example.com" = {
      forceSSL = true;
      enableACME = true;
    };
  };

  postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
  };
};
```

### Lists and Function Arguments
```nix
# Good: Multi-line list formatting
environment.systemPackages = with pkgs; [
  git
  curl
  wget
  neovim
];

# Good: Function argument formatting
{ pkgs, lib, config, specialArgs, ... }:
```

## Module Organization

### File Structure
- **One module per file**: Each `.nix` file should contain a single logical module
- **Clear naming**: Use descriptive filenames that reflect module purpose
- **Imports**: Group imports logically at the top of files

### Module Template
```nix
{ pkgs, lib, config, ... }:

{
  # Module imports (if any)
  imports = [
    # ./submodule.nix
  ];

  # Configuration options
  services.example = {
    enable = true;
    package = pkgs.example;
    settings = {
      # configuration here
    };
  };

  # Environment packages (if needed)
  environment.systemPackages = with pkgs; [
    # packages here
  ];

  # System configuration (if needed)
  systemd.services.example = {
    # service definition
  };
}
```

### Directory Organization
- **system/**: NixOS system-level configuration
- **home/**: Home-manager user-level configuration
- **Modularity**: Keep related functionality together
- **Imports**: Use `default.nix` files to manage imports

## Configuration Best Practices

### Package Management
```nix
# Good: Explicit package references
environment.systemPackages = with pkgs; [
  git
  curl
  wget
];

# Good: Conditional packages
environment.systemPackages = with pkgs; [
  git
  curl
] ++ lib.optionals config.services.docker.enable [
  docker-compose
];

# Avoid: Mixing package sources without clear reason
# environment.systemPackages = [ pkgs.git pkgs-stable.curl ];
```

### Service Configuration
```nix
# Good: Complete service configuration
services.openssh = {
  enable = true;
  settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "no";
    Port = 22;
  };
  openFirewall = true;
};

# Good: Conditional service enabling
services.docker = {
  enable = true;
  enableOnBoot = lib.mkDefault true;
  rootless = {
    enable = true;
    setSocketVariable = true;
  };
};
```

### Variable and Option Naming
- **camelCase**: Use camelCase for attribute names
- **Descriptive**: Choose clear, descriptive names
- **Consistent**: Maintain consistency across modules
- **No Abbreviations**: Avoid unclear abbreviations

```nix
# Good: Clear naming
services.vscode-server = {
  enable = true;
  enableFHS = true;
};

# Avoid: Unclear abbreviations
# services.vsc-srv.en = true;
```

## WSL-Specific Guidelines

### WSL Configuration
```nix
# Good: WSL-specific module structure
{ nixos-wsl, userName, ... }:

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

### Windows Integration
- **Path Handling**: Use proper path handling for Windows/Linux boundaries
- **Certificates**: Handle Windows certificate stores appropriately
- **Performance**: Consider WSL2 performance implications

```nix
# Good: Certificate handling
security.pki.certificateFiles = [
  "/mnt/c/path/to/corporate-cert.crt"
];

# Good: WSL-aware configuration
environment.variables = {
  BROWSER = "/mnt/c/Program Files/Mozilla Firefox/firefox.exe";
};
```

## Error Handling and Validation

### Assertions and Warnings
```nix
# Good: Input validation
{ lib, config, ... }:

{
  assertions = [
    {
      assertion = config.services.docker.enable -> config.virtualisation.docker.enable;
      message = "Docker service requires virtualisation.docker.enable = true";
    }
  ];

  warnings = lib.optionals (!config.services.openssh.enable) [
    "SSH is disabled. Remote access will not be available."
  ];
}
```

### Option Definitions
```nix
# Good: Proper option definition with types and defaults
options = {
  services.myService = {
    enable = lib.mkEnableOption "my custom service";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.myPackage;
      description = "Package to use for my service";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Configuration settings for my service";
    };
  };
};
```

## Documentation Standards

### Comments
- **Purpose**: Explain why, not what
- **Clarity**: Use clear, concise language
- **Context**: Provide context for complex configurations

```nix
# Good: Explanatory comments
# Enable Docker with rootless mode for development containers
# This allows non-root users to manage containers safely
services.docker = {
  enable = true;
  rootless = {
    enable = true;
    setSocketVariable = true;
  };
};

# WSL-specific: Mount Windows drives for cross-platform development
fileSystems."/mnt/c" = {
  device = "C:";
  fsType = "drvfs";
  options = [ "metadata" "uid=1000" "gid=1000" ];
};
```

### Module Documentation
- **Header Comments**: Include purpose and dependencies
- **Option Documentation**: Document all custom options
- **Examples**: Provide usage examples where helpful

## Quality Assurance

### Required Checks
1. **Format**: Run `nix fmt` before committing
2. **Validate**: Run `nix flake check` to ensure validity
3. **Build Test**: Verify configuration builds successfully
4. **Lint**: Follow nixpkgs style guidelines

### Testing Guidelines
- **Incremental**: Test changes incrementally
- **Rollback**: Ensure easy rollback capability
- **Documentation**: Document test procedures
- **CI/CD**: Integrate checks into development workflow

## Common Patterns

### Conditional Configuration
```nix
# Good: Environment-based conditionals
config = lib.mkIf config.services.development.enable {
  environment.systemPackages = with pkgs; [
    git
    nodejs
    python3
  ];
};
```

### Package Overlays
```nix
# Good: Custom package overlay
nixpkgs.overlays = [
  (final: prev: {
    myCustomPackage = prev.callPackage ./packages/my-package.nix {};
  })
];
```

### Home Manager Integration
```nix
# Good: Home manager module structure
{ pkgs, userName, ... }:

{
  home-manager.users.${userName} = {
    programs.git = {
      enable = true;
      userName = "User Name";
      userEmail = "user@example.com";
    };
  };
}
```

---

*These standards ensure consistent, maintainable, and high-quality Nix code across the repository.*