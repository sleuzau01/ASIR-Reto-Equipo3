# ===============================================================
# Script de Post-Instalación para Terminales TPV Racing Santander
# Versión: 2.0 con parámetro bar_id
# Fecha: 08/02/2026
# ===============================================================

# Auto-elevar a administrador si es necesario
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "⚠️  Elevando a permisos de administrador..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🏟️  CONFIGURACIÓN TPV - RACING DE SANTANDER" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# ===============================================================
# BLOQUE 1: VERIFICACIÓN E INSTALACIÓN DE GOOGLE CHROME
# ===============================================================

$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$chromeInstalled = Test-Path $chromePath

if (-not $chromeInstalled) {
    Write-Host "[PASO 1/5] Chrome NO detectado. Iniciando descarga..." -ForegroundColor Yellow
    
    try {
        $chromeInstallerUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
        $installerPath = "$env:TEMP\chrome_installer.exe"
        
        Write-Host "  📥 Descargando Chrome..." -NoNewline
        Invoke-WebRequest -Uri $chromeInstallerUrl -OutFile $installerPath -UseBasicParsing
        Write-Host " ✅ Completado" -ForegroundColor Green
        
        Write-Host "  🔧 Instalando Chrome (esto puede tardar 1-2 minutos)..." -NoNewline
        Start-Process -FilePath $installerPath -ArgumentList "/silent /install" -Wait
        Write-Host " ✅ Completado" -ForegroundColor Green
        
        Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
        
        # Verificar instalación
        if (Test-Path $chromePath) {
            Write-Host "  ✅ Chrome instalado correctamente" -ForegroundColor Green
        } else {
            throw "Chrome no se instaló correctamente"
        }
        
    } catch {
        Write-Host " ❌ ERROR" -ForegroundColor Red
        Write-Host ""
        Write-Host "ERROR al instalar Chrome: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "SOLUCIÓN MANUAL:" -ForegroundColor Yellow
        Write-Host "  1. Descarga Chrome desde: https://www.google.com/chrome/" -ForegroundColor White
        Write-Host "  2. Instálalo manualmente" -ForegroundColor White
        Write-Host "  3. Vuelve a ejecutar este script" -ForegroundColor White
        Write-Host ""
        Read-Host "Presiona ENTER para salir"
        exit 1
    }
} else {
    Write-Host "[PASO 1/5] ✅ Chrome ya está instalado" -ForegroundColor Green
}

Write-Host ""

# ===============================================================
# BLOQUE 2: CONFIGURACIÓN DE PROXY Y CREDENCIALES
# ===============================================================

Write-Host "[PASO 2/5] Configuración de Proxy Squid" -ForegroundColor Cyan
Write-Host ""

$PROXY_IP = "192.168.20.5"
$PROXY_PORT = "3128"

# Base de datos de credenciales por bar
$credenciales = @{
    1 = @{ usuario = "bar1"; password = "Bar12026" }
    2 = @{ usuario = "bar2"; password = "Bar22026" }
    3 = @{ usuario = "bar3"; password = "Bar3Bar2026" }
    4 = @{ usuario = "bar4"; password = "Bar42026" }
    5 = @{ usuario = "bar5"; password = "Bar52026" }
    6 = @{ usuario = "bar6"; password = "Bar62026" }
    7 = @{ usuario = "bar7"; password = "Bar72026" }
    8 = @{ usuario = "bar8"; password = "Bar82026" }
    9 = @{ usuario = "bar9"; password = "Bar92026" }
    10 = @{ usuario = "bar10"; password = "Bar102026" }
    11 = @{ usuario = "bar11"; password = "Bar112026" }
    12 = @{ usuario = "bar12"; password = "Bar122026" }
    13 = @{ usuario = "bar13"; password = "Bar132026" }
    14 = @{ usuario = "bar14"; password = "Bar142026" }
    15 = @{ usuario = "bar15"; password = "Bar152026" }
    16 = @{ usuario = "bar16"; password = "Bar162026" }
}

# ===============================================================
# BLOQUE 3: VALIDACIÓN DE ENTRADA DE USUARIO
# ===============================================================

Write-Host "Introduce el número de bar (1-16):" -ForegroundColor Yellow
Write-Host ""

$valido = $false
do {
    Write-Host "  🏪 Número de bar: " -NoNewline -ForegroundColor White
    $barNumero = Read-Host
    
    if ($barNumero -match '^\d+$' -and [int]$barNumero -ge 1 -and [int]$barNumero -le 16) {
        $valido = $true
        Write-Host "  ✅ Bar $barNumero seleccionado" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Número inválido. Debe ser entre 1 y 16" -ForegroundColor Red
        Write-Host ""
    }
} while (-not $valido)

