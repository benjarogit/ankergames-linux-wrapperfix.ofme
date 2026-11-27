# SPP Tarkov (3089)

[← Spieleliste](../../../README.de.md) · [English](../../en/games/tarkov.md) · [Technik](#6--warum)

Wähle deinen Einstieg. Für Co-op braucht ihr beide **dasselbe SPP-Tarkov-Paket**.
Fika ist darin enthalten.

| Ich möchte … | Hier starten |
| --- | --- |
| **Für Freunde hosten** | [Ich hoste](#ich-hoste) |
| **Bei einem Freund mitspielen** | [Ich trete bei](#ich-trete-bei) |
| **Alleine spielen** | [Solo starten](#2--start) |

[Windows-Installation](#installation-unter-windows) · [Linux-Installation](#1--installation-linux) · [Fehlersuche](#5--fehlersuche)

## Installation unter Windows

1. Installiere SPP Tarkov (3089) in AnkerGames und schließe den Assistenten ab.
   Falls .NET fehlt, installiere [.NET Desktop Runtime 10 und ASP.NET Core
   Runtime 10 für Windows x64](https://dotnet.microsoft.com/en-us/download/dotnet/10.0).
2. Öffne den SPT-Launcher. Falls **Play** erneut den Assistenten öffnet, starte
   `Launcher.exe` aus dem installierten Spielordner.

## 1 · Installation (Linux)

Installiere SPP Tarkov (3089) in AnkerGames. Die Pfade findest du in den
Launch-Einstellungen des Spiels. Führe die Befehle in einer lokalen Kopie
dieses Repositories aus. Falls du es noch nicht hast, wähle auf GitHub
**Code → Download ZIP**, entpacke das Archiv und öffne dort ein Terminal.
Falls der Prefix noch fehlt, drücke einmal **Play**, damit AnkerGames ihn
anlegt. Schließe anschließend den .NET-Hinweis.

| Variable | Pfad, den du einträgst |
| --- | --- |
| `TARKOV_PREFIX` | Wine-Prefix für 3089, z. B. `/mnt/daten/Games/AnkerGames/Games/Prefixes/3089` |
| `TARKOV_GAME_DIR` | Verwalteter Spielordner, z. B. `/mnt/daten/Games/AnkerGames/Games/Escape from Tarkov-3089` |

1. Ersetze die beiden Beispielpfade durch deine eigenen und installiere die
   Windows-.NET-Runtimes im Wine-Prefix.

   ```sh
   TARKOV_PREFIX="/mnt/daten/Games/AnkerGames/Games/Prefixes/3089"
   TARKOV_GAME_DIR="/mnt/daten/Games/AnkerGames/Games/Escape from Tarkov-3089"
   scripts/install-dotnet-runtime.sh "$TARKOV_PREFIX"
   scripts/install-dotnet-runtime.sh "$TARKOV_PREFIX" --aspnet
   ```

2. Wenn du das Paket gerade heruntergeladen hast, drücke **Play** und führe
   den Assistenten einmal aus. Er entpackt rund 65 GB. Schließe danach
   AnkerGames.
3. Der native Tarkov-Start braucht einen umu-Wrapper. Verwende einen
   vorhandenen Wrapper unter `~/.local/bin/umu-run` weiter oder lege mit
   diesem Befehl bei Bedarf einen einfachen Wrapper für Tarkov an.

   ```sh
   mkdir -p ~/.local/bin
   if [ ! -e ~/.local/bin/umu-run ] && [ ! -L ~/.local/bin/umu-run ]; then
     printf '%s\n' '#!/bin/sh' 'exec /usr/bin/umu-run "$@"' > ~/.local/bin/umu-run
     chmod +x ~/.local/bin/umu-run
   fi
   ```

   Stelle sicher, dass im `PATH` von AnkerGames `~/.local/bin` vor `/usr/bin`
   steht. Der native Launcher braucht GTK und WebKitGTK. Lade
   [Microsofts dotnet-install-Skript](https://learn.microsoft.com/de-de/dotnet/core/tools/dotnet-install-script)
   herunter und verwende in den folgenden Befehlen den Pfad zur Skriptdatei:

   ```sh
   bash dotnet-install.sh --channel 10.0 --runtime dotnet --install-dir "$HOME/.local/share/spt-dotnet"
   bash dotnet-install.sh --channel 10.0 --runtime aspnetcore --install-dir "$HOME/.local/share/spt-dotnet"
   ```

4. Richte im selben Terminal wie in Schritt 1 das Play-Ziel und den nativen
   Launcher ein. Falls deine Linux-Runtimes woanders liegen, ergänze beim
   zweiten Befehl `--dotnet <Verzeichnis>`.

   ```sh
   scripts/spp-tarkov-play-target.sh "$TARKOV_GAME_DIR" "$TARKOV_PREFIX"
   scripts/spp-tarkov-linux-launcher.sh "$TARKOV_PREFIX"
   ```

5. Öffne AnkerGames erneut. Unter Linux kann es rund 40 Sekunden dauern,
   bis der native Launcher erscheint und der Server bereit ist.

## 2 · Start

Drücke in AnkerGames **Play**. Wähle im SPT-Launcher **Local Server**, sobald dort **ONLINE** steht.
Erstelle oder wähle dein eigenes Profil und drücke einmal **START GAME**.

<details>
<summary>So sieht der native Launcher unter Linux aus</summary>

![Der native SPT-Launcher mit Local Server online](../../../assets/spp-tarkov-launcher-linux.png)

</details>

## 3 · Co-op

Am einfachsten laufen **SPT-Server und Raid auf demselben PC**. Der
Mitspieler braucht die Adresse dieses PCs und ein eigenes SPT-Profil.

### Ich hoste

1. Schließe die [Windows-](#installation-unter-windows) oder
   [Linux-Installation](#1--installation-linux) ab. Drücke **Play**, wähle **Local Server** bei **ONLINE** und melde dich mit deinem Profil an.
2. Wähle, wie dein Mitspieler sich verbindet.

   <a name="im-selben-heimnetz"></a>

   | Wo ihr seid | Was du tust | Was du weitergibst |
   | --- | --- | --- |
   | Im selben Heimnetz | Nutze deine LAN-IP. Ein VPN ist hier überflüssig. Unter Windows zeigt sie `ipconfig`, unter Linux `ip -4 addr`. | Deine LAN-IP mit `:6969` |
   | In zwei Haushalten | [Richte Tailscale ein](#zwei-haushalte-mit-tailscale). | Deine Tailscale-IP mit `:6969` |

3. Prüfe, ob dein Mitspieler die zwei Ports in der
   [Host-Firewall](#host-firewall) erreichen darf. Drücke einmal **START GAME**.
   Über Tailscale stellst du anschließend [die VPN-IP in Fika](#fika-über-tailscale) ein.
4. Wähle im Spiel **Escape from Tarkov**, **PMC** oder **SCAV**, danach Karte
   und Uhrzeit. Gehe durch Übungsmodus und Versicherung. Klicke
   **Host Raid → Start**. Sobald dein Mitspieler geladen hat, klicke
   **Start Raid**. [Raid-Ablauf bei Project Fika](https://wiki.project-fika.com/playing-fika/hosting-a-raid).

### Ich trete bei

1. Installiere dasselbe Paket unter [Windows](#installation-unter-windows)
   oder [Linux](#1--installation-linux). Lass dir die Serveradresse geben.
   Spielt ihr von verschiedenen Haushalten, nimm die
   [Tailscale-Freigabe des Hosts](#zwei-haushalte-mit-tailscale) an.
2. Drücke **Play** und öffne im SPT-Launcher **Servers → Add New Server**. Gib einen eigenen
   Namen für den Eintrag ein und füge die Adresse des Hosts mit `:6969` ein,
   zum Beispiel `192.168.1.20:6969`.
3. Wähle den Server des Hosts. Erstelle bei Bedarf mit **Create New Profile**
   dein eigenes Profil und melde dich damit an. Drücke einmal **START GAME**.
   Im Spiel steht `FIKA 2.4.2 | SPT 4.1.2`.
4. Wähle dieselbe Karte und Uhrzeit wie der Host. Gehe bis zur Lobby, suche
   seinen Raid und klicke **Join**. Warte, bis der Host den Raid startet.
   [Beitritt bei Project Fika](https://wiki.project-fika.com/playing-fika/joining-a-raid).

### Zwei Haushalte mit Tailscale

1. Beide installieren Tailscale und melden sich mit eigenen Konten an.
   Folgt der Anleitung für [Windows](https://tailscale.com/docs/install/windows)
   oder [Linux](https://tailscale.com/docs/install/linux).
2. Der Host öffnet die [Tailscale-Geräteliste](https://login.tailscale.com/admin/machines),
   wählt beim Spiel-PC **… → Share → Copy invite link** und gibt den Link
   privat weiter. Der Mitspieler öffnet ihn und nimmt die Freigabe an.
   [Tailscale-Gerätefreigabe](https://tailscale.com/docs/features/sharing).
3. Beide lassen Tailscale verbunden. Der Mitspieler verwendet die
   Tailscale-IPv4 des freigegebenen Hosts mit `:6969`. Unter Linux zeigt
   `tailscale ip -4` dem Host seine eigene Tailscale-IPv4.

<details>
<summary>Tailscale auf CachyOS oder Arch Linux installieren</summary>

```sh
sudo pacman -S tailscale
sudo systemctl enable --now tailscaled
sudo tailscale up
```

Öffne den Anmeldelink aus dem Terminal.

</details>

#### Fika über Tailscale

Nach **START GAME** öffnet der **Raid-Host** im Spiel **F12 → Fika.Core →
Network**. Setze **Force IP** und **Force Bind IP** auf deine eigene
Tailscale-IPv4. UPnP und NAT Punching bleiben aus. Der Mitspieler verwendet
die Standardeinstellungen. [VPN-Hinweise von Project Fika](https://wiki.project-fika.com/faqandguides).

Tailscale stellt die private Verbindung ohne Portweiterleitung am Router her.
Radmin VPN unterstützt Windows und kommt für zwei Windows-PCs infrage.
[Radmin-Systemanforderungen](https://www.radmin-vpn.com/help/).

### Host-Firewall

Erlaube eingehend **6969/TCP** für Launcher und Profile und **25565/UDP**
für den Raid. Gib die Ports für die LAN- oder Tailscale-IP des Mitspielers frei.
Das getestete Paket akzeptiert einen Profilnamen ohne Serverpasswort. Halte
den Server daher im vertrauenswürdigen Heimnetz oder privaten VPN.

<details>
<summary>Firewall unter Windows oder Linux einstellen</summary>

- **Windows:** Öffne **Windows Defender Firewall mit erweiterter Sicherheit →
  Eingehende Regeln → Neue Regel → Benutzerdefiniert**. Lege je eine
  Zulassungsregel für den lokalen Port TCP 6969 und UDP 25565 an. Trage
  unter **Bereich** die Mitspieler-IP als Remote-IP-Adresse ein.
  [Windows-Firewall-Anleitung](https://learn.microsoft.com/en-us/windows/security/operating-system-security/network-security/windows-firewall/configure#create-an-inbound-port-rule).
- **Linux mit UFW:** Ersetze die Beispieladresse durch die LAN- oder
  Tailscale-IPv4 des Mitspielers:

  ```sh
  TARKOV_GUEST_IP="192.168.1.21"
  sudo ufw allow from "$TARKOV_GUEST_IP" to any port 6969 proto tcp
  sudo ufw allow from "$TARKOV_GUEST_IP" to any port 25565 proto udp
  sudo ufw status
  ```

</details>

> [!NOTE]
> Der Linux-Client ist gestartet und Fikas Versionsprüfung war erfolgreich.
> Der Beitritt von einem zweiten PC und ein gemeinsamer Raid sind für
> dieses Paket noch ungetestet. [Testbelege](../../../evidence/10-fika-coop.txt).

## 4 · Beenden

AnkerGames kann das Spiel nicht beenden: Es wurde vom SPT-Launcher gestartet,
nicht von AnkerGames, deshalb meldet der Stop-Button `game_stop_not_found`.
Dafür gibt es das Skript:

```sh
scripts/spp-tarkov-stop.sh "<prefix>"            # Spiel + Launcher
scripts/spp-tarkov-stop.sh "<prefix>" --server   # auch der SPT-Server
```

Das Spiel-Fenster schließen geht auch. Zeigt AnkerGames weiter *Playing*,
AnkerGames neu starten — das Badge ist veraltet.

---

## 5 · Fehlersuche

| Was du siehst | Was du tun kannst |
| --- | --- |
| Der Installer öffnet erneut oder der Windows-Launcher bleibt unter Wine weiß | Play-Ziel und nativen Launcher in der [Linux-Installation](#1--installation-linux) prüfen. Für den nativen Start bleibt `SPP_WINE_LAUNCHER` ungesetzt. |
| Der native Launcher bleibt unter Wayland weiß | Launcher schließen und AnkerGames ohne erzwungenes `GDK_BACKEND=x11` starten. |
| **Game has closed** erscheint beim Laden | Warte auf das Spielfenster, bevor du erneut klickst. Die Prozessprüfung des Launchers kann unter Linux zu früh melden. [SPT-Launcher-Quellcode](https://github.com/sp-tarkov/launcher/blob/master/project/SPTarkov.Core/Helpers/GameHelper.cs#L305-L321). |
| Der Launcher öffnet sich nicht oder **START GAME** tut nichts | `~/.local/share/spt-server.log` auf einen Start-Timeout prüfen. [Linux-Pfade](#1--installation-linux) und `GamePath` in `LauncherSettings.json` kontrollieren. |
| Der Mitspieler kann sich nicht anmelden | Adresse, Port `:6969` und TCP-Verbindung mit dem Test unten prüfen. |
| Die Anmeldung klappt, der Raid-Beitritt scheitert | Denselben Server, dieselbe Karte und Uhrzeit wählen. UDP-Regel und VPN-IP am Raid-Host prüfen. |
| **FIKA** fehlt oder die Versionen passen nicht | Paket und Mods auf beiden PCs abgleichen. In `BepInEx/LogOutput.log` nach `Fika.Core` suchen. |
| AnkerGames meldet `game_stop_not_found` | Folge den [Schritten zum Beenden](#4--beenden). |

<details>
<summary>Verbindung vom Mitspieler-PC prüfen</summary>

Öffne `https://<Host-IP>:6969/launcher/v2/ping` mit der LAN- oder
Tailscale-IP des Hosts. Der Testserver verwendet ein selbstsigniertes
Zertifikat. Du kannst den Statuscode auch im Terminal prüfen:

```sh
curl -k -o /dev/null -w '%{http_code}\n' "https://<Host-IP>:6969/launcher/v2/ping"
```

Unter Windows `curl.exe` verwenden und `/dev/null` durch `NUL` ersetzen.
HTTP 200 bestätigt, dass der SPT-Server erreichbar ist. Der Beitritt zum Raid
prüft den separaten UDP-Weg. [FAQ von Project Fika](https://wiki.project-fika.com/faqandguides).

</details>

<details>
<summary>Linux-Runtimefehler und Logdateien</summary>

| Symptom | Ursache | Fix |
|---|---|---|
| `CryptographicException: Erfolg.` bei `CopyWithPrivateKey` | CNG ist in Protons Wine nicht implementiert | nativen Server nutzen |
| `System.ConsolePal.set_Title` / „Ungültiger Zugriff" | `SPT.Server.exe` aus einem Unix-Terminal gestartet | mit `wine start` starten, oder den nativen Server nutzen |
| `Could not find file '...database\itemsToAdd.json'` | ein Mod baut einen Pfad mit Backslash | `ln -s database/itemsToAdd.json 'database\itemsToAdd.json'` |
| `Nicht behebbarer Systemfehler` / `MS.Internal.Invariant.FailFast` | keine nutzbare Schriftfamilie im Prefix | `WINEPREFIX="<prefix>" winetricks -q corefonts` |
| `Failed to create CoreCLR` | W^X unter Wine | mit `DOTNET_EnableWriteXorExecute=0` starten |

Logs:

```
~/.local/share/net.ankergames.launcher/logs/games/prefix-3089.log   Wrapper
~/.local/share/spt-server.log                                      nativer Server
<Spielordner>/Logs/                                                Spiel-Client
```

</details>

## 6 · Warum

* **Installer:** framework-dependent WPF (`net10.0-windows`) verlangt
  `Microsoft.WindowsDesktop.App`; Wine bringt kein .NET, also stoppt der App-Host
  vor dem Fenster.
* **Server:** braucht `Microsoft.AspNetCore.App` und kann unter Wine sein
  TLS-Zertifikat nicht erzeugen (`CopyWithPrivateKey` → CNG, nicht
  implementiert). Der native `SPT.Server.Linux` aus dem Paket umgeht beides.
* **Play-Ziel:** Das Paket enthält nur Installer plus `Data.bin`; nichts sagt dem
  Launcher, was danach starten soll.
* **Launcher-Fenster:** Photino/Blazor auf WebView2; die D3D-Fläche wird unter
  Wine nicht dargestellt, und das Cursor-Handle wird kein X11-Cursor. Photino
  übergibt eigene Browser-Argumente, deshalb kann
  `WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS` nicht helfen.

Belege:
[`08-spp-tarkov-server.txt`](../../../evidence/08-spp-tarkov-server.txt) ·
[`09-spp-tarkov-linux-launcher.txt`](../../../evidence/09-spp-tarkov-linux-launcher.txt) ·
[`10-fika-coop.txt`](../../../evidence/10-fika-coop.txt)

Vorschlag für den Launcher: .NET 10 (+ ASP.NET Core) für 3089 deklarieren, wie
andere Titel bereitstellen und nach dem Wizard Play auf `Launcher.exe` zeigen
lassen.
