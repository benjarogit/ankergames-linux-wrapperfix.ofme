# SPP Tarkov (3089)

[← Spieleliste](../../../README.de.md) · [So funktioniert es](../wie-es-funktioniert.md) · **English:** [Tarkov](../../en/games/tarkov.md)

| | |
|---|---|
| Paket | SPP Tarkov — Singleplayer plus Fika-Co-op |
| SPT / EFT | 4.1.2 / 0.16.9.40743 |
| Co-op | enthalten: Fika-Server 2.4.0, Client 2.4.2 |
| Status unter Linux | läuft: Play → SPT Launcher → Spiel |
| Nötig | .NET 10 im Prefix, Play-Ziel, nativer Launcher |

Inhalt: [1 Installation](#1--installation-linux) · [2 Start](#2--start) ·
[3 Co-op](#3--co-op) · [4 Beenden](#4--beenden) · [5 Fehlersuche](#5--fehlersuche) ·
[6 Warum](#6--warum)

---

## 1 · Installation (Linux)

Das Paket braucht .NET-Runtimes in seinem Wine-Prefix, Play muss das Spiel statt
des Installers starten, und der Launcher muss der native sein. Vier Befehle, im
Repo-Ordner ausgeführt. Die Pfade stehen in AnkerGames → Spiel →
Launch-Einstellungen:

Installiere bei Bedarf den [gemeinsamen umu-Wrapper](../../../README.de.md#der-gemeinsame-fix).
Der native Launcher und Server brauchen außerdem die .NET Runtime und die
ASP.NET Core Runtime für Linux x64 aus dem .NET-10-Kanal. Lade Microsofts
[dotnet-install-Skript](https://learn.microsoft.com/de-de/dotnet/core/tools/dotnet-install-script)
herunter und führe vor Befehl 4 Folgendes aus:

```sh
bash dotnet-install.sh --channel 10.0 --runtime dotnet --install-dir "$HOME/.local/share/spt-dotnet"
bash dotnet-install.sh --channel 10.0 --runtime aspnetcore --install-dir "$HOME/.local/share/spt-dotnet"
```

Sind die Linux-Runtimes woanders installiert, gib bei Befehl 4
`--dotnet <Verzeichnis>` an. Der native Launcher braucht auch GTK und WebKitGTK.

| Platzhalter | Beispiel |
|---|---|
| `<prefix>` | `/mnt/daten/Games/AnkerGames/Games/Prefixes/3089` |
| `<Spielordner>` | `/mnt/daten/Games/AnkerGames/Games/Escape from Tarkov-3089` |

```sh
scripts/install-dotnet-runtime.sh "<prefix>"
scripts/install-dotnet-runtime.sh "<prefix>" --aspnet
scripts/spp-tarkov-play-target.sh "<Spielordner>" "<prefix>"
scripts/spp-tarkov-linux-launcher.sh "<prefix>"
```

Schließe AnkerGames vor Befehl 3. Das Skript legt den Launcher-Einstieg und
einen Runtime-Link im verwalteten Spielordner an. Es sichert die Launcher-Library,
bevor es das Play-Ziel umstellt. Befehl 4 speichert die Linux-Einstellungen und
ergänzt den nativen Start im bestehenden Wrapper.

> **Frische Installation?** Nach Befehl 1 einmal Play drücken und den Wizard
> durchlaufen (er entpackt ~64,7 GB), dann mit Befehl 2 weitermachen.

Was die Befehle tun:

| Befehl | Warum |
|---|---|
| 1 | der Installer ist eine .NET-10-WPF-App, Wine hat kein .NET → *„You must install .NET Desktop Runtime"* |
| 2 | der SPT-Server braucht `Microsoft.AspNetCore.App` |
| 3 | Play startet `SPP_Tarkov_Installer.exe`; das richtet es auf das Spiel |
| 4 | der Windows-Launcher ist WebView2 unter Wine → weißes Fenster, kein Cursor |

---

## 2 · Start

**Play** drücken:

1. Der native Launcher öffnet als **SPT Launcher - Servers**. Der
   Windows-Launcher heißt *SPP Tarkov - Servers*.
2. Warten, bis **Local Server** auf **ONLINE** steht. Den Eintrag wählen und mit
   dem eigenen Profil anmelden.
3. **START GAME** startet `EscapeFromTarkov.exe` unter Proton.

![Der native SPT-Launcher](../../../assets/spp-tarkov-launcher-linux.png)

Beim Kaltstart wartet der Wrapper auf die Antwort des Servers. Bis der
Launcher erscheint, kann es rund 40 Sekunden dauern.

---

## 3 · Co-op

Fika ist in SPP Tarkov enthalten. Nutzt auf beiden PCs dasselbe Paket. Die
Anleitung deckt das Hosten und Beitreten unter Windows und Linux ab.

**Teststand:** Der native SPT-Server hat Fika 2.4.0 geladen und eine
Profilanmeldung über seine LAN-Adresse vom selben Linux-PC angenommen. Der
Linux-Spielclient zeigte Fika 2.4.2 an. Verbindungen von einem zweiten PC,
UDP-Spielverkehr und gemeinsame Raids zwischen Windows und Linux sind für
dieses Paket noch ungetestet. [Co-op-Belege](../../../evidence/10-fika-coop.txt).

### Beide Seiten

Legt fest, wer den SPT-Server startet und den Raid hostet. Der Launcher
verbindet sich über **6969/TCP** mit dem SPT-Server. Das Spiel verbindet sich
über **25565/UDP** mit dem Spieler, der **Host Raid** anklickt. Am einfachsten
übernimmt ein PC beide Aufgaben. Nutzt ein vertrauenswürdiges LAN oder
gemeinsames privates VPN. Der getestete Launcher akzeptierte einen Profilnamen
ohne Serverpasswort. Beschränkt daher den Zugriff auf den Server.

### Host — Windows

1. SPP Tarkov starten und warten, bis der lokale Server online ist.
2. In der Windows Defender Firewall eingehend TCP 6969 für den SPT-Server und
   UDP 25565 für den Spielclient erlauben. Die Regeln auf die LAN- oder
   VPN-Adressen der Mitspieler eingrenzen.
3. Mit eigenem Profil anmelden. Beim Hosten über VPN bei Bedarf die gemeinsame
   Serveradresse im Launcher wählen.

### Host — Linux

1. Der [Linux-Installation](#1--installation-linux) folgen, **Play** drücken
   und warten, bis der Server online ist.
2. TCP 6969 und UDP 25565 eingehend für die Mitspieler im LAN oder VPN
   erlauben. Bei UFW `<Mitspieler-IP>` durch die LAN- oder VPN-IPv4-Adresse
   des Mitspielers ersetzen:

   ```sh
   sudo ufw allow from <Mitspieler-IP> to any port 6969 proto tcp
   sudo ufw allow from <Mitspieler-IP> to any port 25565 proto udp
   sudo ufw status
   ```

3. Mit eigenem Profil anmelden. Beim Hosten über VPN bei Bedarf die gemeinsame
   Serveradresse im Launcher wählen.

### Adresse für den Mitspieler

- **Gleiches LAN:** Die LAN-IPv4-Adresse des Server-PCs verwenden. Unter Windows
  zeigt `ipconfig` die Adresse an, unter Linux `ip -4 addr`.
- **Verschiedene Netze:** Beide treten demselben privaten VPN bei und nutzen
  die VPN-IPv4-Adresse des Server-PCs. Wer den Raid über VPN hostet, drückt im
  Spiel **F12** und setzt unter **Fika.Core → Network** die Optionen
  **Force IP** und **Force Bind IP** auf die eigene VPN-IP. UPnP und NAT
  Punching bleiben dabei deaktiviert.
  [VPN-Anleitung von Project Fika](https://wiki.project-fika.com/hosting-a-fika-server/host-using-a-vpn).

Dem Mitspieler die Adresse, Port `6969` und die Paketversion geben. Auf dem
Mitspieler-PC `https://<Adresse>:6969/launcher/v2/ping` öffnen oder den
folgenden Befehl ausführen. In Windows PowerShell `curl.exe` verwenden und
`/dev/null` durch `NUL` ersetzen.

```sh
curl -k -o /dev/null -w '%{http_code}\n' https://<Adresse>:6969/launcher/v2/ping
```

Vor dem Ausführen `<Adresse>` ersetzen. HTTP 200 bestätigt, dass das
HTTPS-Backend erreichbar ist. Der gemeinsame Raid prüft die separate
UDP-Verbindung.

### Mitspieler — Windows

1. Dasselbe SPP-Tarkov-Paket installieren und **Play** drücken. Falls .NET
   fehlt, die Windows-x64-Desktop-Runtime 10 und ASP.NET Core Runtime 10 bei
   [Microsoft herunterladen](https://dotnet.microsoft.com/en-us/download/dotnet/10.0).
2. Im SPT-Launcher die Server-Liste öffnen (erstes Symbol in der Seitenleiste;
   unter Windows auch *Settings → Add New Server*) → **ADD NEW SERVER**:

   | Feld | Wert |
   |---|---|
   | Name | beliebig, z. B. `Benny` |
   | Adresse | `<Adresse>:6969` |

   Der Launcher ergänzt `https://` selbst; `:6969` bleibt dran, kein Schrägstrich
   am Ende.
3. **CREATE NEW PROFILE**, eigenen Namen wählen, mit diesem Namen anmelden. Nie
   das Profil des Hosts nutzen — sonst teilt man sich den Charakter.
4. **START GAME**. Unten links muss `FIKA 2.4.2 | SPT 4.1.2` stehen.
5. Raid joinen (Ablauf unten).

### Mitspieler — Linux

Wie Windows, zusätzlich der Fix aus diesem Repo, damit Play den nativen Launcher
startet ([Schritte 1–4](#1--installation-linux)). Danach Server eintragen, Profil
anlegen und joinen — genau wie oben.

### Ablauf im Raid

1. Host: Hauptmenü → **Escape from Tarkov** → PMC oder SCAV → Karte und Uhrzeit
   → **Next** durch Practice-Einstellungen und Versicherung.
2. Host: In der Lobby **Host Raid** wählen und mit **Start** laden.
3. Mitspieler: gleicher Menüweg; der Raid des Hosts erscheint in der Lobby-Liste
   → **Join**.
4. Host: **Start Raid** drücken, sobald der Mitspieler fertig geladen hat.
   [Raid hosten](https://wiki.project-fika.com/playing-fika/hosting-a-raid) ·
   [Raid beitreten](https://wiki.project-fika.com/playing-fika/joining-a-raid).

### Co-op-Fehlersuche

| Symptom | Ursache | Fix |
|---|---|---|
| Launcher meldet Server offline | 6969/TCP nicht erreichbar | Adresse, Firewall und VPN prüfen; `https://<Adresse>:6969/launcher/v2/ping` testen |
| Login geht, aber keine Profile | falscher Server gewählt | den Eintrag des Hosts wählen, nicht `Local Server`; ist die Liste leer, ein Profil anlegen |
| `FIKA …` fehlt im Menü | Client-Plugin nicht geladen | gleiches Paket/Version; `BepInEx/LogOutput.log` auf `Fika.Core` prüfen |
| Fika-Versionsfehler | Client und Server passen nicht | gleiches Paket, oder Fika-Versionen angleichen |
| Raid-Liste leer, obwohl der Host gestartet hat | anderer Server oder abweichende Raid-Einstellungen | denselben Server, dieselbe Karte und Uhrzeit wählen |
| „Error opening ports" beim Joinen | 25565/UDP des Raid-Hosts nicht erreichbar | Firewall und VPN-IP des Raid-Hosts prüfen |
| Disconnects, Rubber-Banding | WLAN, VPN-Relay, schwacher Upload | Kabel; anderen VPN-Ausgang testen |
| Abstürze oder Desync mit Mods | inkompatible SPT-Mods | Mods auf beiden Seiten entfernen, dann paarweise zurück |

Mehr: [Fika-FAQ](https://wiki.project-fika.com/faqandguides) und der
[Fika-Discord](https://discord.gg/project-fika).

---

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

| Symptom | Ursache | Fix |
|---|---|---|
| Fenster bleibt weiß, Titel *SPP Tarkov - Servers* | der Windows-Launcher läuft | Schritt 4 erneut; `SPP_WINE_LAUNCHER` darf nicht gesetzt sein |
| Natives Fenster **SPT Launcher - Servers** bleibt weiß | Das trat in der Wayland-Testsitzung bei erzwungenem `GDK_BACKEND=x11` auf | Launcher schließen und AnkerGames ohne erzwungenes GTK-Backend starten |
| Fenster weiß **und** kein Cursor | Windows-Launcher + [Wine-Bug 58922](https://bugs.winehq.org/show_bug.cgi?id=58922) | den nativen Launcher nutzen |
| Weiterhin *„You must install .NET Desktop Runtime"* | Runtime im falschen Prefix, oder Version < 10.0 | `<prefix>/drive_c/Program Files/dotnet/shared/Microsoft.WindowsDesktop.App` prüfen |
| `Framework: 'Microsoft.AspNetCore.App', version '10.0.0'` | ASP.NET Core fehlt | `scripts/install-dotnet-runtime.sh "<prefix>" --aspnet` |
| `CryptographicException: Erfolg.` bei `CopyWithPrivateKey` | CNG ist in Protons Wine nicht implementiert | nativen Server nutzen |
| `System.ConsolePal.set_Title` / „Ungültiger Zugriff" | `SPT.Server.exe` aus einem Unix-Terminal gestartet | mit `wine start` starten, oder den nativen Server nutzen |
| Launcher öffnet sich nicht und das Log meldet einen Server-Timeout | Der lokale Server hat innerhalb von zwei Minuten nicht geantwortet | `~/.local/share/spt-server.log` ansehen und `scripts/spp-tarkov-server.sh "<Spielordner>" --status` ausführen |
| `Could not find file '...database\itemsToAdd.json'` | ein Mod baut einen Pfad mit Backslash | `ln -s database/itemsToAdd.json 'database\itemsToAdd.json'` |
| `Nicht behebbarer Systemfehler` / `MS.Internal.Invariant.FailFast` | keine nutzbare Schriftfamilie im Prefix | `WINEPREFIX="<prefix>" winetricks -q corefonts` |
| `Failed to create CoreCLR` | W^X unter Wine | mit `DOTNET_EnableWriteXorExecute=0` starten |
| Installer startet, aber Play bietet ihn weiter an | Schritt 3 nicht angewandt, oder Spiel außerhalb des verwalteten Ordners | Schritt 3 erneut ausführen |
| Launcher öffnet, **START GAME** tut nichts | Server offline oder `GamePath` falsch | Serverstatus und `LauncherSettings.json` prüfen |
| AnkerGames: `game_stop_not_found` | Spiel vom SPT-Launcher gestartet | [selbst beenden](#4--beenden) |
| Zweites **START GAME** hängt, kein Spielfenster | zwei Starts gleichzeitig, oder ein zweiter Launcher hält den Prefix | alle Launcher und Spielfenster schließen, einmal starten |

Logs:

```
~/.local/share/net.ankergames.launcher/logs/games/prefix-3089.log   Wrapper
~/.local/share/spt-server.log                                      nativer Server
<Spielordner>/Logs/                                                Spiel-Client
```

---

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
