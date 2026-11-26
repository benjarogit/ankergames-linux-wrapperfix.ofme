# Root cause — why online-fix builds fail on Linux

[← Overview](../../README.md) · [Per game](per-game.md) · [Evidence](evidence.md) · **Deutsch:** [Ursachen](../de/ursachen.md)

**Reported against:** Anker Launcher 0.1.33 (`AnkerLauncher-0.1.30-x86_64.AppImage`)
**Runtime:** umu-launcher 1.4.3, Proton Experimental (prefix `11.0-100`), native Steam
**System:** CachyOS, KDE Plasma 6.8 / Wayland, NVIDIA RTX 2060

---

## Contents

1. [How these builds work](#1-how-these-builds-work)
2. [Defect A — Steam client files are not placed](#2-defect-a--steam-client-files-are-not-placed)
3. [Defect B — the native `winmm.dll` proxy is ignored](#3-defect-b--the-native-winmmdll-proxy-is-ignored)
4. [Reference implementation](#4-reference-implementation)
5. [Verification](#5-verification)
6. [Known limitation — overlay and invites](#6-known-limitation--overlay-and-invites)
7. [Metadata note — the "Co-Op" badge](#7-metadata-note--the-co-op-badge)

---

## 1. How these builds work

Online-fix builds do **not** replace Steam. The fix DLL (`OnlineFix64.dll`, or a
`winmm.dll` / `steam_api64.dll` proxy) loads **Valve's real `steamclient64.dll`**
from inside the Wine prefix and connects it to the Steam client running on the
host:

```
<prefix>/drive_c/Program Files (x86)/Steam/
├── steamclient.dll            (from <Steam>/legacycompat/)
├── steamclient64.dll          (from <Steam>/legacycompat/)
├── GameOverlayRenderer64.dll  (from <Steam>/)
├── Steam.dll                  (from <Steam>/legacycompat/)
└── steam.exe                  (from <Steam>/legacycompat/SteamService.exe)
```

The path is resolved from the prefix registry:

```
[Software\\Valve\\Steam\\ActiveProcess]
"SteamClientDll64"="C:\\Program Files (x86)\\Steam\\steamclient64.dll"
"SteamPath"="C:\\Program Files (x86)\\Steam"
```

If those files are missing, `LoadLibrary` fails with **error 126**
(`ERROR_MOD_NOT_FOUND`) — exactly the error users see.

Proton performs this copy itself when it creates a prefix (`steam_in_pfx_dir`
in the `proton` script), but **only while creating or upgrading a prefix**.
Anker creates prefixes through umu, so the launcher's own copy step is the only
reliable path afterwards.

Three proxy layouts appear in the catalog:

| Layout | Loader | Example |
|--------|--------|---------|
| **A** | `steam_api64.dll` replaced, original kept as `steam_api64.of` | SCP 5K |
| **B** | native `winmm.dll` next to the shipping exe, which loads `OnlineFix64.dll` | HYPERCHARGE, Abyssus, Species: Unknown |
| **C** | native `winmm.dll` + `union-crax.ini` + `steam_emu.ini` (union-crax emulator, also loads `steamclient64.dll`) | The Ascent |

Layout **A** works under Wine as-is. Layouts **B** and **C** do not, because
Wine's default DLL order for `winmm` is *builtin first*: the bundled native proxy
is never loaded, the original `steam_api64.dll` runs instead, and
`SteamAPI_Init` fails with AppId 0.

---

## 2. Defect A — Steam client files are not placed

### Symptom

```
Failed to load original steamclient. Error code: 126
```

The game closes before the main menu.

### Evidence

`~/.local/share/net.ankergames.launcher/logs/anker.2026-11-25.log`:

```
16:24:59  INFO Steam's client files were placed in the game's prefix files=5   ← HYPERCHARGE (3645)
```

The launch of **SCP 5K (2006)** at 16:28–16:29 (UTC) produced **no such line**,
and the prefix was left empty:

```
Prefixes/2006/drive_c/Program Files (x86)/Steam/   → only appcache/, config/, steamapps/
Prefixes/3645/drive_c/Program Files (x86)/Steam/   → steamclient64.dll, steamclient.dll,
                                                     GameOverlayRenderer64.dll, Steam.dll, steam.exe
```

The registry in the 2006 prefix already pointed at the (missing) DLLs, so the
fix DLL was told to load a file that did not exist → error 126.

### Root cause

The launcher detects online-fix builds by scanning the game folder for marker
files. The marker list extracted from the launcher binary is:

```
steam_appid.txt  steam_settings  steam_emu.ini  ColdClientLoader.ini
cream_api.ini    OnlineFix.ini   realappid      SmartSteamEmu.ini
SteamConfig.ini  CPY.ini
```

`union-crax.ini` is **not** in that list, and the scan does not reach markers
that sit deep below the game root. The most plausible explanation is a depth
limit in the folder walk — it matches every observation (depth 4 is found,
depth 7–8 is not). AnkerGames can confirm this in the scanner code.

Marker depth below the game root:

| Game | Marker | Depth | Launcher result |
|------|--------|-------|-----------------|
| HYPERCHARGE (3645) | `HYPERCHARGE Unboxed/Unboxed/Binaries/Win64/OnlineFix.ini` | 4 | ✅ files placed |
| Abyssus (2902) | `Abyssus/RGame/Binaries/Win64/OnlineFix.ini` | 4 | ✅ (would be found) |
| Species: Unknown (4035) | `Species Unknown/SpeciesUnknown/Binaries/Win64/OnlineFix.ini` | 4 | ✅ (would be found) |
| The Ascent (4013) | `The Ascent/Engine/Binaries/ThirdParty/Steamworks/Steamv152/Win64/steam_emu.ini` | 7 | ❌ missed |
| SCP 5K (2006) | `5K/WindowsNoEditor/Engine/Binaries/ThirdParty/Steamworks/Steamv151/Win64/OnlineFix.ini` | 8 | ❌ not found |

UE4/UE5 builds keep the Steamworks DLLs in
`Engine/Binaries/ThirdParty/Steamworks/<version>/Win64/`, so *any* UE build that
puts the fix there is 7–8 levels deep. The catalog already knows better: all of
these games are flagged `online_fix: true`.

### Suggested fix

* **Preferred:** rely on the catalog flag — if `online_fix` is true, place the
  five files. No filesystem guessing.
* **Minimum:** scan the whole game root (or at least depth 8) and add
  `union-crax.ini` to the marker list.
* **Always:** verify on **every** launch. The files are lost when the prefix is
  recreated, the game is reinstalled, or the user picks a new prefix.

---

## 3. Defect B — the native `winmm.dll` proxy is ignored

### Symptom

The game starts, but Steam is not initialised:

```
LogSteamShared: Warning: SteamAPI failed to initialize, conditions not met.
LogOnline: Warning: STEAM: Steamworks: SteamUser() failed!
LogOnline: STEAM: [AppId: 0] Client API initialized 0
```

### Evidence

HYPERCHARGE (3645), prefix already contained the five Steam files, fix present:

* **before** (`Unboxed/Saved/Logs/Unboxed.log`, 17:28 local time):
  `SteamAPI failed to initialize, conditions not met` →
  `[AppId: 0] Client API initialized 0`
* **after** launching with `WINEDLLOVERRIDES=winmm=n,b` (17:59):
  `LogSteamShared: Steam SDK Loaded!` →
  `LogOnline: STEAM: Steam User is subscribed 1` →
  `[AppId: 523660] Client API initialized 1`

Steam tracked the process:

```
AppID 480 adding PID 230454 as a tracked process
```

### Root cause

The build ships a native `winmm.dll` next to the shipping executable
(`Unboxed/Binaries/Win64/winmm.dll`, `RGame/Binaries/Win64/winmm.dll`,
`TheAscent/Binaries/Win64/winmm.dll`). On Windows the DLL search order prefers
the application directory, so the proxy loads. Under Wine the default for
`winmm` is `builtin, native`, so the proxy is skipped.

The launcher never sets any `WINEDLLOVERRIDES` — the binary contains no such
string at all. These builds therefore cannot work on Linux as shipped.

### Suggested fix

When a native `winmm.dll` exists anywhere under the game folder (depth ≤ 4 is
enough in practice), append the override to the launch environment:

```sh
export WINEDLLOVERRIDES="${WINEDLLOVERRIDES:+$WINEDLLOVERRIDES;}winmm=n,b"
```

Keep existing overrides (for example the launcher's own `ddraw` overrides for
old titles) — the variable is a semicolon-separated list.

---

## 4. Reference implementation

Minimal, drop-in version of both fixes for a umu/Proton launcher — this is the
code used for the verification above. Full commented file:
[`scripts/fix-reference.sh`](../../scripts/fix-reference.sh).

```sh
# 1) Steam client files for every online-fix build (any marker depth)
place_steam_client() {
  [ -n "$WINEPREFIX" ] || return 0
  steam_dir="$WINEPREFIX/drive_c/Program Files (x86)/Steam"
  [ -f "$steam_dir/steamclient64.dll" ] && return 0

  find "$(dirname "$1")" -maxdepth 8 \
       \( -iname 'OnlineFix.ini' -o -iname 'union-crax.ini' -o -iname 'steam_emu.ini' \) \
       -print -quit 2>/dev/null | grep -q . || return 0

  src="$HOME/.local/share/Steam"
  [ -f "$src/steamclient64.dll" ] || return 0

  mkdir -p "$steam_dir"
  cp -L "$src/steamclient64.dll"             "$steam_dir/steamclient64.dll"
  cp -L "$src/steamclient.dll"               "$steam_dir/steamclient.dll"
  cp -L "$src/GameOverlayRenderer64.dll"     "$steam_dir/GameOverlayRenderer64.dll"
  cp -L "$src/legacycompat/Steam.dll"        "$steam_dir/Steam.dll"
  cp -L "$src/legacycompat/SteamService.exe" "$steam_dir/steam.exe"
}

# 2) Prefer a bundled native winmm.dll (OnlineFix / union-crax / RUNE proxy)
case "$1" in
  *.exe)
    if find "$(dirname "$1")" -maxdepth 4 -iname 'winmm.dll' -print -quit 2>/dev/null | grep -q .; then
      export WINEDLLOVERRIDES="${WINEDLLOVERRIDES:+$WINEDLLOVERRIDES;}winmm=n,b"
    fi
    ;;
esac
```

Notes for the launcher implementation:

* Copy **after** the prefix exists, or create the directory tree yourself (as
  above) — Wine/Proton keeps existing files.
* `steam.exe` is `SteamService.exe` renamed; that is exactly what Proton does.
* Use `cp -L`: the Steam files can be symlinks in some installs (e.g. Flatpak).
* Refresh the five files when the Steam client updates; comparing file
  size/mtime is enough.
* The `find` calls are cheap for one launch, but a catalog flag avoids them
  entirely.

---

## 5. Verification

SCP 5K (`Pandemic.log`), after placing the files:

```
LogSteamShared: Display: Loading Steam SDK 1.51
LogSteamShared: Steam SDK Loaded!
LogOnline: OSS: Creating online subsystem instance for: Steam
LogOnline: STEAM: Steam User is subscribed 1
LogOnline: STEAM: [AppId: 872670] Client API initialized 1
LogOnline: STEAM: AUTH: Steam Auth Enabled
```

HYPERCHARGE, before/after the `winmm` override:

```
- LogSteamShared: Warning: SteamAPI failed to initialize, conditions not met.
- LogOnline: STEAM: [AppId: 0] Client API initialized 0
+ LogSteamShared: Steam SDK Loaded!
+ LogOnline: STEAM: Steam User is subscribed 1
+ LogOnline: STEAM: [AppId: 523660] Client API initialized 1
```

Steam client (`~/.local/share/Steam/logs/gameprocess_log.txt`):

```
[2026-11-25 18:01:17] AppID 480 adding PID 231790 as a tracked process
[2026-11-25 18:01:17] AppID 480 PID 231790 was launched outside Steam, ...
```

Raw excerpts and the evidence sheet: [`evidence.md`](evidence.md).

---

## 6. Known limitation — overlay and invites

Steam only injects its overlay (Shift+Tab, invite dialog) into games it launches
itself. A game started by the launcher is tracked as AppID 480 but gets no
`gameoverlayui` process, so Shift+Tab does nothing. The game's Steam API works
(friends list, lobbies, server lists) and friends can join through the game's
own UI, but overlay-based invites do not work.

If overlay invites are required, the launcher can offer an opt-in **"Add to
Steam"** action: create a non-Steam shortcut that starts the game through Steam
(the launcher already has `steam_shortcut_add` / `game_shortcut_create`
internals). That path also needs the Steam client files in Steam's compatdata
prefix, because Steam uses its own prefix there.

---

## 7. Metadata note — the "Co-Op" badge

`co_op: true` is currently a genre tag. For builds that are offline-only (for
example Call of Duty: Modern Warfare II, 2522 — a Goldberg build with only the
`sp22` campaign client, no `mp22` folder) it reads like "co-op works here".

Suggestion: gate the badge on `online_fix` / `multiplayer`, or add an explicit
"offline only" hint. Catalog metadata is otherwise correct for those titles.
