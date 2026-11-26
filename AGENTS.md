# AnkerGames Linux wrapper fixes

## Documentation

- Use English for repository instructions. Keep public player guides in English
  and German. English is the default entry point in `README.md`, with
  `README.de.md` as its German counterpart.
- Keep both READMEs focused on the games list and the shared wrapper setup.
  Give each game one page per language under `docs/en/games/` and
  `docs/de/games/`. Make the same user-facing change in both language versions.
- Keep Fika co-op on the Tarkov page. Give hosts and guests direct links to
  their own steps. Share the Windows and Linux installation instructions
  between both roles. Explain the LAN and Tailscale setups where players pick
  how to connect.
- Use numbered lists for setup steps, tables for choices and GitHub
  `<details>` sections for optional troubleshooting. Keep required steps
  visible. Verify links and anchors when reorganizing a guide.
- Report what was actually tested. Record game launch, server connection and
  a shared raid as separate checks. Keep supporting logs in `evidence/` and
  redact credentials and profile tokens from new excerpts.

## Wrapper changes

- Keep fixes in the launcher configuration, Wine prefix and wrapper. Preserve
  the original game files and DRM.
- Run `sh -n` on changed shell scripts. For launch behavior changes, verify the
  normal AnkerGames entry point or record the exact simulation and its limits.
