# SPP Tarkov (3089)

[← Games](../../../README.md) · [How it works](../how-it-works.md) · **Deutsch:** [Tarkov](../../de/games/tarkov.md)

| | |
|---|---|
| Package | SPP Tarkov — single player plus Fika co-op |
| SPT / EFT | 4.1.2 / 0.16.9.40743 |
| Co-op | included: Fika server 2.4.0, client 2.4.2 |
| Status on Linux | works: Play → SPT Launcher → game |
| Needs | .NET 10 in the prefix, Play target, native launcher |

Contents: [1 Install](#1--install-linux) · [2 Start](#2--start) ·
[3 Co-op](#3--co-op) · [4 Stop](#4--stop) · [5 Troubleshooting](#5--troubleshooting) ·
[6 Why](#6--why)

---

## 1 · Install (Linux)

The package needs .NET runtimes inside its Wine prefix, Play must start the game
instead of the installer, and the launcher must be the native one. Four commands,
run from this repo. Paths come from AnkerGames → the game → launch settings:

Install the [shared umu wrapper](../../../README.md#the-common-fix) if it is
missing. The native launcher and server also need the Linux x64 .NET Runtime
and ASP.NET Core Runtime, both from the .NET 10 channel. With Microsoft's
[dotnet-install script](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-install-script)
downloaded, run the following before command 4:

```sh
bash dotnet-install.sh --channel 10.0 --runtime dotnet --install-dir "$HOME/.local/share/spt-dotnet"
bash dotnet-install.sh --channel 10.0 --runtime aspnetcore --install-dir "$HOME/.local/share/spt-dotnet"
```

If you installed the Linux runtimes elsewhere, pass `--dotnet <directory>`
to command 4. The native launcher also needs GTK and WebKitGTK.

| Placeholder | Example |
|---|---|
| `<prefix>` | `/mnt/daten/Games/AnkerGames/Games/Prefixes/3089` |
| `<game dir>` | `/mnt/daten/Games/AnkerGames/Games/Escape from Tarkov-3089` |

```sh
scripts/install-dotnet-runtime.sh "<prefix>"
scripts/install-dotnet-runtime.sh "<prefix>" --aspnet
scripts/spp-tarkov-play-target.sh "<game dir>" "<prefix>"
scripts/spp-tarkov-linux-launcher.sh "<prefix>"
```

Close AnkerGames before command 3. That script creates the launcher entry
and a runtime link in the managed game folder, then updates the launcher library
with a backup. Command 4 saves the Linux launcher settings and adds the native
launch block to the existing wrapper.

> **Fresh install?** After command 1, press Play once and run the wizard (it
> unpacks ~64.7 GB), then continue with command 2.

What each command does:

| Command | Why |
|---|---|
| 1 | the installer is a .NET 10 WPF app, Wine has no .NET → *"You must install .NET Desktop Runtime"* |
| 2 | the SPT server needs `Microsoft.AspNetCore.App` |
| 3 | Play starts `SPP_Tarkov_Installer.exe`; this points it at the game |
| 4 | the Windows launcher is WebView2 under Wine → white window, no cursor |

---

## 2 · Start

Press **Play**:

1. The native window opens as **SPT Launcher - Servers**. The Windows launcher
   uses *SPP Tarkov - Servers*.
2. Wait for **Local Server** to show **ONLINE**, then select it and sign into
   your profile.
3. Choose **START GAME** to launch `EscapeFromTarkov.exe` under Proton.

![The native SPT launcher](../../../assets/spp-tarkov-launcher-linux.png)

On a cold start, the wrapper waits for the server to answer before opening
the launcher. The launcher can take around 40 seconds to appear.

---

## 3 · Co-op

Fika is included in SPP Tarkov. Use the same package on both PCs. The
instructions cover hosting and joining on Windows and Linux.
Choose the [same home network](#same-home-network) or
[two homes](#two-homes-using-tailscale) setup.

**Test status:** The native SPT server loaded Fika 2.4.0 and accepted a profile
login through its LAN address from the same Linux PC. The package includes
Fika client 2.4.2, which appeared in the game UI on Linux. Connections from
another PC, UDP raid traffic and shared raids across Windows and Linux have
yet to be tested for this package.
[Co-op evidence](../../../evidence/10-fika-coop.txt).

### Both sides

Agree on who will run the SPT server and host the raid. The launcher connects
to the SPT server on **6969/TCP**. The game connects to the player who clicks
**Host Raid** on **25565/UDP**. Using the same PC for both roles is simplest.
Use a trusted LAN or shared private VPN. The tested launcher accepted a profile
name without a server password, so restrict access to the server.

### Host — Windows

1. Start SPP Tarkov and wait until the local server is online.
2. In Windows Defender Firewall, allow incoming TCP 6969 for the SPT server
   and UDP 25565 for the game client. Scope the rules to the LAN or VPN
   addresses of the players.
3. Sign in with your own profile, using the shared server address in the
   launcher if you are hosting through a VPN.

### Host — Linux

1. Follow the [Linux installation](#1--install-linux), click **Play** and wait
   for the server to come online.
2. Allow incoming TCP 6969 and UDP 25565 from the players on the LAN or VPN.
   For UFW, replace `<guest-IP>` with the guest's LAN or VPN IPv4 address:

   ```sh
   sudo ufw allow from <guest-IP> to any port 6969 proto tcp
   sudo ufw allow from <guest-IP> to any port 25565 proto udp
   sudo ufw status
   ```

3. Sign in with your own profile. For a VPN, select the shared address in the
   launcher if needed.

### Same home network

You can play without a VPN or an additional tool. Start the SPT server on the
host PC. In the SPT Launcher, the guest enters the host's LAN IPv4 address with
`:6969`, for example `192.168.1.20:6969`. On the host, use `ipconfig` on
Windows or `ip -4 addr` on Linux to find the address.

### Two homes using Tailscale

Tailscale connects your two PCs over a private virtual network. This setup
requires no router port forwarding. Radmin VPN provides a Windows client and is
an option for two Windows PCs. For a Linux host and Windows guest, this guide
uses Tailscale. [Radmin system requirements](https://www.radmin-vpn.com/help/).

1. **Both players install Tailscale** and sign in with their own accounts.
   On Windows, use the [Tailscale installer](https://tailscale.com/docs/install/windows).
   On [other Linux distributions](https://tailscale.com/docs/install/linux),
   follow the relevant installation steps. On CachyOS and Arch Linux:

   ```sh
   sudo pacman -S tailscale
   sudo systemctl enable --now tailscaled
   sudo tailscale up
   ```

   Open the link printed in the terminal and sign in.
2. **The host shares their gaming PC.** In the
   [Tailscale Machines list](https://login.tailscale.com/admin/machines),
   choose **… → Share → Copy invite link** on the gaming PC. Send the link
   privately to the guest, who opens it and accepts the share with their own
   account. Both players keep Tailscale connected while playing.
   [Tailscale device sharing](https://tailscale.com/docs/features/sharing).
3. **The guest connects in SPT.** The host starts SPP Tarkov and waits for
   **ONLINE**. The guest uses the shared host's Tailscale IPv4 address with
   `:6969`. On the host, `tailscale ip -4` prints its Tailscale IPv4. The
   guest adds the address under **ADD NEW SERVER** and signs in with their own
   profile.
4. **The host configures Fika.** On the same PC as the SPT server, open
   **F12 → Fika.Core → Network** in the game. Set **Force IP** and
   **Force Bind IP** to the host's own Tailscale IPv4. Leave **UPnP** and
   **NAT Punching** off. The host selects **Host Raid** and the guest selects
   **Join**. [Fika network settings](https://wiki.project-fika.com/faqandguides).

Project Fika also documents router port forwarding for separate networks.
Tailscale keeps the server accessible over the private network. Joining from a
second PC over Tailscale has yet to be verified with this package.
[Project Fika's hosting options](https://wiki.project-fika.com/hosting-a-fika-server).

### Verify the connection

Share the chosen address, port `6969` and package version with the guest. From
the guest PC, open `https://<address>:6969/launcher/v2/ping` or run the
following command. In Windows PowerShell, use `curl.exe` and replace
`/dev/null` with `NUL`.

```sh
curl -k -o /dev/null -w '%{http_code}\n' https://<address>:6969/launcher/v2/ping
```

Replace `<address>` before running the command. HTTP 200 confirms the HTTPS
backend is reachable. The shared raid checks the separate UDP path.

### Guest — Windows

1. Install the **same** SPP Tarkov package and press **Play**. If the package
   asks for .NET, get the Windows x64 Desktop Runtime 10 and ASP.NET Core
   Runtime 10 from [Microsoft's .NET 10 downloads](https://dotnet.microsoft.com/en-us/download/dotnet/10.0).
2. In the SPT Launcher open the server list (first icon in the sidebar;
   on Windows also *Settings → Add New Server*) → **ADD NEW SERVER**:

   | Field | Value |
   |---|---|
   | Name | anything, e.g. `Benny` |
   | Address | `<address>:6969` |

   The launcher adds `https://` itself; keep the `:6969`, no trailing slash.
3. **CREATE NEW PROFILE**, pick a name, log in with that name. Never use the
   host's profile — you would share the character.
4. **START GAME**. Bottom left must show `FIKA 2.4.2 | SPT 4.1.2`.
5. Join the raid (flow below).

### Guest — Linux

Same as Windows, plus this repo's fix so Play starts the native launcher
([steps 1–4](#1--install-linux)). Then add the server, create a profile and join
exactly as above.

### Raid flow

1. Host: main menu → **Escape from Tarkov** → PMC or SCAV → map and time →
   **Next** through practice settings and insurance.
2. Host: select **Host Raid** in the lobby and press **Start** to load in.
3. Guest: same menu path; the host's raid appears in the lobby list → **Join**.
4. Host: press **Start Raid** once the guest has loaded.
   [Fika raid hosting](https://wiki.project-fika.com/playing-fika/hosting-a-raid) ·
   [Joining a Fika raid](https://wiki.project-fika.com/playing-fika/joining-a-raid).

### Co-op troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Launcher says the server is offline | 6969/TCP not reachable | check the address, firewall and VPN; test `https://<address>:6969/launcher/v2/ping` |
| Login works, but no profiles | wrong server selected | select the host's entry, not `Local Server`; if the list is empty, create a profile |
| `FIKA …` missing in the menu | client plugin not loaded | same package/version; check `BepInEx/LogOutput.log` for `Fika.Core` |
| Fika version error | client and server differ | use the same package, or match the Fika versions |
| Raid list empty although the host started one | guest on another server or using different raid settings | select the same server, location and time phase |
| “Error opening ports” when joining | the raid host's 25565/UDP is unreachable | check the raid host’s firewall and VPN IP settings |
| Disconnects, rubber-banding | Wi-Fi, VPN relay, weak upload | wired connection; another VPN exit |
| Crashes or desync with mods | incompatible SPT mods | remove mods on both sides, add them back in pairs |

More: [Fika FAQ](https://wiki.project-fika.com/faqandguides) and the
[Fika Discord](https://discord.gg/project-fika).

---

## 4 · Stop

AnkerGames cannot stop the game: the game is started by the SPT launcher, not by
AnkerGames, so its stop button reports `game_stop_not_found`. Use the script:

```sh
scripts/spp-tarkov-stop.sh "<prefix>"            # game + launcher
scripts/spp-tarkov-stop.sh "<prefix>" --server   # also the SPT server
```

Closing the game window works too. If AnkerGames still shows *Playing*, restart
AnkerGames — the badge is stale.

---

## 5 · Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Window stays white, title *SPP Tarkov - Servers* | the Windows launcher is running | re-run step 4; `SPP_WINE_LAUNCHER` must not be set |
| Native **SPT Launcher - Servers** window stays white | This happened with `GDK_BACKEND=x11` forced on the Wayland test session | Close the launcher and start AnkerGames without forcing the GTK backend |
| Window white **and** no cursor | Windows launcher + [Wine bug 58922](https://bugs.winehq.org/show_bug.cgi?id=58922) | use the native launcher |
| Still *"You must install .NET Desktop Runtime"* | runtime in the wrong prefix, or version < 10.0 | check `<prefix>/drive_c/Program Files/dotnet/shared/Microsoft.WindowsDesktop.App` |
| `Framework: 'Microsoft.AspNetCore.App', version '10.0.0'` | ASP.NET Core missing | `scripts/install-dotnet-runtime.sh "<prefix>" --aspnet` |
| `CryptographicException: Erfolg.` at `CopyWithPrivateKey` | CNG is not implemented in Proton's Wine | run the native server |
| `System.ConsolePal.set_Title` / "Ungültiger Zugriff" | `SPT.Server.exe` started from a Unix terminal | start it with `wine start`, or use the native server |
| The launcher stays closed and the log says the server did not become ready | The local server failed to answer within two minutes | Check `~/.local/share/spt-server.log` and run `scripts/spp-tarkov-server.sh "<game dir>" --status` |
| `Could not find file '...database\itemsToAdd.json'` | a mod builds a path with a backslash | `ln -s database/itemsToAdd.json 'database\itemsToAdd.json'` |
| `Nicht behebbarer Systemfehler` / `MS.Internal.Invariant.FailFast` | no usable font family in the prefix | `WINEPREFIX="<prefix>" winetricks -q corefonts` |
| `Failed to create CoreCLR` | W^X under Wine | launch with `DOTNET_EnableWriteXorExecute=0` |
| Installer starts, but Play keeps offering it | step 3 not applied, or game outside the managed folder | re-run step 3 |
| Launcher opens, **START GAME** does nothing | server offline, or `GamePath` wrong | check server status and `LauncherSettings.json` |
| AnkerGames: `game_stop_not_found` | game started by the SPT launcher | [stop it yourself](#4--stop) |
| Second **START GAME** hangs, no game window | two launches at once, or a second launcher holds the prefix | close all launchers and game windows, start once |

Logs:

```
~/.local/share/net.ankergames.launcher/logs/games/prefix-3089.log   wrapper
~/.local/share/spt-server.log                                      native server
<game dir>/Logs/                                                   game client
```

---

## 6 · Why

* **Installer:** framework-dependent WPF (`net10.0-windows`) asks for
  `Microsoft.WindowsDesktop.App`; Wine ships no .NET, so the app host stops
  before a window is drawn.
* **Server:** needs `Microsoft.AspNetCore.App`, and under Wine cannot create its
  TLS certificate (`CopyWithPrivateKey` → CNG, not implemented). The native
  `SPT.Server.Linux` from the package avoids both.
* **Play target:** the package contains only the installer plus `Data.bin`;
  nothing tells the launcher what to start afterwards.
* **Launcher window:** Photino/Blazor on WebView2; its D3D surface does not
  present under Wine, and the cursor handle cannot become an X11 cursor. Photino
  passes its own browser arguments, so `WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS`
  cannot help.

Evidence:
[`08-spp-tarkov-server.txt`](../../../evidence/08-spp-tarkov-server.txt) ·
[`09-spp-tarkov-linux-launcher.txt`](../../../evidence/09-spp-tarkov-linux-launcher.txt) ·
[`10-fika-coop.txt`](../../../evidence/10-fika-coop.txt)

Suggestion for the launcher: declare .NET 10 (+ ASP.NET Core) for 3089, provision
it like other titles, and after the wizard point Play at `Launcher.exe`.
