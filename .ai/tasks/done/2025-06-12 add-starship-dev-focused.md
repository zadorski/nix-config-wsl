# Starship Prompt Configuration for NixOS-WSL Development Environment

## Overview

This task implements a comprehensive Starship prompt configuration optimized for development workflows in the NixOS-WSL environment. The configuration focuses on providing essential development information while maintaining fast performance suitable for WSL terminals.

## Implementation Approach

### 1. Package Installation
- Add `starship` package to `home/default.nix` via `home.packages`
- Leverage existing Fish shell integration placeholder in `home/shells/default.nix`
- Ensure proper initialization in Fish interactive sessions

### 2. Configuration Strategy
- Create dedicated `home/starship.toml` configuration file
- Focus on development-essential features while maintaining WSL performance
- Use minimal resource consumption to avoid terminal slowdowns
- Implement clear, beginner-friendly configuration with comprehensive comments

### 3. Key Features Implemented

#### Development-Focused Elements
- **Git Integration**: Branch name, status indicators (staged/unstaged/ahead/behind)
- **Language Versions**: Node.js, Python, Rust, Go, Java, and other common development languages
- **Docker Context**: Show current Docker context when relevant
- **Directory Display**: Intelligent truncation for deep project structures
- **Command Feedback**: Execution time for long-running commands, exit code indicators
- **Nix Environment**: Show when in nix-shell or development environments

#### WSL Optimizations
- **Fast Rendering**: Minimal modules enabled to reduce prompt generation time
- **Resource Efficiency**: Disabled resource-intensive features like battery, hostname
- **Path Handling**: Optimized for Windows/Linux path integration
- **Terminal Compatibility**: Tested for common WSL terminal emulators

### 4. Configuration Sections

#### Core Prompt Behavior
```toml
# Fast command timeout for WSL performance
command_timeout = 1000
# Clean single-line prompt for terminal efficiency
add_newline = false
```

#### Git Status Indicators
```toml
[git_branch]
symbol = " "
format = "[$symbol$branch]($style) "

[git_status]
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
staged = "[+${count}](green)"
modified = "[~${count}](yellow)"
untracked = "[?${count}](red)"
```

#### Language Version Display
- Node.js: Shows version when package.json present
- Python: Shows version when in Python project
- Rust: Shows version when Cargo.toml present
- Go: Shows version when go.mod present
- Java: Shows version when pom.xml or build.gradle present

#### Performance Optimizations
- Disabled battery indicator (not relevant for WSL)
- Disabled hostname (WSL context is clear)
- Fast command duration threshold (>2s)
- Minimal directory truncation

## Configuration Files

### Primary Files
1. `home/starship.toml` - Main Starship configuration
2. `home/default.nix` - Updated to include Starship package
3. `home/shells/default.nix` - Fish integration (already prepared)

### Integration Points
- Fish shell automatically initializes Starship when available
- Configuration file placed in standard XDG config location
- Home-manager manages the configuration file deployment

## Development Scenarios

### Example Prompt Displays

1. **Basic Directory Navigation**
   ```
   ~/projects/my-app  
   ```

2. **Git Repository with Changes**
   ```
   ~/projects/my-app  main +2 ~1 ?3 
   ```

3. **Node.js Project**
   ```
   ~/projects/web-app  main  v18.17.0 
   ```

4. **Multiple Languages**
   ```
   ~/projects/full-stack  main  v18.17.0  3.11.0  1.21.0 
   ```

5. **Long Command Execution**
   ```
   ~/projects/my-app  main  took 5s 
   ```

6. **Command Failure**
   ```
   ~/projects/my-app  main ✗ 
   ```

## Performance Considerations

### WSL-Specific Optimizations
- **Command Timeout**: Set to 1000ms to prevent hanging in slow WSL environments
- **Module Selection**: Only essential modules enabled to reduce startup time
- **Caching**: Leverages Starship's built-in caching for repeated information
- **Async Loading**: Language version detection runs asynchronously when possible

