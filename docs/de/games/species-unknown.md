# Species: Unknown (4035)

[← Spieleliste](../../../README.de.md) · [So funktioniert es](../wie-es-funktioniert.md) · **English:** [Species: Unknown](../../en/games/species-unknown.md)

| | |
|---|---|
| Store-App-ID | 2747330 |
| Aufbau | B · nativer `winmm.dll`-Proxy |
| Marker | `OnlineFix.ini`, Tiefe 4 |
| Auf 0.1.33 und älter | **Fix B** |
| Ergebnis mit Wrapper | Fix-DLLs geladen, Steam erfasst den Spielprozess unter App-ID 480 |

## Vorgehen

1. Aktualisiere Anker Launcher auf **0.1.34 oder neuer**.
2. Starte natives Steam und öffne das Spiel über **Play** in AnkerGames.
3. Prüfe das Ergebnis unten. Auf 0.1.33 und älter gibt es den
   [Referenz-Wrapper](../../../README.de.md#der-gemeinsame-fix).

AnkerGames hat die Korrekturen für 0.1.34 bestätigt. Der Nachtest dieses
Titels steht noch aus. Die Prüfung unten zeigt den früheren Test mit dem
Wrapper. [Details zu 0.1.34](../wie-es-funktioniert.md#anker-launcher-0134).

## Fehlerbild auf älteren Versionen

Das Spiel startet. Freunde und Lobbys fehlen. Der Build schreibt kein
brauchbares Unreal-Engine-Log für die Steam-Initialisierung.

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
