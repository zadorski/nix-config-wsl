# Certificate Management

This directory holds root certificates used by the system.

## ZScaler Certificate

The `zscaler.pem` file is automatically managed by the `system/certificates.nix` module:

- **If the file contains a valid certificate**: It will be automatically added to the system's PKI certificate store
- **If the file is missing or contains only placeholder content**: No certificate will be added (no errors)

## Usage

1. **For corporate environments**: Replace the placeholder content in `zscaler.pem` with your actual ZScaler root certificate
2. **For non-corporate environments**: Leave the file as-is (the placeholder will be ignored)

## Certificate Format

The certificate should be in PEM format and contain standard certificate markers like:
- `-----BEGIN CERTIFICATE-----`
- `-----BEGIN TRUSTED CERTIFICATE-----`
- Or other standard PEM certificate headers

## Verification

After rebuilding your system, you can verify certificate loading by checking:
```bash
cat /etc/nixos-certificates-info
```

This file will show the status of certificate validation and loading.
