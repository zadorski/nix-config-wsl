#!/usr/bin/env bash
# Legacy startup script - replaced by nix-setup.sh
# This file is kept for backward compatibility but is no longer used
# The new setup leverages Nix home-manager for configuration management

set -e

echo "Legacy startup script detected."
echo "This setup has been replaced by a Nix-based configuration."
echo "Please use nix-setup.sh for the new simplified setup."
echo ""
echo "If you need the old functionality, it can be found in the git history."
echo "The new setup provides the same functionality with better maintainability."

# ensure git safe directory is configured (essential for container operation)
git config --global --add safe.directory "/workspaces/*" || true

echo "Minimal compatibility setup complete."
echo "Run 'exec fish' to start using the configured shell."