# SCP 5K (2006)

[← Games](../../../README.md) · [How it works](../how-it-works.md) · **Deutsch:** [SCP 5K](../../de/games/scp-5k.md)

| | |
|---|---|
| Store AppID | 872670 |
| Fix layout | A — replaced `steam_api64.dll` (original kept as `steam_api64.of`) |
| Marker | `OnlineFix.ini`, depth 8 |
| On 0.1.33 and earlier | **fix A** only |
| Result with wrapper | `[AppId: 872670] Client API initialized 1` |

## What to do

1. Update Anker Launcher to **0.1.34 or later**.
2. Start native Steam, then open the game with **Play** in AnkerGames.
3. Check the result below. On 0.1.33 and earlier, use the
   [reference wrapper](../../../README.md#the-common-fix).

AnkerGames confirmed the corrections in 0.1.34. This title still needs
a retest. The checks below come from the earlier wrapper test.
[Details for 0.1.34](../how-it-works.md#anker-launcher-0134).

## Symptoms on older versions

```
Failed to load original steamclient. Error code: 126
```

The game closes before the main menu. The five Steam client files are missing in
the prefix, because the launcher's earlier marker scan missed the deeper directory.

## Verify

`5K/Saved/Logs/Pandemic.log`:

```
LogSteamShared: Steam SDK Loaded!
LogOnline: STEAM: Steam User is subscribed 1
LogOnline: STEAM: [AppId: 872670] Client API initialized 1
```

This build uses `steam_api64.dll` as its proxy. Steam tracks the process as AppID 480. If the game still closes, check
`<prefix>/drive_c/Program Files (x86)/Steam/` for the five files.

## Why

The fix DLL resolves Valve's real `steamclient64.dll` through the prefix
registry. The earlier launcher scan missed
`5K/WindowsNoEditor/Engine/Binaries/ThirdParty/Steamworks/Steamv151/Win64/OnlineFix.ini`
(8 folders deep), so it never copies the files. Error 126 is
`ERROR_MOD_NOT_FOUND`.

Evidence: [`05-scp5k-steam-init.txt`](../../../evidence/05-scp5k-steam-init.txt),
[`02-launcher-2006-missing.txt`](../../../evidence/02-launcher-2006-missing.txt).