Write-Host ""

# Obtener credenciales del bar seleccionado
$barConfig = $credenciales[[int]$barNumero]
$usuario = $barConfig.usuario
$password = $barConfig.password

Write-Host "  📋 Configuración detectada:" -ForegroundColor Cyan
Write-Host "     • Bar: $barNumero" -ForegroundColor White
Write-Host "     • Usuario Proxy: $usuario" -ForegroundColor White
Write-Host "     • Servidor Proxy: ${PROXY_IP}:${PROXY_PORT}" -ForegroundColor White
Write-Host ""

# ===============================================================
# BLOQUE 4: CREACIÓN DE ESTRUCTURA DE ARCHIVOS
# ===============================================================

Write-Host "[PASO 3/5] Creando estructura de archivos..." -ForegroundColor Cyan

try {
    # Crear directorio principal TPV
    New-Item -ItemType Directory -Path "C:\tpv" -Force | Out-Null
    Write-Host "  ✅ Directorio C:\tpv creado" -ForegroundColor Green
    
    # Crear directorio de perfil Chrome
    New-Item -ItemType Directory -Path "C:\tpv\chrome-kiosk-profile" -Force | Out-Null
    Write-Host "  ✅ Perfil de Chrome creado" -ForegroundColor Green
    
    # Guardar configuración en archivo
    $config = @"
# Configuración Terminal TPV - Racing Santander
# Generado: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')

BAR_NUMERO=$barNumero
PROXY_USUARIO=$usuario
PROXY_PASSWORD=$password
PROXY_IP=$PROXY_IP
PROXY_PORT=$PROXY_PORT
"@
    
    $config | Out-File -FilePath "C:\tpv\config.txt" -Encoding UTF8
    Write-Host "  ✅ Archivo de configuración guardado" -ForegroundColor Green
    
} catch {
    Write-Host "  ❌ ERROR al crear archivos: $_" -ForegroundColor Red
    Read-Host "Presiona ENTER para salir"
    exit 1
}

Write-Host ""

# ===============================================================
# BLOQUE 5: GENERACIÓN DE SCRIPT DE MODO KIOSCO
# ===============================================================

Write-Host "[PASO 4/5] Generando script de inicio automático..." -ForegroundColor Cyan

# ✅✅✅ CAMBIO CRÍTICO: URL INCLUYE ?bar_id=X ✅✅✅
$urlTPV = "http://localhost/wordpress/tpv-bar/?bar_id=$barNumero"

$scriptKiosco = @"
# ===============================================================
# Script de Inicio Automático TPV - Bar $barNumero
# Generado: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')
# ===============================================================

# Configuración
`$chromePath = "$chromePath"
`$proxyIP = "$PROXY_IP"
`$proxyPort = "$PROXY_PORT"
`$proxyUsuario = "$usuario"
`$proxyPassword = "$password"
`$barNumero = $barNumero
`$url = "$urlTPV"

# Log de inicio
`$logPath = "C:\tpv\tpv-kiosk.log"
Add-Content -Path `$logPath -Value "[`$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Iniciando TPV Bar `$barNumero"

# Esperar a que Windows termine de cargar
Write-Host "Esperando inicio completo del sistema..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Cerrar cualquier instancia de Chrome abierta
try {
    Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 2
} catch {
    # No hay Chrome abierto
}

# Configurar proxy en el registro de Windows
Write-Host "Configurando proxy del sistema..." -ForegroundColor Cyan
try {
    `$regProxy = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    Set-ItemProperty -Path `$regProxy -Name ProxyEnable -Value 1 -Force
    Set-ItemProperty -Path `$regProxy -Name ProxyServer -Value "`${proxyIP}:`${proxyPort}" -Force
    Write-Host "✅ Proxy configurado: `${proxyIP}:`${proxyPort}" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Error al configurar proxy: `$_" -ForegroundColor Yellow
}

# Lanzar Chrome en modo kiosco
Write-Host "Iniciando TPV en modo kiosco..." -ForegroundColor Green
Write-Host "  • URL: `$url" -ForegroundColor White
Write-Host "  • Bar: `$barNumero" -ForegroundColor White
Write-Host ""

`$chromeArgs = @(
    "--kiosk",
    `$url,
    "--proxy-server=`"http://`${proxyUsuario}:`${proxyPassword}@`${proxyIP}:`${proxyPort}`"",
    "--user-data-dir=C:\tpv\chrome-kiosk-profile",
    "--no-first-run",
    "--no-default-browser-check",
    "--disable-infobars",
    "--disable-session-crashed-bubble",
    "--disable-features=TranslateUI",
    "--disable-popup-blocking",
    "--start-maximized"
)

