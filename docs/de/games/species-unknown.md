# Species: Unknown (4035)

[← Spieleliste](../../../README.de.md) · [So funktioniert es](../wie-es-funktioniert.md) · **English:** [Species: Unknown](../../en/games/species-unknown.md)

| | |
|---|---|
| Store-App-ID | 2747330 |
| Aufbau | B · nativer `winmm.dll`-Proxy |
| Marker | `OnlineFix.ini`, Tiefe 4 |
| Benötigt | **Fix B** |
| Ergebnis | Fix-DLLs geladen, Steam erfasst den Spielprozess unter App-ID 480 |

## Was du siehst

Das Spiel startet. Freunde und Lobbys fehlen. Der Build schreibt kein
brauchbares Unreal-Engine-Log für die Steam-Initialisierung.

## Vorgehen

Installiere den [gemeinsamen Wrapper](../../../README.de.md#der-gemeinsame-fix).
Er setzt `WINEDLLOVERRIDES=winmm=n,b`. Der Launcher findet den Marker in
Tiefe 4 und legt die fünf Steam-Client-Dateien bereits ab.

## Prüfung

- `OnlineFix64.dll`, `winmm.dll`, `steamclient64.dll` und
  `GameOverlayRenderer64.dll` sind in den Spielprozess geladen.
- In `~/.local/share/Steam/logs/gameprocess_log.txt` steht
  `AppID 480 adding PID … as a tracked process`.

## Ursache

Die mitgelieferte `Species Unknown/SpeciesUnknown/Binaries/Win64/winmm.dll`
lädt `OnlineFix64.dll`. Ohne Override lädt Wine seine eigene `winmm.dll`.
Dann wird die ursprüngliche `steam_api64.dll` genutzt und
`SteamAPI_Init` scheitert mit App-ID 0.

Belege: [Steam-Prozesslog](../../../evidence/06-steam-tracks-480.txt) und
[Dateien im Prefix](../../../evidence/07-prefix-layout.txt).
