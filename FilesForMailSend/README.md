# 📧 Web Server Files (Email Sending)

This folder contains the files that must be hosted on your web server to send email notifications with the RustDesk ID.

## 📁 Folder Contents

```
FilesForMailSend/
├── rustdesk-mail.php                   # Main email sending script
├── rustdesk-mail-config.php.example    # Configuration example (rename)
├── PHPMailer-master/                   # PHPMailer library
└── README.md                           # This file
```

## 🚀 Server Installation

### 1️⃣ Upload Files

Upload the **entire FilesForMailSend folder** to your web server.

**Example server structure:**
```
/home/yourusername/public_html/
└── FilesForMailSend/
    ├── rustdesk-mail.php
    ├── rustdesk-mail-config.php (you will create this)
    ├── PHPMailer-master/
    └── README.md
```

### 2️⃣ Configure the Configuration File

1. **Rename the example file:**
   ```bash
   cd FilesForMailSend
   cp rustdesk-mail-config.php.example rustdesk-mail-config.php
   ```

2. **Edit the file with your settings:**
   ```bash
   nano rustdesk-mail-config.php
   ```

3. **Fill in the following data:**
   - `API_KEY` - Same key configured in remoto.bat/ini
   - `SMTP_HOST` - SMTP server (e.g., smtp.gmail.com, smtp.yourdomain.com)
   - `SMTP_PORT` - SMTP port (465 for SSL, 587 for TLS)
   - `SMTP_USERNAME` - Your email
   - `SMTP_PASSWORD` - Email password
   - `MAIL_TO_EMAIL` - Email that will receive notifications

### 3️⃣ Adjust Permissions (Linux/Unix)

```bash
# Recommended permissions
chmod 644 rustdesk-mail.php
chmod 600 rustdesk-mail-config.php  # More restrictive for security
chmod -R 755 PHPMailer-master/
```

### 4️⃣ Test the Script

Access the URL in your browser to test:
```
https://yourserver.com/FilesForMailSend/rustdesk-mail.php?id=123456789&key=YourAPIKey
```

**Expected response:**
- ✅ Success: "OK: Email sent successfully. Date: ..."
- ❌ Error: Specific error message

## 🔧 Common SMTP Server Configuration

### Gmail
```php
define('SMTP_HOST', 'smtp.gmail.com');
define('SMTP_PORT', 587);
define('SMTP_SECURE', 'tls');
```
**Note:** You need to create an "App Password" in Google Account.

### Outlook/Hotmail
```php
define('SMTP_HOST', 'smtp-mail.outlook.com');
define('SMTP_PORT', 587);
define('SMTP_SECURE', 'tls');
```

### Yahoo
```php
define('SMTP_HOST', 'smtp.mail.yahoo.com');
define('SMTP_PORT', 465);
define('SMTP_SECURE', 'ssl');
```

### Own Server (cPanel/Plesk)
```php
define('SMTP_HOST', 'mail.yourdomain.com');
define('SMTP_PORT', 465);
define('SMTP_SECURE', 'ssl');
```

## 🔒 Security

### ✅ Best Practices

1. **Never share the `rustdesk-mail-config.php` file**
2. **Use a strong and unique API key**
3. **Set restrictive permissions on configuration file**
4. **Use HTTPS on your server**
5. **Keep PHPMailer updated**

### 🚫 Don't Do

- ❌ Don't commit `rustdesk-mail-config.php` to Git
- ❌ Don't use weak passwords
- ❌ Don't leave configuration file publicly accessible
- ❌ Don't disable API key validation

## 📝 Logs

The script automatically creates a log file:
```
FilesForMailSend/rustdesk-mail.log
```

To view logs:
```bash
tail -f rustdesk-mail.log
```

## 🐛 Troubleshooting

### Error: "Configuration file not found"
- Make sure you renamed the file to `rustdesk-mail-config.php`
- Check if the file is in the same folder as `rustdesk-mail.php`

### Error: "Invalid API key"
- Check if the key is exactly the same in remoto.bat/ini
- Should not have extra spaces

### Error: "PHPMailer not found"
- Check if the `PHPMailer-master` folder is present
- Paths in configuration file use `__DIR__` (relative)

### Email is not sent
- Check SMTP settings
- Enable debug: `define('SMTP_DEBUG', 2);`
- Check logs: `rustdesk-mail.log`
- Test SMTP credentials manually

### Error 500 (Internal Server Error)
- Check web server logs
- Check if PHP is installed and working
- Check file permissions

## 📞 Support

For problems or questions:
- Check the log file: `rustdesk-mail.log`
- Consult main documentation: `../README.md`
- Open an issue on GitHub

## 🔄 Updates

To update PHPMailer:
```bash
cd FilesForMailSend
rm -rf PHPMailer-master
# Download latest version from: https://github.com/PHPMailer/PHPMailer
# Extract to FilesForMailSend folder
```

---

**Important:** Always keep backups of your settings before making updates!

