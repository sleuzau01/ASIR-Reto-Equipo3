# ============================================================
# POST-INSTALACIÓN TPV RACING SANTANDER
# Ejecutar UNA VEZ como Administrador después de instalar Windows
# ============================================================

# Auto-elevar a administrador si es necesario
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "⚠️  Elevando a permisos de administrador..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Clear-Host
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  POST-INSTALACIÓN TPV RACING SANTANDER" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# VERIFICAR E INSTALAR GOOGLE CHROME
# ============================================================

Write-Host "Verificando Google Chrome..." -ForegroundColor Yellow

$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$chromeInstalled = Test-Path $chromePath

if (-not $chromeInstalled) {
    Write-Host "❌ Google Chrome NO está instalado" -ForegroundColor Red
    Write-Host "Descargando e instalando Chrome..." -ForegroundColor Cyan
    Write-Host ""
    
    try {
        # Descargar instalador de Chrome
        $chromeInstallerUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
        $installerPath = "$env:TEMP\chrome_installer.exe"
        
        Write-Host "[1/3] Descargando Chrome..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $chromeInstallerUrl -OutFile $installerPath -UseBasicParsing
        Write-Host "✅ Descarga completada" -ForegroundColor Green
        
        # Instalar Chrome silenciosamente
        Write-Host "[2/3] Instalando Chrome (esto puede tardar 1-2 minutos)..." -ForegroundColor Yellow
        Start-Process -FilePath $installerPath -ArgumentList "/silent /install" -Wait
        Write-Host "✅ Chrome instalado" -ForegroundColor Green
        
        # Limpiar instalador
        Write-Host "[3/3] Limpiando archivos temporales..." -ForegroundColor Yellow
        Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
        Write-Host "✅ Limpieza completada" -ForegroundColor Green
        
        # Verificar instalación
        Start-Sleep -Seconds 3
        if (Test-Path $chromePath) {
            Write-Host ""
            Write-Host "✅ Google Chrome instalado correctamente" -ForegroundColor Green
            Write-Host ""
        } else {
            Write-Host ""
            Write-Host "⚠️  Chrome instalado pero no detectado en ruta estándar" -ForegroundColor Yellow
            Write-Host "Verifica manualmente: $chromePath" -ForegroundColor Yellow
            Write-Host ""
        }
        
    } catch {
        Write-Host ""
        Write-Host "❌ ERROR al instalar Chrome: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Instala Chrome manualmente desde: https://www.google.com/chrome/" -ForegroundColor Yellow
        Write-Host "Luego vuelve a ejecutar este script" -ForegroundColor Yellow
        Write-Host ""
        pause
        exit
    }
    
} else {
    Write-Host "✅ Google Chrome ya está instalado" -ForegroundColor Green
    Write-Host ""
}

# ============================================================
# CONFIGURACIÓN DEL BAR
# ============================================================

# Configuración fija del proxy
$PROXY_IP = "192.168.20.5"
$PROXY_PORT = "3128"

# Base de datos de credenciales
$credenciales = @{
    1 = "Bar12026"
    2 = "Bar22026"
    3 = "Bar3Bar2026"
    4 = "Bar4Bar2026"
    5 = "Bar5Bar2026"
    6 = "Bar6Bar2026"
    7 = "Bar7Bar2026"
    8 = "Bar8Bar2026"
    9 = "Bar9Bar2026"
    10 = "Bar10Bar2026"
    11 = "Bar11Bar2026"
    12 = "Bar12Bar2026"
    13 = "Bar13Bar2026"
    14 = "Bar14Bar2026"
    15 = "Bar15Bar2026"
    16 = "Bar16Bar2026"
}

# Solicitar número de bar
Write-Host "¿Qué número de bar eres? (1-16)" -ForegroundColor Yellow
do {
    $barNumero = Read-Host "Número de bar"
    
    if ($barNumero -match '^\d+$' -and [int]$barNumero -ge 1 -and [int]$barNumero -le 16) {
        $valido = $true
    } else {
        Write-Host "❌ Número inválido. Debe ser entre 1 y 16" -ForegroundColor Red
        $valido = $false
    }
} while (-not $valido)

