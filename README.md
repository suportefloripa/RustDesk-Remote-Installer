<div align="center">

# 🖥️ RustDesk Auto Installer

**Automated installation and configuration system for RustDesk on Windows with email notification**

<p align="center">
  <a href="https://creativecommons.org/licenses/by-nc/4.0/">
    <img src="https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg" alt="License: CC BY-NC 4.0">
  </a>
  <img src="https://img.shields.io/github/stars/suportefloripa/RustDesk-Remote-Installer?style=social" alt="GitHub Stars">
  <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome">
  <img src="https://img.shields.io/badge/Made%20with-Batch%20%26%20PowerShell-blue" alt="Made with Batch & PowerShell">
  <img src="https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows" alt="Platform: Windows">
</p>

<p align="center">
  <a href="#-features">Features</a> •
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-installation">Installation</a> •
  <a href="#-configuration">Configuration</a> •
  <a href="#-usage">Usage</a> •
  <a href="#-contributing">Contributing</a>
</p>

</div>

---

## 📋 Description

This project allows **IT professionals** to remotely install and configure **RustDesk** on Windows computers automatically, receiving the generated ID by email for future access. Perfect for managing multiple computers, remote support, and IT infrastructure management.

## ✨ Features

- 🚀 **Automatic installation** of the latest RustDesk version
- ⚙️ **Automatic configuration** with custom server and password
- 🧠 **Smart detection**: doesn't reinstall if version is already up to date
- 📧 **Email notification** with generated ID
- 🔧 **Installation as Windows service** for automatic startup
- 📝 **Support for .ini configuration file** (optional)
- 📊 **Detailed logs** with colors and clear formatting
- 🔒 **Security with API key** validation
- 🎯 **Optional email sending** (can be disabled)
- 🔐 **Password protection** (hidden on client screen)
- 🎨 **Beautiful console interface** with progress indicators

## 🚀 Quick Start

### Prerequisites

**Server Requirements:**
- PHP 7.0 or higher
- Web server (Apache/Nginx)
- SMTP access for sending emails
- PHPMailer library

**Client Requirements:**
- Windows 7 or higher
- PowerShell 3.0 or higher
- Internet connection
- Administrator privileges

### 📦 Installation

#### Step 1: Server Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/suportefloripa/RustDesk-Remote-Installer.git
   cd RustDesk-Remote-Installer
   ```

2. **Configure email settings:**
   ```bash
   cd FilesForMailSend
   cp rustdesk-mail-config.php.example rustdesk-mail-config.php
   ```

3. **Edit `rustdesk-mail-config.php`:**
   ```php
   define('API_KEY', 'your-secure-api-key-here');
   define('SMTP_HOST', 'smtp.gmail.com');
   define('SMTP_PORT', 587);
   define('SMTP_USERNAME', 'your-email@gmail.com');
   define('SMTP_PASSWORD', 'your-app-password');
   define('MAIL_TO_EMAIL', 'it-team@company.com');
   ```

4. **Upload files to your web server:**
   - `install.ps1` → `https://yourserver.com/rustdesk/install.ps1`
   - `FilesForMailSend/` folder → `https://yourserver.com/rustdesk-mail.php`

5. **Install PHPMailer** (if not already installed):
   ```bash
   composer require phpmailer/phpmailer
   ```
   Or download from: https://github.com/PHPMailer/PHPMailer

#### Step 2: Client Configuration

**Option A: Using .ini file (Recommended) ⭐**

1. **Copy the example file:**
   ```bash
   cp remoto.ini.example remoto.ini
   ```

2. **Edit `remoto.ini`:**
   ```ini
   SERVER_URL=https://yourserver.com/rustdesk
   RUSTDESK_PASSWORD=YourSecurePassword123
   RUSTDESK_CONFIG=YourRustDeskConfigString
   API_KEY=your-secure-api-key-here
   MAIL_SCRIPT_URL=https://yourserver.com/rustdesk-mail.php
   SEND_EMAIL=yes
   ```

   > **⚠️ IMPORTANT:** `SERVER_URL` should be the **directory path only** (without `/install.ps1`).
   >
   > **Examples:**
   > - ✅ Correct: `SERVER_URL=https://yoursite.com/rustdesk`
   > - ✅ Correct: `SERVER_URL=https://yoursite.com/scripts/rustdesk`
   > - ❌ Wrong: `SERVER_URL=https://yoursite.com/rustdesk/install.ps1`

3. **Distribute to clients:**
   - Send both `remoto.bat` and `remoto.ini` files together

**Option B: Direct configuration in .bat**

