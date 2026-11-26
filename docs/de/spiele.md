# Spiel-Matrix

[← Übersicht](../../README.de.md) · [Ursachen](ursachen.md) · [Evidenz](evidenz.md) · **English:** [Per game](../en/per-game.md)

Alle fünf Spiele wurden mit demselben Launcher-Build (0.1.33), derselben
Laufzeit (umu 1.4.3 + Proton Experimental `11.0-100`) und ihren vorhandenen
Prefixes getestet. Der einzige Unterschied zwischen den Läufen sind die beiden
Fixes im Launcher.

---

## Ergebnisse

| ID | Spiel | Fix-Layout | Echte AppID | Fake-AppID | Marker | Tiefe | Fix A nötig | Fix B nötig | Nachweis |
|----|-------|-----------|-------------|------------|--------|-------|-------------|-------------|----------|
| 2006 | SCP 5K | A — `steam_api64.dll` | 872670 | 480 | `OnlineFix.ini` | 8 | ✅ ja | — | UE-Log (`[AppId: 872670] Client API initialized 1`) |
| 3645 | HYPERCHARGE: Unboxed | B — `winmm.dll` | 523660 | 480 | `OnlineFix.ini` | 4 | bereits kopiert | ✅ ja | UE-Log (`[AppId: 523660] Client API initialized 1`) |
| 2902 | Abyssus | B — `winmm.dll` | 1721110 | 480 | `OnlineFix.ini` | 4 | bereits kopiert | ✅ ja | geladene Module + Steam-Prozessliste |
| 4013 | The Ascent | C — `winmm.dll` + union-crax | 979690 | 480 | `steam_emu.ini` | 7 | ✅ ja | ✅ ja | geladene Module + Steam-Prozessliste |
| 4035 | Species: Unknown | B — `winmm.dll` | 2747330 | 480 | `OnlineFix.ini` | 4 | bereits kopiert | ✅ ja | geladene Module + Steam-Prozessliste |

Legende:

* **Fix A** = die fünf Steam-Client-Dateien in den Prefix kopieren.
* **Fix B** = `WINEDLLOVERRIDES=winmm=n,b` setzen.
* **Tiefe** = Ordner zwischen Spielwurzel und Marker-Datei.
* „bereits kopiert“ heißt: Der Marker lag flach genug für den Scan des
  Launchers, es fehlte nur Fix B.

---

## Was die Layouts bedeuten

### Layout A — ersetzte `steam_api64.dll`

Der Build tauscht die `steam_api64.dll` des Spiels gegen die Fix-Version und
behält das Original als `steam_api64.of`. Die Ersatz-DLL findet den echten
Steam-Client über die Registry des Prefix, deshalb ist **nur Fix A nötig**.
SCP 5K ist der einzige Titel in diesem Set mit diesem Layout.

### Layout B — `winmm.dll`-Proxy

Der Build legt eine native `winmm.dll` neben die startende Exe. Diese DLL ist
der Loader: Sie zieht `OnlineFix64.dll` nach, die `SteamAPI_Init` hookt und sich
mit dem echten Steam-Client verbindet. Unter Windows gewinnt das
Anwendungsverzeichnis die DLL-Suchreihenfolge, unter Wine nicht — daher ist
**Fix B nötig**. HYPERCHARGE, Abyssus und Species: Unknown nutzen dieses Layout.

### Layout C — `winmm.dll` + union-crax

The Ascent liefert `winmm.dll` zusammen mit `union-crax.ini` und
`steam_emu.ini`. union-crax lädt ebenfalls `steamclient64.dll` aus dem Prefix,
dieses Layout braucht also **beide Fixes**: die Dateien (Marker auf Tiefe 7) und
den DLL-Override.

---

## Wie „Steam initialisiert“ geprüft wurde

* **UE4/UE5-Spiele mit Log** (SCP 5K, HYPERCHARGE): Das Spiel schreibt
  `LogSteamShared`- / `LogOnline`-Zeilen. `Client API initialized 1` mit der
  echten AppID ist der eindeutige Beweis.
* **Builds ohne brauchbares UE-Log** (Abyssus, The Ascent, Species: Unknown):
  Geprüft wurde der Prozess selbst — `OnlineFix64.dll`, `winmm.dll`,
  `steamclient64.dll` und `GameOverlayRenderer64.dll` im Spielprozess — plus
  `gameprocess_log.txt` von Steam, das das Spiel als getrackten Prozess unter
  AppID 480 führt.
* **Alle fünf**: `~/.local/share/Steam/logs/gameprocess_log.txt` zeigt
  `AppID 480 adding PID … as a tracked process`. Das passiert nur nach einem
  erfolgreichen Handshake mit dem Steam-Client.

AppID 480 ist Spacewar, Valves öffentliche Test-App. Der Fix gibt sie vor, damit
Steam die Client-API ohne Spielbesitz erlaubt. Das ist unter Windows identisch
und genau das, was Koop mit Windows-Spielern möglich macht.

---

## Titel, die betroffen aussehen, es aber nicht sind

### Escape from Tarkov (3089)

Kein Steam-Titel. Das Paket ist **SPP Tarkov** — ein Singleplayer-Projekt
(`SPP_Tarkov_Installer.exe` + `Data.bin`, „Complete SPP Tarkov client & local
server environment“). Es ist keine Steam-Client-API beteiligt, also greift
keiner der Fixes. Koop bräuchte einen separaten Community-Mod (z. B. Fika) und
einen gehosteten Server. Die Katalog-Metadaten (`multiplayer: false`,
`online_fix: false`) bilden das bereits ab.

### Call of Duty: Modern Warfare II (2522)

Ein Goldberg-/Offline-Build (`steam_settings/`, `steam_api64.dll`,
`steam_api64_GSE.dll`), der nur den `sp22`-Kampagnen-Client enthält — ein
`mp22`-Ordner fehlt. Die Katalog-Metadaten sind korrekt (`multiplayer: false`,
`online_fix: false`), aber `co_op: true` ist nur ein Genre-Tag von der
Store-Seite und unter Linux irreführend: Spec-Ops-Koop läuft auf
Activision-/Steam-Servern mit Account und Anti-Cheat, ein clientseitiger
Steam-Fix kann das nicht ermöglichen.

Vorschlag: das „Co-Op“-Badge an `online_fix` / `multiplayer` koppeln oder einen
expliziten „offline only“-Hinweis ergänzen. Siehe auch
[die Metadaten-Notiz](ursachen.md#7-metadaten--das-co-op-badge).

---

## Reproduktion

1. Prefix von Spiel 2006 löschen (`…/Prefixes/2006`).
2. Aus dem Launcher starten → `Failed to load original steamclient. Error code: 126`.
3. Die fünf Dateien in den Prefix kopieren → das Spiel startet, die Steam-API initialisiert.
4. Spiel 3645 starten (Dateien vorhanden) → Log zeigt `[AppId: 0] Client API initialized 0`.
5. 3645 mit `WINEDLLOVERRIDES=winmm=n,b` starten → `[AppId: 523660] Client API initialized 1`.
