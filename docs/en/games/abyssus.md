# Abyssus (2902)

[← Games](../../../README.md) · [How it works](../how-it-works.md) · **Deutsch:** [Abyssus](../../de/games/abyssus.md)

| | |
|---|---|
| Store AppID | 1721110 |
| Fix layout | B — native `winmm.dll` proxy |
| Marker | `OnlineFix.ini`, depth 4 |
| On 0.1.33 and earlier | **fix B** only |
| Result with wrapper | fix DLLs mapped, Steam tracks the game as AppID 480 |

## What to do

**Officially fixed in Anker Launcher 0.1.34.**

1. Update [Anker Launcher](https://ankergames.net/launcher) to **0.1.34 or later**.
2. Start native Steam, then open the game with **Play** in AnkerGames.

[Details for 0.1.34](../how-it-works.md#anker-launcher-0134).

## Symptoms on older versions

The game starts, but Steam is not initialised — no friends, no lobbies. The build
writes no usable UE log, so the symptom is the missing Steam features.

## Verify

* `OnlineFix64.dll`, `winmm.dll`, `steamclient64.dll` and
  `GameOverlayRenderer64.dll` are mapped into the game process.
* `~/.local/share/Steam/logs/gameprocess_log.txt` shows
  `AppID 480 adding PID … as a tracked process`.

## Why

`Abyssus/RGame/Binaries/Win64/winmm.dll` is the loader for `OnlineFix64.dll`.
Wine's default order for `winmm` is `builtin, native`, so without the override
the original `steam_api64.dll` runs and `SteamAPI_Init` fails with AppId 0.

Evidence: [`06-steam-tracks-480.txt`](../../../evidence/06-steam-tracks-480.txt),
[`07-prefix-layout.txt`](../../../evidence/07-prefix-layout.txt).
