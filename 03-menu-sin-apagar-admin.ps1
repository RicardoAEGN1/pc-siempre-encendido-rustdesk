# 03 - Menu Inicio sin Apagar: solo Suspender + Reiniciar (REQUIERE ADMIN)
# El boton "Apagar" desaparece del menu Inicio. Lo mas cercano es Suspender.
# El apagado real SOLO queda por terminal: shutdown /s /t 0  o  Stop-Computer
# Reversible: borra las claves Hide* o ejecuta revertir-blindaje.ps1
$ErrorActionPreference = "Continue"
#Requires -RunAsAdministrator

Write-Output "=== 1. Quitar NoClose total (volvemos a menu granular) ==="
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoClose /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoClose /f

Write-Output "=== 2. Ocultar Apagar, Hibernar Y Reiniciar (solo queda Suspender) ==="
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start" /v HideShutDown /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start" /v HideHibernate /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start" /v HideRestart /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start" /v HideSleep /t REG_DWORD /d 0 /f

Write-Output "=== 2b. Ocultar 'Instalar actualizaciones y apagar/reiniciar' ==="
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAUShutdownOption /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAUAsDefaultShutdownOption /t REG_DWORD /d 1 /f

Write-Output "=== 3. Boton de energia del menu = Suspender (UIBUTTON=0) ==="
$SUB = "4f971e89-eebd-4455-a8de-9e59040e7347"
$UI  = "a7066653-8d6c-40a8-910e-a1f54b84c7e5"
$schemes = powercfg /list | Select-String -Pattern "[0-9a-f]{8}-" | ForEach-Object {
  if ($_ -match "([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})") { $Matches[1].ToLower() }
} | Select-Object -Unique
foreach ($s in $schemes) {
  powercfg /SETACVALUEINDEX $s $SUB $UI 0
  powercfg /SETDCVALUEINDEX $s $SUB $UI 0
}
$active = powercfg /getactivescheme | ForEach-Object {
  if ($_ -match "([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})") { $Matches[1].ToLower() }
}
if ($active) { powercfg /S $active }

Write-Output "=== 4. Login sin boton de apagado (se mantiene) ==="
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ShutdownWithoutLogon /t REG_DWORD /d 0 /f

Write-Output "=== VERIFICACION ==="
reg query "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start"
Write-Output "=== FIN - Reiniciando Explorer para aplicar el menu ==="
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
