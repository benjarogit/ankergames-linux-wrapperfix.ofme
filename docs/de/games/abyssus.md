# Abyssus (2902)

[← Spieleliste](../../../README.de.md) · [So funktioniert es](../wie-es-funktioniert.md) · **English:** [Abyssus](../../en/games/abyssus.md)

| | |
|---|---|
| Store-AppID | 1721110 |
| Fix-Layout | B — nativer `winmm.dll`-Proxy |
| Marker | `OnlineFix.ini`, Tiefe 4 |
| Auf 0.1.33 und älter | **nur Fix B** |
| Ergebnis mit Wrapper | Fix-DLLs im Prozess, Steam trackt das Spiel als AppID 480 |

## Was du tust

1. Aktualisiere Anker Launcher auf **0.1.34 oder neuer**.
2. Starte natives Steam und öffne das Spiel über **Play** in AnkerGames.
3. Prüfe das Ergebnis unten. Auf 0.1.33 und älter gibt es den
   [Referenz-Wrapper](../../../README.de.md#der-gemeinsame-fix).

AnkerGames hat die Korrekturen für 0.1.34 bestätigt. Der Nachtest dieses
Titels steht noch aus. Die Prüfung unten zeigt den früheren Test mit dem
Wrapper. [Details zu 0.1.34](../wie-es-funktioniert.md#anker-launcher-0134).

## Fehlerbild auf älteren Versionen

Das Spiel startet, aber Steam wird nicht initialisiert — keine Freunde, keine
Lobbys. Der Build schreibt kein nutzbares UE-Log, das Symptom sind die fehlenden
Steam-Funktionen.

## Prüfen

* `OnlineFix64.dll`, `winmm.dll`, `steamclient64.dll` und
  `GameOverlayRenderer64.dll` sind in den Spielprozess geladen.
* `~/.local/share/Steam/logs/gameprocess_log.txt` zeigt
  `AppID 480 adding PID … as a tracked process`.

## Warum

`Abyssus/RGame/Binaries/Win64/winmm.dll` ist der Loader für `OnlineFix64.dll`.
Wine lädt `winmm` standardmäßig als `builtin, native`; ohne Override läuft die
originale `steam_api64.dll` und `SteamAPI_Init` scheitert mit AppId 0.

Belege: [`06-steam-tracks-480.txt`](../../../evidence/06-steam-tracks-480.txt),
[`07-prefix-layout.txt`](../../../evidence/07-prefix-layout.txt).
