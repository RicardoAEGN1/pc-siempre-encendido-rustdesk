# PC siempre encendido + RustDesk (Windows 10/11)

Deja el PC imposible de apagar por error y siempre accesible por RustDesk:
- Botón físico de encendido = **solo apaga la pantalla** (nunca apaga el PC).
- Nunca suspender / hibernar.
- RustDesk como servicio automático + recuperación.
- Oculta Apagar del menú Inicio y login (opcional, con admin).

Probado en Windows 11 Pro. Reversible.

## Uso en otro PC

1. Instala [RustDesk](https://rustdesk.com) y configura contraseña permanente.
2. Abre PowerShell **sin admin** y ejecuta:
   ```powershell
   .\01-boton-solo-pantalla.ps1
   ```
   Pulsa el botón físico para probar: solo se apaga la pantalla.
3. Para blindaje total, abre PowerShell **como administrador** y ejecuta:
   ```powershell
   .\02-blindaje-admin.ps1
   ```
   Te pedirá UAC. Reinicia Explorer o el PC.
4. Para deshacer todo (como admin):
   ```powershell
   .\revertir-blindaje.ps1
   ```

## Qué hace cada script

| Script | Admin | Efecto |
|---|---|---|
| `01-boton-solo-pantalla.ps1` | No | PBUTTON=apagar pantalla (4), SBUTTON/LID=nada (0), STANDBY/HIBERNATE/HYBRID=0 nunca, en todos los planes |
| `02-blindaje-admin.ps1` | Sí | `hibernate off`, Fast Startup OFF, RustDesk auto+recovery, NoClose=1 (oculta Apagar), ShutdownWithoutLogon=0, NoAutoReboot=1 |
| `revertir-blindaje.ps1` | Sí | Restaura hibernación, Fast Startup, muestra Apagar, botón=Apagar (3) |

## Límites honestos

- Mantener el botón 5 seg **siempre** fuerza apagado (hardware, no se puede evitar).
- `shutdown /s` como admin sigue funcionando.
- Si se va la luz: activa en BIOS `Restore on AC Power Loss = Power On` + desactiva `ErP/Deep Sleep`.
- Para que RustDesk entre tras reinicio: deja sesión iniciada o usa servicio (ya configurado) + fija IP o DDNS.

## Verificación

```powershell
powercfg /a              # Hibernate debe decir "not been enabled"
sc.exe query RustDesk    # STATE: RUNNING, START_TYPE: AUTO_START
sc.exe qfailure RustDesk # RESTART x3
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoClose
```
