# SPP Tarkov co-op: server host and guest

[← Overview](../../README.md) · [Tarkov fix](dotnet-installer.md) · [Evidence](evidence.md) · **Deutsch:** [Co-op](../de/coop.md)

SPP Tarkov ships **Fika**, the co-op mod for SPT. Nothing has to be installed:
the server mod is in `SPT_Runtime/user/mods/fika-server` (2.4.0), the client
plugin in `BepInEx/plugins/Fika` (2.4.2). What is missing is the network path
between the two players.

Two roles, two checklists:

| Role | Runs | Does |
|---|---|---|
| **Server host** | the SPT server on their PC | opens the ports, creates their own profile, hosts the raid |
| **Guest** | only the game client | connects to the host's server, creates their own profile, joins the raid |

Fika needs **two ports**:

| Port | Protocol | Purpose |
|---|---|---|
| 6969 | TCP | SPT backend: launcher login, profiles, inventory, Fika API |
| 25565 | UDP | in-raid networking between the players |

---

## Both sides: the same build

The client and the server must speak the same SPT and Fika versions. The
easiest and only tested combination here is **the same SPP Tarkov package on
both PCs**:

```
SPT   4.1.2
Fika  2.4.0 (server) / 2.4.2 (client)
```

A standard SPT install also works, but it needs the matching Fika client and
the same SPT version. Mixing 4.0 and 4.1 mods, or different Fika versions, is
the most common reason a connection fails.

> The launcher logs in with the **profile name** in SPT 4.1; no server password
> is checked. Anyone who can reach the server can create a profile and log in as
> an existing one. Share the address only with friends and never expose the
> server to the public internet without a VPN — Fika is not designed for public
> servers.

---

## Part A — the server host

### 1 · Start the server and check Fika

Start the SPT server as usual (Play in AnkerGames starts it, or run
`scripts/spp-tarkov-server.sh "<game dir>"`). The log must contain:

```
Mod: server Version: 2.4.0 (GUID: Fika | targets SPT: >=4.1.0) von: Fika geladen
[Fika Server] Overriding SPT configuration
```

Fika changes the listen address to `0.0.0.0`, so the server is reachable from
the network without editing `http.json`:

```sh
ss -ltn | grep 6969        # 0.0.0.0:6969
```

### 2 · Choose how the guest reaches you

| Situation | Address for the guest | What to do |
|---|---|---|
| Same LAN | `https://<LAN-IP>:6969` | nothing, only the firewall |
| Internet, router access | `https://<public-IP>:6969` | forward 6969/TCP and 25565/UDP to this PC |
| CGNAT / no port forwarding | `https://<VPN-IP>:6969` | both install a VPN such as ZeroTier or Tailscale |

The LAN address:

```sh
ip -4 route get 1.1.1.1 | awk '{print $7}'
```

The public address:

```sh
curl -4 -s https://ifconfig.me
```

