# Windows SSL Certificate Validation Script
# Run this in PowerShell on your Windows host to diagnose SSL certificate issues

# Set output encoding to UTF-8 with BOM
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Check if running in Windows Terminal
$isWindowsTerminal = $env:WT_SESSION -ne $null

# Define fallback ASCII symbols for non-Windows Terminal environments
$symbols = @{
    "CheckMark" = if ($isWindowsTerminal) { "✅" } else { "[OK]" }
    "CrossMark" = if ($isWindowsTerminal) { "❌" } else { "[FAIL]" }
    "Warning" = if ($isWindowsTerminal) { "⚠️" } else { "[WARN]" }
    "Magnifier" = if ($isWindowsTerminal) { "🔍" } else { "[INFO]" }
    "Folder" = if ($isWindowsTerminal) { "📁" } else { "[DIR]" }
    "Rocket" = if ($isWindowsTerminal) { "🚀" } else { "[NEXT]" }
    "Clipboard" = if ($isWindowsTerminal) { "📋" } else { "[LIST]" }
    "Wrench" = if ($isWindowsTerminal) { "🔧" } else { "[FIX]" }
    "Bulb" = if ($isWindowsTerminal) { "💡" } else { "[TIP]" }
}

Write-Host "$($symbols.Magnifier) Windows SSL Certificate Environment Analysis" -ForegroundColor Cyan
Write-Host $("=" * 60)

# Check Windows Environment Variables
Write-Host "`n1. Checking SSL Environment Variables..." -ForegroundColor Yellow
$sslVars = @(
    'SSL_CERT_FILE',
    'REQUESTS_CA_BUNDLE', 
    'CURL_CA_BUNDLE',
    'NODE_EXTRA_CA_CERTS',
    'NIX_SSL_CERT_FILE',
    'HTTPS_CA_BUNDLE',
    'CA_BUNDLE'
)

$missingVars = @()
foreach ($var in $sslVars) {
    $value = [Environment]::GetEnvironmentVariable($var, 'User')
    if (-not $value) {
        $value = [Environment]::GetEnvironmentVariable($var, 'Machine')
    }
    
    if ($value) {
        Write-Host "   $($symbols.CheckMark) $var = $value" -ForegroundColor Green
        if (Test-Path $value) {
            Write-Host "      $($symbols.Folder) File exists" -ForegroundColor Green
        } else {
            Write-Host "      $($symbols.CrossMark) File not found" -ForegroundColor Red
        }
    } else {
        Write-Host "   $($symbols.CrossMark) $var = NOT SET" -ForegroundColor Red
        $missingVars += $var
    }
}

# Check Windows Certificate Store for Zscaler
Write-Host "`n2. Checking Windows Certificate Store..." -ForegroundColor Yellow
try {
    $zscalerCerts = Get-ChildItem -Path Cert:\LocalMachine\Root | Where-Object { $_.Subject -like "*Zscaler*" }
    if ($zscalerCerts) {
        Write-Host "   $($symbols.CheckMark) Found Zscaler certificates:" -ForegroundColor Green
        foreach ($cert in $zscalerCerts) {
            Write-Host "      - $($cert.Subject)" -ForegroundColor Green
            Write-Host "        Valid: $($cert.NotBefore) to $($cert.NotAfter)" -ForegroundColor Gray
        }
    } else {
        Write-Host "   $($symbols.Warning) No Zscaler certificates found in Root store" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   $($symbols.CrossMark) Error accessing certificate store: $($_.Exception.Message)" -ForegroundColor Red
}

# Check common certificate file locations
Write-Host "`n3. Checking Common Certificate Locations..." -ForegroundColor Yellow
$certPaths = @(
    "$env:APPDATA\zscaler\cert.pem",
    "$env:LOCALAPPDATA\zscaler\cert.pem", 
    "C:\Program Files\Zscaler\ZSClient\cert.pem",
    "C:\Program Files (x86)\Zscaler\ZSClient\cert.pem",
    "$env:USERPROFILE\.zscaler\cert.pem",
    "C:\zscaler-root-ca.crt",
    "$env:TEMP\zscaler-root-ca.crt"
)

$foundCerts = @()
foreach ($path in $certPaths) {
    if (Test-Path $path) {
        Write-Host "   $($symbols.CheckMark) Found: $path" -ForegroundColor Green
        $foundCerts += $path
    } else {
        Write-Host "   $($symbols.CrossMark) Not found: $path" -ForegroundColor Gray
    }
}

# Test SSL connectivity from Windows
Write-Host "`n4. Testing SSL Connectivity from Windows..." -ForegroundColor Yellow
$testUrls = @(
    'https://nixos.org',
    'https://github.com',
    'https://cache.nixos.org'
)

foreach ($url in $testUrls) {
    try {
        $response = Invoke-WebRequest -Uri $url -Method Head -TimeoutSec 10
        Write-Host "   $($symbols.CheckMark) $url - Status: $($response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "   $($symbols.CrossMark) $url - Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Generate recommendations
Write-Host "`n$($symbols.Clipboard) RECOMMENDATIONS:" -ForegroundColor Cyan
Write-Host $("=" * 30)

if ($missingVars.Count -gt 0) {
    Write-Host "`n$($symbols.Wrench) Missing Environment Variables to Set:" -ForegroundColor Yellow
    foreach ($var in $missingVars) {
        Write-Host "   - $var" -ForegroundColor Red
    }
}

if ($foundCerts.Count -gt 0) {
    Write-Host "`n$($symbols.Bulb) Suggested Certificate File:" -ForegroundColor Yellow
    Write-Host "   Use: $($foundCerts[0])" -ForegroundColor Green
    Write-Host "`n$($symbols.Wrench) Recommended Environment Variable Settings:" -ForegroundColor Yellow
    Write-Host "   SSL_CERT_FILE=$($foundCerts[0])" -ForegroundColor Green
    Write-Host "   REQUESTS_CA_BUNDLE=$($foundCerts[0])" -ForegroundColor Green
    Write-Host "   CURL_CA_BUNDLE=$($foundCerts[0])" -ForegroundColor Green
    Write-Host "   NODE_EXTRA_CA_CERTS=$($foundCerts[0])" -ForegroundColor Green
    Write-Host "   NIX_SSL_CERT_FILE=$($foundCerts[0])" -ForegroundColor Green
} else {
    Write-Host "`n$($symbols.Warning) No certificate files found. You may need to:" -ForegroundColor Yellow
    Write-Host "   1. Export Zscaler certificate from Windows certificate store" -ForegroundColor Gray
    Write-Host "   2. Contact IT for the corporate certificate bundle" -ForegroundColor Gray
    Write-Host "   3. Check Zscaler client installation" -ForegroundColor Gray
}

Write-Host "`n$($symbols.Rocket) Next Steps:" -ForegroundColor Cyan
Write-Host "1. Set the missing environment variables in Windows" -ForegroundColor White
Write-Host "2. Restart VSCode and WSL after setting variables" -ForegroundColor White  
Write-Host "3. Run the WSL validation script" -ForegroundColor White
Write-Host "4. Rebuild the devcontainer" -ForegroundColor White

Write-Host "`n$($symbols.CheckMark) Windows SSL Analysis Complete!" -ForegroundColor Green