try {
    Start-Process -FilePath `$chromePath -ArgumentList `$chromeArgs
    Add-Content -Path `$logPath -Value "[`$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] TPV iniciado correctamente"
} catch {
    Add-Content -Path `$logPath -Value "[`$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] ERROR: `$_"
    Write-Host "❌ ERROR al iniciar Chrome: `$_" -ForegroundColor Red
}
"@

try {
    $scriptKiosco | Out-File -FilePath "C:\tpv\IniciarKiosco.ps1" -Encoding UTF8
    Write-Host "  ✅ Script de kiosco generado (C:\tpv\IniciarKiosco.ps1)" -ForegroundColor Green
} catch {
    Write-Host "  ❌ ERROR al generar script: $_" -ForegroundColor Red
    Read-Host "Presiona ENTER para salir"
    exit 1
}

Write-Host ""

# ===============================================================
# BLOQUE 6: CONFIGURACIÓN DE TAREA PROGRAMADA
# ===============================================================

Write-Host "[PASO 5/5] Configurando inicio automático al login..." -ForegroundColor Cyan

try {
    # Eliminar tarea anterior si existe
    $taskName = "RacingTPV-Bar${barNumero}"
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    
    if ($existingTask) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "  🗑️  Tarea anterior eliminada" -ForegroundColor Yellow
    }
    
    # Crear nueva tarea programada
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File C:\tpv\IniciarKiosco.ps1"
    $trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
    
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
    
    Write-Host "  ✅ Tarea programada '$taskName' creada" -ForegroundColor Green
    Write-Host "     El TPV se iniciará automáticamente al encender el PC" -ForegroundColor White
    
} catch {
    Write-Host "  ❌ ERROR al crear tarea programada: $_" -ForegroundColor Red
    Write-Host "  ⚠️  El TPV NO se iniciará automáticamente" -ForegroundColor Yellow
}

Write-Host ""

# ===============================================================
# BLOQUE 7: RESUMEN FINAL
# ===============================================================

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ✅  INSTALACIÓN COMPLETADA CON ÉXITO" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 RESUMEN DE CONFIGURACIÓN:" -ForegroundColor Yellow
Write-Host "  • Bar configurado: $barNumero" -ForegroundColor White
Write-Host "  • URL TPV: $urlTPV" -ForegroundColor White
Write-Host "  • Proxy: ${PROXY_IP}:${PROXY_PORT}" -ForegroundColor White
Write-Host "  • Usuario Proxy: $usuario" -ForegroundColor White
Write-Host "  • Directorio: C:\tpv\" -ForegroundColor White
Write-Host "  • Inicio automático: ACTIVADO" -ForegroundColor Green
Write-Host ""
Write-Host "🔄 PRÓXIMOS PASOS:" -ForegroundColor Yellow
Write-Host "  1. Reinicia el ordenador" -ForegroundColor White
Write-Host "  2. El TPV se abrirá automáticamente al iniciar sesión" -ForegroundColor White
Write-Host "  3. Selecciona tu usuario (María, Pedro, Laura, Admin)" -ForegroundColor White
Write-Host "  4. Comienza a registrar ventas" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  IMPORTANTE:" -ForegroundColor Red
Write-Host "  • Asegúrate de que el servidor WordPress esté accesible" -ForegroundColor White
Write-Host "  • Verifica que el proxy Squid (${PROXY_IP}) esté activo" -ForegroundColor White
Write-Host "  • El PC debe estar conectado a la red del estadio" -ForegroundColor White
Write-Host ""

# ===============================================================
# BLOQUE 8: AUTO-ELIMINACIÓN DEL SCRIPT
# ===============================================================

Write-Host "🗑️  Este script se auto-eliminará en 5 segundos..." -ForegroundColor DarkGray
Start-Sleep -Seconds 5

try {
    Remove-Item $PSCommandPath -Force -ErrorAction SilentlyContinue
} catch {
    # Ignorar error si no se puede auto-eliminar
}

Write-Host ""
Write-Host "Presiona ENTER para reiniciar el PC ahora, o cierra esta ventana para hacerlo más tarde..." -ForegroundColor Yellow
$respuesta = Read-Host

if ($respuesta -eq "" -or $respuesta -match '^(s|si|y|yes)$') {
    Write-Host "Reiniciando en 3 segundos..." -ForegroundColor Green
    Start-Sleep -Seconds 3
    Restart-Computer -Force
}