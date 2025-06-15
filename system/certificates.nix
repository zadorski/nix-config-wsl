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

    # Python ecosystem certificate configuration
    REQUESTS_CA_BUNDLE = systemCertBundle;          # Python requests library
    PIP_CERT = systemCertBundle;                    # Python pip package manager
    PYTHONHTTPSVERIFY = "1";                        # enable Python SSL verification
    PYTHONCASSLDEFAULTPATH = systemCertBundle;      # Python SSL default path

    # Node.js ecosystem certificate configuration
    NODE_EXTRA_CA_CERTS = systemCertBundle;         # Node.js runtime
    NPM_CONFIG_CAFILE = systemCertBundle;           # npm package manager
    YARN_CAFILE = systemCertBundle;                 # Yarn package manager

    # Rust ecosystem certificate configuration
    CARGO_HTTP_CAINFO = systemCertBundle;           # Rust cargo package manager
    RUSTUP_USE_CURL = "1";                          # use curl for rustup (respects CURL_CA_BUNDLE)

    # Go ecosystem certificate configuration
    GOPATH_CERT_FILE = systemCertBundle;            # Go modules (legacy)
    GOPROXY_CERT_FILE = systemCertBundle;           # Go proxy certificate file
    GOSUMDB_CERT_FILE = systemCertBundle;           # Go checksum database

    # Java ecosystem certificate configuration
    JAVA_OPTS = "-Djavax.net.ssl.trustStore=${systemCertBundle}";  # Java applications
    MAVEN_OPTS = "-Djavax.net.ssl.trustStore=${systemCertBundle}"; # Maven build tool
    GRADLE_OPTS = "-Djavax.net.ssl.trustStore=${systemCertBundle}"; # Gradle build tool

    # development tools certificate configuration
    GIT_SSL_CAINFO = systemCertBundle;              # Git operations
    # DOCKER_CERT_PATH removed - should point to directory, not file
    # Docker will use SSL_CERT_FILE and CURL_CA_BUNDLE for certificate validation
    DOCKER_TLS_VERIFY = "1";                        # enable Docker TLS verification

    # additional certificate variables for development environments
    # ensures devenv and other development tools can access certificates
    DEVENV_SSL_CERT_FILE = systemCertBundle;

    # modern package managers and tools
    DENO_CERT = systemCertBundle;                   # Deno runtime
    BUN_CA_BUNDLE_PATH = systemCertBundle;          # Bun runtime
    PNPM_CA_FILE = systemCertBundle;                # pnpm package manager

    # container and cloud tools
    HELM_CA_FILE = systemCertBundle;                # Helm package manager
    KUBECTL_CA_BUNDLE = systemCertBundle;           # kubectl CLI tool

    # development environment tools
    VSCODE_NODEJS_RUNTIME_ARGS = "--use-openssl-ca"; # VS Code Node.js runtime
  };

  # system-level indication that certificate management is active
  # useful for debugging and verifying certificate configuration
  environment.etc."nixos-certificates-info".text = lib.optionalString isValidCert ''
    ZScaler certificate automatically loaded from: ${toString certPath}
    Certificate validation: ${if isValidCert then "PASSED" else "FAILED"}
    System certificate bundle: ${systemCertBundle}

    Core SSL environment variables configured:
    - SSL_CERT_FILE=${systemCertBundle}
    - NIX_SSL_CERT_FILE=${systemCertBundle}
    - CURL_CA_BUNDLE=${systemCertBundle}

    Language ecosystem variables:
    - Python: REQUESTS_CA_BUNDLE, PIP_CERT, PYTHONHTTPSVERIFY
    - Node.js: NODE_EXTRA_CA_CERTS, NPM_CONFIG_CAFILE, YARN_CAFILE
    - Rust: CARGO_HTTP_CAINFO, RUSTUP_USE_CURL
    - Go: GOPATH_CERT_FILE, GOPROXY_CERT_FILE, GOSUMDB_CERT_FILE
    - Java: JAVA_OPTS, MAVEN_OPTS, GRADLE_OPTS

    Development tools:
    - Git: GIT_SSL_CAINFO
    - Docker: DOCKER_TLS_VERIFY (uses SSL_CERT_FILE and CURL_CA_BUNDLE)
    - Modern tools: DENO_CERT, BUN_CA_BUNDLE_PATH, PNPM_CA_FILE

    Total SSL variables configured: 20+
  '';
}
