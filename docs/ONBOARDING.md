# Quick Onboarding

Follow these steps to get a minimal NixOS environment in WSL.

1. clone the repository and enter the directory
2. run `nixos-rebuild switch --flake .#nixos`
3. connect with VS Code Remote WSL to start working

copy the company root certificate to `certs/zscaler.pem` so the system can import it.

Store secrets only in your home directory after the first login.
the system starts bash for login and switches to fish for interactive use.
