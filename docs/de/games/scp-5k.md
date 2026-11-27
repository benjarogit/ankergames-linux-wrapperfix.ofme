# SCP 5K (2006)

[← Spieleliste](../../../README.de.md) · [So funktioniert es](../wie-es-funktioniert.md) · **English:** [SCP 5K](../../en/games/scp-5k.md)

| | |
|---|---|
| Store-AppID | 872670 |
| Fix-Layout | A — ersetzte `steam_api64.dll` (Original als `steam_api64.of`) |
| Marker | `OnlineFix.ini`, Tiefe 8 |
| Auf 0.1.33 und älter | **nur Fix A** |
| Ergebnis mit Wrapper | `[AppId: 872670] Client API initialized 1` |

## Was du tust

**Offiziell behoben in Anker Launcher 0.1.34.**

1. Aktualisiere den [Anker Launcher](https://ankergames.net/launcher) auf **0.1.34 oder neuer**.
2. Starte natives Steam und öffne das Spiel über **Play** in AnkerGames.

[Details zu 0.1.34](../wie-es-funktioniert.md#anker-launcher-0134).

## Fehlerbild auf älteren Versionen

```
Failed to load original steamclient. Error code: 126
```

Das Spiel schließt vor dem Hauptmenü. Die fünf Steam-Client-Dateien fehlen im
Prefix, weil die Marker-Suche des Launchers vor Tiefe 8 aufhört.

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
auf. Die frühere Suche des Launchers erreichte
`5K/WindowsNoEditor/Engine/Binaries/ThirdParty/Steamworks/Steamv151/Win64/OnlineFix.ini`
(8 Ordner tief) nicht und kopiert deshalb nichts. Fehler 126 ist
`ERROR_MOD_NOT_FOUND`.

Belege: [`05-scp5k-steam-init.txt`](../../../evidence/05-scp5k-steam-init.txt),
[`02-launcher-2006-missing.txt`](../../../evidence/02-launcher-2006-missing.txt).
