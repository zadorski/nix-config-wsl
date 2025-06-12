{ lib, pkgs, ... }:

let
  certPath = ../certs/zscaler.pem;
  
  certExists = builtins.pathExists certPath;
  
  certContent = if certExists then builtins.readFile certPath else "";
  
  isValidCert = certExists &&
    (lib.hasInfix "BEGIN CERTIFICATE" certContent ||
     lib.hasInfix "BEGIN TRUSTED CERTIFICATE" certContent ||
     lib.hasInfix "-----BEGIN" certContent) &&
    !(lib.hasInfix "placeholder" certContent);

  # system certificate bundle location (standard NixOS path)
  systemCertBundle = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

in
{
  # conditionally add the ZScaler certificate to the system PKI store
  # only if the certificate file exists and appears to be a valid certificate
  security.pki.certificateFiles = lib.optionals isValidCert [
    certPath
  ];

  # configure SSL certificate environment variables for Nix and development tools
  # these variables ensure that nix-shell environments can access corporate certificates
  environment.variables = lib.mkIf isValidCert {
    # primary SSL certificate file for most applications
    SSL_CERT_FILE = systemCertBundle;

    # Nix-specific certificate configuration
    NIX_SSL_CERT_FILE = systemCertBundle;

    # curl-based operations (used by many package managers)
    CURL_CA_BUNDLE = systemCertBundle;

    # Python requests library certificate bundle
    REQUESTS_CA_BUNDLE = systemCertBundle;

    # Node.js certificate configuration
    NODE_EXTRA_CA_CERTS = systemCertBundle;
  };

  # system-level indication that certificate management is active
  # useful for debugging and verifying certificate configuration
  environment.etc."nixos-certificates-info".text = lib.optionalString isValidCert ''
    ZScaler certificate automatically loaded from: ${toString certPath}
    Certificate validation: ${if isValidCert then "PASSED" else "FAILED"}
    System certificate bundle: ${systemCertBundle}

    Environment variables configured:
    - SSL_CERT_FILE=${systemCertBundle}
    - NIX_SSL_CERT_FILE=${systemCertBundle}
    - CURL_CA_BUNDLE=${systemCertBundle}
    - REQUESTS_CA_BUNDLE=${systemCertBundle}
    - NODE_EXTRA_CA_CERTS=${systemCertBundle}
  '';
}
