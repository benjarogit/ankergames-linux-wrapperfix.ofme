# AnkerGames on Linux

[Deutsch](README.de.md) · [How it works](docs/en/how-it-works.md)

## Games

### Officially fixed in Anker Launcher 0.1.34

Update [Anker Launcher](https://ankergames.net/launcher) to **0.1.34 or later**,
start native Steam, and open the game with **Play**. AnkerGames confirmed both
Linux fixes. [What changed in 0.1.34](docs/en/how-it-works.md#anker-launcher-0134).

| Game | Issue fixed |
| --- | --- |
| [SCP 5K (2006)](docs/en/games/scp-5k.md) | Missing Steam files |
| [HYPERCHARGE: Unboxed (3645)](docs/en/games/hypercharge.md) | Steam initialization |
| [Abyssus (2902)](docs/en/games/abyssus.md) | Steam initialization |
| [The Ascent (4013)](docs/en/games/the-ascent.md) | Steam files and initialization |
| [Species: Unknown (4035)](docs/en/games/species-unknown.md) | Steam initialization |

### Separate Linux setup

- [SPP Tarkov (3089)](docs/en/games/tarkov.md) · .NET and native SPT launcher setup, solo play and Fika co-op.

## Repository and scope

`docs/en/games/` and `docs/de/games/` contain the game guides. `scripts/`
contains the fixes, and `evidence/` and `assets/` contain logs and screenshots.
The [technical notes](docs/en/how-it-works.md) explain the two defects and
document the results and limitations.

The evidence covers Anker Launcher 0.1.30/0.1.33, umu-launcher 1.4.3,
Proton Experimental and native Steam on CachyOS / KDE Wayland / NVIDIA.
The fixes prepare the Wine prefix and launcher configuration. Game files and
DRM are untouched.
