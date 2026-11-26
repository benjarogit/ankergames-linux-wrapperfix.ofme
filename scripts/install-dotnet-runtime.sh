#!/bin/sh
# ---------------------------------------------------------------------------
# install-dotnet-runtime.sh — put .NET Desktop Runtime into a Wine prefix
#
# Why: SPP_Tarkov_Installer.exe (AnkerGames 3089) is a framework-dependent
# WPF app targeting net10.0-windows. Wine/Proton does not ship
# Microsoft.WindowsDesktop.App, so the app host stops with
#   "You must install .NET Desktop Runtime to run this application."
#
# What: downloads the official win-x64 runtime zips and extracts them to
#   <prefix>/drive_c/Program Files/dotnet
# which is the default location the .NET app host probes. No registry
# changes, no installer EXE, no winetricks needed.
#
# Usage:
#   ./install-dotnet-runtime.sh <wineprefix> [version]
#
#   <wineprefix>  e.g. "/mnt/daten/Games/AnkerGames/Games/Prefixes/3089"
#   [version]     default 10.0.15; any 10.0.x works (patch roll-forward)
# ---------------------------------------------------------------------------
set -eu

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

if [ $# -lt 1 ]; then
  sed -n '2,20p' "$0"
  exit 1
fi

prefix=$1
version=${2:-10.0.15}

[ -d "$prefix/drive_c" ] || die "not a Wine prefix: $prefix"
case "$version" in
  [0-9]*.[0-9]*.[0-9]*) ;;
  *) die "version must look like 10.0.15" ;;
esac

dest="$prefix/drive_c/Program Files/dotnet"
if [ -f "$dest/shared/Microsoft.WindowsDesktop.App/$version/.version" ]; then
  echo "already installed: $dest (WindowsDesktop $version)"
  exit 0
fi

cache="${XDG_CACHE_HOME:-$HOME/.cache}/anker-dotnet"
mkdir -p "$cache"

base="https://builds.dotnet.microsoft.com/dotnet"
runtime_url="$base/Runtime/$version/dotnet-runtime-$version-win-x64.zip"
desktop_url="$base/WindowsDesktop/$version/windowsdesktop-runtime-$version-win-x64.zip"

fetch() {
  url=$1
  file=$2
  if [ -f "$cache/$file" ]; then
    echo "cached: $file"
  else
    echo "downloading: $file"
    curl -fL --retry 3 --progress-bar -o "$cache/$file.part" "$url" \
      || die "download failed: $url"
    mv "$cache/$file.part" "$cache/$file"
  fi
}

fetch "$runtime_url" "dotnet-runtime-$version-win-x64.zip"
fetch "$desktop_url" "windowsdesktop-runtime-$version-win-x64.zip"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM

unzip -q "$cache/dotnet-runtime-$version-win-x64.zip" -d "$tmp"
unzip -q "$cache/windowsdesktop-runtime-$version-win-x64.zip" -d "$tmp"

[ -f "$tmp/shared/Microsoft.NETCore.App/$version/.version" ] \
  || die "base runtime zip is incomplete"
[ -f "$tmp/shared/Microsoft.WindowsDesktop.App/$version/.version" ] \
  || die "desktop runtime zip is incomplete"

mkdir -p "$dest"
cp -r "$tmp/." "$dest/"

echo "installed: $dest"
echo "  Microsoft.NETCore.App       $version"
echo "  Microsoft.WindowsDesktop.App $version"

# WPF needs at least one usable font family. Proton prefixes ship fonts and
# register the host's; a bare Wine prefix may not, and then WPF aborts with
# "Nicht behebbarer Systemfehler" while shaping text.
if [ ! -f "$prefix/drive_c/windows/Fonts/arial.ttf" ]; then
  echo
  echo "note: no Arial in this prefix. If the app aborts with"
  echo "      'Nicht behebbarer Systemfehler', install fonts first:"
  echo "        WINEPREFIX=\"$prefix\" winetricks -q corefonts"
fi
