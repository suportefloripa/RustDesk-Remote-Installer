$ErrorActionPreference='SilentlyContinue'
$PSDefaultParameterValues['*:Encoding']='utf8BOM'
$org=$env:ORG_NAME
$tech=$env:TECH_NAME
$cfg=$env:RUSTDESK_CFG
$pw=$env:RUSTDESK_PW
$mailMode=$env:MAIL_MODE
$mailUrl=$env:MAIL_URL
$mailToken=$env:MAIL_TOKEN
$mailTo=$env:MAIL_TO
$mailFrom=$env:MAIL_FROM
$smtpHost=$env:SMTP_HOST
$smtpPort=$env:SMTP_PORT
$smtpUser=$env:SMTP_USER
$smtpPass=$env:SMTP_PASS
$smtpTls=$env:SMTP_TLS
if([string]::IsNullOrWhiteSpace($pw)){ $chars=(65..90)+(97..122)+(48..57); $pw=-join((1..12|%{[char]($chars|Get-Random)}})) }
$url='https://github.com/rustdesk/rustdesk/releases/latest'
$request=[System.Net.WebRequest]::Create($url)
$response=$request.GetResponse()
$realTagUrl=$response.ResponseUri.OriginalString
$RDLATEST=$realTagUrl.split('/')[-1].Trim('v')
$rdver=$null
try{ $rdver=(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\RustDesk\').Version }catch{}
function Apply-ConfigAndNotify{
  Set-Location "$env:ProgramFiles\RustDesk"
  if($cfg){ .\rustdesk.exe --config $cfg }
  if($pw){ .\rustdesk.exe --password $pw }
  $id=(.\rustdesk.exe --get-id)
  if($mailMode -eq 'php' -and $mailUrl -and $mailToken){
    try{ Invoke-WebRequest -Uri ($mailUrl+'?id='+$id+'&key='+$mailToken+'&org='+$org+'&tech='+$tech) | Out-Null }catch{}
  }elseif($mailMode -eq 'smtp' -and $smtpHost -and $mailTo -and $mailFrom){
    $body='RustDesk ID: '+$id+'; Org: '+$org+'; Tech: '+$tech
    $cred=$null
    if($smtpUser -and $smtpPass){ $secure=$smtpPass|ConvertTo-SecureString -AsPlainText -Force; $cred=New-Object System.Management.Automation.PSCredential($smtpUser,$secure) }
    try{ Send-MailMessage -From $mailFrom -To $mailTo -Subject 'RustDesk ID' -Body $body -SmtpServer $smtpHost -Port ([int]$smtpPort) -UseSsl:([bool]::Parse($smtpTls)) -Credential $cred }catch{}
  }
}
if($rdver -and $rdver -eq $RDLATEST){
  Set-Location "$env:ProgramFiles\RustDesk"
  Apply-ConfigAndNotify
  .\rustdesk.exe
  exit
}
if(!(Test-Path C:\Temp)){ New-Item -ItemType Directory -Force -Path C:\Temp | Out-Null }
Set-Location C:\Temp
Invoke-WebRequest ('https://github.com/rustdesk/rustdesk/releases/download/'+$RDLATEST+'/rustdesk-'+$RDLATEST+'-x86_64.exe') -OutFile 'rustdesk.exe'
Start-Process .\rustdesk.exe --silent-install
Start-Sleep -Seconds 10
Set-Location "$env:ProgramFiles\RustDesk"
Apply-ConfigAndNotify
$ServiceName='rustdesk'
$arrService=Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if($arrService -eq $null){
  Start-Process .\rustdesk.exe --install-service -Wait
  try{ Stop-Process -Name 'RustDesk' }catch{}
  Start-Sleep -Seconds 5
}
$arrService=Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if($arrService){ while($arrService.Status -ne 'Running'){ Start-Service $ServiceName; Start-Sleep -Seconds 5; $arrService.Refresh() } }
.\rustdesk.exe
Exit