### Resource Usage
- **Memory**: Minimal impact due to selective module loading
- **CPU**: Optimized for quick prompt generation
- **I/O**: Reduced filesystem checks through smart module configuration

## Customization Options

### User Customization Points
1. **Color Scheme**: Easy to modify colors in configuration file
2. **Module Selection**: Simple to enable/disable specific language modules
3. **Symbol Customization**: All symbols clearly documented and customizable
4. **Timeout Adjustment**: Command timeout can be adjusted based on system performance

### Extension Possibilities
- Additional language support can be easily added
- Cloud provider context (AWS, Azure, GCP) modules available
- Kubernetes context support for container development
- Custom modules for project-specific information

## Testing and Validation

### Verification Steps
1. **Installation Check**: Verify Starship package is available in PATH
2. **Configuration Loading**: Confirm starship.toml is read correctly
3. **Fish Integration**: Test prompt appears in Fish interactive sessions
4. **Feature Testing**: Validate Git, language, and directory features
5. **Performance Testing**: Ensure prompt generation is fast in WSL environment

### Common Development Scenarios
- Git repository navigation and status display
- Multi-language project development
- Docker container development workflows
- Long-running command execution feedback
- Error handling and exit code display

## Integration with Existing Configuration

### Compatibility
- **Fish Shell**: Seamlessly integrates with existing Fish configuration
- **Bash Fallback**: Works if user switches to bash interactive mode
- **Home-manager**: Properly managed through Nix configuration
- **WSL Environment**: Optimized for WSL-specific considerations

### Minimal Impact
- No changes to existing shell behavior
- Maintains current Fish abbreviations and customizations
- Preserves existing development workflow
- Adds value without complexity

This implementation enhances the development experience while maintaining the foundational, minimal approach established in the NixOS-WSL configuration.

## Implementation Status: ✅ COMPLETED

### Files Created/Modified

1. **`.ai/tasks/doing/2025-06-12 add-starship-config.md`** - This task documentation
2. **`home/starship.toml`** - Comprehensive Starship configuration optimized for WSL development
3. **`home/default.nix`** - Updated to include Starship package and XDG configuration management
4. **`home/shells.nix`** - Enhanced Fish shell integration comments (Starship integration was already present)

### Key Implementation Details

#### Starship Package Installation
- Added `starship` to `home.packages` in `home/default.nix`
- Configured XDG config file management for `starship.toml`
- Leveraged existing Fish shell integration in `home/shells.nix`

#### Configuration Highlights
- **Performance Optimized**: 1000ms command timeout for WSL compatibility
- **Development Focused**: Git status, language versions, Docker context, Nix shell indicators
- **WSL Specific**: Disabled battery, hostname, and other irrelevant modules
- **Comprehensive Language Support**: Node.js, Python, Rust, Go, Java, C/C++, PHP, Ruby, and more
- **Clean Prompt Design**: Single-line format with clear status indicators

#### Testing Results
- ✅ `nix flake check` passes successfully
- ✅ Starship configuration validates correctly
- ✅ No diagnostic issues found
- ✅ All files properly integrated with existing configuration

### Usage Instructions

After applying this configuration:

1. **Rebuild the system**: `nixos-rebuild switch --flake .#nixos`
2. **Start a new Fish session**: The Starship prompt will automatically activate
3. **Navigate to Git repositories**: See branch and status information
4. **Work in development projects**: Language versions will display automatically
5. **Run long commands**: Execution time will be shown for commands >2 seconds

### Customization Points

Users can easily customize the prompt by editing `home/starship.toml`:
- **Colors**: Modify style attributes for different modules
- **Symbols**: Change icons and indicators to personal preference
- **Modules**: Enable/disable specific language or context modules
- **Timeout**: Adjust command timeout based on system performance

The implementation successfully provides a modern, informative development prompt while maintaining the minimal, beginner-friendly approach of the NixOS-WSL configuration.