1. Edit `remoto.bat` and change:
   ```batch
   SET "USE_INI_FILE=no"
   SET "SERVER_URL=https://yourserver.com/rustdesk"
   SET "RUSTDESK_PASSWORD=YourPassword"
   SET "RUSTDESK_CONFIG=YourConfigString"
   SET "API_KEY=your-api-key"
   SET "MAIL_SCRIPT_URL=https://yourserver.com/rustdesk-mail.php"
   SET "SEND_EMAIL=yes"
   ```

2. Send only `remoto.bat` to clients

**Option C: Without email notification**

Set in `remoto.ini` or `remoto.bat`:
```ini
SEND_EMAIL=no
```
The ID will only be displayed on screen.

## 📖 Usage

### For IT Professionals

1. **Prepare the files** according to the installation steps above
2. **Send to client** via email, USB drive, or network share
3. **Instruct client** to run `remoto.bat` as administrator

### For End Users

1. **Right-click** on `remoto.bat`
2. **Select** "Run as administrator"
3. **Wait** for the installation to complete
4. **Note the RustDesk ID** displayed on screen (password is hidden)
5. **Close the window** when finished

### What Happens During Installation?

```
=============================================================
          RustDesk Auto Installer & Configurator
=============================================================

[INFO] Starting RustDesk installation/configuration...
[INFO] Checking latest RustDesk version...
[OK] Latest version available: 1.4.3
[INFO] Downloading RustDesk installer...
[OK] Download completed successfully
[INFO] Installing RustDesk...
[OK] Installation completed successfully
[INFO] Applying RustDesk configuration...
[OK] Configuration applied successfully
[INFO] Getting RustDesk ID...
[OK] ID obtained successfully: 1234567890
[INFO] Sending ID by email...
[OK] Email sent successfully
[OK] RustDesk interface started

=============================================================
            Installation Completed Successfully!
=============================================================

  RustDesk ID: 1234567890
  Password:    ********

  You can close this window now.
```

## 📁 Project Structure

```
RustDesk-Remote-Installer/
├── 📄 remoto.bat                          # Main batch script for client
├── 📄 remoto.ini.example                  # Configuration file example
├── 📄 install.ps1                         # PowerShell installation script
├── 📄 README.md                           # This documentation
├── 📄 CHANGELOG.md                        # Version history
├── 📄 QUICK_START.md                      # Quick start guide
├── 📄 LICENSE                             # License file
├── 📄 .gitignore                          # Git ignore rules
└── 📁 FilesForMailSend/                   # Server-side files
    ├── 📄 rustdesk-mail.php               # Email notification script
    ├── 📄 rustdesk-mail-config.php.example # Email configuration template
    ├── 📄 README.md                       # Server setup documentation
    └── 📁 PHPMailer-master/               # PHPMailer library (external)
```

## ⚙️ Configuration

### 📝 remoto.ini Configuration

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `SERVER_URL` | **Base URL** where install.ps1 is located (**WITHOUT** the filename) | `https://yourserver.com/rustdesk` | ✅ Yes |
| `RUSTDESK_PASSWORD` | Password for remote access (6+ characters) | `MyS3cur3P@ss` | ✅ Yes |
| `RUSTDESK_CONFIG` | RustDesk server configuration string | `0nIvJHcuEGd09W...` | ✅ Yes |
| `API_KEY` | Authentication key (32+ characters recommended) | `dRTiHUmOZ8CSQNW3...` | ✅ Yes |
| `MAIL_SCRIPT_URL` | Full URL of PHP email script | `https://server.com/rustdesk-mail.php` | ⚠️ If email enabled |
| `SEND_EMAIL` | Send email notification? | `yes` or `no` | ✅ Yes |

> **⚠️ CRITICAL: Understanding SERVER_URL**
>
> The `SERVER_URL` must be the **directory path only**, NOT the full file path.
> The script automatically appends `/install.ps1` to this URL.
>
> **Examples:**
> - ✅ **Correct:** `SERVER_URL=https://yoursite.com/rustdesk`
>   - Script will download: `https://yoursite.com/rustdesk/install.ps1`
> - ✅ **Correct:** `SERVER_URL=https://yoursite.com/scripts/remote`
>   - Script will download: `https://yoursite.com/scripts/remote/install.ps1`
> - ❌ **Wrong:** `SERVER_URL=https://yoursite.com/rustdesk/install.ps1`
>   - Script will try: `https://yoursite.com/rustdesk/install.ps1/install.ps1` ❌

### 📧 rustdesk-mail-config.php Configuration

