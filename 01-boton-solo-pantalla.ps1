# 01 - Boton fisico = solo apaga pantalla + nunca suspender (NO requiere admin)
# Ejecutar en PowerShell normal. Aplica a TODOS los planes y reactiva el actual.
$ErrorActionPreference = "Continue"

$SUB   = "4f971e89-eebd-4455-a8de-9e59040e7347" # SUB_BUTTONS
$PB    = "7648efa3-dd9c-4e3e-b566-50f929386280" # Power button action (0=nada,1=sleep,2=hiber,3=apagar,4=pantalla)
$SB    = "96996bc0-ad50-47ec-923b-6f41874dd9eb" # Sleep button action
$LID   = "5ca83367-6e45-459f-a27b-476b1d01c936" # Lid close
$FORCE = "833a6b62-dfa4-46d1-82f8-e09e34d029d6" # Forced button/lid shutdown (0=off)
$SSUB  = "238c9fa8-0aad-41ed-83f4-97be242c8f20" # SUB_SLEEP
$STBY  = "29f6c1db-86da-48c5-9fdb-f2b67b1f44da" # Sleep after (0=nunca)
$HIB   = "9d7815a6-7ee4-497e-8888-515a05f02364" # Hibernate after (0=nunca)
$HYB   = "94ac6d29-73ce-41a6-809f-6363ba21b47e" # Hybrid sleep (0=off)

# Detectar planes instalados + activo
$schemes = powercfg /list | Select-String -Pattern "[0-9a-f]{8}-" | ForEach-Object {
  if ($_ -match "([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})") { $Matches[1].ToLower() }
} | Select-Object -Unique
$active = powercfg /getactivescheme | ForEach-Object {
  if ($_ -match "([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})") { $Matches[1].ToLower() }
}
Write-Output "Planes: $($schemes -join ', ')"
Write-Output "Activo: $active"

foreach ($s in $schemes) {
  powercfg /SETACVALUEINDEX $s $SUB $PB 4;     powercfg /SETDCVALUEINDEX $s $SUB $PB 4
  powercfg /SETACVALUEINDEX $s $SUB $SB 0;     powercfg /SETDCVALUEINDEX $s $SUB $SB 0
  powercfg /SETACVALUEINDEX $s $SUB $LID 0;    powercfg /SETDCVALUEINDEX $s $SUB $LID 0
  powercfg /SETACVALUEINDEX $s $SUB $FORCE 0;  powercfg /SETDCVALUEINDEX $s $SUB $FORCE 0
  powercfg /SETACVALUEINDEX $s $SSUB $STBY 0;  powercfg /SETDCVALUEINDEX $s $SSUB $STBY 0
  powercfg /SETACVALUEINDEX $s $SSUB $HIB 0;   powercfg /SETDCVALUEINDEX $s $SSUB $HIB 0
  powercfg /SETACVALUEINDEX $s $SSUB $HYB 0;   powercfg /SETDCVALUEINDEX $s $SSUB $HYB 0
}
if ($active) { powercfg /S $active }

Write-Output "=== Verificacion (plan activo) ==="
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\$active\$SUB\$PB" 2>&1 | Select-String "SettingIndex"
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\$active\$SSUB\$STBY" 2>&1 | Select-String "SettingIndex"
Write-Output "OK: boton=0x4 (pantalla), sleep=0x0 (nunca). Prueba pulsar el boton fisico."