# Obtener credenciales
$usuario = "bar${barNumero}"
$password = $credenciales[[int]$barNumero]

# Mostrar resumen
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "CONFIGURACIÓN DETECTADA:" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host "Bar: $barNumero"
Write-Host "Usuario Proxy: $usuario"
Write-Host "Contraseña Proxy: $password"
Write-Host "Servidor Proxy: ${PROXY_IP}:${PROXY_PORT}"
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

$confirmar = Read-Host "¿Los datos son correctos? (S/N)"
if ($confirmar -ne "S" -and $confirmar -ne "s") {
    Write-Host "Instalación cancelada" -ForegroundColor Yellow
    pause
    exit
}

Write-Host ""
Write-Host "Iniciando instalación..." -ForegroundColor Cyan
Write-Host ""

# [1/5] Crear estructura de carpetas
Write-Host "[1/5] Creando estructura de carpetas..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "C:\tpv" -Force | Out-Null
New-Item -ItemType Directory -Path "C:\tpv\chrome-kiosk-profile" -Force | Out-Null
Write-Host "✅ Carpetas creadas" -ForegroundColor Green

# [2/5] Guardar configuración
Write-Host "[2/5] Guardando configuración del bar..." -ForegroundColor Yellow

$config = @"
# Configuración Bar $barNumero
BAR_NUMERO=$barNumero
PROXY_USUARIO=$usuario
PROXY_PASSWORD=$password
PROXY_IP=$PROXY_IP
PROXY_PORT=$PROXY_PORT
"@

$config | Out-File -FilePath "C:\tpv\config.txt" -Encoding UTF8
Write-Host "✅ Configuración guardada" -ForegroundColor Green

# [3/5] Crear script de kiosco
Write-Host "[3/5] Creando script modo kiosco..." -ForegroundColor Yellow

$scriptKiosco = @"
# ============================================================
# MODO KIOSCO TPV - BAR $barNumero
# Se ejecuta automáticamente al iniciar Windows
# ============================================================

# Configuración
`$proxyIP = "$PROXY_IP"
`$proxyPort = "$PROXY_PORT"
`$proxyUsuario = "$usuario"
`$proxyPassword = "$password"
`$url = "http://localhost/wordpress/panel-tpv/"
`$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
`$kioskProfile = "C:\tpv\chrome-kiosk-profile"

# Esperar a que Windows termine de cargar
Start-Sleep -Seconds 15

# Cerrar cualquier Chrome abierto
Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Configurar proxy en el sistema
`$regProxy = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
Set-ItemProperty -Path `$regProxy -Name ProxyEnable -Value 1 -Force
Set-ItemProperty -Path `$regProxy -Name ProxyServer -Value "`${proxyIP}:`${proxyPort}" -Force

