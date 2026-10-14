# Revertir blindaje (REQUIERE PowerShell COMO ADMINISTRADOR)
$ErrorActionPreference = "Continue"
#Requires -RunAsAdministrator

Write-Output "=== Revertir ==="
powercfg /hibernate on
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 1 /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoClose /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoClose /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ShutdownWithoutLogon /t REG_DWORD /d 1 /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoRebootWithLoggedOnUsers /f

# Boton fisico -> Apagar (3). Cambia a 1 (suspender) o 0 (nada) si prefieres.
$SUB = "4f971e89-eebd-4455-a8de-9e59040e7347"
$PB  = "7648efa3-dd9c-4e3e-b566-50f929386280"
$schemes = powercfg /list | Select-String -Pattern "[0-9a-f]{8}-" | ForEach-Object {
  if ($_ -match "([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})") { $Matches[1].ToLower() }
} | Select-Object -Unique
foreach ($s in $schemes) {
  powercfg /SETACVALUEINDEX $s $SUB $PB 3
  powercfg /SETDCVALUEINDEX $s $SUB $PB 3
}
$active = powercfg /getactivescheme | ForEach-Object {
  if ($_ -match "([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})") { $Matches[1].ToLower() }
}
if ($active) { powercfg /S $active }
Write-Output "Revertido. Reinicia Explorer o el PC."
