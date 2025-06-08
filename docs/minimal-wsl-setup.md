# Minimal NixOS WSL Setup Guide

This guide helps you set up a minimal NixOS environment on WSL using the provided Flake configuration. This setup is designed to be a lean base for development, which you can extend with additional tools and services as needed.

## Prerequisites

*   Windows 10/11 with WSL installed and a WSL distribution (e.g., Ubuntu) set up.
*   Nix package manager installed in your WSL distribution. Follow the official instructions at [https://nixos.org/download.html](https://nixos.org/download.html) (multi-user installation is recommended).

## Initial Setup

1.  **Clone the Repository:**
    Clone this repository to a location on your Windows machine that is accessible from your WSL distribution (e.g., `C:\Users\YourUser\projects\nix-config-wsl`). Let's assume it's cloned to `~/projects/nix-config-wsl` from within WSL.

    ```bash
    # Example path, adjust as needed
    git clone <your-repo-url> ~/projects/nix-config-wsl
    cd ~/projects/nix-config-wsl
    ```

2.  **Build the NixOS WSL Configuration:**
    From within the repository directory in your WSL shell, run:

    ```bash
    # This command builds the NixOS configuration defined in flake.nix
    # The configuration name is 'nixos' (as defined in flake.nix: nixosConfigurations.nixos)
    nixos-rebuild switch --flake .#nixos
    ```
    This process might take some time as it downloads and builds all the necessary packages.

3.  **Accessing Your NixOS WSL Environment:**
    Once the build is complete, you can access your NixOS environment. If you are using the standard NixOS-WSL setup, it should register itself as a new WSL distribution. You can list your WSL distributions with `wsl -l -v`.

    To log in:
    ```bash
    wsl -d nixos
    ```

## VS Code Remote Server Integration

This configuration includes the VS Code Server for a seamless remote development experience.

1.  Ensure you have the [Remote - WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl) extension installed in VS Code on your Windows machine.
2.  Open VS Code.
3.  Click on the green "Open a Remote Window" button in the bottom-left corner of the VS Code window.
4.  Select "Connect to WSL".
5.  If `nixos` is your default WSL distribution or already running, it might connect automatically. Otherwise, choose `nixos` from the list of distributions.
6.  You can then open folders within your NixOS environment (e.g., `/home/nixos/your_project`).

## Configuring Custom Root Certificates (e.g., ZScaler)

For corporate environments or when dealing with custom CAs, you might need to add root certificates.

1.  **Place Certificate Files:**
    Copy your certificate files (e.g., `.crt`, `.pem` files) to a location on your Windows C: drive that is accessible from WSL. A common practice is to create a dedicated folder, for example: `C:\certs\`. From WSL, this would typically be accessible via `/mnt/c/certs/`.

2.  **Update NixOS Configuration:**
    *   Open `system/certificates.nix` in your cloned repository.
    *   Locate the `security.pki.certificateFiles` option. It will be commented out by default.
    *   Uncomment the line and add the paths to your certificate files. For example:
        ```nix
        security.pki.certificateFiles = [
          /mnt/c/certs/zscaler.crt
          /mnt/c/certs/my_corporate_ca.pem
        ];
        ```
    *   Save the file.

3.  **Rebuild the System:**
    After updating `system/certificates.nix`, rebuild your NixOS WSL configuration:
    ```bash
    nixos-rebuild switch --flake .#nixos
    ```

## Extending Your Minimal Setup

This configuration is minimal by design. Here’s how to add common tools and services:

### Enabling Docker

1.  **Uncomment Docker Module:**
    Open `system/default.nix`. Add `./docker.nix` back to the `imports` array:
    ```nix
    imports = [
      ./wsl.nix
      ./vscode-server.nix
      ./nix.nix
      ./users.nix
      ./ssh.nix
      ./shells.nix
      ./certificates.nix # Ensure this is also present
      ./docker.nix       # Add this line
    ];
    ```

2.  **Review `system/docker.nix`:**
    The `system/docker.nix` file should contain settings like `virtualisation.docker.enable = true;`. You might want to add your user to the `docker` group by adding `users.users.<yourUserName>.extraGroups = [ "docker" ];` to `system/users.nix` (or directly in `system/docker.nix` if structured that way).

3.  **Rebuild:**
    ```bash
    nixos-rebuild switch --flake .#nixos
    ```

### Enabling Podman (Alternative to Docker)

1.  **Create or Adapt `system/podman.nix`:**
    You can create a `system/podman.nix` file. A basic configuration might look like this (refer to `docs/podman.nix` for a more detailed example if available):
    ```nix
    # system/podman.nix
    { pkgs, ... }:
    {
      virtualisation.podman = {
        enable = true;
        # To enable rootless Docker-compatible socket
        dockerCompat = true;
        # Add users to the podman group if needed, or configure default user namespaces
      };
      # Example: ensure your user can run rootless podman
      users.users.nixos.extraGroups = [ "podman" ]; # Replace 'nixos' with your actual username
    }
    ```

2.  **Import in `system/default.nix`:**
    Add `./podman.nix` to the `imports` in `system/default.nix`.

3.  **Rebuild:**
    ```bash
    nixos-rebuild switch --flake .#nixos
    ```

### Adding Development Tools (e.g., Python, Node.js)

You can add packages system-wide or manage them per-project using Nix shells or Home Manager.

*   **System-wide (via `system/default.nix`):**
    Edit `environment.systemPackages` in `system/default.nix`:
    ```nix
    environment.systemPackages = with pkgs; [
      git
      curl
      wget
      # Add more packages here
      python3
      nodejs_20 # Check available versions with `nix search nodejs`
    ];
    ```

*   **User-specific (via `home/default.nix` using Home Manager):**
    Edit `home.packages` in `home/default.nix`:
    ```nix
    home.packages = with pkgs; [
      # Add user-specific packages here
      neovim
      ripgrep
    ];
    ```

After making changes, always rebuild your system: `nixos-rebuild switch --flake .#nixos`.

## Shell Configuration: Bash (Login) and Fish (Interactive)

For optimal stability and compatibility with WSL, your default login shell is **Bash**.

However, for a more user-friendly and feature-rich interactive experience, **Fish shell** is configured and will start automatically when you open a new terminal. Fish offers excellent features like:

*   **Smart auto-completion:** Suggests commands based on history and context.
*   **Syntax highlighting:** Helps catch errors before running commands.
*   **User-friendly scripting:** Simpler and more intuitive than Bash for many common tasks.
*   **No configuration needed by default:** Works great out of the box.

**Customizing Fish:**
You can further customize Fish (e.g., add plugins, change prompts, set abbreviations) by modifying the `programs.fish` section in your `home/shells/default.nix` file. After making changes, rebuild your system:
`nixos-rebuild switch --flake .#nixos`

If you need to access a pure Bash session (without Fish starting automatically), you might explore options like `bash --norc` or temporarily commenting out the `initExtra` line in `home/shells/default.nix` and rebuilding. However, for most interactive work, Fish should provide a superior experience.
```
