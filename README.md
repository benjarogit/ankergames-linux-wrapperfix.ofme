# AnkerGames on Linux

[Deutsch](README.de.md) · [How it works](docs/en/how-it-works.md)

## Games

| Game | Guide |
| --- | --- |
| [SPP Tarkov (3089)](docs/en/games/tarkov.md) | Setup, solo play and Fika co-op |
| [SCP 5K (2006)](docs/en/games/scp-5k.md) | Missing Steam files · Fix A |
| [HYPERCHARGE: Unboxed (3645)](docs/en/games/hypercharge.md) | Steam initialization · Fix B |
| [Abyssus (2902)](docs/en/games/abyssus.md) | Steam initialization · Fix B |
| [The Ascent (4013)](docs/en/games/the-ascent.md) | Steam files and initialization · Fixes A and B |
| [Species: Unknown (4035)](docs/en/games/species-unknown.md) | Steam initialization · Fix B |

## The common fix

The `umu-run` wrapper supplies missing Steam client files in the Wine prefix
(fix A) and enables the game's bundled native `winmm.dll` where present (fix B).
Run these commands from the repository with native Steam installed:

```sh
mkdir -p ~/.local/bin
cp scripts/fix-reference.sh ~/.local/bin/umu-run
chmod +x ~/.local/bin/umu-run
```

Ensure AnkerGames sees `~/.local/bin` before `/usr/bin` in its `PATH`, then
launch the game as usual. If you also use the Tarkov launcher fix, run
`scripts/spp-tarkov-linux-launcher.sh "<prefix>"` after copying the wrapper.
Copying the wrapper again replaces its Tarkov block.

## Repository and scope

`docs/en/games/` and `docs/de/games/` contain the game guides. `scripts/`
contains the fixes, and `evidence/` and `assets/` contain logs and screenshots.
The [technical notes](docs/en/how-it-works.md) explain the two defects and
document the results and limitations.

The evidence covers Anker Launcher 0.1.30/0.1.33, umu-launcher 1.4.3,
Proton Experimental and native Steam on CachyOS / KDE Wayland / NVIDIA.
The fixes prepare the Wine prefix and launcher configuration. Game files and
DRM are untouched.
