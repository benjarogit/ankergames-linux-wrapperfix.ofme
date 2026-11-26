# SPP Tarkov (3089)

[← Games](../../../README.md) · [Deutsch](../../de/games/tarkov.md) · [Technical notes](#6--why)

Choose what you want to do. Both players need the **same SPP Tarkov package**.
It includes Fika.

| I want to… | Start here |
| --- | --- |
| **Host co-op** | [Host a raid](#host-a-raid) |
| **Join a friend** | [Join a raid](#join-a-raid) |
| **Play solo** | [Start a local game](#2--start) |

[Windows setup](#install-on-windows) · [Linux setup](#1--install-linux) · [Troubleshooting](#5--troubleshooting)

## Install on Windows

1. Install SPP Tarkov (3089) in AnkerGames and complete the setup wizard.
   If a runtime is missing, install [.NET Desktop Runtime 10 and ASP.NET Core
   Runtime 10 for Windows x64](https://dotnet.microsoft.com/en-us/download/dotnet/10.0).
2. Open the SPT Launcher. If **Play** opens the setup wizard again, launch
   `Launcher.exe` from the installed game folder.

## 1 · Install (Linux)

Install SPP Tarkov (3089) in AnkerGames and get your paths from the game's
launch settings. Run the commands below from a local copy of this repository.
To get it, choose **Code → Download ZIP** on GitHub, extract it, and open a
terminal in the extracted folder. If the prefix does not exist yet, click
**Play** once so AnkerGames creates it, then close the .NET prompt.

| Variable | Path to enter |
| --- | --- |
| `TARKOV_PREFIX` | The Wine prefix for 3089, for example `/mnt/daten/Games/AnkerGames/Games/Prefixes/3089` |
| `TARKOV_GAME_DIR` | The managed game folder, for example `/mnt/daten/Games/AnkerGames/Games/Escape from Tarkov-3089` |

1. Replace both example paths with your own and install the Windows .NET
   runtimes inside the Wine prefix.

   ```sh
   TARKOV_PREFIX="/mnt/daten/Games/AnkerGames/Games/Prefixes/3089"
   TARKOV_GAME_DIR="/mnt/daten/Games/AnkerGames/Games/Escape from Tarkov-3089"
   scripts/install-dotnet-runtime.sh "$TARKOV_PREFIX"
   scripts/install-dotnet-runtime.sh "$TARKOV_PREFIX" --aspnet
   ```

2. If the package is freshly downloaded, press **Play** and finish the wizard
   once. The wizard unpacks around 65 GB. Then close AnkerGames.
3. Install the [umu wrapper](../../../README.md#the-common-fix) if it is
   missing. The native launcher also needs GTK and WebKitGTK. Download
   [Microsoft's dotnet-install script](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-install-script)
   and run these commands using the path where you saved it:

   ```sh
   bash dotnet-install.sh --channel 10.0 --runtime dotnet --install-dir "$HOME/.local/share/spt-dotnet"
   bash dotnet-install.sh --channel 10.0 --runtime aspnetcore --install-dir "$HOME/.local/share/spt-dotnet"
   ```

4. In the same terminal as step 1, set the Play target and enable the native
   launcher. If the Linux runtimes are elsewhere, add `--dotnet <directory>`
   to the second command.

   ```sh
   scripts/spp-tarkov-play-target.sh "$TARKOV_GAME_DIR" "$TARKOV_PREFIX"
   scripts/spp-tarkov-linux-launcher.sh "$TARKOV_PREFIX"
   ```

5. Reopen AnkerGames. On Linux, the native launcher can take around 40 seconds
   to appear while the server starts.

## 2 · Start

Click **Play** in AnkerGames. In the SPT Launcher, select **Local Server** when it shows **ONLINE**, and
create or select your own profile. Click **START GAME** once.

<details>
<summary>What the native launcher looks like on Linux</summary>

![The native SPT launcher with Local Server online](../../../assets/spp-tarkov-launcher-linux.png)

</details>

## 3 · Co-op

The simplest setup is to run the **SPT server and host the raid on the same
PC**. The guest needs that PC's address and their own SPT profile.

### Host a raid

1. Complete [Windows](#install-on-windows) or [Linux setup](#1--install-linux).
   Click **Play**, select **Local Server** when it is **ONLINE**, and sign
   into your own profile.
2. Pick how your friend will connect.

   <a name="same-home-network"></a>

   | Where you are | What you do | What you send |
   | --- | --- | --- |
   | Same home network | Use your LAN IP. No VPN needed. Find it with `ipconfig` on Windows or `ip -4 addr` on Linux. | Your LAN IP with `:6969` |
   | Two homes | [Set up Tailscale](#two-homes-using-tailscale). | Your Tailscale IP with `:6969` |

3. Confirm your firewall allows the guest to reach the two ports in
   [Host firewall](#host-firewall). Click **START GAME** once. If using
   Tailscale, then [set the VPN IP in Fika](#fika-over-tailscale).
4. In Tarkov, choose **Escape from Tarkov**, **PMC** or **SCAV**, then a
   location and time. Continue through practice settings and insurance.
   Click **Host Raid → Start**. Once your guest has loaded, click **Start Raid**.
   [Fika hosting steps](https://wiki.project-fika.com/playing-fika/hosting-a-raid).

### Join a raid

1. Install the same package using [Windows](#install-on-windows) or
   [Linux setup](#1--install-linux). Ask the host for their address. If you are
   playing from different homes, accept the host's [Tailscale share](#two-homes-using-tailscale).
2. Click **Play**, then open **Servers → Add New Server** in the SPT Launcher. Enter a name and
   paste the host's address including `:6969`. An example is
   `192.168.1.20:6969`.
3. Select the host's server, choose **Create New Profile** if needed, and sign
   in with your own profile. Click **START GAME** once. Look for
   `FIKA 2.4.2 | SPT 4.1.2` in the game.
4. Choose the same location and time as the host. Continue to the lobby, find
   their raid, and select **Join**. Wait for the host to start it.
   [Fika joining steps](https://wiki.project-fika.com/playing-fika/joining-a-raid).

### Two homes using Tailscale

1. Both players install Tailscale and sign in with their own accounts.
   Follow the [Windows](https://tailscale.com/docs/install/windows) or
   [Linux instructions](https://tailscale.com/docs/install/linux).
2. The host opens [Tailscale's device list](https://login.tailscale.com/admin/machines),
   selects **… → Share → Copy invite link** on their gaming PC, and sends the
   link privately. The guest opens it and accepts the share.
   [Tailscale device sharing](https://tailscale.com/docs/features/sharing).
3. Both players keep Tailscale connected. The guest uses the shared host's
   Tailscale IPv4 with `:6969`. On Linux, the host can find their own address
   with `tailscale ip -4`.

<details>
<summary>Install Tailscale on CachyOS or Arch Linux</summary>

```sh
sudo pacman -S tailscale
sudo systemctl enable --now tailscaled
sudo tailscale up
```

Open the sign-in link from the terminal.

</details>

#### Fika over Tailscale

After **START GAME**, the **raid host** opens **F12 → Fika.Core → Network**.
Set **Force IP** and **Force Bind IP** to your own Tailscale IPv4. Leave UPnP
and NAT Punching off. The guest uses Fika's default settings.
[Project Fika's VPN guidance](https://wiki.project-fika.com/faqandguides).

Tailscale provides the private link without router port forwarding. Radmin VPN
supports Windows and can be used when both PCs run Windows.
[Radmin requirements](https://www.radmin-vpn.com/help/).

### Host firewall

Allow incoming **6969/TCP** to SPT for launcher and profile traffic and
**25565/UDP** to the game for raid traffic. Allow the guest's LAN or Tailscale
IP. This package accepted a profile name without a server password, so keep
the backend on your trusted LAN or private VPN.

<details>
<summary>Firewall steps for Windows and Linux</summary>

- **Windows:** Open **Windows Defender Firewall with Advanced Security →
  Inbound Rules → New Rule → Custom**. Add one allow rule for local port
  TCP 6969 and another for UDP 25565. Under **Scope**, use the guest’s IP
  as the remote address.
  [Windows firewall instructions](https://learn.microsoft.com/en-us/windows/security/operating-system-security/network-security/windows-firewall/configure#create-an-inbound-port-rule).
- **Linux with UFW:** Replace the example below with the guest's LAN or
  Tailscale IPv4, then run:

  ```sh
  TARKOV_GUEST_IP="192.168.1.21"
  sudo ufw allow from "$TARKOV_GUEST_IP" to any port 6969 proto tcp
  sudo ufw allow from "$TARKOV_GUEST_IP" to any port 25565 proto udp
  sudo ufw status
  ```

</details>

> [!NOTE]
> The Linux client started and Fika's server version check passed.
> A guest connection from a second PC and a shared raid are still untested
> with this package. [Test evidence](../../../evidence/10-fika-coop.txt).

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

| What you see | What to do |
| --- | --- |
| The installer still opens, or the Windows launcher is blank under Wine | Check the Play target and native launcher in [Linux setup](#1--install-linux). Keep `SPP_WINE_LAUNCHER` unset for the native launcher. |
| The native launcher is blank under Wayland | Close it and start AnkerGames without forcing `GDK_BACKEND=x11`. |
| **Game has closed** appears while the game is loading | Wait for the game window before clicking again. The launcher's process check can report too early on Linux. [SPT launcher source](https://github.com/sp-tarkov/launcher/blob/master/project/SPTarkov.Core/Helpers/GameHelper.cs#L305-L321). |
| The launcher stays closed or **START GAME** does nothing | Check `~/.local/share/spt-server.log` for a startup timeout. Check the [Linux paths](#1--install-linux) and `GamePath` in `LauncherSettings.json`. |
| The guest cannot sign in | Confirm the address, `:6969` and TCP access using the check below. |
| The guest can sign in but cannot join the raid | Select the same server, location and time. Check the host's UDP rule and VPN IP settings. |
| **FIKA** is missing or a version mismatch appears | Match the package and mods on both PCs. Check `BepInEx/LogOutput.log` for `Fika.Core`. |
| AnkerGames says `game_stop_not_found` | Use [the stop steps](#4--stop). |

<details>
<summary>Check the connection from the guest's PC</summary>

Open `https://<host-IP>:6969/launcher/v2/ping`. Replace `<host-IP>` with
the LAN or Tailscale address. The test server uses a self-signed certificate.
You can also check the response code from the terminal:

```sh
curl -k -o /dev/null -w '%{http_code}\n' "https://<host-IP>:6969/launcher/v2/ping"
```

On Windows, use `curl.exe` with `NUL` in place of `/dev/null`. HTTP 200
confirms that the SPT server is reachable. Joining the raid checks the
separate UDP path. [Project Fika FAQ](https://wiki.project-fika.com/faqandguides).

</details>

<details>
<summary>Linux runtime errors and log paths</summary>

| Symptom | Cause | Fix |
|---|---|---|
| `CryptographicException: Erfolg.` at `CopyWithPrivateKey` | CNG is not implemented in Proton's Wine | run the native server |
| `System.ConsolePal.set_Title` / "Ungültiger Zugriff" | `SPT.Server.exe` started from a Unix terminal | start it with `wine start`, or use the native server |
| `Could not find file '...database\itemsToAdd.json'` | a mod builds a path with a backslash | `ln -s database/itemsToAdd.json 'database\itemsToAdd.json'` |
| `Nicht behebbarer Systemfehler` / `MS.Internal.Invariant.FailFast` | no usable font family in the prefix | `WINEPREFIX="<prefix>" winetricks -q corefonts` |
| `Failed to create CoreCLR` | W^X under Wine | launch with `DOTNET_EnableWriteXorExecute=0` |

Logs:

```
~/.local/share/net.ankergames.launcher/logs/games/prefix-3089.log   wrapper
~/.local/share/spt-server.log                                      native server
<game dir>/Logs/                                                   game client
```

</details>

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
