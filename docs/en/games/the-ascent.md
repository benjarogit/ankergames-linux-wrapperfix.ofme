# The Ascent (4013)

[← Games](../../../README.md) · [How it works](../how-it-works.md) · **Deutsch:** [The Ascent](../../de/games/the-ascent.md)

| | |
|---|---|
| Store AppID | 979690 |
| Fix layout | C — `winmm.dll` + union-crax (`union-crax.ini`, `steam_emu.ini`) |
| Marker | `steam_emu.ini`, depth 7 |
| Needs | **fix A + fix B** |
| Result | fix DLLs mapped, Steam tracks the game as AppID 480 |

## What you see

Either the game closes before the menu (missing files) or it starts without
Steam. Both problems are present at once, so both fixes are required.

## What to do

Install the shared wrapper once — it places the five files **and** sets
`WINEDLLOVERRIDES=winmm=n,b`:

[The common fix →](../../../README.md#the-common-fix)

## Verify

* `OnlineFix64.dll`, `winmm.dll`, `steamclient64.dll` and
  `GameOverlayRenderer64.dll` are mapped into the game process.
* `~/.local/share/Steam/logs/gameprocess_log.txt` shows
  `AppID 480 adding PID … as a tracked process`.

## Why

The build ships `TheAscent/Binaries/Win64/winmm.dll` together with
`union-crax.ini` and `steam_emu.ini`. union-crax loads `steamclient64.dll` from
the prefix, so the Steam client files must exist (fix A) — and the marker sits 7
folders deep, past the launcher's scan. The native `winmm.dll` needs the DLL
override (fix B).

Evidence: [`06-steam-tracks-480.txt`](../../../evidence/06-steam-tracks-480.txt),
[`07-prefix-layout.txt`](../../../evidence/07-prefix-layout.txt).
