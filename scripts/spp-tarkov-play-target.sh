#!/bin/sh
# ---------------------------------------------------------------------------
# spp-tarkov-play-target.sh — make "Play" in AnkerGames start the game
#
# Why: the catalog entry for SPP Tarkov (3089) is an installer package. The
# launcher starts SPP_Tarkov_Installer.exe on every Play — the file
# "Run SPP_Tarkov_Installer and follow the instructions.txt" names it — and
# that wizard unpacks Data.bin (64.7 GB) again each time. Nothing in the
# package tells the launcher what to start after the install.
#
# What: puts the SPT launcher inside the game folder the launcher watches:
#   <game dir>/Launcher.exe      the stub from the installed game (starts
#                                SPT_Runtime\SPT.Launcher.exe)
#   <game dir>/SPT_Runtime       symlink to the installed SPT_Runtime
# and records Launcher.exe as this game's executable in library.json.
# Close AnkerGames before running this; it rewrites library.json on start.
#
# Usage:
#   ./spp-tarkov-play-target.sh <game dir> <prefix> [--game-id 3089]
#                               [--library-json <path>] [--dry-run]
#
#   <game dir>   e.g. "/mnt/daten/Games/AnkerGames/Games/Escape from Tarkov-3089"
#   <prefix>     e.g. "/mnt/daten/Games/AnkerGames/Games/Prefixes/3089"
# ---------------------------------------------------------------------------
set -eu

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
usage() { sed -n '2,27p' "$0"; }

game=
prefix=
game_id=3089
library_json="${XDG_CONFIG_HOME:-$HOME/.config}/net.ankergames.launcher/library.json"
dry=0

while [ $# -gt 0 ]; do
  case "$1" in
    --game-id) [ $# -ge 2 ] || die "--game-id needs a value"; game_id=$2; shift 2 ;;
    --library-json) [ $# -ge 2 ] || die "--library-json needs a path"; library_json=$2; shift 2 ;;
    --dry-run) dry=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) die "unknown option: $1" ;;
    *)
      if [ -z "$game" ]; then game=$1
      elif [ -z "$prefix" ]; then prefix=$1
      else die "unexpected argument: $1"
      fi
      shift
      ;;
  esac
done

[ -n "$game" ] && [ -n "$prefix" ] || { usage; exit 1; }
[ -d "$game" ] || die "no such game folder: $game"
[ -d "$prefix/drive_c" ] || die "not a Wine prefix: $prefix"

installed="$prefix/drive_c/Games/SPP-Tarkov"
[ -f "$installed/Launcher.exe" ] || die "no Launcher.exe in $installed — run the SPP installer first"
[ -d "$installed/SPT_Runtime" ] || die "no SPT_Runtime in $installed — run the SPP installer first"

if pgrep -x anker-launcher >/dev/null 2>&1 || pgrep -f 'AnkerLauncher.*AppImage' >/dev/null 2>&1; then
  die "AnkerGames is running — quit it first, it rewrites library.json"
fi

run() {
  if [ "$dry" = 1 ]; then
    printf 'would: %s\n' "$*"
  else
    "$@"
  fi
}

# 1 · the stub, next to the package files
if cmp -s "$installed/Launcher.exe" "$game/Launcher.exe"; then
  echo "ok: $game/Launcher.exe"
else
  run cp -f "$installed/Launcher.exe" "$game/Launcher.exe"
  echo "placed: $game/Launcher.exe"
fi

# 2 · SPT_Runtime as a link, so the stub finds the real files
link="$game/SPT_Runtime"
if [ -L "$link" ]; then
  current=$(readlink -f "$link" || true)
  if [ "$current" = "$(readlink -f "$installed/SPT_Runtime")" ]; then
    echo "ok: $link -> $current"
  else
    run ln -sfn "$installed/SPT_Runtime" "$link"
    echo "relinked: $link -> $installed/SPT_Runtime"
  fi
elif [ -e "$link" ]; then
  echo "note: $link is a real directory, left alone"
else
  run ln -sfn "$installed/SPT_Runtime" "$link"
  echo "linked: $link -> $installed/SPT_Runtime"
fi

# 3 · tell the launcher what to start
[ -f "$library_json" ] || die "no library.json at $library_json"
command -v python3 >/dev/null 2>&1 || die "python3 is required to edit library.json"

if [ "$dry" = 1 ]; then
  echo "would: set games.$game_id.executable = Launcher.exe in $library_json"
else
  python3 - "$library_json" "$game_id" <<'PY'
import json, os, shutil, sys, time

path, game_id = sys.argv[1], sys.argv[2]
data = json.load(open(path, encoding="utf-8"))
game = data.get("games", {}).get(game_id)
if game is None:
    sys.exit(f"game {game_id} is not in the library")

if game.get("executable") == "Launcher.exe":
    print(f"ok: game {game_id} already starts Launcher.exe")
    sys.exit(0)

shutil.copy2(path, f"{path}.bak-{time.strftime('%Y%m%d-%H%M%S')}")
game["executable"] = "Launcher.exe"
tmp = f"{path}.tmp"
with open(tmp, "w", encoding="utf-8") as fh:
    json.dump(data, fh, ensure_ascii=False, separators=(",", ":"))
os.chmod(tmp, 0o600)
os.replace(tmp, path)
print(f"set: game {game_id} starts Launcher.exe")
PY
fi

echo
echo "done. start AnkerGames and press Play — it should open the SPT launcher."
