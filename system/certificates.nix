{ lib, ... }:
let
  windows-certs-2-wsl-dir = /mnt/c/Users/8J5204897/Documents/git/windows-certs-2-wsl;
  certDir = "${windows-certs-2-wsl-dir}/all-certificates"; # run `.\get-all-certs.ps1` from https://github.com/bayaro/windows-certs-2-wsl
in
{
  # standard way causes issue due to `ca-certificates.crt` found in the folder
  #security.pki.certificateFiles = lib.filesystem.listFilesRecursive "${certDir}";

  # list only the *.pem files per https://discourse.nixos.org/t/how-to-use-a-wildcard-in-a-path-expression/51083/6
  security.pki.certificateFiles = lib.pipe "${certDir}" [
    builtins.readDir
    (lib.filterAttrs (name: _: lib.hasSuffix ".pem" name))
    (lib.mapAttrsToList (name: _: "${certDir}" + "/${name}"))
  ];  
}