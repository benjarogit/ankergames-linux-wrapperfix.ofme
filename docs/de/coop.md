# SPP Tarkov Co-op: Server-Ersteller und Mitspieler

[← Übersicht](../../README.de.md) · [Tarkov-Fix](dotnet-installer.md) · [Evidenz](evidenz.md) · **English:** [Co-op](../en/coop.md)

SPP Tarkov bringt **Fika** mit, den Co-op-Mod für SPT. Es muss nichts installiert
werden: Der Server-Mod liegt in `SPT_Runtime/user/mods/fika-server` (2.4.0), das
Client-Plugin in `BepInEx/plugins/Fika` (2.4.2). Es fehlt nur der Netzwerkweg
zwischen den beiden Rechnern.

Zwei Rollen, zwei Checklisten:

| Rolle | betreibt | tut |
|---|---|---|
| **Server-Ersteller** | den SPT-Server auf dem eigenen PC | öffnet die Ports, legt das eigene Profil an, hostet den Raid |
| **Mitspieler** | nur den Spiel-Client | verbindet sich mit dem Server, legt ein eigenes Profil an, joint den Raid |

Fika braucht **zwei Ports**:

| Port | Protokoll | Zweck |
|---|---|---|
| 6969 | TCP | SPT-Backend: Launcher-Login, Profile, Inventar, Fika-API |
| 25565 | UDP | Netzwerk im Raid zwischen den Spielern |

---

## Beide Seiten: derselbe Build

Client und Server müssen dieselben SPT- und Fika-Versionen sprechen. Am
einfachsten — und hier getestet — ist **dasselbe SPP-Tarkov-Paket auf beiden
PCs**:

```
SPT   4.1.2
Fika  2.4.0 (Server) / 2.4.2 (Client)
```

Eine normale SPT-Installation geht auch, braucht aber den passenden
Fika-Client und dieselbe SPT-Version. Gemischte 4.0-/4.1-Mods oder
unterschiedliche Fika-Versionen sind die häufigste Ursache, wenn keine
Verbindung zustande kommt.

Unter Linux braucht der Mitspieler denselben Launcher-Fix wie der Host (dieses
Repo: nativer `SPT.Launcher.Linux` über den Wrapper). Unter Windows reicht der
normale SPT-Launcher.

> Der Launcher meldet sich in SPT 4.1 mit dem **Profilnamen** an; ein
> Server-Passwort wird nicht geprüft. Wer den Server erreicht, kann ein Profil
> anlegen und sich als vorhandenes Profil anmelden. Die Adresse nur an Freunde
> weitergeben und den Server nie ohne VPN öffentlich erreichbar machen — Fika
> ist nicht für öffentliche Server gedacht.

---

## Teil A — der Server-Ersteller

### 1 · Server starten und Fika prüfen

Den SPT-Server wie gewohnt starten (Play in AnkerGames startet ihn, oder
`scripts/spp-tarkov-server.sh "<Spielordner>"`). Im Log muss stehen:

```
Mod: server Version: 2.4.0 (GUID: Fika | targets SPT: >=4.1.0) von: Fika geladen
[Fika Server] Overriding SPT configuration
```

Fika stellt die Listen-Adresse auf `0.0.0.0` um, der Server ist also ohne
Änderung an `http.json` aus dem Netz erreichbar:

```sh
ss -ltn | grep 6969        # 0.0.0.0:6969
```

### 2 · Weg zum Mitspieler wählen

| Situation | Adresse für den Mitspieler | nötig |
|---|---|---|
| gleiches LAN | `https://<LAN-IP>:6969` | nur die Firewall |
| Internet, Router-Zugriff | `https://<öffentliche-IP>:6969` | 6969/TCP und 25565/UDP auf diesen PC weiterleiten |
| CGNAT / kein Port-Forwarding | `https://<VPN-IP>:6969` | auf beiden PCs ein VPN wie ZeroTier oder Tailscale |

Die LAN-Adresse:

