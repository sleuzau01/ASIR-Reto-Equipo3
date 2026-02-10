# ===============================================================
# Script de Post-Instalación para Terminales TPV Racing Santander
# Versión: 2.1 FIXED
# Fecha: 10/02/2026
# ===============================================================

# 1. AUTO-ELEVACIÓN A ADMINISTRADOR (Obligatorio)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "⚠️  Elevando permisos..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 2. CONFIGURACIÓN CENTRAL (¡REVISA ESTO!)
$ALB_DNS = "racing-alb-123456789.eu-central-1.elb.amazonaws.com" # <--- PON AQUÍ TU DNS REAL
$PROXY_IP = "192.168.20.5"
$PROXY_PORT = "3128"

# Usuarios Squid (Deben coincidir con tu servidor Proxy)
$credenciales = @{
    1 = @{ u="bar1"; p="Bar12026" }; 2 = @{ u="bar2"; p="Bar22026" };
    3 = @{ u="bar3"; p="Bar32026" }; 4 = @{ u="bar4"; p="Bar42026" };
    5 = @{ u="bar5"; p="Bar52026" }; 6 = @{ u="bar6"; p="Bar62026" };
    7 = @{ u="bar7"; p="Bar72026" }; 8 = @{ u="bar8"; p="Bar82026" };
    9 = @{ u="bar9"; p="Bar92026" }; 10 = @{ u="bar10"; p="Bar102026" };
    11 = @{ u="bar11"; p="Bar112026" }; 12 = @{ u="bar12"; p="Bar122026" };
    13 = @{ u="bar13"; p="Bar132026" }; 14 = @{ u="bar14"; p="Bar142026" };
    15 = @{ u="bar15"; p="Bar152026" }; 16 = @{ u="bar16"; p="Bar162026" }
}

# 3. INSTALACIÓN SILENCIOSA DE CHROME
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $chromePath)) {
    Write-Host "📥 Instalando Google Chrome..." -ForegroundColor Cyan
    $installer = "$env:TEMP\chrome_install.exe"
    Invoke-WebRequest "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile $installer
    Start-Process -FilePath $installer -ArgumentList "/silent /install" -Wait
    Remove-Item $installer -ErrorAction SilentlyContinue
}

# 4. SELECCIÓN DE BAR
Clear-Host
Write-Host "🏟️  CONFIGURACIÓN TPV RACING" -ForegroundColor Green
do {
    $barID = Read-Host "👉 Introduce NÚMERO DE BAR (1-16)"
} until ($barID -match '^\d+$' -and [int]$barID -ge 1 -and [int]$barID -le 16)

$user = $credenciales[[int]$barID].u
$pass = $credenciales[[int]$barID].p
$finalURL = "http://$ALB_DNS/wordpress/tpv-bar/?bar_id=$barID"

# 5. CREAR ESTRUCTURA
New-Item -ItemType Directory -Path "C:\tpv\chrome-kiosk-profile" -Force | Out-Null

# 6. GENERAR LANZADOR KIOSCO
$launcherScript = @"
`$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
`$args = @(
    "--kiosk",
    "$finalURL",
    "--proxy-server=`"http://$PROXY_IP:$PROXY_PORT`"",
    "--user-data-dir=C:\tpv\chrome-kiosk-profile",
    "--no-first-run",
    "--disable-infobars",
    "--start-maximized"
)
# Configurar Proxy en Registro Windows por si acaso
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 1 -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyServer -Value "$PROXY_IP:$PROXY_PORT" -Force

# Matar Chrome viejo y lanzar nuevo
Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Process -FilePath `$chrome -ArgumentList `$args
"@

$launcherScript | Out-File "C:\tpv\IniciarKiosco.ps1" -Encoding UTF8

# 7. TAREA PROGRAMADA (AUTO-INICIO)
$taskName = "RacingTPV-AutoStart"
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -File C:\tpv\IniciarKiosco.ps1"
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User $env:USERNAME -RunLevel Highest | Out-Null

Write-Host ""
Write-Host "✅ INSTALACIÓN COMPLETADA. EL PC SE REINICIARÁ EN 5 SEGUNDOS." -ForegroundColor Green
Start-Sleep -Seconds 5
Restart-Computer -Force