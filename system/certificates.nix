{ lib, ... }:

let
  # Path to the ZScaler certificate file relative to the flake root
  certPath = ../certs/zscaler.pem;
  
  # Check if the certificate file exists and is not just a placeholder
  certExists = builtins.pathExists certPath;
  
  # Read the certificate file content to check if it's valid
  # A valid certificate should contain "BEGIN CERTIFICATE" or similar markers
  certContent = if certExists then builtins.readFile certPath else "";
  
  # Check if the certificate content looks like a real certificate
  # (not just a placeholder comment or empty file)
  isValidCert = certExists && 
    (lib.hasInfix "BEGIN CERTIFICATE" certContent || 
     lib.hasInfix "BEGIN TRUSTED CERTIFICATE" certContent ||
     lib.hasInfix "-----BEGIN" certContent) &&
    !(lib.hasInfix "placeholder" certContent);

in
{
  # Conditionally add the ZScaler certificate to the system PKI store
  # Only if the certificate file exists and appears to be a valid certificate
  security.pki.certificateFiles = lib.optionals isValidCert [
    certPath
  ];
  
  # Optional: Add a system-level indication that certificate management is active
  # This can be useful for debugging or system introspection
  environment.etc."nixos-certificates-info".text = lib.optionalString isValidCert ''
    ZScaler certificate automatically loaded from: ${toString certPath}
    Certificate validation: ${if isValidCert then "PASSED" else "FAILED"}
  '';
}
