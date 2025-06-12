# Enhance NixOS WSL Development Startup Experience

**Date:** 2025-01-27  
**Status:** In Progress  
**Priority:** High  
**Category:** Development Environment Enhancement

## Objective

Enhance the NixOS WSL development startup experience by implementing Fish shell session management, SSH key management with keychain, enhanced directory listing with eza, and curated development environment variables.

## Context

The current nix-config-wsl setup provides a solid foundation with Fish shell, Starship prompt, and basic development tools. However, the startup experience can be improved with:

1. **Session Management**: Fish shell currently starts fresh without session restoration
2. **SSH Key Management**: Manual SSH key loading creates friction in development workflows
3. **Directory Listing**: Basic eza configuration lacks development-optimized table view
4. **Environment Variables**: Minimal environment setup misses productivity opportunities

## Implementation Strategy

### 1. Fish Shell Session Management
- **Approach**: Implement session restoration to continue from last working directory
- **Fallback**: Default to home directory when no previous session exists
- **Compatibility**: Maintain existing Fish/Starship/direnv integration
- **Performance**: Optimize for WSL environment constraints

### 2. SSH Key Management with Keychain
- **Tool**: Integrate keychain utility for automatic SSH key loading
- **Configuration**: Auto-load keys on startup without repeated passphrase prompts
- **Compatibility**: Ensure Azure DevOps SSH access requirements are met
- **Security**: Maintain secure key handling practices

### 3. Enhanced Eza Configuration
- **Format**: Table-style output with development-relevant columns
- **Information**: Display permissions, size, modified time, git status
- **Style**: Lightweight table format without heavy borders
- **Accessibility**: Maintain Catppuccin Mocha color scheme with WCAG 2.1 compliance
- **Performance**: Balance information density vs readability

### 4. Development Environment Variables
- **Scope**: Focus on Docker, Git, development tools, WSL-specific optimizations
- **Balance**: Comprehensive coverage without configuration bloat
- **Modularity**: Use lib.mkIf patterns for conditional loading

## Technical Implementation

### Files Modified
1. **`home/shells.nix`** - Session management, keychain, environment variables
2. **`home/development.nix`** - Enhanced eza configuration, keychain package
3. **`system/README.md`** - User guidance and troubleshooting

### Key Features Implemented
- Fish shell session restoration with home directory fallback
- Keychain integration for seamless SSH key management
- Enhanced eza table view with development-optimized columns
- Curated environment variables for productivity enhancement
- Modular configuration with conditional loading patterns

## Expected Benefits

1. **Improved Workflow Continuity**: Session restoration reduces context switching
2. **Seamless SSH Access**: Automatic key loading eliminates authentication friction
3. **Enhanced File Navigation**: Rich directory information aids development tasks
4. **Optimized Environment**: Curated variables boost productivity without bloat

## Testing Strategy

1. **Session Management**: Verify directory restoration and home fallback
2. **SSH Integration**: Test keychain loading and Azure DevOps access
3. **Directory Listing**: Validate eza table output and color compliance
4. **Environment Variables**: Confirm variable availability and values
5. **Performance**: Ensure WSL startup time remains acceptable

## Documentation

- Task documentation in `.ai/tasks/doing/`
- User guidance in `system/README.md`
- Implementation rationale and troubleshooting included
- WCAG 2.1 accessibility compliance documented

## Implementation Details

### Fish Shell Session Management
- **File**: `home/shells.nix`
- **Feature**: Session restoration with `~/.config/fish/last_dir` state file
- **Behavior**: Restores last working directory or defaults to home
- **Integration**: Compatible with existing Fish/Starship/direnv setup

### SSH Key Management
- **Package**: Added `keychain` to `home/development.nix`
- **Configuration**: Auto-loads `id_maco`, `id_rsa`, `id_ed25519` keys
- **Compatibility**: Supports GitHub and Azure DevOps authentication
- **Security**: Uses SSH agent integration for secure key handling

### Enhanced Eza Configuration
- **Commands**: `ls`, `ll`, `la`, `lld`, `tree`, `treed` with development focus
- **Information**: Permissions, size, relative timestamps, git status
- **Format**: Clean table layout without heavy borders
- **Accessibility**: Maintains Catppuccin Mocha WCAG 2.1 compliance

### Development Environment Variables
- **Scope**: Editor, Docker, Git, WSL, development tools
- **Balance**: 15 curated variables for productivity enhancement
- **Performance**: Conditional loading with lib.mkIf patterns
- **Integration**: Seamless with existing devenv/Docker workflows

## Success Criteria

- [x] Fish shell restores last working directory or defaults to home
- [x] SSH keys load automatically without repeated prompts
- [x] Eza displays development-relevant information in clean table format
- [x] Environment variables enhance productivity without bloat
- [x] All configurations maintain WSL performance optimizations
- [x] Documentation provides clear usage instructions and troubleshooting

## Testing Commands

After rebuilding the NixOS configuration, test the enhancements:

### Session Management Testing
```bash
# Test directory restoration
cd ~/projects
exit
# New shell should start in ~/projects

# Test fallback behavior
echo "/nonexistent/path" > ~/.config/fish/last_dir
exit
# New shell should start in home directory
```

### SSH Key Management Testing
```bash
# Verify keychain is loaded
keychain -l

# Test SSH connections
ssh -T git@github.com
ssh -T git@ssh.dev.azure.com
```

### Eza Configuration Testing
```bash
# Test enhanced directory listings
ls          # basic with icons and git
ll          # detailed table view
la          # comprehensive with hidden files
lld         # full development view
tree        # project structure
treed       # detailed tree view
```

### Environment Variables Testing
```bash
# Verify development environment
echo $EDITOR $DOCKER_BUILDKIT $BAT_THEME
env | grep -E "(GIT_|DOCKER_|BAT_)"
```

## Notes

- Implementation follows modular NixOS configuration patterns
- Maintains compatibility with existing devenv and Docker workflows
- Preserves Catppuccin Mocha theme with accessibility standards
- Balances feature richness with lean configuration philosophy
- All features use conditional loading for optimal performance
