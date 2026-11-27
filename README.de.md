# AnkerGames unter Linux

[English](README.md) · [So funktioniert es](docs/de/wie-es-funktioniert.md)

## Spiele

| Spiel | Anleitung |
| --- | --- |
| [SPP Tarkov (3089)](docs/de/games/tarkov.md) | Installation, Solo und Fika-Co-op |
| [SCP 5K (2006)](docs/de/games/scp-5k.md) | Fehlende Steam-Dateien |
| [HYPERCHARGE: Unboxed (3645)](docs/de/games/hypercharge.md) | Steam-Initialisierung |
| [Abyssus (2902)](docs/de/games/abyssus.md) | Steam-Initialisierung |
| [The Ascent (4013)](docs/de/games/the-ascent.md) | Steam-Dateien und -Initialisierung |
| [Species: Unknown (4035)](docs/de/games/species-unknown.md) | Steam-Initialisierung |

## Online-Fix ab Anker Launcher 0.1.34

Aktualisiere den [Anker Launcher](https://ankergames.net/launcher) auf
**0.1.34 oder neuer**, starte natives Steam und starte das Spiel in AnkerGames
zuerst mit dem Launcher-Fix. Das AnkerGames-Team hat beide Korrekturen für
0.1.34 bestätigt. Die vorhandenen Belege stammen aus 0.1.30/0.1.33 mit dem
Referenz-Wrapper. Der Nachtest aller fünf Spiele auf 0.1.34 steht noch aus.
[Was sich geändert hat](docs/de/wie-es-funktioniert.md#anker-launcher-0134).

Für [SPP Tarkov](docs/de/games/tarkov.md) gilt weiterhin die separate
Einrichtung für .NET und den nativen SPT-Launcher.

## Der gemeinsame Fix

<details>
<summary>Referenz-Wrapper für ältere Launcher-Versionen</summary>

Der Wrapper ergänzt fehlende Steam-Client-Dateien im Wine-Prefix (Fix A) und
aktiviert die mitgelieferte native `winmm.dll` (Fix B). Nutze ihn als
Ausweichlösung auf 0.1.33 und älter. Führe die Befehle im Repo-Ordner aus.

```sh
mkdir -p ~/.local/bin
cp -i scripts/fix-reference.sh ~/.local/bin/umu-run
chmod +x ~/.local/bin/umu-run
```

Im `PATH` von AnkerGames muss `~/.local/bin` vor `/usr/bin` stehen. Wenn du
einen bestehenden Wrapper ersetzt, führe den Tarkov-Setup-Befehl bei Bedarf
erneut aus, damit er den nativen Startblock einfügt.

</details>

## Aufbau und Geltungsbereich

Die Spielanleitungen liegen unter `docs/en/games/` und `docs/de/games/`.
`scripts/` enthält die Fixes. Logs und Screenshots liegen unter `evidence/`
und `assets/`. Die [Technikseite](docs/de/wie-es-funktioniert.md) erklärt die
beiden Defekte und dokumentiert die Ergebnisse und Grenzen.

Die Belege stammen aus Anker Launcher 0.1.30/0.1.33, umu-launcher 1.4.3,
Proton Experimental und nativem Steam auf CachyOS / KDE Wayland / NVIDIA.
Die Fixes bereiten den Wine-Prefix und die Launcher-Konfiguration vor.
Spieldateien und DRM bleiben unverändert.
