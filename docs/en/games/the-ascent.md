# The Ascent (4013)

[← Games](../../../README.md) · [How it works](../how-it-works.md) · **Deutsch:** [The Ascent](../../de/games/the-ascent.md)

| | |
|---|---|
| Store AppID | 979690 |
| Fix layout | C — `winmm.dll` + union-crax (`union-crax.ini`, `steam_emu.ini`) |
| Marker | `steam_emu.ini`, depth 7 |
| On 0.1.33 and earlier | **fix A + fix B** |
| Result with wrapper | fix DLLs mapped, Steam tracks the game as AppID 480 |

## What to do

1. Update Anker Launcher to **0.1.34 or later**.
2. Start native Steam, then open the game with **Play** in AnkerGames.
3. Check the result below. On 0.1.33 and earlier, use the
   [reference wrapper](../../../README.md#the-common-fix).

AnkerGames confirmed the corrections in 0.1.34. This title still needs
a retest. The checks below come from the earlier wrapper test.
[Details for 0.1.34](../how-it-works.md#anker-launcher-0134).

## Symptoms on older versions

Either the game closes before the menu (missing files) or it starts without
Steam. Both problems affected the earlier launches.

## Verify

* `OnlineFix64.dll`, `winmm.dll`, `steamclient64.dll` and
  `GameOverlayRenderer64.dll` are mapped into the game process.
* `~/.local/share/Steam/logs/gameprocess_log.txt` shows
  `AppID 480 adding PID … as a tracked process`.

## Why

The build ships `TheAscent/Binaries/Win64/winmm.dll` together with
`union-crax.ini` and `steam_emu.ini`. union-crax loads `steamclient64.dll` from
the prefix, so the Steam client files must exist (fix A) — and the marker sits 7
folders deep, past the earlier general scan. The native `winmm.dll` needs the DLL
override (fix B).

Evidence: [`06-steam-tracks-480.txt`](../../../evidence/06-steam-tracks-480.txt),
[`07-prefix-layout.txt`](../../../evidence/07-prefix-layout.txt).
