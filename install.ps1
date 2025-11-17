# ============================================================================
# RustDesk Auto Installer - PowerShell Script
# ============================================================================
# This script automatically installs and configures RustDesk
# Supports update and configuration without reinstallation
# ============================================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$Password,
    
    [Parameter(Mandatory=$true)]
    [string]$Config,
    
    [Parameter(Mandatory=$false)]
    [string]$ApiKey = "",
    
    [Parameter(Mandatory=$false)]
    [string]$MailScriptUrl = "",
    
    [Parameter(Mandatory=$false)]
    [string]$SendEmail = "yes"
)

$ErrorActionPreference = 'silentlycontinue'
$PSDefaultParameterValues['*:Encoding'] = 'utf8BOM'

# Load System.Web assembly for URL encoding
Add-Type -AssemblyName System.Web

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Write-Log {
    param([string]$Message, [string]$Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Define colors for each type
    $color = switch ($Type) {
        "OK"      { "Green" }
        "ERROR"   { "Red" }
        "WARNING" { "Yellow" }
        "INFO"    { "Cyan" }
        default   { "White" }
    }

    # Define symbols for each type (ASCII compatible)
    $symbol = switch ($Type) {
        "OK"      { "[OK]" }
        "ERROR"   { "[ERROR]" }
        "WARNING" { "[WARN]" }
        "INFO"    { "[INFO]" }
        default   { "[*]" }
    }

    Write-Host "[$timestamp] " -NoNewline -ForegroundColor DarkGray
    Write-Host "$symbol " -NoNewline -ForegroundColor $color
    Write-Host "$Message" -ForegroundColor $color
}

function Get-LatestRustDeskVersion {
    try {
        Write-Log "Checking latest RustDesk version..."
        $url = 'https://www.github.com/rustdesk/rustdesk/releases/latest'
        $request = [System.Net.WebRequest]::Create($url)
        $response = $request.GetResponse()
        $realTagUrl = $response.ResponseUri.OriginalString
        $version = $realTagUrl.split('/')[-1].Trim('v')
        Write-Log "Latest version available: $version" "OK"
        return $version
    }
    catch {
        Write-Log "Error checking version: $_" "ERROR"
        return $null
    }
}

function Get-InstalledRustDeskVersion {
    try {
        $version = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\RustDesk\" -ErrorAction SilentlyContinue).Version
        if ($version) {
            Write-Log "Installed version: $version" "OK"
            return $version
        }
        return $null
    }
    catch {
        return $null
    }
}

function Set-RustDeskConfig {
    param([string]$ConfigString, [string]$PasswordString)
    
    try {
        Write-Log "Applying RustDesk configuration..."
        
        $rustdeskPath = "$env:ProgramFiles\RustDesk"
        if (!(Test-Path $rustdeskPath)) {
            Write-Log "RustDesk not found at: $rustdeskPath" "ERROR"
            return $false
        }
        
        Set-Location $rustdeskPath
        
        # Apply configuration
        & .\rustdesk.exe --config $ConfigString
        Start-Sleep -Seconds 2
        
        # Apply password
        & .\rustdesk.exe --password $PasswordString
        Start-Sleep -Seconds 2
        
        Write-Log "Configuration applied successfully" "OK"
        return $true
    }
    catch {
        Write-Log "Error applying configuration: $_" "ERROR"
        return $false
    }
}

function Get-RustDeskID {
    try {
        $rustdeskPath = "$env:ProgramFiles\RustDesk"
        $rustdeskExe = Join-Path $rustdeskPath "rustdesk.exe"

        if (-not (Test-Path $rustdeskExe)) {
            Write-Log "RustDesk executable not found" "ERROR"
            return $null
        }

        Write-Log "Getting RustDesk ID..." "INFO"

        # Try multiple times with delay (RustDesk may need time to initialize)
        $maxAttempts = 5
        $attempt = 0

        while ($attempt -lt $maxAttempts) {
            $attempt++

            # Execute and capture output
            $output = & $rustdeskExe --get-id 2>&1 | Out-String
            $id = $output.Trim()

            # Check if we got a valid ID (numeric)
            if ($id -match '^\d+$') {
                Write-Log "ID obtained successfully: $id" "OK"
                return $id
            }

            if ($attempt -lt $maxAttempts) {
                Start-Sleep -Seconds 2
            }
        }

        Write-Log "Failed to get ID after $maxAttempts attempts" "ERROR"
        return $null
    }
    catch {
        Write-Log "Error getting ID: $_" "ERROR"
        return $null
    }
}

function Send-RustDeskIDByEmail {
    param([string]$ID, [string]$Key, [string]$Url)

    try {
        # Validate parameters
        if ([string]::IsNullOrWhiteSpace($ID)) {
            Write-Log "ID is empty, cannot send email" "ERROR"
            return $false
        }

        if ([string]::IsNullOrWhiteSpace($Key)) {
            Write-Log "API Key is empty, cannot send email" "ERROR"
            return $false
        }

        if ([string]::IsNullOrWhiteSpace($Url)) {
            Write-Log "URL is empty, cannot send email" "ERROR"
            return $false
        }

        # Clean and validate URL
        $Url = $Url.Trim()

        # Check if URL is valid
        if (-not ($Url -match '^https?://')) {
            Write-Log "Invalid URL format: $Url (must start with http:// or https://)" "ERROR"
            return $false
        }

        # Build the complete URL with parameters
        # Store base URL before encoding
        $baseUrl = $Url.Trim()

        # URL encode the parameters to handle special characters
        $encodedID = [System.Web.HttpUtility]::UrlEncode($ID)
        $encodedKey = [System.Web.HttpUtility]::UrlEncode($Key)

        # Build full URL
        $fullUrl = "${baseUrl}?id=${encodedID}&key=${encodedKey}"

        Write-Log "Sending ID by email..." "INFO"

        $response = Invoke-WebRequest -Uri $fullUrl -Method Get -UseBasicParsing -TimeoutSec 30

        # Check if response contains success message
        if ($response.Content -match "OK:|SUCCESS") {
            Write-Log "Email sent successfully" "OK"
        } else {
            Write-Log "Email request completed (check your inbox)" "OK"
        }

        return $true
    }
    catch {
        Write-Log "Error sending email: $_" "ERROR"
        Write-Log "URL attempted: $Url" "ERROR"
        return $false
    }
}

function Install-RustDeskService {
    try {
        $ServiceName = 'rustdesk'
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        
        if ($service -eq $null) {
            Write-Log "Installing RustDesk service..."
            $rustdeskPath = "$env:ProgramFiles\RustDesk"
            Set-Location $rustdeskPath
            Start-Process .\rustdesk.exe -ArgumentList "--install-service" -Wait -NoNewWindow
            Start-Sleep -Seconds 5
            
            # Stop GUI process if running
            Stop-Process -Name "RustDesk" -Force -ErrorAction SilentlyContinue
            
            # Start service
            Start-Service $ServiceName -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 3

            
            Write-Log "Service installed and started" "OK"
        }
        else {
            Write-Log "Service already installed" "INFO"
            if ($service.Status -ne 'Running') {
                Start-Service $ServiceName
                Write-Log "Service started" "OK"
            }
        }
        return $true
    }
    catch {
        Write-Log "Error installing service: $_" "ERROR"
        return $false
    }
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

# Clear screen for better presentation
Clear-Host

# Display header
Write-Host ""
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host "                                                             " -ForegroundColor Cyan
Write-Host "          RustDesk Auto Installer & Configurator             " -ForegroundColor Cyan
Write-Host "                                                             " -ForegroundColor Cyan
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Log "Starting RustDesk installation/configuration..." "INFO"

# Check versions
$latestVersion = Get-LatestRustDeskVersion
if ($latestVersion -eq $null) {
    Write-Log "Could not check latest version. Aborting." "ERROR"
    exit 1
}

$installedVersion = Get-InstalledRustDeskVersion
$needsInstallation = $false

# ============================================================================
# DECISION: INSTALL OR JUST CONFIGURE
# ============================================================================

if ($installedVersion -eq $null) {
    Write-Log "RustDesk is not installed. Full installation will be performed." "INFO"
    $needsInstallation = $true
}
elseif ($installedVersion -eq $latestVersion) {
    Write-Log "RustDesk $installedVersion is already installed (latest version)." "OK"
    Write-Log "Skipping installation. Only applying configuration..." "INFO"
    $needsInstallation = $false
}
else {
    Write-Log "Installed version ($installedVersion) differs from latest ($latestVersion)." "INFO"
    Write-Log "Update will be performed..." "INFO"
    $needsInstallation = $true
}

# ============================================================================
# INSTALLATION (IF NEEDED)
# ============================================================================

if ($needsInstallation) {
    Write-Log "Starting installation process..." "INFO"
    
    # Create temporary folder
    $tempPath = "C:\Temp"
    if (!(Test-Path $tempPath)) {
        New-Item -ItemType Directory -Force -Path $tempPath | Out-Null
        Write-Log "Temporary folder created: $tempPath" "OK"
    }
    
    Set-Location $tempPath
    
    # Download installer
    $installerUrl = "https://github.com/rustdesk/rustdesk/releases/download/$latestVersion/rustdesk-$latestVersion-x86_64.exe"
    $installerPath = "$tempPath\rustdesk.exe"
    
    Write-Log "Downloading RustDesk $latestVersion..." "INFO"
    Write-Log "URL: $installerUrl" "INFO"
    
    try {
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing
        Write-Log "Download completed successfully" "OK"
    }
    catch {
        Write-Log "Error downloading installer: $_" "ERROR"
        exit 1
    }
    
    # Execute silent installation
    Write-Log "Installing RustDesk $latestVersion..." "INFO"
    try {
        Start-Process -FilePath $installerPath -ArgumentList "--silent-install" -Wait -NoNewWindow
        Write-Log "Installation completed" "OK"
    }
    catch {
        Write-Log "Error during installation: $_" "ERROR"
        exit 1
    }
    
    # Wait for installation to finish
    Write-Log "Waiting for installation to complete..." "INFO"
    Start-Sleep -Seconds 10
}

# ============================================================================
# CONFIGURATION
# ============================================================================

Write-Log "Applying custom configuration..." "INFO"

$configResult = Set-RustDeskConfig -ConfigString $Config -PasswordString $Password
if (!$configResult) {
    Write-Log "Failed to apply configuration" "ERROR"
    exit 1
}

# ============================================================================
# GET ID AND SEND EMAIL (IF ENABLED)
# ============================================================================

$rustdeskID = Get-RustDeskID

if ($rustdeskID) {
    
    # Check if email should be sent
    if ($SendEmail -ieq "yes") {
        if ([string]::IsNullOrWhiteSpace($ApiKey) -or [string]::IsNullOrWhiteSpace($MailScriptUrl)) {
            Write-Log "Email configuration missing, skipping..." "WARNING"
        }
        else {
            # Send email
            $emailResult = Send-RustDeskIDByEmail -ID $rustdeskID -Key $ApiKey -Url $MailScriptUrl
            if (!$emailResult) {
                Write-Log "Failed to send email notification" "WARNING"
            }
        }
    }
}
else {
    Write-Log "Could not get RustDesk ID" "ERROR"
}

# ============================================================================
# INSTALL AND START SERVICE
# ============================================================================

$serviceResult = Install-RustDeskService
if (!$serviceResult) {
    Write-Log "Warning: Failed to configure service, but installation completed" "WARNING"
}

# ============================================================================
# FINALIZATION
# ============================================================================

Write-Host ""
Write-Host "=============================================================" -ForegroundColor Green
Write-Host "                                                             " -ForegroundColor Green
Write-Host "            Installation Completed Successfully!             " -ForegroundColor Green
Write-Host "                                                             " -ForegroundColor Green
Write-Host "=============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  RustDesk ID: " -NoNewline -ForegroundColor White
Write-Host "$rustdeskID" -ForegroundColor Yellow
Write-Host "  Password:    " -NoNewline -ForegroundColor White
Write-Host "********" -ForegroundColor DarkGray
Write-Host ""

# Start RustDesk interface
$rustdeskPath = "$env:ProgramFiles\RustDesk"
if (Test-Path "$rustdeskPath\rustdesk.exe") {
    Start-Process "$rustdeskPath\rustdesk.exe" -NoNewWindow
    Write-Log "RustDesk interface started" "OK"
}

Write-Host ""
Write-Host "  You can close this window now." -ForegroundColor DarkGray
Write-Host ""
exit 0

