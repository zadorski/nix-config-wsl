# Devenv WSL Optimizations

This document details the targeted enhancements implemented to optimize devenv configuration for WSL environments, addressing repository cleanliness, automated git configuration, and corporate certificate integration.

## 1. Repository Cleanliness Enhancement

### Problem
Devenv creates cache files and temporary directories that can clutter the repository and accidentally get committed to version control.

### Solution
Implemented comprehensive repository cleanliness measures:

#### A. External Cache Configuration
```nix
# devenv.nix
{
  # move devenv cache outside project directory
  cachix.enable = false;  # disable cachix integration to reduce cache files
  
  # configure devenv to use system-wide cache locations
  devenv = {
    root = "/home/nixos/.cache/devenv/nix-config-wsl";
    warnOnNewGeneration = false;  # reduce noise in repository
  };

  env = {
    # repository cleanliness: configure cache and temporary directories
    DEVENV_ROOT = "/home/nixos/.cache/devenv/nix-config-wsl";
    XDG_CACHE_HOME = "/home/nixos/.cache";
    DIRENV_LOG_FORMAT = "";  # reduce direnv logging noise
  };
}
```

#### B. Enhanced .gitignore Patterns
Added devenv-specific patterns to `.gitignore`:
```gitignore
# devenv development environment artifacts
.devenv/
.devenv.*
devenv.lock
.devenv.flake.nix
```

#### C. Benefits
- ✅ **Clean repository** - No devenv artifacts in project directory
- ✅ **Shared cache** - Efficient cache sharing across projects
- ✅ **Reduced noise** - Less logging and temporary file clutter
- ✅ **Version control safety** - Automatic exclusion of development artifacts

## 2. Automated Git Configuration Enhancement

### Problem
Development artifacts from devenv, direnv, and other tools can accidentally be staged and committed.

### Solution
Implemented automated global gitignore management through home-manager:

#### A. Global Gitignore Configuration
```nix
# home/development.nix
programs.git = {
  # global gitignore configuration for development artifacts
  ignores = [
    # devenv and development environment artifacts
    ".devenv/"
    ".devenv.*"
    "devenv.lock"
    ".devenv.flake.nix"
    
    # direnv artifacts
    ".direnv/"
    ".envrc.cache"
    
    # nix build artifacts
    "result"
    "result-*"
    ".result"
    ".nix-gc-roots"
    ".nix-profile"
    ".nix-eval-cache"
    
    # development caches and temporary files
    ".cache/"
    "node_modules/"
    "__pycache__/"
    ".pytest_cache/"
    ".mypy_cache/"
    ".tox/"
    ".coverage"
    ".nyc_output/"
    "dist/"
    "build/"
    "target/"
    
    # editor artifacts
    ".vscode/settings.json"
    ".vscode/launch.json"
    ".vscode/tasks.json"
    ".idea/"
    "*.swp"
    "*.swo"
    "*~"
    
    # temporary files
    "*.tmp"
    "*.temp"
    ".backup/"
    ".git-backup/"
    
    # logs
    "*.log"
    "npm-debug.log*"
    "yarn-debug.log*"
    "yarn-error.log*"
    
    # OS artifacts
    ".DS_Store"
    "Thumbs.db"
    
    # language-specific artifacts
    "*.pyc"
    "*.pyo"
    "*.pyd"
    "*.class"
    "*.o"
    "*.a"
    "*.so"
    "*.exe"
    "*.dll"
  ];

  extraConfig = {
    # automatically exclude devenv and development artifacts
    core.excludesfile = "~/.config/git/ignore";
  };
};
```

#### B. Benefits
- ✅ **Automatic exclusion** - Development artifacts never accidentally staged
- ✅ **Portable configuration** - Works across all WSL instances
- ✅ **Comprehensive coverage** - Covers all common development tools
- ✅ **Home-manager integration** - Managed declaratively with other configurations

## 3. Corporate Certificate Integration Enhancement

### Problem
Corporate environments (like Zscaler) require custom certificates, and devenv may not inherit these properly, causing SSL handshake failures.

