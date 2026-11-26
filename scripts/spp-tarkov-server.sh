#!/bin/sh
# ---------------------------------------------------------------------------
# spp-tarkov-server.sh — run the native SPT server that ships with SPP Tarkov
#
# Why: the Windows server (SPT.Server.exe) cannot create its TLS certificate
# under Wine — CNG/CopyWithPrivateKey fails and the launcher keeps the
# "Local Server" card on OFFLINE. The package also ships a native Linux build,
# SPT_Runtime/SPT.Server.Linux, which serves the same HTTP API on
# https://127.0.0.1:6969. The Windows launcher talks to it unchanged.
#
# What: starts that server in its own session (it survives the launcher),
# writes a log, and waits until /launcher/v2/ping answers.
#
# Usage:
#   ./spp-tarkov-server.sh <game-dir> [--wait <seconds>] [--status] [--stop]
#
#   <game-dir>  folder that contains SPT_Runtime (the SPT_Runtime itself works)
#   --wait N    seconds to wait for the server (default 120)
#   --status    print whether the server answers, start nothing
#   --stop      stop a server started this way
#
# Needs the .NET 10 Linux runtime (Core + ASP.NET Core). Default location:
#   ~/.local/share/spt-dotnet      override with SPT_DOTNET_ROOT
# ---------------------------------------------------------------------------
set -eu

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
usage() { sed -n '2,22p' "$0"; }

ping_url=https://127.0.0.1:6969/launcher/v2/ping
log="${XDG_STATE_HOME:-$HOME/.local/share}/spt-server.log"

alive() { curl -sk --max-time 2 -o /dev/null "$ping_url" 2>/dev/null; }

game=
wait_s=120
mode=start

while [ $# -gt 0 ]; do
  case "$1" in
    --wait) [ $# -ge 2 ] || die "--wait needs a number"; wait_s=$2; shift 2 ;;
    --status) mode=status; shift ;;
    --stop) mode=stop; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) die "unknown option: $1" ;;
    *) game=$1; shift ;;
  esac
done

case "$mode" in
  status)
    if alive; then echo "SPT server: online ($ping_url)"; exit 0; fi
    echo "SPT server: offline"
    exit 1
    ;;
  stop)
    pids=$(pgrep -f 'SPT\.Server\.Linux' 2>/dev/null || true)
    for p in $pids; do
      [ "$p" = "$$" ] && continue
      [ "$p" = "$PPID" ] && continue
      kill "$p" 2>/dev/null || true
    done
    echo "stopped: ${pids:-nothing}"
    exit 0
    ;;
esac

[ -n "$game" ] || { usage; exit 1; }
[ -d "$game" ] || die "no such directory: $game"

runtime="$game"
[ -x "$runtime/SPT.Server.Linux" ] || runtime="$game/SPT_Runtime"
[ -x "$runtime/SPT.Server.Linux" ] || die "SPT.Server.Linux not found in $game"

if alive; then
  echo "SPT server already running: $ping_url"
  exit 0
fi

dotnet_root="${SPT_DOTNET_ROOT:-$HOME/.local/share/spt-dotnet}"
[ -d "$dotnet_root/shared/Microsoft.AspNetCore.App" ] \
  || die "no ASP.NET Core runtime under $dotnet_root (set SPT_DOTNET_ROOT)"

mkdir -p "$(dirname "$log")"
echo "starting: $runtime/SPT.Server.Linux (log: $log)"
( cd "$runtime" && DOTNET_ROOT="$dotnet_root" setsid ./SPT.Server.Linux \
    >>"$log" 2>&1 </dev/null & )

i=0
while [ "$i" -lt "$wait_s" ]; do
  sleep 1
  i=$((i + 1))
  if alive; then
    echo "SPT server online after ${i}s: $ping_url"
    exit 0
  fi
done

echo "SPT server did not answer within ${wait_s}s — last log lines:" >&2
tail -n 15 "$log" >&2 || true
exit 1
