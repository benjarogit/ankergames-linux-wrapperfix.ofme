# AnkerGames unter Linux

[English](README.md) · [So funktioniert es](docs/de/wie-es-funktioniert.md)

## Spiele

| Spiel | Anleitung |
| --- | --- |
| [SPP Tarkov (3089)](docs/de/games/tarkov.md) | Installation, Solo und Fika-Co-op |
| [SCP 5K (2006)](docs/de/games/scp-5k.md) | Fehlende Steam-Dateien · Fix A |
| [HYPERCHARGE: Unboxed (3645)](docs/de/games/hypercharge.md) | Steam-Initialisierung · Fix B |
| [Abyssus (2902)](docs/de/games/abyssus.md) | Steam-Initialisierung · Fix B |
| [The Ascent (4013)](docs/de/games/the-ascent.md) | Steam-Dateien und -Initialisierung · Fix A und B |
| [Species: Unknown (4035)](docs/de/games/species-unknown.md) | Steam-Initialisierung · Fix B |

## Der gemeinsame Fix

Der `umu-run`-Wrapper ergänzt fehlende Steam-Client-Dateien im Wine-Prefix
(Fix A) und aktiviert die native `winmm.dll`, wenn das Spiel sie mitbringt
(Fix B). Führe die Befehle mit installiertem nativem Steam im Repo-Ordner aus.

```sh
mkdir -p ~/.local/bin
cp scripts/fix-reference.sh ~/.local/bin/umu-run
chmod +x ~/.local/bin/umu-run
```

Im `PATH` von AnkerGames muss `~/.local/bin` vor `/usr/bin` stehen. Starte
danach das Spiel wie gewohnt. Falls du auch den Tarkov-Fix nutzt, führe
`scripts/spp-tarkov-linux-launcher.sh "<prefix>"` nach dem Kopieren aus.
Erneutes Kopieren des Wrappers ersetzt den Tarkov-Block.

## Aufbau und Geltungsbereich

Die Spielanleitungen liegen unter `docs/en/games/` und `docs/de/games/`.
`scripts/` enthält die Fixes. Logs und Screenshots liegen unter `evidence/`
und `assets/`. Die [Technikseite](docs/de/wie-es-funktioniert.md) erklärt die
beiden Defekte und dokumentiert die Ergebnisse und Grenzen.

Die Belege stammen aus Anker Launcher 0.1.30/0.1.33, umu-launcher 1.4.3,
Proton Experimental und nativem Steam auf CachyOS / KDE Wayland / NVIDIA.
Die Fixes bereiten den Wine-Prefix und die Launcher-Konfiguration vor.
Spieldateien und DRM bleiben unverändert.
