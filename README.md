# AnkerGames on Linux

[Deutsch](README.de.md) · [How it works](docs/en/how-it-works.md)

## Games

| Game | Guide |
| --- | --- |
| [SPP Tarkov (3089)](docs/en/games/tarkov.md) | Setup, solo play and Fika co-op |
| [SCP 5K (2006)](docs/en/games/scp-5k.md) | Missing Steam files |
| [HYPERCHARGE: Unboxed (3645)](docs/en/games/hypercharge.md) | Steam initialization |
| [Abyssus (2902)](docs/en/games/abyssus.md) | Steam initialization |
| [The Ascent (4013)](docs/en/games/the-ascent.md) | Steam files and initialization |
| [Species: Unknown (4035)](docs/en/games/species-unknown.md) | Steam initialization |

## Online-fix from Anker Launcher 0.1.34

Update [Anker Launcher](https://ankergames.net/launcher) to **0.1.34 or later**,
start native Steam, and try launching the game through AnkerGames with the
launcher fix first. The AnkerGames team confirmed both corrections for 0.1.34.
The existing evidence is from 0.1.30/0.1.33 with the reference wrapper.
Retesting all five games on 0.1.34 is still pending.
[What changed](docs/en/how-it-works.md#anker-launcher-0134).

[SPP Tarkov](docs/en/games/tarkov.md) has its own .NET and native SPT launcher
setup.

## The common fix

<details>
<summary>Reference wrapper for older launcher versions</summary>

The wrapper supplies missing Steam client files in the Wine prefix (fix A) and
enables the bundled native `winmm.dll` (fix B). It is a fallback for 0.1.33
and earlier. Run these commands from the repo folder.

```sh
mkdir -p ~/.local/bin
cp -i scripts/fix-reference.sh ~/.local/bin/umu-run
chmod +x ~/.local/bin/umu-run
```

Ensure AnkerGames sees `~/.local/bin` before `/usr/bin` in its `PATH`. If you
replace an existing wrapper, rerun the Tarkov setup command if you need it to
restore the native launch block.

</details>

## Repository and scope

`docs/en/games/` and `docs/de/games/` contain the game guides. `scripts/`
contains the fixes, and `evidence/` and `assets/` contain logs and screenshots.
The [technical notes](docs/en/how-it-works.md) explain the two defects and
document the results and limitations.

The evidence covers Anker Launcher 0.1.30/0.1.33, umu-launcher 1.4.3,
Proton Experimental and native Steam on CachyOS / KDE Wayland / NVIDIA.
The fixes prepare the Wine prefix and launcher configuration. Game files and
DRM are untouched.
