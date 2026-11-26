# HYPERCHARGE: Unboxed (3645)

[← Spieleliste](../../../README.de.md) · [So funktioniert es](../wie-es-funktioniert.md) · **English:** [HYPERCHARGE](../../en/games/hypercharge.md)

| | |
|---|---|
| Store-AppID | 523660 |
| Fix-Layout | B — nativer `winmm.dll`-Proxy |
| Marker | `OnlineFix.ini`, Tiefe 4 |
| Braucht | **nur Fix B** |
| Ergebnis | `[AppId: 523660] Client API initialized 1` |

## Was du siehst

Das Spiel startet, aber Steam wird nicht initialisiert:

```
LogSteamShared: Warning: SteamAPI failed to initialize, conditions not met.
LogOnline: STEAM: [AppId: 0] Client API initialized 0
```

Keine Freundesliste, keine Lobbys.

## Was du tust

Einmal den gemeinsamen Wrapper installieren — er setzt
`WINEDLLOVERRIDES=winmm=n,b`:

[Der gemeinsame Fix →](../../../README.de.md#der-gemeinsame-fix)

Die fünf Steam-Client-Dateien sind hier schon vorhanden: Der Marker liegt auf
Tiefe 4, die Suche des Launchers findet ihn. Es fehlte nur der DLL-Override.

## Prüfen

`Unboxed/Saved/Logs/Unboxed.log`:

```
LogSteamShared: Steam SDK Loaded!
LogOnline: STEAM: Steam User is subscribed 1
LogOnline: STEAM: [AppId: 523660] Client API initialized 1
```

## Warum

Der Build liefert `Unboxed/Binaries/Win64/winmm.dll`, die `OnlineFix64.dll` lädt.
Unter Windows gewinnt das Anwendungsverzeichnis die DLL-Suchreihenfolge; unter
Wine ist `winmm` standardmäßig `builtin, native`, also wird der Proxy
übersprungen. Der Override `winmm=n,b` bevorzugt die native DLL.

Belege: [`03-hypercharge-before.txt`](../../../evidence/03-hypercharge-before.txt),
[`04-hypercharge-after.txt`](../../../evidence/04-hypercharge-after.txt).