# Crear perfil si no existe
if (-not (Test-Path `$kioskProfile)) {
    New-Item -ItemType Directory -Path `$kioskProfile -Force | Out-Null
}

# Construir proxy autenticado
`$proxyAuth = "`${proxyUsuario}:`${proxyPassword}@`${proxyIP}:`${proxyPort}"

# Lanzar Chrome en modo kiosco con proxy
`$chromeArgs = @(
    "--kiosk",
    `$url,
    "--user-data-dir=```"`$kioskProfile```"",
    "--proxy-server=```"http://`${proxyAuth}```"",
    "--no-first-run",
    "--disable-infobars",
    "--disable-session-crashed-bubble",
    "--disable-features=TranslateUI"
)

Start-Process -FilePath `$chromePath -ArgumentList `$chromeArgs
"@

$scriptKiosco | Out-File -FilePath "C:\tpv\IniciarKiosco.ps1" -Encoding UTF8
Write-Host "✅ Script kiosco creado" -ForegroundColor Green

# [4/5] Configurar tarea programada
Write-Host "[4/5] Configurando inicio automático..." -ForegroundColor Yellow

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File C:\tpv\IniciarKiosco.ps1"
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0

try {
    Register-ScheduledTask -TaskName "RacingTPV-Bar${barNumero}" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
    Write-Host "✅ Tarea programada creada" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Error al crear tarea programada: $($_.Exception.Message)" -ForegroundColor Red
}

# [5/5] Configurar políticas
Write-Host "[5/5] Configurando políticas de ejecución..." -ForegroundColor Yellow
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force -ErrorAction SilentlyContinue
Write-Host "✅ Políticas configuradas" -ForegroundColor Green

# Crear archivo resumen
$resumen = @"
==========================================
INSTALACIÓN COMPLETADA
Bar $barNumero - Racing Santander
==========================================

FECHA: $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")
PC: $env:COMPUTERNAME
USUARIO: $env:USERNAME

==========================================
CONFIGURACIÓN
==========================================

Bar: $barNumero
Usuario Proxy: $usuario
Contraseña Proxy: $password
Servidor Proxy: ${PROXY_IP}:${PROXY_PORT}

==========================================
ARCHIVOS CREADOS
==========================================

C:\tpv\config.txt
C:\tpv\IniciarKiosco.ps1
C:\tpv\chrome-kiosk-profile\

==========================================
TAREA PROGRAMADA
==========================================

Nombre: RacingTPV-Bar${barNumero}
Trigger: Al iniciar sesión
Script: C:\tpv\IniciarKiosco.ps1

==========================================
PRÓXIMOS PASOS
==========================================

1. REINICIAR el PC
2. Al iniciar sesión, el kiosco se activará
3. Chrome abrirá automáticamente en modo kiosco
4. Conectará al proxy automáticamente

==========================================
"@

$resumen | Out-File -FilePath "C:\tpv\instalacion-bar${barNumero}.txt" -Encoding UTF8
$resumen | Out-File -FilePath "$env:USERPROFILE\Desktop\Instalacion-Bar${barNumero}.txt" -Encoding UTF8

# Mostrar resumen final
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "✅ INSTALACIÓN COMPLETADA EXITOSAMENTE" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "BAR: $barNumero" -ForegroundColor Cyan
Write-Host "USUARIO: $usuario" -ForegroundColor Cyan
Write-Host "CONTRASEÑA: $password" -ForegroundColor Cyan
Write-Host "PROXY: ${PROXY_IP}:${PROXY_PORT}" -ForegroundColor Cyan
Write-Host ""
Write-Host "============================================" -ForegroundColor Yellow
Write-Host "⚠️  REINICIA EL PC AHORA" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Al reiniciar:" -ForegroundColor White
Write-Host "1. El sistema iniciará automáticamente" -ForegroundColor White
Write-Host "2. Chrome se abrirá en modo kiosco" -ForegroundColor White
Write-Host "3. Conectará al proxy automáticamente" -ForegroundColor White
Write-Host "4. Mostrará el panel TPV" -ForegroundColor White
Write-Host ""

$reiniciar = Read-Host "¿Deseas REINICIAR el PC ahora? (S/N)"

if ($reiniciar -eq "S" -or $reiniciar -eq "s") {
    Write-Host ""
    Write-Host "Reiniciando en 10 segundos..." -ForegroundColor Yellow
    Write-Host "Presiona Ctrl+C para cancelar" -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    # Auto-eliminar este script
    Remove-Item $PSCommandPath -Force -ErrorAction SilentlyContinue
    
    Restart-Computer -Force
} else {
    Write-Host ""
    Write-Host "⚠️  RECUERDA REINICIAR MANUALMENTE" -ForegroundColor Yellow
    Write-Host ""
    pause
    
    # Auto-eliminar este script
    Remove-Item $PSCommandPath -Force -ErrorAction SilentlyContinue
}