| Constant | Description | Example |
|----------|-------------|---------|
| `API_KEY` | Same key configured in remoto.ini | `dRTiHUmOZ8CSQNW3VgIKF2zpvSLOWbDz` |
| `SMTP_HOST` | SMTP server address | `smtp.gmail.com` |
| `SMTP_PORT` | SMTP port (587 for TLS, 465 for SSL) | `587` |
| `SMTP_USERNAME` | Email account username | `your-email@gmail.com` |
| `SMTP_PASSWORD` | Email account password or app password | `your-app-password` |
| `MAIL_TO_EMAIL` | Destination email for notifications | `it-team@company.com` |

> **💡 Tip for Gmail users:**
> - Enable 2-factor authentication
> - Generate an "App Password" at: https://myaccount.google.com/apppasswords
> - Use the app password instead of your regular password

### 🔐 How to Get RustDesk Config String

1. Install RustDesk on a test computer
2. Configure your custom server settings
3. Go to: `C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\RustDesk\config\`
4. Open `RustDesk2.toml` file
5. Copy the entire content or specific configuration
6. Encode to base64 or use as-is in `RUSTDESK_CONFIG`

## 🔒 Security Features

- 🔐 **API key validation** on all HTTP requests
- 🧹 **Input data sanitization** to prevent injection attacks
- 📊 **Comprehensive logging** of all operations
- 🔒 **Password hidden** on client screen (shown as `********`)
- 📁 **Separate configuration files** (not versioned in Git)
- 🚫 **No sensitive data** in repository
- ✅ **HTTPS recommended** for all communications

### Security Best Practices

1. **Use strong API keys** (32+ characters, random)
2. **Use strong passwords** for RustDesk access
3. **Never commit** `remoto.ini` or `rustdesk-mail-config.php` with real data
4. **Use HTTPS** for your web server
5. **Restrict PHP script access** (IP whitelist if possible)
6. **Regularly update** RustDesk and server components
7. **Monitor logs** for suspicious activity

## 📝 Logs and Monitoring

### Client-Side Logs
- **Location**: Console output during installation
- **Format**: Colored text with timestamps
- **Levels**: `[INFO]`, `[OK]`, `[WARN]`, `[ERROR]`

### Server-Side Logs
- **Location**: `rustdesk-mail.log` (auto-created)
- **Content**: Email sending attempts, errors, API key validation
- **Format**: `[YYYY-MM-DD HH:MM:SS] [LEVEL] Message`

### Log Example
```
[2025-11-17 12:30:00] [INFO] Email request received
[2025-11-17 12:30:00] [OK] API key validated
[2025-11-17 12:30:01] [OK] Email sent successfully to: it@company.com
[2025-11-17 12:30:01] [INFO] RustDesk ID: 1234567890
```

## 🛠️ System Requirements

### Server Requirements
| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **PHP** | 7.0 | 8.0+ |
| **Web Server** | Apache 2.4 / Nginx 1.18 | Latest stable |
| **PHPMailer** | 6.0 | Latest |
| **SSL Certificate** | Optional | ✅ Required |
| **Disk Space** | 10 MB | 50 MB |
| **SMTP Access** | Required | Dedicated SMTP |

### Client Requirements
| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **Windows** | 7 SP1 | 10/11 |
| **PowerShell** | 3.0 | 5.1+ |
| **RAM** | 2 GB | 4 GB+ |
| **Disk Space** | 50 MB | 100 MB |
| **Internet** | 1 Mbps | 5 Mbps+ |
| **Privileges** | Administrator | Administrator |

## 🐛 Troubleshooting

### Common Issues

<details>
<summary><b>❌ Error: "URI inválido: o nome do host não pôde ser analisado"</b></summary>

**Cause:** Invalid `SERVER_URL` or `MAIL_SCRIPT_URL`

**Solution:**
- Check that URLs start with `http://` or `https://`
- Verify there are no extra spaces
- Ensure `SERVER_URL` doesn't include `/install.ps1`
</details>

<details>
<summary><b>❌ Error: "504 Gateway Time-out"</b></summary>

**Cause:** Cloudflare proxy or server timeout

**Solution:**
- Disable Cloudflare proxy (DNS Only mode) for the mail subdomain
- Increase PHP `max_execution_time` to 300 seconds
- Check SMTP server connectivity
</details>

<details>
<summary><b>❌ Email not received</b></summary>

**Cause:** SMTP configuration or spam filter

**Solution:**
- Check `rustdesk-mail.log` for errors
- Verify SMTP credentials
- Check spam/junk folder
- Test SMTP settings with a simple PHP script
- For Gmail: Use App Password, not regular password
</details>

