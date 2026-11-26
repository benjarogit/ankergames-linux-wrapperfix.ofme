#!/bin/sh
# ---------------------------------------------------------------------------
# spp-tarkov-linux-launcher.sh — make Play start the native SPT launcher
#
# Why: the Windows launcher (SPT.Launcher.exe) is Photino/Blazor on WebView2.
# Under Wine its page is a D3D swapchain in a child window owned by
# msedgewebview2.exe, which does not present on this setup: the window stays
# white. WebView2 also sets the cursor from the browser process, and Wine
# cannot turn that handle into an X11 cursor (Wine bug 58922), so the pointer
# disappears. The usual WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS workaround does
# not help: Photino passes its own AdditionalBrowserArguments, which makes
# WebView2 ignore both the environment variable and the registry policy.
#
# What: the package ships SPT_Runtime/SPT.Launcher.Linux. It renders with
# GTK/WebKit — no Wine, no WebView2, normal cursor — and starts the game
# through umu/Proton itself. This script
#   1. points the launcher config at the Linux paths (game folder, prefix,
#      umu-run, Proton), and
#   2. adds a guarded block to the umu wrapper so that "Play" (GAMEID 3089,
#      Launcher.exe) starts the native launcher instead of the Windows one.
#
# Usage:
#   ./spp-tarkov-linux-launcher.sh <prefix>
#       [--runtime <SPT_Runtime>] [--umu <python-umu-run>]
#       [--proton <name-or-path>] [--wrapper <umu-run wrapper>]
#       [--dotnet <linux-dotnet-root>] [--dry-run]
#
#   <prefix>   e.g. "/mnt/daten/Games/AnkerGames/Games/Prefixes/3089"
#
# Needs the .NET 10 Linux runtime (Core + ASP.NET Core), default
# ~/.local/share/spt-dotnet — the same one spp-tarkov-server.sh uses.
# ---------------------------------------------------------------------------
set -eu

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
usage() { sed -n '2,30p' "$0"; }

prefix=
runtime=
umu=/usr/bin/umu-run
proton=
wrapper="${XDG_BIN_HOME:-$HOME/.local/bin}/umu-run"
dotnet_root="${SPT_DOTNET_ROOT:-$HOME/.local/share/spt-dotnet}"
dry=0

while [ $# -gt 0 ]; do
  case "$1" in
    --runtime) [ $# -ge 2 ] || die "--runtime needs a path"; runtime=$2; shift 2 ;;
    --umu) [ $# -ge 2 ] || die "--umu needs a path"; umu=$2; shift 2 ;;
    --proton) [ $# -ge 2 ] || die "--proton needs a name or path"; proton=$2; shift 2 ;;
    --wrapper) [ $# -ge 2 ] || die "--wrapper needs a path"; wrapper=$2; shift 2 ;;
    --dotnet) [ $# -ge 2 ] || die "--dotnet needs a path"; dotnet_root=$2; shift 2 ;;
    --dry-run) dry=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) die "unknown option: $1" ;;
    *)
      if [ -z "$prefix" ]; then prefix=$1
      else die "unexpected argument: $1"
      fi
      shift
      ;;
  esac
done

[ -n "$prefix" ] || { usage; exit 1; }
[ -d "$prefix/drive_c" ] || die "not a Wine prefix: $prefix"

[ -n "$runtime" ] || runtime="$prefix/drive_c/Games/SPP-Tarkov/SPT_Runtime"
[ -x "$runtime/SPT.Launcher.Linux" ] || die "no SPT.Launcher.Linux in $runtime"
game_dir=$(dirname "$runtime")
[ -f "$game_dir/EscapeFromTarkov.exe" ] || die "no EscapeFromTarkov.exe in $game_dir"

[ -x "$dotnet_root/dotnet" ] || die "no .NET runtime at $dotnet_root/dotnet (see docs)"
[ -f "$umu" ] || die "no umu-run at $umu"
case "$(head -n 1 "$umu" 2>/dev/null)" in
  *python*) ;;
  *) die "$umu is not the Python umu-run; pass the real script (usually /usr/bin/umu-run) with --umu" ;;
esac

