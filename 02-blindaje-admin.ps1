# 02 - Blindaje total (REQUIERE PowerShell COMO ADMINISTRADOR)
# Reversible con .\revertir-blindaje.ps1 (tambien como admin)
$ErrorActionPreference = "Continue"
#Requires -RunAsAdministrator

Write-Output "=== 1. Desactivar hibernacion (quita Hibernar y Fast Startup) ==="
powercfg /hibernate off
Write-Output "hibernate exit: $LASTEXITCODE"

Write-Output "=== 2. Desactivar Fast Startup (apagado hibrido) ==="
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f

Write-Output "=== 3. RustDesk servicio auto + recuperacion + arranque ==="
sc.exe config RustDesk start= auto
sc.exe failure RustDesk reset= 86400 actions= restart/60000/restart/60000/restart/60000
sc.exe failureflag RustDesk 1
net start RustDesk

Write-Output "=== 4. Ocultar Apagar/Reiniciar/Suspender del Inicio (NoClose) ==="
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoClose /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoClose /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ShutdownWithoutLogon /t REG_DWORD /d 0 /f

Write-Output "=== 5. Evitar reinicio automatico por Windows Update con sesion iniciada ==="
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoRebootWithLoggedOnUsers /t REG_DWORD /d 1 /f

Write-Output "=== VERIFICACION ==="
powercfg /a
sc.exe query RustDesk
sc.exe qfailure RustDesk
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoClose
Write-Output "=== FIN - Cierra sesion o reinicia Explorer para ver el menu sin Apagar ==="
