# The Ascent (4013)

[← Spieleliste](../../../README.de.md) · [So funktioniert es](../wie-es-funktioniert.md) · **English:** [The Ascent](../../en/games/the-ascent.md)

| | |
|---|---|
| Store-App-ID | 979690 |
| Aufbau | C · `winmm.dll` und union-crax (`union-crax.ini`, `steam_emu.ini`) |
| Marker | `steam_emu.ini`, Tiefe 7 |
| Auf 0.1.33 und älter | **Fix A und Fix B** |
| Ergebnis mit Wrapper | Fix-DLLs geladen, Steam erfasst den Spielprozess unter App-ID 480 |

## Vorgehen

**Offiziell behoben in Anker Launcher 0.1.34.**

1. Aktualisiere den [Anker Launcher](https://ankergames.net/launcher) auf **0.1.34 oder neuer**.
2. Starte natives Steam und öffne das Spiel über **Play** in AnkerGames.

[Details zu 0.1.34](../wie-es-funktioniert.md#anker-launcher-0134).

## Fehlerbild auf älteren Versionen

Das Spiel schließt vor dem Hauptmenü oder startet ohne Steam. Es fehlen die
Steam-Client-Dateien im Prefix, und Wine lädt die mitgelieferte Proxy-DLL nicht.

## Prüfung

- `OnlineFix64.dll`, `winmm.dll`, `steamclient64.dll` und
  `GameOverlayRenderer64.dll` sind in den Spielprozess geladen.
- In `~/.local/share/Steam/logs/gameprocess_log.txt` steht
  `AppID 480 adding PID … as a tracked process`.

## Ursache

union-crax lädt `steamclient64.dll` aus dem Prefix. Die frühere Suche fand den
Marker `steam_emu.ini` in Tiefe 7 nicht und legte die Dateien nicht ab. Für
`TheAscent/Binaries/Win64/winmm.dll` braucht Wine zusätzlich den DLL-Override.

Belege: [Steam-Prozesslog](../../../evidence/06-steam-tracks-480.txt) und
[Dateien im Prefix](../../../evidence/07-prefix-layout.txt).
