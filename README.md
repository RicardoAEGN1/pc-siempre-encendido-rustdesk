# PC siempre encendido + RustDesk (Windows 10/11)

Deja el PC imposible de apagar por error y siempre accesible por RustDesk:
- Botón físico de encendido = **solo apaga la pantalla** (nunca apaga el PC).
- Menú Inicio **sin Apagar**: solo Suspender + Reiniciar.
- Nunca suspender / hibernar por tiempo.
- RustDesk como servicio automático + recuperación.
- Apagado real SOLO por terminal.

Probado en Windows 11 Pro. Reversible.

## Uso en otro PC

1. Instala [RustDesk](https://rustdesk.com) y configura contraseña permanente.
2. Sin admin:
   ```powershell
   .\01-boton-solo-pantalla.ps1
   ```
   Pulsa el botón físico para probar: solo se apaga la pantalla.
3. Como administrador:
   ```powershell
   .\02-blindaje-admin.ps1
   .\03-menu-sin-apagar-admin.ps1
   ```
   El menú de energía queda con Suspender + Reiniciar (sin Apagar ni Hibernar).
4. Para deshacer todo (como admin):
   ```powershell
   .\revertir-blindaje.ps1
   ```

## Qué hace cada script

| Script | Admin | Efecto |
|---|---|---|
| `01-boton-solo-pantalla.ps1` | No | PBUTTON=apagar pantalla (4), SBUTTON/LID=nada (0), STANDBY/HIBERNATE/HYBRID=0 nunca, en todos los planes |
| `02-blindaje-admin.ps1` | Sí | `hibernate off`, Fast Startup OFF, RustDesk auto+recovery, NoAutoReboot=1, sin Apagar en login |
| `03-menu-sin-apagar-admin.ps1` | Sí | Oculta Apagar+Hibernar+Reiniciar (`HideShutDown/HideHibernate/HideRestart=1`, `HideSleep=0`: solo queda Suspender). Oculta "Actualizar y apagar/reiniciar" (`NoAUShutdownOption=1`). UIBUTTON=Suspender |
| `revertir-blindaje.ps1` | Sí | Restaura hibernación, Fast Startup, muestra Apagar, botón=Apagar (3) |

## Apagar solo por terminal

Con `03` aplicado, el apagado real solo funciona por terminal (las políticas solo ocultan la UI):
```powershell
shutdown /s /t 0   # apagar
shutdown /r /t 0   # reiniciar (también visible en el menú)
Stop-Computer -Force
```

## Bloqueo extra con apps (opcional)

Repos que interceptan el apagado con la API soportada (`ShutdownBlockReasonCreate` + `WM_QUERYENDSESSION`):
- [TishSerg/BlockShutdown](https://github.com/TishSerg/BlockShutdown) (open source, bandeja, `BlockShutdown.exe "motivo" 45`)
- [cresstone shutdownBlocker v1.2.2](https://cresstone.com/apps/shutdownBlocker/) (portable, `shutdownBlocker.exe -block -startHidden`, inicio con Windows por tarea programada, intercepta `shutdown.exe`/`MusNotification.exe` como admin)
- [stefansundin/shutdownguard](https://github.com/stefansundin/shutdownguard) (sin mantenimiento)

Nota: en PCs con WDAC/AppLocker escolar los exe sin firmar pueden ser bloqueados
(`Control de Aplicaciones bloqueó este fichero`). En ese caso la política granular de `03` ya es suficiente.

## Límites honestos

- Mantener el botón 5 seg **siempre** fuerza apagado (hardware, no se puede evitar).
- `shutdown /s` como admin sigue funcionando (a propósito: es tu vía de apagado).
- Si se va la luz: activa en BIOS `Restore on AC Power Loss = Power On`.
- Para RustDesk tras reinicio: deja sesión iniciada o usa el servicio + IP fija o DDNS.

## Verificación

```powershell
powercfg /a              # Hibernate debe decir "not been enabled"
sc.exe query RustDesk    # STATE: RUNNING, START_TYPE: AUTO_START
sc.exe qfailure RustDesk # RESTART x3
reg query "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start"
```
