# The Ascent (4013)

[← Spieleliste](../../../README.de.md) · [So funktioniert es](../wie-es-funktioniert.md) · **English:** [The Ascent](../../en/games/the-ascent.md)

| | |
|---|---|
| Store-App-ID | 979690 |
| Aufbau | C · `winmm.dll` und union-crax (`union-crax.ini`, `steam_emu.ini`) |
| Marker | `steam_emu.ini`, Tiefe 7 |
| Benötigt | **Fix A und Fix B** |
| Ergebnis | Fix-DLLs geladen, Steam erfasst den Spielprozess unter App-ID 480 |

## Was du siehst

Das Spiel schließt vor dem Hauptmenü oder startet ohne Steam. Es fehlen die
Steam-Client-Dateien im Prefix, und Wine lädt die mitgelieferte Proxy-DLL nicht.

## Vorgehen

Installiere den [gemeinsamen Wrapper](../../../README.de.md#der-gemeinsame-fix).
Er ergänzt die fünf Steam-Client-Dateien und setzt
`WINEDLLOVERRIDES=winmm=n,b`.

## Prüfung

- `OnlineFix64.dll`, `winmm.dll`, `steamclient64.dll` und
  `GameOverlayRenderer64.dll` sind in den Spielprozess geladen.
- In `~/.local/share/Steam/logs/gameprocess_log.txt` steht
  `AppID 480 adding PID … as a tracked process`.

## Ursache

union-crax lädt `steamclient64.dll` aus dem Prefix. Der Launcher findet den
Marker `steam_emu.ini` in Tiefe 7 nicht und legt die Dateien nicht ab. Für
`TheAscent/Binaries/Win64/winmm.dll` braucht Wine zusätzlich den DLL-Override.

Belege: [Steam-Prozesslog](../../../evidence/06-steam-tracks-480.txt) und
[Dateien im Prefix](../../../evidence/07-prefix-layout.txt).
