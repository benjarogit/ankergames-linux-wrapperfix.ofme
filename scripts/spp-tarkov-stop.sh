#!/bin/sh
# ---------------------------------------------------------------------------
# spp-tarkov-stop.sh — stop SPP Tarkov (game, launcher, optionally the server)
#
# Why: AnkerGames cannot stop the game. The game is started by the SPT
# launcher, not by AnkerGames, so its stop button reports
#   game_stop_not_found — No running game process was found in this installation.
#
# Usage:
#   ./spp-tarkov-stop.sh <prefix> [--server]
#
#   <prefix>   e.g. "/mnt/daten/Games/AnkerGames/Games/Prefixes/3089"
#   --server   also stop the native SPT server
# ---------------------------------------------------------------------------
set -eu

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
usage() { sed -n '2,14p' "$0"; }

prefix=
stop_server=0
for arg in "$@"; do
  case "$arg" in
    --server) stop_server=1 ;;
    -h|--help) usage; exit 0 ;;
    -*) die "unknown option: $arg" ;;
    *)
      [ -z "$prefix" ] || die "unexpected argument: $arg"
      prefix=$arg
      ;;
  esac
done

[ -n "$prefix" ] || { usage; exit 1; }
[ -d "$prefix/drive_c" ] || die "not a Wine prefix: $prefix"
prefix=$(realpath -e -- "$prefix")
runtime=$(realpath -e -- "$prefix/drive_c/Games/SPP-Tarkov/SPT_Runtime") \
  || die "SPT_Runtime not found in $prefix"

# 1 · Wine session of this prefix: the game and any Windows launcher
ws=
for candidate in \
  "$HOME/.local/share/Steam/steamapps/common/Proton - Experimental/files/bin/wineserver" \
  "$HOME"/.local/share/Steam/compatibilitytools.d/*/files/bin/wineserver
do
  [ -x "$candidate" ] && { ws=$candidate; break; }
done
if [ -n "$ws" ]; then
  if WINEPREFIX="$prefix" "$ws" -k 2>/dev/null; then
    echo "stopped: Wine session of $prefix"
  else
    echo "note: no Wine session stopped for $prefix"
  fi
else
  echo "note: no Proton wineserver found; skipping the Wine session"
fi

# 2 · umu-run wrappers that were started for this prefix
for pid in $(pgrep -f 'umu-run.*EscapeFromTarkov[.]exe' 2>/dev/null || true); do
  if tr '\0' '\n' 2>/dev/null < "/proc/$pid/environ" | grep -qx "WINEPREFIX=$prefix"; then
    if kill -TERM "$pid" 2>/dev/null; then
      echo "stopped: umu-run game wrapper (pid $pid)"
    fi
  fi
done

# 3 · Native processes belonging to this installation only.
stop_native() {
  executable=$1
  for pid in $(pgrep -f "$executable" 2>/dev/null || true); do
    [ "$(readlink "/proc/$pid/exe" 2>/dev/null)" = "$runtime/$executable" ] || continue
    if kill -TERM "$pid" 2>/dev/null; then
      echo "stopped: $executable (pid $pid)"
    fi
  done
}

stop_native SPT.Launcher.Linux
if [ "$stop_server" = 1 ]; then
  stop_native SPT.Server.Linux
fi
