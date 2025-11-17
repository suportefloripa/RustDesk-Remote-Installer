@echo off
chcp 65001 >nul
cls

REM ============================================================================
REM RustDesk Auto Installer - Batch Script
REM ============================================================================
REM This script downloads and executes the RustDesk installation
REM Can read settings from a remoto.ini file or use default values
REM ============================================================================

set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

REM ============================================================================
REM DEFAULT SETTINGS (FALLBACK)
REM ============================================================================
REM Edit these variables with your own settings
REM These will be used if remoto.ini file doesn't exist or USE_INI_FILE=no

SET "USE_INI_FILE=yes"

REM SERVER_URL: Base URL where install.ps1 is hosted (WITHOUT the filename)
REM IMPORTANT: This should be the DIRECTORY path, not the full file path
REM Example: If your install.ps1 is at https://yoursite.com/subfolder/install.ps1
REM          Then SERVER_URL should be: https://yoursite.com/subfolder
REM The script will automatically append "/install.ps1" to this URL
SET "SERVER_URL=http://yourserver.com"

SET "RUSTDESK_PASSWORD=YourPasswordHere"
SET "RUSTDESK_CONFIG=YourConfigStringHere"
SET "API_KEY=YourAPIKeyHere"
SET "MAIL_SCRIPT_URL=https://yourserver.com/FilesForMailSend/rustdesk-mail.php"
SET "SEND_EMAIL=yes"

REM ============================================================================
REM READ .INI FILE (IF EXISTS AND USE_INI_FILE=yes)
REM ============================================================================

IF /I "%USE_INI_FILE%"=="yes" (
    IF EXIST "%~dp0remoto.ini" (
        echo [INFO] remoto.ini file found. Loading settings...
        
        REM Read settings from .ini file
        FOR /F "usebackq tokens=1,2 delims==" %%A IN ("%~dp0remoto.ini") DO (
            SET "%%A=%%B"
        )
        echo [OK] Settings loaded from remoto.ini
    ) ELSE (
        echo [WARNING] remoto.ini file not found. Using default script settings.
    )
) ELSE (
    echo [INFO] .ini file usage disabled. Using default script settings.
)

REM ============================================================================
REM ENVIRONMENT PREPARATION
REM ============================================================================

SET "c-temp=%SystemDrive%\Temp\RustDesk"
echo [INFO] Preparing temporary directory: %c-temp%

IF NOT EXIST "%c-temp%\" (
    mkdir "%c-temp%"
    echo [OK] Directory created: %c-temp%
) ELSE (
    echo [OK] Directory already exists: %c-temp%
)

cd /d "%c-temp%"
echo [INFO] Current directory: %CD%

REM ============================================================================
REM DOWNLOAD INSTALLATION SCRIPT
REM ============================================================================

IF EXIST "%c-temp%\install.ps1" (
    echo [INFO] Removing old install.ps1...
    del "%c-temp%\install.ps1"
)

echo [INFO] Downloading installation script from: %SERVER_URL%/install.ps1
echo [INFO] Saving to: %c-temp%\install.ps1
powershell -Command "try { $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest '%SERVER_URL%/install.ps1' -OutFile '%c-temp%\install.ps1' -UseBasicParsing -ErrorAction Stop; Write-Host '[OK] Download completed successfully' } catch { Write-Host '[ERROR] Download failed:' $_.Exception.Message; exit 1 }"

IF NOT EXIST "%c-temp%\install.ps1" (
    echo [ERROR] Failed to download installation script!
    echo [ERROR] Check if the URL is correct: %SERVER_URL%/install.ps1
    echo [ERROR] Expected file location: %c-temp%\install.ps1
    pause
    exit /B 1
)

REM ============================================================================
REM VERIFY DOWNLOADED FILE
REM ============================================================================

echo [INFO] Verifying downloaded file...
powershell -Command "$content = Get-Content '%c-temp%\install.ps1' -Raw -Encoding UTF8; $firstLine = ($content -split \"`n\")[0]; if ($firstLine -notmatch '^#|^param|^<#|^\s*$') { Write-Host '[ERROR] Downloaded file is not a valid PowerShell script!' -ForegroundColor Red; Write-Host '[ERROR] First line of file:' $firstLine -ForegroundColor Red; Write-Host '[ERROR] The server may be returning an error page instead of the script.' -ForegroundColor Red; Write-Host '[ERROR] Please check:' -ForegroundColor Yellow; Write-Host '  1. The URL is correct: %SERVER_URL%/install.ps1' -ForegroundColor Yellow; Write-Host '  2. The file exists on the server' -ForegroundColor Yellow; Write-Host '  3. The server is not redirecting or showing an error page' -ForegroundColor Yellow; exit 1 } else { Write-Host '[OK] File appears to be a valid PowerShell script' -ForegroundColor Green }"

IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] File validation failed!
    pause
    exit /B 1
)

REM ============================================================================
REM EXECUTE POWERSHELL SCRIPT
REM ============================================================================

REM Double-check file exists before execution
IF NOT EXIST "%c-temp%\install.ps1" (
    echo [ERROR] Script file disappeared! Path: %c-temp%\install.ps1
    dir "%c-temp%"
    pause
    exit /B 1
)

echo [INFO] Starting RustDesk installation...
echo [INFO] Script location: %c-temp%\install.ps1
echo [INFO] File size:
dir "%c-temp%\install.ps1" | find "install.ps1"
echo.

REM Execute with full path and working directory set
cd /d "%c-temp%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& { Set-Location '%c-temp%'; & '%c-temp%\install.ps1' -Password '%RUSTDESK_PASSWORD%' -Config '%RUSTDESK_CONFIG%' -ApiKey '%API_KEY%' -MailScriptUrl '%MAIL_SCRIPT_URL%' -SendEmail '%SEND_EMAIL%' }"

IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Installation encountered problems. Error code: %ERRORLEVEL%
    pause
    exit /B %ERRORLEVEL%
)

echo.
echo [OK] Process completed!
exit /B 0

