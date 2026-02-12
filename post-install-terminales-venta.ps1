# ==============================================================================
# SCRIPT: Instalador TPV Racing
# DESCRIPCIÓN: Configura Chrome en modo Kiosco con perfil aislado y auto-inicio.
# ==============================================================================

$ErrorActionPreference = "Stop"

# --- FUNCIONES VISUALES ---
function Write-Header {
    param([string]$text)
    Write-Host "`n" + ("=" * 40) -ForegroundColor Cyan
    Write-Host "  $text" -ForegroundColor Cyan -NoNewline
    Write-Host " "
    Write-Host ("=" * 40) -ForegroundColor Cyan
}

# --- PASO 1: ELEVACIÓN DE PRIVILEGIOS ---
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsPrincipal]::CurrentRoleToCapabilityMapping.Administrator)) {
    Write-Host "`n[!] Se requieren permisos de administrador. Elevando..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Clear-Host
Write-Header "TPV RACING - INSTALADOR"

# --- PASO 2: VERIFICACIÓN DE REQUISITOS ---
Write-Host "[*] Verificando Google Chrome..." -ForegroundColor Gray
$chromePath = "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $chromePath)) { $chromePath = "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe" }

if (Test-Path $chromePath) {
    Write-Host "    - Chrome detectado: OK" -ForegroundColor Green
} else {
    Write-Host "    - ERROR: Chrome no instalado." -ForegroundColor Red
    pause ; exit
}

# --- PASO 3: ENTRADA DE DATOS ---
Write-Host "`n[*] CONFIGURACIÓN DEL BAR" -ForegroundColor Yellow
$barID = ""
while ($barID -notmatch '^(?:[1-9]|1[0-6])$') {
    $barID = Read-Host "    - Introduce el ID del Bar (1-16)"
}

$ALB_DNS = "localhost"
$url = "http://$ALB_DNS/wordpress/tpv-bar/?bar_id=$barID"
$profileDir = "C:\tpv\perfil_chrome"

# --- PASO 4: PREPARACIÓN DEL SISTEMA ---
Write-Host "`n[*] CREANDO ENTORNO..." -ForegroundColor Yellow
if (!(Test-Path $profileDir)) {
    New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
    Write-Host "    - Directorio de perfil creado." -ForegroundColor Gray
}

# --- PASO 5: PERSISTENCIA (ACCESO DIRECTO) ---
Write-Host "[*] CONFIGURANDO AUTO-INICIO..." -ForegroundColor Yellow
try {
    $startupFolder = [Environment]::GetFolderPath("Startup")
    $shortcutPath = Join-Path $startupFolder "IniciarTPV.lnk"
    
    $wsh = New-Object -ComObject WScript.Shell
    $shortcut = $wsh.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $chromePath
    $shortcut.Arguments = "--kiosk --user-data-dir=`"$profileDir`" --no-first-run --no-default-browser-check $url"
    $shortcut.Save()
    Write-Host "    - Acceso directo creado en Carpeta de Inicio." -ForegroundColor Green
} catch {
    Write-Host "    - Error creando acceso directo." -ForegroundColor Red
}

# --- PASO 6: LANZAMIENTO INICIAL ---
Write-Header "INSTALACIÓN COMPLETADA"
Write-Host "El TPV se iniciará automáticamente con Windows." -ForegroundColor Gray
Write-Host "Lanzando vista previa en 3 segundos..." -ForegroundColor Cyan
Start-Sleep -Seconds 3

Start-Process $chromePath -ArgumentList "--kiosk --user-data-dir=`"$profileDir`" --no-first-run --no-default-browser-check $url"