#!/bin/sh
# ---------------------------------------------------------------------------
# Reference implementation: online-fix builds under Wine/Proton
#
# This is NOT a patch for a game and contains no game data. It shows the two
# things a Linux launcher (umu/Proton) has to do before starting an online-fix
# build, so that the fix DLL can reach the Steam client.
#
# Both steps are launcher-side only. They are exactly what Proton's own
# "proton" script does when it creates a prefix, plus one Wine DLL override
# that Windows does not need (Windows prefers the DLL next to the .exe, Wine
# prefers its builtin one).
#
# Input:  $1 = path to the game executable the launcher is about to start
#         $WINEPREFIX = the game's Wine prefix
# Output: exit 0, environment prepared for `umu-run "$1"`
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Fix 1 - Steam client files inside the prefix
#
# The fix DLL (OnlineFix64.dll, union-crax, ...) resolves
#   HKCU\Software\Valve\Steam\ActiveProcess\SteamClientDll64
# and calls LoadLibrary on it. That path is
#   C:\Program Files (x86)\Steam\steamclient64.dll
# inside the prefix. If the file is missing -> "Error code: 126"
# (ERROR_MOD_NOT_FOUND) and the game aborts.
#
# The five files and their sources on the host:
#   <Steam>/steamclient64.dll            -> steamclient64.dll
#   <Steam>/steamclient.dll              -> steamclient.dll
#   <Steam>/GameOverlayRenderer64.dll    -> GameOverlayRenderer64.dll
#   <Steam>/legacycompat/Steam.dll       -> Steam.dll
#   <Steam>/legacycompat/SteamService.exe-> steam.exe   (renamed!)
#
# Note: Proton copies the same five files, but only while it creates or
# upgrades a prefix. If the prefix already exists (normal case after the first
# start, or after a launcher update) nothing is copied, so the launcher has to
# make sure they are there on every start.
# ---------------------------------------------------------------------------

place_steam_client() {
  exe="$1"
  [ -n "$WINEPREFIX" ] || return 0

  steam_dir="$WINEPREFIX/drive_c/Program Files (x86)/Steam"
  [ -f "$steam_dir/steamclient64.dll" ] && return 0   # already in place

  # Only for builds that actually ship a fix. Markers used by the catalog:
  #   OnlineFix.ini   -> OnlineFix builds
  #   union-crax.ini  -> union-crax builds (The Ascent)
  #   steam_emu.ini   -> RUNE/union-crax builds
  # The marker can be deep below the game root:
  #   <root>/Engine/Binaries/ThirdParty/Steamworks/<ver>/Win64/steam_emu.ini
  # so scan the whole tree (depth 8 is enough for UE4/UE5 layouts).
  find "$(dirname "$exe")" -maxdepth 8 \
       \( -iname 'OnlineFix.ini' -o -iname 'union-crax.ini' -o -iname 'steam_emu.ini' \) \
       -print -quit 2>/dev/null | grep -q . || return 0

  src="$HOME/.local/share/Steam"
  [ -f "$src/steamclient64.dll" ] || return 0

  mkdir -p "$steam_dir" || return 0
  cp -L "$src/steamclient64.dll"             "$steam_dir/steamclient64.dll"
  cp -L "$src/steamclient.dll"               "$steam_dir/steamclient.dll"
  cp -L "$src/GameOverlayRenderer64.dll"     "$steam_dir/GameOverlayRenderer64.dll"
  cp -L "$src/legacycompat/Steam.dll"        "$steam_dir/Steam.dll"
  cp -L "$src/legacycompat/SteamService.exe" "$steam_dir/steam.exe"
}

# ---------------------------------------------------------------------------
# Fix 2 - prefer the bundled native winmm.dll
#
# Most online-fix builds ship a native winmm.dll next to the shipping
# executable. That DLL is the loader: it loads OnlineFix64.dll, which hooks
# SteamAPI_Init and connects to the real Steam client.
#
# On Windows the application directory wins the DLL search order, so the proxy
# loads. Wine's default for winmm is "builtin, native" -> the proxy is skipped,
# the original steam_api64.dll runs and SteamAPI_Init fails:
#   LogSteamShared: Warning: SteamAPI failed to initialize, conditions not met.
#   LogOnline: STEAM: [AppId: 0] Client API initialized 0
#
# "winmm=n,b" = native first, builtin as fallback. Append, do not overwrite:
# the launcher may already set other overrides (e.g. ddraw for old titles).
# ---------------------------------------------------------------------------

prefer_native_winmm() {
  exe="$1"
  find "$(dirname "$exe")" -maxdepth 4 -iname 'winmm.dll' -print -quit 2>/dev/null \
    | grep -q . || return 0

  WINEDLLOVERRIDES="${WINEDLLOVERRIDES:+$WINEDLLOVERRIDES;}winmm=n,b"
  export WINEDLLOVERRIDES
}

# ---------------------------------------------------------------------------
# Call site
# ---------------------------------------------------------------------------

case "$1" in
  *.exe)
    place_steam_client "$1"
    prefer_native_winmm "$1"
    ;;
esac

exec /usr/bin/umu-run "$@"
