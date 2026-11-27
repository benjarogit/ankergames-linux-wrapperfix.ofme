# HYPERCHARGE: Unboxed (3645)

[← Games](../../../README.md) · [How it works](../how-it-works.md) · **Deutsch:** [HYPERCHARGE](../../de/games/hypercharge.md)

| | |
|---|---|
| Store AppID | 523660 |
| Fix layout | B — native `winmm.dll` proxy |
| Marker | `OnlineFix.ini`, depth 4 |
| On 0.1.33 and earlier | **fix B** only |
| Result with wrapper | `[AppId: 523660] Client API initialized 1` |

## What to do

**Officially fixed in Anker Launcher 0.1.34.**

1. Update [Anker Launcher](https://ankergames.net/launcher) to **0.1.34 or later**.
2. Start native Steam, then open the game with **Play** in AnkerGames.

[Details for 0.1.34](../how-it-works.md#anker-launcher-0134).

## Symptoms on older versions

The game starts, but Steam is not initialised:

```
LogSteamShared: Warning: SteamAPI failed to initialize, conditions not met.
LogOnline: STEAM: [AppId: 0] Client API initialized 0
```

No friends list, no lobbies.

## Verify

`Unboxed/Saved/Logs/Unboxed.log`:

```
LogSteamShared: Steam SDK Loaded!
LogOnline: STEAM: Steam User is subscribed 1
LogOnline: STEAM: [AppId: 523660] Client API initialized 1
```

## Why

The build ships `Unboxed/Binaries/Win64/winmm.dll`, which loads `OnlineFix64.dll`.
On Windows the application directory wins the DLL search order; under Wine
`winmm` defaults to `builtin, native`, so the proxy is skipped. The override
`winmm=n,b` prefers the native DLL.

Evidence: [`03-hypercharge-before.txt`](../../../evidence/03-hypercharge-before.txt),
[`04-hypercharge-after.txt`](../../../evidence/04-hypercharge-after.txt).
