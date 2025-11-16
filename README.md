<p align="center">
  <a href="https://creativecommons.org/licenses/by-nc/4.0/">
    <img src="https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg" alt="License: CC BY-NC 4.0">
  </a>
  <img src="https://img.shields.io/github/stars/usuario/repositorio?style=social" alt="GitHub Stars">
  <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome">
  <img src="https://img.shields.io/badge/Made%20with-Batch-blue" alt="Made with Batch">
</p>

# RustDesk Remote Installer

> ⭐ **Obrigado por apoiar este projeto!**  
> Se você gostou, considere deixar uma estrela no GitHub.  
> Isso ajuda muito e motiva a continuar melhorando! 🙌

## 📄 Licença
Este projeto é disponibilizado sob a licença **Creative Commons BY-NC 4.0**.

Isso significa:

- ✔️ **Você pode usar, modificar e fazer fork do código livremente** para uso **pessoal e não comercial**.  
- ✔️ **Você deve manter a atribuição ao autor original**.  
- ❌ **Não é permitido vender, comercializar ou utilizar este código em produtos pagos**.

O arquivo da licença deve ser incluído como `LICENSE` no repositório.

---

## PT-BR

### Visão Geral
- Instala e configura RustDesk em clientes Windows usando um único `remoto.bat`.
- Lê `remoto.ini` opcional (`USE_INI=yes`) ou usa variáveis no topo do `.bat`.
- Gera e executa localmente `install.ps1`, aplica `--config` e `--password`, obtém `--get-id` e envia e‑mail via endpoint PHP ou SMTP.
- Se a versão instalada já for a mais recente, não reinstala; apenas configura e envia o e‑mail.

### Arquivos
- `remoto.bat`: arquivo entregue ao cliente; eleva para administrador, lê INI opcional, gera e executa `install.ps1`.
- `remoto.ini.example`: modelo de configuração para profissionais de TI (opcional).
- `rustdesk-mail.php`: exemplo de endpoint para envio do ID por e‑mail.

### Requisitos
- Windows 10 ou superior, com privilégios de administrador.
- Acesso à internet para baixar releases do GitHub.
- `https` para `MAIL_URL` quando usar modo PHP.
- TLS para SMTP quando usar modo SMTP.

### Início Rápido
1. Defina se vai usar `remoto.ini` ou variáveis no próprio `.bat`.
2. Caso opte por INI: copie `remoto.ini.example` para `remoto.ini` e preencha com os seus dados.
3. Ajuste `USE_INI=yes` ou `no` no topo do `remoto.bat`.
4. Execute `remoto.bat` como administrador no cliente.

### Configuração

#### Usando arquivo INI
Sessões e chaves principais:

- `[general]`  
  - `USE_INI`  
  - `ORG_NAME`  
  - `TECH_NAME`  

- `[rustdesk]`  
  - `RUSTDESK_CFG`  
  - `RUSTDESK_PW` (vazio gera senha aleatória)  

- `[email]`  
  - `MAIL_MODE` (`php` ou `smtp`)  
  - `MAIL_URL`  
  - `MAIL_TOKEN`  
  - `MAIL_TO`  
  - `MAIL_FROM`  

- `[smtp]`  
  - `SMTP_HOST`  
  - `SMTP_PORT`  
  - `SMTP_USER`  
  - `SMTP_PASS`  
  - `SMTP_TLS`  

#### Fallback (variáveis no .bat)
Caso não utilize INI (`USE_INI=no`), as mesmas chaves são definidas como variáveis no topo do `remoto.bat`.

### Exemplos

#### `remoto.ini`
```ini
[general]
USE_INI=yes
ORG_NAME=MinhaEmpresa
TECH_NAME=Fulano

[rustdesk]
RUSTDESK_CFG=SEU_CONFIG_STRING_AQUI
RUSTDESK_PW=

[email]
MAIL_MODE=php
MAIL_URL=https://seu-dominio/rustdesk-mail.php
MAIL_TOKEN=SEU_TOKEN_SEGURO
MAIL_TO=suporte@dominio.com
MAIL_FROM=nao-responder@dominio.com

[smtp]
SMTP_HOST=smtp.dominio.com
SMTP_PORT=587
SMTP_USER=user
SMTP_PASS=pass
SMTP_TLS=true
```