Port forwarding is done in the router ("port forwarding" or "virtual server"):
**6969 TCP** and **25565 UDP** → the host PC's LAN address. The Fika wiki has
the step-by-step pages:
[port forwarding](https://wiki.project-fika.com/hosting-a-fika-server/host-using-port-forwarding)
and [VPN](https://wiki.project-fika.com/hosting-a-fika-server/host-using-a-vpn).

For a VPN, use the address the VPN client shows for the host (Tailscale `100.x`,
ZeroTier `10.x`/`172.x`, Radmin `26.x`). No router changes, no public IP.

### 3 · Open the Linux firewall

This setup runs `ufw`:

```sh
sudo ufw allow 6969/tcp
sudo ufw allow 25565/udp
sudo ufw status
```

With `firewalld` instead:

```sh
sudo firewall-cmd --add-port=6969/tcp --add-port=25565/udp
sudo firewall-cmd --runtime-to-permanent
```

### 4 · Verify from outside

On the host:

```sh
curl -k -o /dev/null -w '%{http_code}\n' https://<address>:6969/launcher/v2/ping
```

`200` means the server answers. Then check 6969/TCP from the internet with a
port checker such as <https://portchecker.co>. If it is closed, the router rule,
the firewall or the ISP is the problem — switch to the VPN method.

### 5 · Host the raid

The host PC is the one with 25565/UDP open, so the host also hosts the raid:

1. Main menu → **Escape from Tarkov** → PMC or SCAV.
2. Pick map and time, **Next** through practice settings and insurance.
3. In the lobby click **Host Raid**, then **Start**.
4. The raid waits (`Waiting for host to start the raid`). When the guest has
   joined, press **Start Raid**.

The host needs a profile of their own in the launcher (create one if the server
is fresh); the guest creates a separate one.

### 6 · What to send the guest

```
Server:   https://<address>:6969
Build:    SPP Tarkov, SPT 4.1.2, Fika 2.4.2 client
Login:    create your own profile, then log in with that name
```

If the guest does not use the same package, send the exact mod list too. Fika
can enforce it in `user/mods/fika-server/assets/configs/fika.jsonc`:

```jsonc
"client": {
  "mods": {
    "required": [],   // GUIDs the guest must have
    "optional": []    // GUIDs the guest may have
  }
}
```

---

## Part B — the guest

### 1 · Use the same build

Install the same SPP Tarkov package (or SPT 4.1.2 + Fika 2.4.2 client). Do not
add mods the host does not have, and do not mix SPT 4.0 and 4.1 mods.

### 2 · Add the host's server

Open the SPT launcher (the window that opens from Play) → server list (first
icon in the sidebar; on Windows “Settings → Add New Server”) → **ADD**:

| Field | Value |
|---|---|
| Name | anything, e.g. `Benny` |
| Address | `<address>:6969` — the launcher adds `https://`; a pasted `https://…` is accepted too, but no trailing slash |

The address is the one the host sent — LAN IP, public IP or VPN IP, always with
`:6969`.

### 3 · Create your own profile

The server lists the existing profiles. Click **CREATE NEW PROFILE**, pick a
unique name, and log in with **that name**. Never log in to the host's or
another player's profile — you would share the same character and inventory.

### 4 · Start the game and check Fika

Press **START GAME**. In the main menu the bottom left must show
`FIKA 2.4.2 | SPT 4.1.2`, and the **Online players** widget must be visible on
the right. If the label is missing, the Fika client did not load.

### 5 · Join the raid

Main menu → **Escape from Tarkov** → PMC or SCAV → map and time → **Next**
through practice settings and insurance → the host's raid appears in the lobby
list → **Join**. The raid starts when the host presses **Start Raid**.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Launcher says the server is offline | 6969/TCP not reachable | check the router rule, `ufw`, the VPN; test `https://<address>:6969/launcher/v2/ping` from outside |
| Guest can log in but sees no profiles | connected to the wrong server | select the host's entry in the launcher, not `Local Server`; if the list is empty, create a profile |
| `FIKA …` label missing in the menu | Fika client not loaded | same package/version; check `BepInEx/LogOutput.log` for `Fika.Core` |
| Fika version error | client and server versions differ | use the same package, or match client/server Fika versions |
| Raid list empty although the host started one | guest not on the same server, or UDP blocked | both must be on the host's server; open 25565/UDP on the **raid host** |
| “Error opening ports” when joining | the raid host's 25565/UDP is not reachable | let the server host host the raid, or forward 25565/UDP on the player who hosts |
| Disconnects, rubber-banding | Wi-Fi, VPN relay, weak upload | wired connection; try a different VPN exit |
| Crashes or desync with mods | incompatible SPT mods | remove mods on both sides until it works, then add them back in pairs |

More: [Fika FAQ](https://wiki.project-fika.com/faqandguides) and the
[Fika Discord](https://discord.gg/project-fika).

---

## Optional: NAT punching

If neither player can open 25565/UDP, Fika can tunnel the raid connection
through a NAT punch server. Enable it in `fika.jsonc`:

```jsonc
"natPunchServer": {
  "enable": true,
  "port": 6790
}
```

and point the client at a NAT punch server. The public one and the self-hosted
variant are described here:
[NAT punching](https://wiki.project-fika.com/advanced-features/nat-punching).
Port forwarding or a VPN is still the more reliable path.

---

## Why the server is already reachable

Fika overrides the SPT listen address from `127.0.0.1` to `0.0.0.0`
(`fika.jsonc` → `server.SPT.http.ip`). That is why the native Linux server,
started by the wrapper, accepts connections from the LAN without touching
`SPT_Data/configs/http.json`. The host's own launcher keeps using
`https://127.0.0.1:6969`; only the guest needs the network address.
