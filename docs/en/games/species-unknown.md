# Species: Unknown (4035)

[← Games](../../../README.md) · [How it works](../how-it-works.md) · **Deutsch:** [Species: Unknown](../../de/games/species-unknown.md)

| | |
|---|---|
| Store AppID | 2747330 |
| Fix layout | B — native `winmm.dll` proxy |
| Marker | `OnlineFix.ini`, depth 4 |
| Needs | **fix B** only |
| Result | fix DLLs mapped, Steam tracks the game as AppID 480 |

## What you see

The game starts, but Steam is not initialised — no friends, no lobbies. The build
writes no usable UE log, so the missing Steam features are the symptom.

## What to do

Install the shared wrapper once — it sets `WINEDLLOVERRIDES=winmm=n,b`:

[The common fix →](../../../README.md#the-common-fix)

The five Steam client files are already placed: the marker is at depth 4.

## Verify

* `OnlineFix64.dll`, `winmm.dll`, `steamclient64.dll` and
  `GameOverlayRenderer64.dll` are mapped into the game process.
* `~/.local/share/Steam/logs/gameprocess_log.txt` shows
  `AppID 480 adding PID … as a tracked process`.

## Why

`Species Unknown/SpeciesUnknown/Binaries/Win64/winmm.dll` loads
`OnlineFix64.dll`. Without the DLL override Wine loads its builtin `winmm`, the
original `steam_api64.dll` runs, and `SteamAPI_Init` fails with AppId 0.

Evidence: [`06-steam-tracks-480.txt`](../../../evidence/06-steam-tracks-480.txt),
[`07-prefix-layout.txt`](../../../evidence/07-prefix-layout.txt).