#### Variáveis no `remoto.bat`
```bat
set "USE_INI=no"
set "ORG_NAME=MinhaEmpresa"
set "TECH_NAME=Fulano"
set "RUSTDESK_CFG=SEU_CONFIG_STRING_AQUI"
set "RUSTDESK_PW="
set "MAIL_MODE=php"
set "MAIL_URL=https://seu-dominio/rustdesk-mail.php"
set "MAIL_TOKEN=SEU_TOKEN_SEGURO"
set "MAIL_TO=suporte@dominio.com"
set "MAIL_FROM=nao-responder@dominio.com"
set "SMTP_HOST=smtp.dominio.com"
set "SMTP_PORT=587"
set "SMTP_USER=user"
set "SMTP_PASS=pass"
set "SMTP_TLS=true"
```

### Opções de E‑mail
- `php`: o script chama `MAIL_URL?id=...&key=...&org=...&tech=...`. Proteja `MAIL_TOKEN` e valide sempre no endpoint.
- `smtp`: usa `Send-MailMessage` com TLS e credenciais opcionais.

**Importante**  
- O valor de `MAIL_TOKEN` deve ser idêntico ao `$token` definido em `rustdesk-mail.php`. Caso contrário, o endpoint responderá `unauthorized` e o e‑mail não será enviado.

### Requisitos do Servidor (PHP)
- PHP 7.4+ (recomendado 8.x).
- Endpoint acessível via `https`.
- Para `mail()` nativo:
  - Servidor deve ter MTA configurado (sendmail/postfix/exim) e permissões de envio.
  - Configurar DNS (SPF/DMARC) para evitar rejeições.
- Para PHPMailer (opcional, recomendado quando não há MTA ou para melhor entrega):
  - Instalação: `composer require phpmailer/phpmailer`.
  - SMTP: fornecer `HOST`, `PORT`, `USER`, `PASS`, `TLS` de sua conta/servidor de e‑mail.
  - O endpoint deve validar o token e enviar o e‑mail via SMTP.

### Segurança
- Use `https` para URLs e não versione segredos (tokens, senhas, etc.).
- Restrinja o endpoint PHP apenas às origens necessárias.
- Rotacione tokens periodicamente.
- Valide parâmetros recebidos antes de usá‑los.

### Solução de Problemas
- **Falhas de download**: verifique firewall/proxy e acesso ao GitHub.
- **Token inválido**: alinhe `MAIL_TOKEN` com o servidor.
- **SMTP falhando**: revise `SMTP_*`, TLS, porta e autenticação.
- **Serviço `rustdesk`**: tente `Start-Service rustdesk` e verifique permissões.

---

## Créditos
- Autor: Rodrigo Motta  
- Site: https://motta.pro

---

## EN-US

### Overview
- Installs and configures RustDesk on Windows clients using a single `remoto.bat`.
- Reads optional `remoto.ini` (`USE_INI=yes`) or falls back to variables at the top of the `.bat`.
- Locally generates and runs `install.ps1`, applies `--config` and `--password`, gets `--get-id`, and emails it via PHP endpoint or SMTP.
- If the installed version already matches the latest release, it skips reinstall, only configures and sends the email.

### Files
- `remoto.bat`: client-delivered file; elevates to administrator, reads optional INI, generates and executes `install.ps1`.
- `remoto.ini.example`: configuration template for IT professionals (optional).
- `rustdesk-mail.php`: example endpoint used to send the RustDesk ID via email.

### Requirements
- Windows 10 or later, with administrative privileges.
- Internet access to GitHub Releases.
- `https` for `MAIL_URL` when using PHP mode.
- TLS for SMTP when using SMTP mode.