<details>
<summary><b>❌ RustDesk ID not obtained</b></summary>

**Cause:** RustDesk not fully initialized

**Solution:**
- Wait 10-15 seconds and try again
- Check if RustDesk service is running
- Restart RustDesk service
- Reinstall RustDesk
</details>

<details>
<summary><b>❌ "Access Denied" or "Administrator privileges required"</b></summary>

**Cause:** Script not running as administrator

**Solution:**
- Right-click `remoto.bat` → "Run as administrator"
- Check UAC settings
- Ensure user has admin rights
</details>

## 🤝 Contributing

Contributions are **welcome and appreciated**! Here's how you can help:

### Ways to Contribute

- 🐛 **Report bugs** by opening an issue
- 💡 **Suggest features** or improvements
- 📝 **Improve documentation**
- 🔧 **Submit pull requests**
- ⭐ **Star the project** if you find it useful
- 📢 **Share with others** who might benefit

### Development Workflow

1. **Fork** the repository
2. **Clone** your fork:
   ```bash
   git clone https://github.com/YOUR-USERNAME/RustDesk-Remote-Installer.git
   ```
3. **Create a branch** for your feature:
   ```bash
   git checkout -b feature/amazing-feature
   ```
4. **Make your changes** and test thoroughly
5. **Commit** with clear messages:
   ```bash
   git commit -m "Add: Amazing new feature"
   ```
6. **Push** to your fork:
   ```bash
   git push origin feature/amazing-feature
   ```
7. **Open a Pull Request** with a clear description

### Code Style Guidelines

- Use clear, descriptive variable names
- Add comments for complex logic
- Follow existing code formatting
- Test on multiple Windows versions if possible
- Update documentation for new features

## 📄 License

This project is licensed under the **Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0)**.

**You are free to:**
- ✅ Share — copy and redistribute the material
- ✅ Adapt — remix, transform, and build upon the material

**Under the following terms:**
- 📝 **Attribution** — You must give appropriate credit
- 🚫 **NonCommercial** — You may not use the material for commercial purposes

For more details, see the [LICENSE](LICENSE) file or visit [Creative Commons](https://creativecommons.org/licenses/by-nc/4.0/).

## ⚠️ Important Disclaimers

1. **🔒 Security**: Always use strong, unique passwords for production environments
2. **💾 Backup**: Backup your configuration files before updating
3. **🧪 Testing**: Test in a controlled environment before deploying to production
4. **👤 Privacy**: Respect user privacy and inform users about remote access installation
5. **⚖️ Legal**: Ensure you have proper authorization before installing remote access software
6. **🛡️ Responsibility**: This tool is provided "as-is" without warranty. Use at your own risk.

## 📞 Support & Contact

### Getting Help

- 📖 **Documentation**: Read this README and [QUICK_START.md](QUICK_START.md)
- 🐛 **Bug Reports**: [Open an issue](https://github.com/suportefloripa/RustDesk-Remote-Installer/issues)
- 💬 **Questions**: [GitHub Discussions](https://github.com/suportefloripa/RustDesk-Remote-Installer/discussions)
- 📧 **Email**: For private inquiries, contact via GitHub profile

### Useful Links

- 🌐 **RustDesk Official**: https://rustdesk.com
- 📚 **RustDesk Documentation**: https://rustdesk.com/docs
- 💻 **RustDesk GitHub**: https://github.com/rustdesk/rustdesk
- 📧 **PHPMailer**: https://github.com/PHPMailer/PHPMailer

## 🌟 Acknowledgments

- **RustDesk Team** - For creating an amazing open-source remote desktop solution
- **PHPMailer Team** - For the reliable email library
- **Contributors** - Everyone who has contributed to this project
- **IT Community** - For feedback and suggestions

## 📊 Project Stats

<p align="center">
  <img src="https://img.shields.io/github/last-commit/suportefloripa/RustDesk-Remote-Installer" alt="Last Commit">
  <img src="https://img.shields.io/github/issues/suportefloripa/RustDesk-Remote-Installer" alt="Open Issues">
  <img src="https://img.shields.io/github/issues-pr/suportefloripa/RustDesk-Remote-Installer" alt="Pull Requests">
  <img src="https://img.shields.io/github/forks/suportefloripa/RustDesk-Remote-Installer?style=social" alt="Forks">
</p>

---

<div align="center">

**Made with ❤️ by [Rodrigo Motta](https://motta.pro)**

[Website](https://motta.pro) • [GitHub](https://github.com/suportefloripa/RustDesk-Remote-Installer)

*If this project helped you, consider giving it a ⭐ star!*

</div>

