{ lib, ... }:

let
  certPath = ../certs/zscaler.pem;
  
  certExists = builtins.pathExists certPath;
  
  certContent = if certExists then builtins.readFile certPath else "";
  
  isValidCert = certExists && 
    (lib.hasInfix "BEGIN CERTIFICATE" certContent || 
     lib.hasInfix "BEGIN TRUSTED CERTIFICATE" certContent ||
     lib.hasInfix "-----BEGIN" certContent) &&
    !(lib.hasInfix "placeholder" certContent);

in
{
  # conditionally add the zscaler certificate to the system PKI store
  security.pki.certificateFiles = lib.optionals isValidCert [
    certPath
  ];
  
  environment.etc."nixos-certificates-info".text = lib.optionalString isValidCert ''
    ZScaler certificate automatically loaded from: ${toString certPath}
    Certificate validation: ${if isValidCert then "PASSED" else "FAILED"}
  '';
}
