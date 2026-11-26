# SCP 5K (2006)

[← Games](../../../README.md) · [How it works](../how-it-works.md) · **Deutsch:** [SCP 5K](../../de/games/scp-5k.md)

| | |
|---|---|
| Store AppID | 872670 |
| Fix layout | A — replaced `steam_api64.dll` (original kept as `steam_api64.of`) |
| Marker | `OnlineFix.ini`, depth 8 |
| Needs | **fix A** only |
| Result | `[AppId: 872670] Client API initialized 1` |

## What you see

```
Failed to load original steamclient. Error code: 126
```

The game closes before the main menu. The five Steam client files are missing in
the prefix, because the launcher's marker scan stops before depth 8.

## What to do

Install the shared wrapper once — it places the files for every online-fix game:

[The common fix →](../../../README.md#the-common-fix)

Nothing else is specific to SCP 5K. No `winmm` override is needed: this build
replaces `steam_api64.dll` itself.

## Verify

`5K/Saved/Logs/Pandemic.log`:

```
LogSteamShared: Steam SDK Loaded!
LogOnline: STEAM: Steam User is subscribed 1
LogOnline: STEAM: [AppId: 872670] Client API initialized 1
```

Steam tracks the process as AppID 480. If the game still closes, check
`<prefix>/drive_c/Program Files (x86)/Steam/` for the five files.

## Why

The fix DLL resolves Valve's real `steamclient64.dll` through the prefix
registry. The launcher's scan looks for marker files but does not reach
`5K/WindowsNoEditor/Engine/Binaries/ThirdParty/Steamworks/Steamv151/Win64/OnlineFix.ini`
(8 folders deep), so it never copies the files. Error 126 is
`ERROR_MOD_NOT_FOUND`.

Evidence: [`05-scp5k-steam-init.txt`](../../../evidence/05-scp5k-steam-init.txt),
[`02-launcher-2006-missing.txt`](../../../evidence/02-launcher-2006-missing.txt).
