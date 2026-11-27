# AnkerGames unter Linux

[English](README.md) · [So funktioniert es](docs/de/wie-es-funktioniert.md)

## Spiele

### Offiziell behoben in Anker Launcher 0.1.34

Aktualisiere den [Anker Launcher](https://ankergames.net/launcher) auf
**0.1.34 oder neuer**, starte natives Steam und öffne das Spiel über **Play**.
AnkerGames hat die beiden Linux-Korrekturen bestätigt.
[Was sich in 0.1.34 geändert hat](docs/de/wie-es-funktioniert.md#anker-launcher-0134).

| Spiel | Behobenes Problem |
| --- | --- |
| [SCP 5K (2006)](docs/de/games/scp-5k.md) | Fehlende Steam-Dateien |
| [HYPERCHARGE: Unboxed (3645)](docs/de/games/hypercharge.md) | Steam-Initialisierung |
| [Abyssus (2902)](docs/de/games/abyssus.md) | Steam-Initialisierung |
| [The Ascent (4013)](docs/de/games/the-ascent.md) | Steam-Dateien und -Initialisierung |
| [Species: Unknown (4035)](docs/de/games/species-unknown.md) | Steam-Initialisierung |

### Separate Einrichtung unter Linux

- [SPP Tarkov (3089)](docs/de/games/tarkov.md) · Einrichtung mit .NET und nativem SPT-Launcher, Solo und Fika-Co-op.

## Aufbau und Geltungsbereich

Die Spielanleitungen liegen unter `docs/en/games/` und `docs/de/games/`.
`scripts/` enthält die Fixes. Logs und Screenshots liegen unter `evidence/`
und `assets/`. Die [Technikseite](docs/de/wie-es-funktioniert.md) erklärt die
beiden Defekte und dokumentiert die Ergebnisse und Grenzen.

Die Belege stammen aus Anker Launcher 0.1.30/0.1.33, umu-launcher 1.4.3,
Proton Experimental und nativem Steam auf CachyOS / KDE Wayland / NVIDIA.
Die Fixes bereiten den Wine-Prefix und die Launcher-Konfiguration vor.
Spieldateien und DRM bleiben unverändert.
