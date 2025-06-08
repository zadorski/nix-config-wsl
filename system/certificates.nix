{ pkgs, ... }:

{
  # System-wide CA certificates
  # Users should place their custom root certificates (e.g., ZScaler, corporate CAs)
  # in a directory accessible from WSL, for example, /mnt/c/certs/
  # Then, list them here.
  # Example:
  # security.pki.certificateFiles = [
  #   /mnt/c/certs/zscaler.crt
  #   /mnt/c/certs/mycorp-ca.pem
  # ];
  #
  # By default, no extra certificates are added.
  # Users need to uncomment and customize the following line:
  # security.pki.certificateFiles = [ ];

  # To ensure the directory for certificates is available if needed through nix store.
  # This is more of a placeholder, actual certs are usually outside the store.
  environment.systemPackages = [ pkgs.cacert ]; # Provides /etc/ssl/certs/ca-bundle.crt
}
