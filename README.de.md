<div align="center">

# Anker Launcher unter Linux

**Online-Fix-Builds erreichen Steam nicht. Zwei Fixes im Launcher lösen das.**

[English](README.md) · [Ursachen](docs/de/ursachen.md) · [Spiele](docs/de/spiele.md) · [Evidenz](docs/de/evidenz.md)

![Plattform](https://img.shields.io/badge/plattform-Linux-0f172a?style=flat-square)
![Laufzeit](https://img.shields.io/badge/laufzeit-umu%20%2B%20Proton-0f172a?style=flat-square)
![Spiele geprüft](https://img.shields.io/badge/spiele%20gepr%C3%BCft-5-067647?style=flat-square)
![Spieldateien verändert](https://img.shields.io/badge/spieldateien%20ver%C3%A4ndert-keine-b42318?style=flat-square)

</div>

![Startkette vor und nach dem Fix](assets/before-after.svg)

---

## Kurzfassung

Die Online-Fix-Builds von AnkerGames ersetzen Steam nicht, sondern nutzen den
echten Steam-Client weiter: Eine Proxy-DLL im Spiel lädt `steamclient64.dll`
aus dem Wine-Prefix und verbindet sie mit dem Steam-Client auf dem Host.
Deshalb funktioniert Koop mit Windows-Spielern — das Spiel spricht mit echtem
Steam und meldet sich nur als **AppID 480 (Spacewar)** an.

Unter Linux bricht diese Kette an zwei Stellen. Beide liegen im Launcher, nicht
im Spiel:

| # | Fehler im Launcher | Was der Spieler sieht |
|---|---|---|
| **A** | Der Scan nach den Online-Fix-Markern stoppt zu früh. Bei UE4/UE5-Builds liegt der Marker 7–8 Ordner tief, deshalb werden die fünf Steam-Client-Dateien nie in den Prefix kopiert | `Failed to load original steamclient. Error code: 126` — das Spiel beendet sich vor dem Menü |
| **B** | `WINEDLLOVERRIDES=winmm=n,b` wird nie gesetzt. Wine ignoriert damit die mitgelieferte native `winmm.dll` und lädt seine eingebaute Variante | Spiel startet, aber `SteamAPI failed to initialize` / `[AppId: 0] Client API initialized 0` — keine Freunde, keine Lobbys |

Fix A kopiert fünf Dateien. Fix B hängt eine Umgebungsvariable an. Mehr ist es
nicht — rund 20 Zeilen in der Startkette.

---

## Ergebnisse

Beide Fixes manuell angewendet, fünf Spiele, gleiche Builds, gleiche Prefixes:

| ID | Spiel | Fix-Layout | Echte AppID | Steam initialisiert | Steam trackt |
|----|-------|-----------|-------------|---------------------|--------------|
| 2006 | SCP 5K | `steam_api64.dll` | 872670 | ✅ `[AppId: 872670] Client API initialized 1` | AppID 480 |
| 3645 | HYPERCHARGE: Unboxed | `winmm.dll`-Proxy | 523660 | ✅ `[AppId: 523660] Client API initialized 1` | AppID 480 |
| 2902 | Abyssus | `winmm.dll`-Proxy | 1721110 | ✅ Fix-DLLs im Prozess geladen | AppID 480 |
| 4013 | The Ascent | `winmm.dll` + union-crax | 979690 | ✅ Fix-DLLs im Prozess geladen | AppID 480 |
| 4035 | Species: Unknown | `winmm.dll`-Proxy | 2747330 | ✅ Fix-DLLs im Prozess geladen | AppID 480 |

„Steam trackt AppID 480“ ist erwartet und richtig: Der Fix gibt sich als
Spacewar aus, damit Steam die Client-API ohne Spielbesitz erlaubt. Freunde sehen
dich als „Spacewar“ — unter Windows verhalten sich diese Builds genauso.

---

## Workaround jetzt (ohne Launcher-Update)

Der Launcher ruft `umu-run` auf. Ein Wrapper weiter vorne im `PATH` bereitet
den Prefix vor jedem Start vor:

```sh
mkdir -p ~/.local/bin
cp scripts/fix-reference.sh ~/.local/bin/umu-run
chmod +x ~/.local/bin/umu-run
```

`~/.local/bin` muss in `PATH` vor `/usr/bin` stehen. Das Skript endet mit
`exec /usr/bin/umu-run "$@"` — den Pfad anpassen, falls `umu-run` woanders
liegt.

Danach das Spiel wie gewohnt aus dem Launcher starten. Im Spielordner wird
nichts verändert, der Launcher funktioniert normal weiter.

> Der Wrapper muss weiterhin tun, was dein Setup schon gebraucht hat (z. B. das
> Aufräumen der AppImage-Umgebung). Diese Zeilen oben ergänzen; die beiden
> Fix-Funktionen sind unabhängig davon.

---

## Für die Launcher-Entwickler

Drei Änderungen, nach Vorliebe sortiert:

1. **Das Katalog-Flag nutzen.** Jedes betroffene Spiel ist bereits
   `online_fix: true`. Setz die fünf Dateien, wenn das Flag gesetzt ist — kein
   Raten im Dateisystem nötig. Falls der Scan bleibt: den ganzen Spielordner
   durchlaufen (Tiefe 8 deckt alle bisher gesehenen UE4/UE5-Layouts ab) und
   `union-crax.ini` in die Markerliste aufnehmen.
2. **Bei jedem Start erneut prüfen.** Proton kopiert diese Dateien nur, wenn es
   einen Prefix erstellt oder aktualisiert. Nach dem ersten Start, einem
   Launcher-Update oder einer Neuinstallation ist der Ordner wieder leer.
3. **Den DLL-Override setzen.** Liegt eine native `winmm.dll` unter dem
   Spielordner, `winmm=n,b` an `WINEDLLOVERRIDES` anhängen — anhängen, nie
   überschreiben, denn die Variable ist eine semikolongetrennte Liste und
   enthält evtl. schon eigene Overrides des Launchers.

Der genaue Code steht in [`scripts/fix-reference.sh`](scripts/fix-reference.sh)
(~60 kommentierte Zeilen, `sh`, keine Abhängigkeiten).

---

## Verwandt: SPP Tarkov braucht die .NET Desktop Runtime

Ein anderes Problem mit demselben Muster — eine fehlende Voraussetzung im
Prefix, kein Steam-Fehler. `SPP_Tarkov_Installer.exe` (Spiel 3089) ist eine
framework-abhängige WPF-App für .NET 10, und im Prefix fehlt
`Microsoft.WindowsDesktop.App`. Der App-Host bricht ab mit *„You must install
.NET Desktop Runtime to run this application“*.

Ein Befehl behebt das, ohne einen Windows-Installer auszuführen:

```sh
scripts/install-dotnet-runtime.sh "<prefix>"
```

Das Skript entpackt die offiziellen win-x64-Runtime-Zips nach
`<prefix>/drive_c/Program Files/dotnet` — den Standardpfad, den der .NET-App-Host
durchsucht. Details, Screenshots und Fehlersuche:
[docs/de/dotnet-installer.md](docs/de/dotnet-installer.md).

---

## Aufbau des Repos

```
README.md                  diese Übersicht auf Englisch (Standard)
README.de.md               dieselbe Übersicht auf Deutsch
docs/en/root-cause.md      technische Analyse: Hintergrund, beide Defekte, Evidenz
docs/en/per-game.md        Spiel-Matrix, Marker-Tiefen, nicht betroffene Titel
docs/en/evidence.md        kommentierte Log-Auszüge und der Evidenz-Screenshot
docs/en/dotnet-installer.md  SPP Tarkov: fehlende .NET Desktop Runtime im Prefix
docs/de/…                  deutsche Fassung der vier Dokumente
evidence/                  rohe Log-Auszüge (01–07), auf die die Docs verweisen
scripts/fix-reference.sh   Referenz-Implementierung beider Fixes
scripts/install-dotnet-runtime.sh  installiert .NET Desktop Runtime 10 in einen Prefix
assets/before-after.svg    das Diagramm oben
assets/evidence.png        Evidenzblatt (Logs, vorher/nachher)
assets/spp-tarkov-*.png    Installer-Dialog und Setup-Assistent (vorher/nachher)
```

---

## Bekannte Einschränkung

Steam injiziert sein Overlay nur in Spiele, die **Steam selbst** startet. Ein
Spiel, das der Launcher startet, wird als AppID 480 getrackt, bekommt aber
keinen `gameoverlayui`-Prozess — Shift+Tab tut nichts, Overlay-Einladungen
fehlen. Die Steam-API selbst funktioniert: Freundesliste, Lobbys, Serverbrowser
und Beitritte über die Spiel-UI.

Wenn Overlay-Einladungen gebraucht werden, ist die saubere Lösung eine
optionale **„Zu Steam hinzufügen“**-Aktion: einen Non-Steam-Shortcut anlegen und
Steam das Spiel starten lassen. Die Shortcut-Logik existiert im Launcher bereits
(`steam_shortcut_add`). Dieser Weg braucht dieselben fünf Dateien im
compatdata-Prefix von Steam.

---

## Umfang

* Nur Linux-Laufzeit: umu-launcher + Proton. Getestet mit Anker Launcher
  0.1.33, umu-launcher 1.4.3, Proton Experimental (Prefix `11.0-100`), nativem
  Steam, CachyOS / KDE Wayland / NVIDIA.
* Es werden keine Spieldateien verändert und kein DRM umgangen. Die Fixes
  bereiten nur den Wine-Prefix vor und setzen einen Wine-DLL-Override — genau
  das, was Progons eigenes `proton`-Skript beim Anlegen eines Prefixes tut.
* Der Bericht beschreibt beobachtetes Verhalten und einen reproduzierbaren
  Fix. Er ist keine offizielle Aussage von AnkerGames.

---

<div align="center">

MIT-Lizenz · geschrieben von [benjarogit](https://github.com/benjarogit) · November 2026

</div>
