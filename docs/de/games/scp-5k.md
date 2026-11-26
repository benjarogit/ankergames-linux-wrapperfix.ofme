# SCP 5K (2006)

[← Spieleliste](../../../README.de.md) · [So funktioniert es](../wie-es-funktioniert.md) · **English:** [SCP 5K](../../en/games/scp-5k.md)

| | |
|---|---|
| Store-AppID | 872670 |
| Fix-Layout | A — ersetzte `steam_api64.dll` (Original als `steam_api64.of`) |
| Marker | `OnlineFix.ini`, Tiefe 8 |
| Braucht | **nur Fix A** |
| Ergebnis | `[AppId: 872670] Client API initialized 1` |

## Was du siehst

```
Failed to load original steamclient. Error code: 126
```

Das Spiel schließt vor dem Hauptmenü. Die fünf Steam-Client-Dateien fehlen im
Prefix, weil die Marker-Suche des Launchers vor Tiefe 8 aufhört.

## Was du tust

Einmal den gemeinsamen Wrapper installieren — er platziert die Dateien für alle
Online-Fix-Spiele:

[Der gemeinsame Fix →](../../../README.de.md#der-gemeinsame-fix)

Sonst ist nichts spielspezifisch. Kein `winmm`-Override nötig: Dieser Build
ersetzt `steam_api64.dll` selbst.

## Prüfen

`5K/Saved/Logs/Pandemic.log`:

```
LogSteamShared: Steam SDK Loaded!
LogOnline: STEAM: Steam User is subscribed 1
LogOnline: STEAM: [AppId: 872670] Client API initialized 1
```

Steam trackt den Prozess als AppID 480. Schließt das Spiel weiterhin, prüfe
`<prefix>/drive_c/Program Files (x86)/Steam/` auf die fünf Dateien.

## Warum

Die Fix-DLL löst Valves echte `steamclient64.dll` über die Registry des Prefixes
auf. Die Suche des Launchers erreicht
`5K/WindowsNoEditor/Engine/Binaries/ThirdParty/Steamworks/Steamv151/Win64/OnlineFix.ini`
(8 Ordner tief) nicht und kopiert deshalb nichts. Fehler 126 ist
`ERROR_MOD_NOT_FOUND`.

Belege: [`05-scp5k-steam-init.txt`](../../../evidence/05-scp5k-steam-init.txt),
[`02-launcher-2006-missing.txt`](../../../evidence/02-launcher-2006-missing.txt).