### Solution
Enhanced certificate integration at both system and devenv levels:

#### A. System-Level Certificate Enhancement
```nix
# system/certificates.nix
environment.variables = lib.mkIf isValidCert {
  # primary SSL certificate file for most applications
  SSL_CERT_FILE = systemCertBundle;
  NIX_SSL_CERT_FILE = systemCertBundle;
  CURL_CA_BUNDLE = systemCertBundle;
  REQUESTS_CA_BUNDLE = systemCertBundle;
  NODE_EXTRA_CA_CERTS = systemCertBundle;

  # additional certificate variables for development environments
  DEVENV_SSL_CERT_FILE = systemCertBundle;
  
  # language-specific package managers
  PIP_CERT = systemCertBundle;                    # Python pip
  CARGO_HTTP_CAINFO = systemCertBundle;           # Rust cargo
  GOPATH_CERT_FILE = systemCertBundle;            # Go modules
  JAVA_OPTS = "-Djavax.net.ssl.trustStore=${systemCertBundle}";  # Java applications
  
  # development tools
  GIT_SSL_CAINFO = systemCertBundle;              # Git operations
  DOCKER_CERT_PATH = systemCertBundle;            # Docker operations
};
```

#### B. Devenv Certificate Configuration
```nix
# devenv.nix
env = {
  # certificate handling: inherit from system configuration
  SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
  NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
  CURL_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
  REQUESTS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
  NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
  
  # additional certificate variables for comprehensive coverage
  PIP_CERT = "/etc/ssl/certs/ca-certificates.crt";
  CARGO_HTTP_CAINFO = "/etc/ssl/certs/ca-certificates.crt";
  GIT_SSL_CAINFO = "/etc/ssl/certs/ca-certificates.crt";
  
  # ensure devenv respects system certificates
  DEVENV_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
};
```

#### C. Benefits
- ✅ **Seamless SSL handling** - All tools respect corporate certificates
- ✅ **Comprehensive coverage** - Supports all major language package managers
- ✅ **System integration** - Leverages existing certificate configuration
- ✅ **Development tool support** - Git, Docker, and other tools work correctly

## Implementation Summary

### Files Modified
1. **`devenv.nix`** - Added cache configuration and certificate variables
2. **`.gitignore`** - Added devenv-specific exclusion patterns
3. **`home/development.nix`** - Added global gitignore configuration
4. **`system/certificates.nix`** - Enhanced certificate variable coverage

### Integration Points
- **Home-manager** - Git configuration managed declaratively
- **System configuration** - Certificate handling at OS level
- **Devenv** - Environment inherits system certificate configuration
- **WSL** - Optimized for WSL-specific performance characteristics

### Testing Validation
```bash
# Test certificate configuration
curl -I https://github.com  # Should work without SSL errors

# Test git operations
git clone https://github.com/user/repo  # Should work with corporate proxy

# Test package managers
npm install package  # Should work through corporate firewall
pip install package  # Should respect corporate certificates

# Test devenv environment
devenv shell  # Should activate without SSL errors
```

## Best Practices Implemented

1. **Separation of Concerns** - User-specific vs project-shared configuration
2. **Declarative Management** - All configuration managed through Nix
3. **Corporate Compatibility** - Full support for enterprise environments
4. **Performance Optimization** - WSL-specific optimizations
5. **Maintainability** - Single source of truth for certificate configuration

## Troubleshooting

### Certificate Issues
```bash
# Verify certificate configuration
echo $SSL_CERT_FILE
ls -la /etc/ssl/certs/ca-certificates.crt

# Test certificate validation
openssl s_client -connect github.com:443 -CAfile $SSL_CERT_FILE
```

### Repository Cleanliness
```bash
# Check for devenv artifacts
find . -name ".devenv*" -o -name "devenv.lock"

# Verify gitignore is working
git status --ignored
```

### Performance Monitoring
```bash
# Check cache usage
du -sh ~/.cache/devenv/

# Monitor environment activation time
time devenv shell --command "echo 'Environment ready'"
```

These optimizations ensure devenv provides a clean, efficient, and corporate-compatible development environment for WSL users.
