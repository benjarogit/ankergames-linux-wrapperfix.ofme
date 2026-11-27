# HYPERCHARGE: Unboxed (3645)

[← Spieleliste](../../../README.de.md) · [So funktioniert es](../wie-es-funktioniert.md) · **English:** [HYPERCHARGE](../../en/games/hypercharge.md)

| | |
|---|---|
| Store-AppID | 523660 |
| Fix-Layout | B — nativer `winmm.dll`-Proxy |
| Marker | `OnlineFix.ini`, Tiefe 4 |
| Auf 0.1.33 und älter | **nur Fix B** |
| Ergebnis mit Wrapper | `[AppId: 523660] Client API initialized 1` |

## Was du tust

1. Aktualisiere Anker Launcher auf **0.1.34 oder neuer**.
2. Starte natives Steam und öffne das Spiel über **Play** in AnkerGames.
3. Prüfe das Ergebnis unten. Auf 0.1.33 und älter gibt es den
   [Referenz-Wrapper](../../../README.de.md#der-gemeinsame-fix).

AnkerGames hat die Korrekturen für 0.1.34 bestätigt. Der Nachtest dieses
Titels steht noch aus. Die Prüfung unten zeigt den früheren Test mit dem
Wrapper. [Details zu 0.1.34](../wie-es-funktioniert.md#anker-launcher-0134).

## Fehlerbild auf älteren Versionen

Das Spiel startet, aber Steam wird nicht initialisiert:

```
LogSteamShared: Warning: SteamAPI failed to initialize, conditions not met.
LogOnline: STEAM: [AppId: 0] Client API initialized 0
```

Keine Freundesliste, keine Lobbys.

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
