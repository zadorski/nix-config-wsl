# Fix Shell and Bat Configuration Issues

**Date**: 2025-01-13  
**Status**: Completed  
**Type**: Configuration Fix

## Problem Statement

Two configuration issues needed resolution:

1. **Shell Configuration**: `echo $SHELL` returned `/bin/bash` instead of fish, despite fish being configured as the interactive shell
2. **Bat Theme Warning**: `cat`/`bat` commands showed warning: `[bat warning]: Unknown theme 'Catppuccin-mocha', using default.`

## Root Cause Analysis

### Shell Issue
- User login shell was set to `pkgs.bashInteractive` in `system/users.nix`
- Fish was configured only at home-manager level with bash-to-fish exec switching
- System-level fish was not enabled, causing PATH integration issues

### Bat Theme Issue  
- `catppuccin-bat` parameter was not being passed to `home/development.nix`
- Theme loading was conditional but the condition was never met
- Module parameter chain was incomplete

## Solution Implementation

### 1. Shell Configuration Fix

**File**: `system/users.nix`
- Changed user shell from `pkgs.bashInteractive` to `pkgs.fish`
- Updated comments to reflect fish as default interactive shell

**File**: `system/shells.nix`  
- Added `programs.fish.enable = true` for system-wide fish support
- Updated comments to clarify bash remains available for scripts
- Maintained bash as system default for compatibility

**File**: `home/shells.nix`
- Removed bash-to-fish exec switching logic
- Simplified bash configuration for script compatibility
- Fish remains primary interactive shell with full configuration

### 2. Bat Theme Configuration Fix

**File**: `home/default.nix`
- Added catppuccin theme parameters to module signature
- Fixed parameter passing to `development.nix` module
- Used explicit import with parameter passing

## Technical Details

### Shell Architecture
```
System Level:
- programs.fish.enable = true (PATH integration)
- users.defaultUserShell = pkgs.bash (system scripts)
- Individual user shell = pkgs.fish (interactive use)

User Level:
- Fish: Primary interactive shell with full configuration
- Bash: Available for scripts and fallback scenarios
```

### Theme Integration
```
Flake Inputs → home/default.nix → home/development.nix
catppuccin-bat parameter properly passed through module chain
```

## Validation Results

### Configuration Validation
```bash
nix flake check  # ✅ Passes all checks
```

### Expected Behavior After Deployment
```bash
echo $SHELL          # Should show fish path
bat --version        # Should work without theme warnings
cat some_file        # Should use Catppuccin-mocha theme
```

## Benefits

1. **Improved User Experience**: Fish as default shell with proper $SHELL variable
2. **System Stability**: Bash remains available for scripts and system operations  
3. **Consistent Theming**: Bat uses Catppuccin-mocha theme without warnings
4. **Nix Best Practices**: Proper module parameter passing and system integration

## Files Modified

- `system/users.nix` - User shell configuration
- `system/shells.nix` - System-wide shell enablement  
- `home/shells.nix` - Shell initialization logic
- `home/default.nix` - Module parameter passing

## Testing Recommendations

1. **Shell Testing**: Verify `$SHELL` variable and fish functionality
2. **Script Compatibility**: Test bash scripts still execute properly
3. **Theme Testing**: Verify bat displays with Catppuccin-mocha theme
4. **System Integration**: Ensure nix operations work correctly

## Notes

- Changes maintain backward compatibility with existing scripts
- Fish PATH integration handled by system-level enablement
- Bash remains available as fallback shell
- Theme loading is conditional and gracefully handles missing themes