### Quick Start
1. Decide whether to use `remoto.ini` or environment variables in `remoto.bat`.
2. If using INI: copy `remoto.ini.example` to `remoto.ini` and fill in your values.
3. Set `USE_INI=yes` or `no` at the top of `remoto.bat`.
4. Run `remoto.bat` as administrator on the client.

### Configuration

#### INI
- `[general]`: `USE_INI`, `ORG_NAME`, `TECH_NAME`  
- `[rustdesk]`: `RUSTDESK_CFG`, `RUSTDESK_PW` (empty generates a random password)  
- `[email]`: `MAIL_MODE` (`php` or `smtp`), `MAIL_URL`, `MAIL_TOKEN`, `MAIL_TO`, `MAIL_FROM`  
- `[smtp]`: `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`, `SMTP_TLS`  

#### Fallback (variables in .bat)
Same keys can be set at the top of `remoto.bat` when `USE_INI=no`.

### Examples

#### `remoto.ini`
```ini
[general]
USE_INI=yes
ORG_NAME=MyCompany
TECH_NAME=John Doe

[rustdesk]
RUSTDESK_CFG=YOUR_CONFIG_STRING_HERE
RUSTDESK_PW=

[email]
MAIL_MODE=php
MAIL_URL=https://your-domain/rustdesk-mail.php
MAIL_TOKEN=YOUR_SECURE_TOKEN
MAIL_TO=support@your-domain.com
MAIL_FROM=no-reply@your-domain.com

[smtp]
SMTP_HOST=smtp.your-domain.com
SMTP_PORT=587
SMTP_USER=user
SMTP_PASS=pass
SMTP_TLS=true
```

#### Variables in `remoto.bat`
```bat
set "USE_INI=no"
set "ORG_NAME=MyCompany"
set "TECH_NAME=John Doe"
set "RUSTDESK_CFG=YOUR_CONFIG_STRING_HERE"
set "RUSTDESK_PW="
set "MAIL_MODE=php"
set "MAIL_URL=https://your-domain/rustdesk-mail.php"
set "MAIL_TOKEN=YOUR_SECURE_TOKEN"
set "MAIL_TO=support@your-domain.com"
set "MAIL_FROM=no-reply@your-domain.com"
set "SMTP_HOST=smtp.your-domain.com"
set "SMTP_PORT=587"
set "SMTP_USER=user"
set "SMTP_PASS=pass"
set "SMTP_TLS=true"
```

### Email Options
- `php`: the script calls `MAIL_URL?id=...&key=...&org=...&tech=...`. Protect `MAIL_TOKEN` and always validate it on the server.
- `smtp`: uses `Send-MailMessage` with TLS and optional credentials.

**Important**  
- `MAIL_TOKEN` must exactly match the `$token` defined in `rustdesk-mail.php`. Otherwise, the endpoint will return `unauthorized` and the email will not be sent.

### Server Requirements (PHP)
- PHP 7.4+ (8.x recommended).
- Endpoint reachable via `https`.
- For native `mail()`:
  - Server must have an MTA configured (sendmail/postfix/exim) and proper send permissions.
  - Configure DNS (SPF/DMARC) to avoid delivery issues.
- For PHPMailer (optional, recommended for better deliverability or when no MTA is available):
  - Install with `composer require phpmailer/phpmailer`.
  - Provide `HOST`, `PORT`, `USER`, `PASS`, `TLS` from your mail provider.
  - The endpoint should validate the token and send email via SMTP.

### Security
- Always use `https` for URLs.
- Do not commit secrets (tokens, passwords, etc.) to version control.
- Restrict access to the PHP endpoint.
- Rotate tokens periodically.

### Troubleshooting
- **Download failures**: check firewall/proxy and connectivity to GitHub.
- **Invalid token**: make sure `MAIL_TOKEN` matches the server.
- **SMTP issues**: review `SMTP_*` values, TLS settings and ports.
- **`rustdesk` service issues**: try `Start-Service rustdesk` and check permissions.

---

## Credits
- Author: Rodrigo Motta  
- Website: https://motta.pro
