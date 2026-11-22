# Spoken — Subtitle Grabber (unofficial community build)

This is an **unofficial** community distribution of [Spoken](https://github.com/rusty-key/spoken-wow) 3.12.0 for **World of Warcraft Forever**. Its changes are maintained in [Praxeomatic/spoken-wow, feature/subtitle-grabber](https://github.com/Praxeomatic/spoken-wow/tree/feature/subtitle-grabber). The original project is maintained by rusty-key; this fork is not an official Spoken release.

## What changes

- Subtitle text does not intercept mouse clicks or wheel input.
- A four-arrow grabber appears with the subtitle playback controls; drag it to move the subtitle and controls together.
- **Lock Position** disables dragging but leaves playback controls working.
- Releasing the mouse stops dragging even if the drag-stop event is missed.
- The button tooltip explains what it does.

Praxeomatic tested the changes stepwise and confirmed the final behavior in WoW Forever. The feature has automated test coverage; the automated suite was last reported passing before a subsequent test-and-comment cleanup, and that final cleanup has not had a fresh full CI run.

## Install (Windows)

**Close the game first.** Download [Install-Spoken-Community.ps1](Install-Spoken-Community.ps1) and review it, then run it in PowerShell, substituting your actual WoW Forever `Interface\AddOns` path. For example:

```powershell
$installer = Get-ChildItem "$env:USERPROFILE\Downloads" -Filter 'Install-Spoken-Community*.ps1' -File | Where-Object { $_.Name -match '^Install-Spoken-Community(?:\s*\(\d+\))?\.ps1$' } | Sort-Object LastWriteTime -Descending | Select-Object -First 1; if (-not $installer) { throw 'Installer not found in Downloads' }; powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer.FullName -AddOnsPath 'D:\World of Warcraft\_forever_\Interface\AddOns'
```

The installer downloads the GitHub branch archive, validates the six addon folders, backs up existing installations before replacing them, writes a timestamped log under `Documents\SpokenCommunityInstallLogs`, and opens the log folder. It leaves separately installed voice packs and SavedVariables alone.

**Manual installation:** [Download the community ZIP](https://github.com/Praxeomatic/spoken-wow/archive/refs/heads/community/subtitle-grabber.zip), extract it, open the single outer archive folder, and copy these six folders into your WoW Forever `Interface\AddOns` directory:

`Spoken`, `Spoken_Quests`, `Spoken_Places`, `Spoken_Readables`, `Spoken_Bosses`, `SpokenContributions`.

Do not copy the outer archive folder itself into `AddOns`. Back up existing versions of those six folders first; avoid leaving mixed versions in place. Existing **voice packs remain separate downloads** from the [official project](https://github.com/rusty-key/spoken-wow).

This branch is an installable source snapshot, **not** a GitHub Release asset and **not** an independently published CurseForge addon.

## Development attribution — Human–AI collaboration

This contribution was developed through a partnership between **[Praxeomatic](https://github.com/Praxeomatic)** and OpenAI's ChatGPT.

**Praxeomatic's contribution:** Identified the usability problem, conceived and defined the interaction model, authored the initial code, established implementation requirements, and directed subsequent revisions. Praxeomatic conducted stepwise in-game testing throughout development, identified defects, evaluated usability and functionality, directed corrective work, and performed final in-game acceptance testing.

**AI contribution:** ChatGPT reviewed and revised Praxeomatic's original code, wrote additional code where necessary, assisted with error correction and regression tests, reduced unnecessary complexity, and improved readability, comments, and maintainability in accordance with the original project's conventions.

**Development responsibility:** Praxeomatic retained creative and technical direction, made the substantive design decisions, and validated the functionality in the World of Warcraft client.

## Licensing and credits

Spoken is based on work by [rusty-key and contributors](https://github.com/rusty-key/spoken-wow). See [LICENSE](LICENSE) and [THIRD_PARTY.md](THIRD_PARTY.md) for license information and third-party material.