```sh
ip -4 route get 1.1.1.1 | awk '{print $7}'
```

Die öffentliche Adresse:

```sh
curl -4 -s https://ifconfig.me
```

Port-Forwarding im Router („Port Forwarding“ oder „Virtual Server“):
**6969 TCP** und **25565 UDP** → LAN-Adresse des Host-PCs. Die Schritt-für-
Schritt-Seiten im Fika-Wiki:
[Port-Forwarding](https://wiki.project-fika.com/hosting-a-fika-server/host-using-port-forwarding)
und [VPN](https://wiki.project-fika.com/hosting-a-fika-server/host-using-a-vpn).

Beim VPN die Adresse nehmen, die der VPN-Client für den Host anzeigt (Tailscale
`100.x`, ZeroTier `10.x`/`172.x`, Radmin `26.x`). Keine Router-Änderung, keine
öffentliche IP.

### 3 · Linux-Firewall öffnen

Hier läuft `ufw`:

```sh
sudo ufw allow 6969/tcp
sudo ufw allow 25565/udp
sudo ufw status
```

Mit `firewalld` stattdessen:

```sh
sudo firewall-cmd --add-port=6969/tcp --add-port=25565/udp
sudo firewall-cmd --runtime-to-permanent
```

### 4 · Von außen prüfen

Auf dem Host:

```sh
curl -k -o /dev/null -w '%{http_code}\n' https://<Adresse>:6969/launcher/v2/ping
```

`200` heißt: Der Server antwortet. Danach 6969/TCP aus dem Internet mit einem
Port-Checker prüfen, z. B. <https://portchecker.co>. Ist der Port zu, liegt es
an der Router-Regel, der Firewall oder am Provider — dann die VPN-Variante
nehmen.

### 5 · Raid hosten

Der Host-PC ist der mit dem offenen 25565/UDP, also hostet er auch den Raid:

1. Hauptmenü → **Escape from Tarkov** → PMC oder SCAV.
2. Karte und Uhrzeit wählen, durch Practice-Einstellungen und Versicherung
   mit **Next**.
3. In der Lobby **Host Raid** klicken, dann **Start**.
4. Der Raid wartet (`Waiting for host to start the raid`). Wenn der Mitspieler
   drin ist, **Start Raid** drücken.

Der Host braucht ein eigenes Profil im Launcher (bei einem frischen Server
eines anlegen); der Mitspieler legt ein separates an.

### 6 · Was der Mitspieler braucht

```
Server:   https://<Adresse>:6969
Build:    SPP Tarkov, SPT 4.1.2, Fika-Client 2.4.2
Login:    eigenes Profil anlegen, dann mit diesem Namen anmelden
```

Nutzt der Mitspieler nicht dasselbe Paket, zusätzlich die genaue Mod-Liste
schicken. Fika kann sie erzwingen, in
`user/mods/fika-server/assets/configs/fika.jsonc`:

```jsonc
"client": {
  "mods": {
    "required": [],   // GUIDs, die der Mitspieler haben muss
    "optional": []    // GUIDs, die er haben darf
  }
}
```

---

## Teil B — der Mitspieler

### 1 · Denselben Build verwenden

Dasselbe SPP-Tarkov-Paket installieren (oder SPT 4.1.2 + Fika-Client 2.4.2).
Keine Mods hinzufügen, die der Host nicht hat, und keine 4.0- mit
4.1-Mods mischen.

### 2 · Server des Hosts eintragen

Im SPT-Launcher (dem Fenster, das Play öffnet) → Server-Liste (erstes Symbol in
der Seitenleiste; unter Windows „Settings → Add New Server“) → **ADD**:

| Feld | Wert |
|---|---|
| Name | beliebig, z. B. `Benny` |
| Adresse | `<Adresse>:6969` — der Launcher ergänzt `https://`; ein eingefügtes `https://…` wird akzeptiert, aber ohne Schrägstrich am Ende |

Die Adresse ist die vom Host — LAN-IP, öffentliche IP oder VPN-IP, immer mit
`:6969`.

### 3 · Eigenes Profil anlegen

Der Server listet die vorhandenen Profile. **CREATE NEW PROFILE** klicken,
einen eigenen Namen wählen und sich mit **diesem Namen** anmelden. Nie in das
Profil des Hosts oder eines anderen Spielers einloggen — sonst teilt man sich
Charakter und Inventar.

### 4 · Spiel starten und Fika prüfen

**START GAME** drücken. Im Hauptmenü muss unten links `FIKA 2.4.2 | SPT 4.1.2`
stehen und rechts das **Online players**-Widget sichtbar sein. Fehlt der
Schriftzug, wurde der Fika-Client nicht geladen.

### 5 · Raid joinen

Hauptmenü → **Escape from Tarkov** → PMC oder SCAV → Karte und Uhrzeit →
**Next** durch Practice-Einstellungen und Versicherung → der Raid des Hosts
erscheint in der Lobby-Liste → **Join**. Der Raid startet, wenn der Host
**Start Raid** drückt.

---

## Fehlersuche

| Symptom | Ursache | Fix |
|---|---|---|
| Launcher meldet Server offline | 6969/TCP nicht erreichbar | Router-Regel, `ufw`, VPN prüfen; `https://<Adresse>:6969/launcher/v2/ping` von außen testen |
| Login geht, aber keine Profile sichtbar | falscher Server gewählt | den Eintrag des Hosts wählen, nicht `Local Server`; ist die Liste leer, ein Profil anlegen |
| `FIKA …` fehlt im Menü | Fika-Client nicht geladen | gleiches Paket/Version; `BepInEx/LogOutput.log` auf `Fika.Core` prüfen |
| Fika-Versionsfehler | Client und Server passen nicht zusammen | gleiches Paket, oder Client/Server-Versionen angleichen |
| Raid-Liste leer, obwohl der Host gestartet hat | Mitspieler nicht auf demselben Server, oder UDP blockiert | beide auf dem Host-Server; 25565/UDP beim **Raid-Host** öffnen |
| „Error opening ports“ beim Joinen | 25565/UDP des Raid-Hosts nicht erreichbar | den Server-Ersteller den Raid hosten lassen, oder 25565/UDP dort weiterleiten |
| Disconnects, Rubber-Banding | WLAN, VPN-Relay, schwacher Upload | Kabel; anderen VPN-Ausgang testen |
| Abstürze oder Desync mit Mods | inkompatible SPT-Mods | Mods auf beiden Seiten entfernen, dann paarweise wieder hinzufügen |

Mehr: [Fika-FAQ](https://wiki.project-fika.com/faqandguides) und der
[Fika-Discord](https://discord.gg/project-fika).

---

## Optional: NAT Punching

Wenn keiner der beiden 25565/UDP öffnen kann, kann Fika die Raid-Verbindung
über einen NAT-Punch-Server tunneln. In `fika.jsonc` aktivieren:

```jsonc
"natPunchServer": {
  "enable": true,
  "port": 6790
}
```

und den Client auf einen NAT-Punch-Server zeigen lassen. Der öffentliche und
die selbst gehostete Variante:
[NAT Punching](https://wiki.project-fika.com/advanced-features/nat-punching).
Port-Forwarding oder VPN bleibt der zuverlässigere Weg.

---

## Warum der Server schon erreichbar ist

Fika stellt die SPT-Listen-Adresse von `127.0.0.1` auf `0.0.0.0` um
(`fika.jsonc` → `server.SPT.http.ip`). Deshalb nimmt der native Linux-Server,
den der Wrapper startet, Verbindungen aus dem LAN an, ohne dass
`SPT_Data/configs/http.json` angefasst werden muss. Der eigene Launcher des
Hosts bleibt bei `https://127.0.0.1:6969`; nur der Mitspieler braucht die
Netzwerkadresse.
