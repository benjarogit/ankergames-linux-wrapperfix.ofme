# Ursachen — warum Online-Fix-Builds unter Linux scheitern

[← Übersicht](../../README.de.md) · [Ursachen](ursachen.md) · [Spiele](spiele.md) · [Evidenz](evidenz.md) · [Tarkov-Fix](dotnet-installer.md) · [Co-op](coop.md) · **English:** [Root cause](../en/root-cause.md)

**Getestet mit:** Anker Launcher 0.1.33 (`AnkerLauncher-0.1.30-x86_64.AppImage`)
**Laufzeit:** umu-launcher 1.4.3, Proton Experimental (Prefix `11.0-100`), natives Steam
**System:** CachyOS, KDE Plasma 6.8 / Wayland, NVIDIA RTX 2060

---

## Inhalt

1. [So funktionieren diese Builds](#1-so-funktionieren-diese-builds)
2. [Defekt A — Steam-Client-Dateien werden nicht kopiert](#2-defekt-a--steam-client-dateien-werden-nicht-kopiert)
3. [Defekt B — der native `winmm.dll`-Proxy wird ignoriert](#3-defekt-b--der-native-winmmdll-proxy-wird-ignoriert)
4. [Referenz-Implementierung](#4-referenz-implementierung)
5. [Verifikation](#5-verifikation)
6. [Bekannte Einschränkung — Overlay und Einladungen](#6-bekannte-einschränkung--overlay-und-einladungen)
7. [Metadaten — das „Co-Op“-Badge](#7-metadaten--das-co-op-badge)

---

## 1. So funktionieren diese Builds

Online-Fix-Builds ersetzen Steam **nicht**. Die Fix-DLL (`OnlineFix64.dll` oder
ein `winmm.dll`- / `steam_api64.dll`-Proxy) lädt **Valves echte
`steamclient64.dll`** aus dem Wine-Prefix und verbindet sie mit dem Steam-Client
auf dem Host:

```
<prefix>/drive_c/Program Files (x86)/Steam/
├── steamclient.dll            (aus <Steam>/legacycompat/)
├── steamclient64.dll          (aus <Steam>/legacycompat/)
├── GameOverlayRenderer64.dll  (aus <Steam>/)
├── Steam.dll                  (aus <Steam>/legacycompat/)
└── steam.exe                  (aus <Steam>/legacycompat/SteamService.exe)
```

Der Pfad kommt aus der Registry des Prefix:

```
[Software\\Valve\\Steam\\ActiveProcess]
"SteamClientDll64"="C:\\Program Files (x86)\\Steam\\steamclient64.dll"
"SteamPath"="C:\\Program Files (x86)\\Steam"
```

Fehlen die Dateien, scheitert `LoadLibrary` mit **Fehler 126**
(`ERROR_MOD_NOT_FOUND`) — genau der Fehler, den Spieler sehen.

Proton kopiert diese Dateien selbst, wenn es einen Prefix anlegt
(`steam_in_pfx_dir` im `proton`-Skript) — aber **nur beim Erstellen oder
Aktualisieren**. Anker legt Prefixes über umu an, danach ist der Kopierschritt
des Launchers der einzige verlässliche Weg.

Im Katalog gibt es drei Proxy-Layouts:

| Layout | Loader | Beispiel |
|--------|--------|----------|
| **A** | `steam_api64.dll` ersetzt, Original als `steam_api64.of` | SCP 5K |
| **B** | native `winmm.dll` neben der Exe, lädt `OnlineFix64.dll` | HYPERCHARGE, Abyssus, Species: Unknown |
| **C** | native `winmm.dll` + `union-crax.ini` + `steam_emu.ini` (union-crax, lädt ebenfalls `steamclient64.dll`) | The Ascent |

Layout **A** funktioniert unter Wine unverändert. Layouts **B** und **C** nicht,
denn Wines Standardreihenfolge für `winmm` ist *builtin zuerst*: Der
mitgelieferte Proxy wird nie geladen, stattdessen läuft die originale
`steam_api64.dll`, und `SteamAPI_Init` scheitert mit AppId 0.

---

## 2. Defekt A — Steam-Client-Dateien werden nicht kopiert

### Symptom

```
Failed to load original steamclient. Error code: 126
```

Das Spiel beendet sich vor dem Hauptmenü.

### Evidenz

`~/.local/share/net.ankergames.launcher/logs/anker.2026-11-25.log`:

```
16:24:59  INFO Steam's client files were placed in the game's prefix files=5   ← HYPERCHARGE (3645)
```

Beim Start von **SCP 5K (2006)** um 16:28–16:29 (UTC) fehlt diese Zeile, und der
Prefix blieb leer:

```
Prefixes/2006/drive_c/Program Files (x86)/Steam/   → nur appcache/, config/, steamapps/
Prefixes/3645/drive_c/Program Files (x86)/Steam/   → steamclient64.dll, steamclient.dll,
                                                     GameOverlayRenderer64.dll, Steam.dll, steam.exe
```

Die Registry im 2006-Prefix zeigte bereits auf die fehlenden DLLs — die Fix-DLL
sollte also eine Datei laden, die es nicht gab → Fehler 126.

### Ursache

Der Launcher erkennt Online-Fix-Builds über einen Scan nach Marker-Dateien. Die
Markerliste aus dem Launcher-Binary:

```
steam_appid.txt  steam_settings  steam_emu.ini  ColdClientLoader.ini
cream_api.ini    OnlineFix.ini   realappid      SmartSteamEmu.ini
SteamConfig.ini  CPY.ini
```

`union-crax.ini` fehlt in dieser Liste, und der Scan erreicht keine Marker, die
tief unter der Spielwurzel liegen. Die plausibelste Erklärung ist ein
Tiefenlimit im Verzeichnislauf — es passt zu allen Beobachtungen (Tiefe 4 wird
gefunden, Tiefe 7–8 nicht). AnkerGames kann das im Scanner-Code bestätigen.

Marker-Tiefe unter der Spielwurzel:

| Spiel | Marker | Tiefe | Ergebnis im Launcher |
|-------|--------|-------|----------------------|
| HYPERCHARGE (3645) | `HYPERCHARGE Unboxed/Unboxed/Binaries/Win64/OnlineFix.ini` | 4 | ✅ Dateien kopiert |
| Abyssus (2902) | `Abyssus/RGame/Binaries/Win64/OnlineFix.ini` | 4 | ✅ (würde gefunden) |
| Species: Unknown (4035) | `Species Unknown/SpeciesUnknown/Binaries/Win64/OnlineFix.ini` | 4 | ✅ (würde gefunden) |
| The Ascent (4013) | `The Ascent/Engine/Binaries/ThirdParty/Steamworks/Steamv152/Win64/steam_emu.ini` | 7 | ❌ verpasst |
| SCP 5K (2006) | `5K/WindowsNoEditor/Engine/Binaries/ThirdParty/Steamworks/Steamv151/Win64/OnlineFix.ini` | 8 | ❌ nicht gefunden |

UE4/UE5-Builds legen die Steamworks-DLLs unter
`Engine/Binaries/ThirdParty/Steamworks/<version>/Win64/` ab — jeder UE-Build mit
Fix an dieser Stelle liegt also 7–8 Ebenen tief. Der Katalog weiß es besser:
Alle diese Spiele sind `online_fix: true`.

### Lösungsvorschlag

* **Bevorzugt:** das Katalog-Flag nutzen — bei `online_fix` die fünf Dateien
  kopieren. Kein Raten im Dateisystem.
* **Minimum:** die ganze Spielwurzel scannen (oder mindestens Tiefe 8) und
  `union-crax.ini` in die Markerliste aufnehmen.
* **Immer:** bei **jedem** Start prüfen. Die Dateien gehen verloren, wenn der
  Prefix neu erstellt, das Spiel neu installiert oder ein anderer Prefix
  gewählt wird.

---

## 3. Defekt B — der native `winmm.dll`-Proxy wird ignoriert

### Symptom

Das Spiel startet, aber Steam wird nicht initialisiert:

```
LogSteamShared: Warning: SteamAPI failed to initialize, conditions not met.
LogOnline: Warning: STEAM: Steamworks: SteamUser() failed!
LogOnline: STEAM: [AppId: 0] Client API initialized 0
```

### Evidenz

HYPERCHARGE (3645), die fünf Steam-Dateien lagen bereits im Prefix:

* **vorher** (`Unboxed/Saved/Logs/Unboxed.log`, 17:28 lokal):
  `SteamAPI failed to initialize, conditions not met` →
  `[AppId: 0] Client API initialized 0`
* **nachher** mit `WINEDLLOVERRIDES=winmm=n,b` (17:59):
  `LogSteamShared: Steam SDK Loaded!` →
  `LogOnline: STEAM: Steam User is subscribed 1` →
  `[AppId: 523660] Client API initialized 1`

Steam hat den Prozess getrackt:

```
AppID 480 adding PID 230454 as a tracked process
```

### Ursache

Der Build liefert eine native `winmm.dll` neben der startenden Exe
(`Unboxed/Binaries/Win64/winmm.dll`, `RGame/Binaries/Win64/winmm.dll`,
`TheAscent/Binaries/Win64/winmm.dll`). Unter Windows gewinnt das
Anwendungsverzeichnis die DLL-Suchreihenfolge, der Proxy lädt also. Unter Wine
ist die Voreinstellung für `winmm` `builtin, native` — der Proxy wird
übersprungen.

Der Launcher setzt überhaupt keine `WINEDLLOVERRIDES`; das Binary enthält den
String nicht. Diese Builds können unter Linux also nicht funktionieren, so wie
sie ausgeliefert werden.

### Lösungsvorschlag

Liegt irgendwo unter dem Spielordner eine native `winmm.dll` (Tiefe ≤ 4 reicht
in der Praxis), den Override anhängen:

```sh
export WINEDLLOVERRIDES="${WINEDLLOVERRIDES:+$WINEDLLOVERRIDES;}winmm=n,b"
```

Bestehende Overrides behalten (z. B. `ddraw` für alte Titel) — die Variable ist
eine semikolongetrennte Liste.

---

## 4. Referenz-Implementierung

Minimalversion beider Fixes für einen umu/Proton-Launcher — genau der Code, mit
dem oben verifiziert wurde. Voll kommentiert:
[`scripts/fix-reference.sh`](../../scripts/fix-reference.sh).

```sh
# 1) Steam-Client-Dateien für jeden Online-Fix-Build (beliebige Marker-Tiefe)
place_steam_client() {
  [ -n "$WINEPREFIX" ] || return 0
  steam_dir="$WINEPREFIX/drive_c/Program Files (x86)/Steam"
  [ -f "$steam_dir/steamclient64.dll" ] && return 0

  find "$(dirname "$1")" -maxdepth 8 \
       \( -iname 'OnlineFix.ini' -o -iname 'union-crax.ini' -o -iname 'steam_emu.ini' \) \
       -print -quit 2>/dev/null | grep -q . || return 0

  src="$HOME/.local/share/Steam"
  [ -f "$src/steamclient64.dll" ] || return 0

  mkdir -p "$steam_dir"
  cp -L "$src/steamclient64.dll"             "$steam_dir/steamclient64.dll"
  cp -L "$src/steamclient.dll"               "$steam_dir/steamclient.dll"
  cp -L "$src/GameOverlayRenderer64.dll"     "$steam_dir/GameOverlayRenderer64.dll"
  cp -L "$src/legacycompat/Steam.dll"        "$steam_dir/Steam.dll"
  cp -L "$src/legacycompat/SteamService.exe" "$steam_dir/steam.exe"
}

# 2) Mitgelieferte native winmm.dll bevorzugen (OnlineFix / union-crax / RUNE)
case "$1" in
  *.exe)
    if find "$(dirname "$1")" -maxdepth 4 -iname 'winmm.dll' -print -quit 2>/dev/null | grep -q .; then
      export WINEDLLOVERRIDES="${WINEDLLOVERRIDES:+$WINEDLLOVERRIDES;}winmm=n,b"
    fi
    ;;
esac
```

Hinweise für die Launcher-Implementierung:

* Erst kopieren, **nachdem** der Prefix existiert — oder den Verzeichnisbaum
  selbst anlegen (wie oben); Wine/Proton lässt vorhandene Dateien stehen.
* `steam.exe` ist die umbenannte `SteamService.exe`; genau das macht Proton.
* `cp -L` verwenden: Die Steam-Dateien können in manchen Installationen
  Symlinks sein (z. B. Flatpak).
* Die fünf Dateien aktualisieren, wenn sich der Steam-Client aktualisiert —
  Vergleich von Größe/mtime genügt.
* Die `find`-Aufrufe sind pro Start günstig, ein Katalog-Flag spart sie ganz.

---

## 5. Verifikation

SCP 5K (`Pandemic.log`), nachdem die Dateien im Prefix lagen:

```
LogSteamShared: Display: Loading Steam SDK 1.51
LogSteamShared: Steam SDK Loaded!
LogOnline: OSS: Creating online subsystem instance for: Steam
LogOnline: STEAM: Steam User is subscribed 1
LogOnline: STEAM: [AppId: 872670] Client API initialized 1
LogOnline: STEAM: AUTH: Steam Auth Enabled
```

HYPERCHARGE, vor/nach dem `winmm`-Override:

```
- LogSteamShared: Warning: SteamAPI failed to initialize, conditions not met.
- LogOnline: STEAM: [AppId: 0] Client API initialized 0
+ LogSteamShared: Steam SDK Loaded!
+ LogOnline: STEAM: Steam User is subscribed 1
+ LogOnline: STEAM: [AppId: 523660] Client API initialized 1
```

Steam-Client (`~/.local/share/Steam/logs/gameprocess_log.txt`):

```
[2026-11-25 18:01:17] AppID 480 adding PID 231790 as a tracked process
[2026-11-25 18:01:17] AppID 480 PID 231790 was launched outside Steam, ...
```

Rohauszüge und das Evidenzblatt: [`evidenz.md`](evidenz.md).

---

## 6. Bekannte Einschränkung — Overlay und Einladungen

Steam injiziert sein Overlay (Shift+Tab, Einladungsdialog) nur in Spiele, die es
selbst startet. Ein vom Launcher gestartetes Spiel wird als AppID 480 getrackt,
bekommt aber keinen `gameoverlayui`-Prozess — Shift+Tab tut nichts. Die
Steam-API funktioniert (Freundesliste, Lobbys, Serverlisten), Freunde können
über die Spiel-UI beitreten, aber Overlay-Einladungen fehlen.

Wenn Overlay-Einladungen gebraucht werden, kann der Launcher eine optionale
**„Zu Steam hinzufügen“**-Aktion anbieten: ein Non-Steam-Shortcut, der das Spiel
über Steam startet (die Interna `steam_shortcut_add` / `game_shortcut_create`
existieren bereits). Dieser Weg braucht die Steam-Client-Dateien zusätzlich im
compatdata-Prefix von Steam, weil Steam dort einen eigenen Prefix nutzt.

---

## 7. Metadaten — das „Co-Op“-Badge

`co_op: true` ist derzeit ein Genre-Tag. Bei reinen Offline-Builds (zum Beispiel
Call of Duty: Modern Warfare II, 2522 — Goldberg-Build, nur `sp22`-Kampagne,
kein `mp22`-Ordner) liest es sich wie „Koop funktioniert hier“.

Vorschlag: das Badge an `online_fix` / `multiplayer` koppeln oder einen
expliziten „offline only“-Hinweis ergänzen. Die übrigen Katalog-Metadaten sind
für diese Titel korrekt.
