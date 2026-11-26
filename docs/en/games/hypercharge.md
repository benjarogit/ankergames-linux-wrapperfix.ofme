# HYPERCHARGE: Unboxed (3645)

[← Games](../../../README.md) · [How it works](../how-it-works.md) · **Deutsch:** [HYPERCHARGE](../../de/games/hypercharge.md)

| | |
|---|---|
| Store AppID | 523660 |
| Fix layout | B — native `winmm.dll` proxy |
| Marker | `OnlineFix.ini`, depth 4 |
| Needs | **fix B** only |
| Result | `[AppId: 523660] Client API initialized 1` |

## What you see

The game starts, but Steam is not initialised:

```
LogSteamShared: Warning: SteamAPI failed to initialize, conditions not met.
LogOnline: STEAM: [AppId: 0] Client API initialized 0
```

No friends list, no lobbies.

## What to do

Install the shared wrapper once — it sets `WINEDLLOVERRIDES=winmm=n,b`:

[The common fix →](../../../README.md#the-common-fix)

The five Steam client files are already placed here: the marker sits at depth 4,
so the launcher's own scan finds it. Only the DLL override was missing.

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