if [ -z "$proton" ]; then
  for candidate in \
    "$HOME/.local/share/Steam/steamapps/common/Proton - Experimental" \
    "$HOME/.local/share/Steam/compatibilitytools.d"/* \
    "$HOME/.steam/steam/compatibilitytools.d"/*
  do
    [ -d "$candidate" ] || continue
    case "$candidate" in
      *LegacyRuntime*) continue ;;
    esac
    proton=$candidate
    break
  done
fi
[ -n "$proton" ] || die "no Proton found; pass one with --proton"
if [ -d "$proton" ]; then
  :
else
  # A bare name such as GE-Proton11-1 is resolved by umu-run itself.
  :
fi

settings="$runtime/user/Launcher/LauncherSettings.json"
[ -f "$settings" ] || die "no launcher config at $settings (start the launcher once)"

run() {
  if [ "$dry" = 1 ]; then printf 'would: %s\n' "$*"; else "$@"; fi
}

echo "runtime:  $runtime"
echo "game:     $game_dir"
echo "prefix:   $prefix"
echo "umu:      $umu"
echo "proton:   $proton"
echo "dotnet:   $dotnet_root"
echo "wrapper:  $wrapper"
echo

# 1 · launcher config: Linux paths
if [ "$dry" = 1 ]; then
  echo "would: write GamePath=$game_dir and LinuxSettings (PrefixPath=$prefix, UmuPath=$umu, ProtonVersion=$proton)"
else
  python3 - "$settings" "$game_dir" "$prefix" "$umu" "$proton" <<'PY'
import json, os, shutil, sys, time

path, game, prefix, umu, proton = sys.argv[1:6]
data = json.load(open(path, encoding="utf-8"))
linux = data.setdefault("LinuxSettings", {})

if (data.get("GamePath") == game and linux.get("PrefixPath") == prefix
        and linux.get("UmuPath") == umu and linux.get("ProtonVersion") == proton):
    print("ok: launcher config already points at the Linux paths")
    sys.exit(0)

shutil.copy2(path, f"{path}.bak-{time.strftime('%Y%m%d-%H%M%S')}")
data["GamePath"] = game
linux["PrefixPath"] = prefix
linux["UmuPath"] = umu
linux["ProtonVersion"] = proton
tmp = f"{path}.tmp"
with open(tmp, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2, ensure_ascii=False)
    fh.write("\n")
os.replace(tmp, path)
print(f"set: {path}")
PY
fi

# 2 · umu wrapper: start the native launcher for GAMEID 3089
begin="# >>> SPP Tarkov native launcher"
end="# <<< SPP Tarkov native launcher"
[ -f "$wrapper" ] || die "no umu wrapper at $wrapper — install one first (see README)"

if grep -qF "$begin" "$wrapper"; then
  echo "ok: $wrapper already starts the native launcher"
else
  block=$(mktemp)
  cat >"$block" <<EOF
$begin (managed by spp-tarkov-linux-launcher.sh) >>>
case "\${1##*/}" in
  Launcher.exe)
    if [ "\${GAMEID:-}" = "3089" ] && [ -z "\${SPP_WINE_LAUNCHER:-}" ]; then
      spt_dir="\$(cd "\$(dirname "\$1")" 2>/dev/null && pwd)"
      [ -x "\$spt_dir/SPT_Runtime/SPT.Launcher.Linux" ] || spt_dir="\$PWD"
      if [ -x "\$spt_dir/SPT_Runtime/SPT.Launcher.Linux" ]; then
        if ! curl -sk --max-time 2 https://127.0.0.1:6969/launcher/v2/ping >/dev/null 2>&1; then
          ( cd "\$spt_dir/SPT_Runtime" && \\
            DOTNET_ROOT="$dotnet_root" setsid -f ./SPT.Server.Linux >>"\$HOME/.local/share/spt-server.log" 2>&1 </dev/null )
        fi
        echo "SPP Tarkov: starting the native SPT launcher"
        cd "\$spt_dir/SPT_Runtime" || exit 1
        unset GAMEID
        exec env DOTNET_ROOT="$dotnet_root" ./SPT.Launcher.Linux
      fi
    fi
    ;;
esac
$end <<<
EOF
  if [ "$dry" = 1 ]; then
    echo "would: insert the native-launcher block into $wrapper"
  else
    command -v python3 >/dev/null 2>&1 || die "python3 is required"
    python3 - "$wrapper" "$block" "$begin" <<'PY'
import os, shutil, sys, time

wrapper, block_path, marker = sys.argv[1:4]
lines = open(wrapper, encoding="utf-8").read().splitlines(keepends=True)
block = open(block_path, encoding="utf-8").read()
if any(marker in line for line in lines):
    print("ok: block already present")
    sys.exit(0)

insert_at = None
for i in range(len(lines) - 1, -1, -1):
    if lines[i].startswith("exec "):
        insert_at = i
        break
if insert_at is None:
    sys.exit("error: no final 'exec' line found in the wrapper")

shutil.copy2(wrapper, f"{wrapper}.bak-{time.strftime('%Y%m%d-%H%M%S')}")
lines.insert(insert_at, block + "\n")
tmp = f"{wrapper}.tmp"
with open(tmp, "w", encoding="utf-8") as fh:
    fh.writelines(lines)
os.chmod(tmp, 0o755)
os.replace(tmp, wrapper)
print(f"patched: {wrapper}")
PY
    rm -f "$block"
  fi
fi

echo
echo "done. Close AnkerGames, start it again and press Play — the native SPT"
echo "launcher should open, with a normal cursor. SPP_WINE_LAUNCHER=1 starts the"
echo "Windows launcher under Wine instead (it needs Windows paths in the config)."
