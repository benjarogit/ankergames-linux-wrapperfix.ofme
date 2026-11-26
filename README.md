<div align="center">

# AnkerGames on Linux

**Two fixes for games that fail to start. Neither touches the game files.**

[Deutsch](README.de.md) · [Tarkov guide](docs/en/tarkov.md) · [Co-op](docs/en/coop.md) · [Background](docs/en/background.md)

![platform](https://img.shields.io/badge/platform-Linux-0f172a?style=flat-square)
![runtime](https://img.shields.io/badge/runtime-umu%20%2B%20Proton-0f172a?style=flat-square)
![game files](https://img.shields.io/badge/game%20files-touched%20none-b42318?style=flat-square)

</div>

AnkerGames starts games through `umu-run` and Proton. Two different things go
wrong there:

* **Online-fix builds** never reach Steam — a few files are missing in the Wine
  prefix and one DLL override is not set. Fixes [A and B](#online-fix-builds).
* **SPP Tarkov** needs .NET runtimes in the prefix and a launcher that is not
  WebView2 — four commands, see [the Tarkov guide](docs/en/tarkov.md).

## Pick your case

| I want to… | Go to |
|---|---|
| play SPP Tarkov | [Tarkov guide](docs/en/tarkov.md) — or the four commands below |
| play Tarkov co-op with a friend | [Co-op guide](docs/en/coop.md) |
| fix another AnkerGames title | [Online-fix builds](#online-fix-builds) |
| understand why it breaks | [Background](docs/en/background.md) |

---

## SPP Tarkov: four commands

Run them from this repo. The two paths come from AnkerGames (game → launch
settings); typical values:

| Placeholder | Example |
|---|---|
| `<prefix>` | `/mnt/daten/Games/AnkerGames/Games/Prefixes/3089` |
| `<game dir>` | `/mnt/daten/Games/AnkerGames/Games/Escape from Tarkov-3089` |

```sh
# 1 · .NET 10 for the installer, the server and the launcher
scripts/install-dotnet-runtime.sh "<prefix>"

# 2 · ASP.NET Core for the SPT server
scripts/install-dotnet-runtime.sh "<prefix>" --aspnet

# 3 · Play starts the game, not the installer
scripts/spp-tarkov-play-target.sh "<game dir>" "<prefix>"

# 4 · Play starts the native launcher, not the white WebView2 window
scripts/spp-tarkov-linux-launcher.sh "<prefix>"
```

Close AnkerGames before step 3 (it rewrites its library file on start), then
open it again and press **Play**.

![The native SPT launcher on Linux](assets/spp-tarkov-launcher-linux.png)

You should get the **SPT Launcher** window, `Local Server` flips to ONLINE after
about 40 seconds, and **START GAME** launches the game.

> White window or no cursor? Step 4 did not take effect — see
> [Troubleshooting](docs/en/tarkov.md#troubleshooting).
> Step 4 also starts the server automatically before the launcher.

The full walkthrough (what each step does, verification, manual fallback,
troubleshooting) is in **[docs/en/tarkov.md](docs/en/tarkov.md)**.

---

## Co-op

Co-op needs no extra install: SPP Tarkov ships **Fika** (server 2.4.0, client
2.4.2).

* **Host:** opens `6969/TCP` and `25565/UDP`, hosts the raid.
* **Guest:** adds `https://<host>:6969` in the SPT Launcher, creates a profile,
  joins the raid.

Both checklists, the port-forwarding/VPN decision and troubleshooting:
**[docs/en/coop.md](docs/en/coop.md)**.

---

## Online-fix builds

These builds keep Valve's real Steam client: a proxy DLL inside the game loads
`steamclient64.dll` from the Wine prefix and connects it to the Steam client on
the host. On Linux the chain breaks in two places:

| # | What is missing | What you see |
|---|---|---|
| **A** | five Steam client files in the prefix | `Failed to load original steamclient. Error code: 126` — the game closes before the menu |
| **B** | `WINEDLLOVERRIDES=winmm=n,b` | game starts, but `[AppId: 0] Client API initialized 0` — no friends, no lobbies |

Both fixes live in one wrapper in front of `umu-run`:

```sh
mkdir -p ~/.local/bin
cp scripts/fix-reference.sh ~/.local/bin/umu-run
chmod +x ~/.local/bin/umu-run
```

`~/.local/bin` must come before `/usr/bin` in `PATH`. Then start the game as
usual. Nothing in the game folder changes.

> Using the Tarkov fix too? Run `scripts/spp-tarkov-linux-launcher.sh` **after**
> copying the wrapper — it inserts its block into the same file. Copying the
> wrapper again removes the block; just re-run the script.

Verified with the same launcher, runtime and prefixes:

| ID | Game | Needs | Result |
|---|---|---|---|
| 2006 | SCP 5K | A | `[AppId: 872670] Client API initialized 1` |
| 3645 | HYPERCHARGE: Unboxed | B | `[AppId: 523660] Client API initialized 1` |
| 2902 | Abyssus | B | fix DLLs mapped, Steam tracks the game |
| 4013 | The Ascent | A + B | fix DLLs mapped, Steam tracks the game |
| 4035 | Species: Unknown | B | fix DLLs mapped, Steam tracks the game |

Steam shows these games as **AppID 480 (Spacewar)** — that is how the builds work
on Windows too. Details, the five-game matrix and the reference code:
**[docs/en/background.md](docs/en/background.md)**.

---

## Documentation

| Document | Deutsch | Covers |
|---|---|---|
| [tarkov.md](docs/en/tarkov.md) | [tarkov.md](docs/de/tarkov.md) | SPP Tarkov from Play to the game, step by step |
| [coop.md](docs/en/coop.md) | [coop.md](docs/de/coop.md) | Fika: host, guest, ports, troubleshooting |
| [background.md](docs/en/background.md) | [hintergrund.md](docs/de/hintergrund.md) | how online-fix builds work, defect A/B, evidence |

---

## Repository layout

```
README.md                             this page (English, default)
README.de.md                          the same page in German
docs/en/, docs/de/                    tarkov, coop, background — both languages
evidence/                             raw log excerpts 01–10
scripts/fix-reference.sh              both online-fix fixes (the umu wrapper)
scripts/install-dotnet-runtime.sh     .NET runtimes 10 into a prefix
scripts/spp-tarkov-play-target.sh     Play starts the game, not the installer
scripts/spp-tarkov-linux-launcher.sh  Play starts the native SPT launcher
scripts/spp-tarkov-server.sh          starts the native SPT server manually
assets/                               screenshots and the pipeline diagram
```

---

## Scope

* Tested with Anker Launcher 0.1.30/0.1.33, umu-launcher 1.4.3, Proton
  Experimental, native Steam, CachyOS / KDE Wayland / NVIDIA.
* No game files are modified and no DRM is circumvented. The fixes only prepare
  the Wine prefix and set one Wine DLL override — the same work Proton's own
  `proton` script does when it creates a prefix.
* This is an observation and a reproducible fix, not an official AnkerGames
  statement.

<div align="center">

MIT licensed · written by [benjarogit](https://github.com/benjarogit) · November 2026

</div>
