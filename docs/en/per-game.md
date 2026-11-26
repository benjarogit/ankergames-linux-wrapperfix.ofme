# Per-game matrix

[← Overview](../../README.md) · [Root cause](root-cause.md) · [Per game](per-game.md) · [Evidence](evidence.md) · [Tarkov fix](dotnet-installer.md) · [Co-op](coop.md) · **Deutsch:** [Spiele](../de/spiele.md)

All five games below were tested with the same launcher build (0.1.33), the same
runtime (umu 1.4.3 + Proton Experimental `11.0-100`) and their existing prefixes.
The only change between runs is the two launcher-side fixes.

---

## Results

| ID | Game | Fix layout | Real AppID | Fake AppID | Marker | Depth | Fix A needed | Fix B needed | Verified by |
|----|------|-----------|-----------|-----------|--------|-------|--------------|--------------|-------------|
| 2006 | SCP 5K | A — `steam_api64.dll` | 872670 | 480 | `OnlineFix.ini` | 8 | ✅ yes | — | UE log (`[AppId: 872670] Client API initialized 1`) |
| 3645 | HYPERCHARGE: Unboxed | B — `winmm.dll` | 523660 | 480 | `OnlineFix.ini` | 4 | already placed | ✅ yes | UE log (`[AppId: 523660] Client API initialized 1`) |
| 2902 | Abyssus | B — `winmm.dll` | 1721110 | 480 | `OnlineFix.ini` | 4 | already placed | ✅ yes | loaded modules + Steam process list |
| 4013 | The Ascent | C — `winmm.dll` + union-crax | 979690 | 480 | `steam_emu.ini` | 7 | ✅ yes | ✅ yes | loaded modules + Steam process list |
| 4035 | Species: Unknown | B — `winmm.dll` | 2747330 | 480 | `OnlineFix.ini` | 4 | already placed | ✅ yes | loaded modules + Steam process list |

Legend:

* **Fix A** = copy the five Steam client files into the prefix.
* **Fix B** = set `WINEDLLOVERRIDES=winmm=n,b`.
* **Depth** = folders between the game root and the marker file.
* "already placed" means the marker was shallow enough for the launcher's own
  scan, so only Fix B was missing.

---

## What each layout means

### Layout A — replaced `steam_api64.dll`

The build swaps the game's `steam_api64.dll` for the fix version and keeps the
original as `steam_api64.of`. The replacement resolves the real Steam client
through the prefix registry, so **only Fix A is required**. SCP 5K is the only
title in this set that uses this layout.

### Layout B — `winmm.dll` proxy

The build drops a native `winmm.dll` next to the shipping executable. That DLL
is the loader: it pulls in `OnlineFix64.dll`, which hooks `SteamAPI_Init` and
connects to the real Steam client. On Windows the application directory wins
the DLL search order; under Wine it does not, hence **Fix B is required**.
HYPERCHARGE, Abyssus and Species: Unknown use this layout.

### Layout C — `winmm.dll` + union-crax

The Ascent ships `winmm.dll` together with `union-crax.ini` and `steam_emu.ini`.
union-crax also loads `steamclient64.dll` from the prefix, so this layout needs
**both fixes**: the files (marker at depth 7) and the DLL override.

---

## How "Steam initialised" was checked

* **UE4/UE5 games with a log** (SCP 5K, HYPERCHARGE): the game writes
  `LogSteamShared` / `LogOnline` lines. `Client API initialized 1` with the real
  AppID is the definitive proof.
* **Builds without a usable UE log** (Abyssus, The Ascent, Species: Unknown):
  the check is the process itself — `OnlineFix64.dll`, `winmm.dll`,
  `steamclient64.dll` and `GameOverlayRenderer64.dll` mapped into the game
  process — plus Steam's `gameprocess_log.txt` showing the game as a tracked
  process under AppID 480.
* **All five**: `~/.local/share/Steam/logs/gameprocess_log.txt` records
  `AppID 480 adding PID … as a tracked process`, which only happens after a
  successful Steam client handshake.

AppID 480 is Spacewar, Valve's public test app. The fix spoofs it so Steam
allows the client API without owning the game. This is identical to the
behaviour on Windows and is what makes co-op with Windows players possible.

---

## Titles that look affected but are not

### Escape from Tarkov (3089)

Not a Steam title. The package is **SPP Tarkov** — a single-player project
(`SPP_Tarkov_Installer.exe` + `Data.bin`, "Complete SPP Tarkov client & local
server environment"). No Steam client API is involved, so neither fix applies.
Co-op is already included: the package ships Fika (server 2.4.0, client 2.4.2).
Host and guest checklists: [coop.md](coop.md). Catalog metadata
(`multiplayer: false`, `online_fix: false`) already reflects this.

It does have its own Linux blockers: the installer is a framework-dependent
.NET 10 WPF app and the prefix has no `Microsoft.WindowsDesktop.App`. After that
the local server fails twice — it needs `Microsoft.AspNetCore.App`, and under
Wine it cannot create its TLS certificate. Both are covered by provisioning the
official runtime zips plus running the native `SPT.Server.Linux` — see
[dotnet-installer.md](dotnet-installer.md).

Play also starts the installer, not the game, because the package contains
nothing else. The wizard re-extracts 64.7 GB on every run;
`spp-tarkov-play-target.sh` points Play at the installed SPT launcher instead.
The Windows launcher itself stays white under Wine and loses the cursor
(WebView2), so `spp-tarkov-linux-launcher.sh` makes Play run the native
`SPT.Launcher.Linux` that ships with the package.

### Call of Duty: Modern Warfare II (2522)

A Goldberg/offline build (`steam_settings/`, `steam_api64.dll`,
`steam_api64_GSE.dll`) that ships only the `sp22` campaign client — there is no
`mp22` folder. Catalog metadata is correct (`multiplayer: false`,
`online_fix: false`), but `co_op: true` is only a genre tag taken from the store
page and is misleading on Linux: Spec Ops co-op runs on Activision/Steam
dedicated servers with account + anti-cheat, so no client-side Steam fix can
enable it.

Suggestion: gate the "Co-Op" badge on `online_fix` / `multiplayer`, or add an
explicit "offline only" hint. See also
[the metadata note](root-cause.md#7-metadata-note--the-co-op-badge).

---

## Reproduction recipe

1. Delete the prefix of game 2006 (`…/Prefixes/2006`).
2. Start it from the launcher → `Failed to load original steamclient. Error code: 126`.
3. Copy the five files into the prefix → the game starts and the Steam API initialises.
4. Start game 3645 (files present) → it logs `[AppId: 0] Client API initialized 0`.
5. Start 3645 with `WINEDLLOVERRIDES=winmm=n,b` → `[AppId: 523660] Client API initialized 1`.
