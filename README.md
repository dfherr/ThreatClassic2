# ThreatClassic2 [!["Open Issues"](https://img.shields.io/github/issues-raw/dfherr/ThreatClassic2.svg)](https://github.com/dfherr/ThreatClassic2/issues)
ThreatClassic2 is a threat meter for WoW Classic (Era, Anniversary, Mists) and WoW Forever.

## Features

### Core
- Threat list for your target including party/raid members. You're always shown, even outside the top bars.
- Pull aggro bar: threat needed to pull from the current tank (110% melee / 130% range), relative or absolute.
- Healer mode: shows your target's target when you target a friendly unit (Classic only).
- Out of melee filter: hide or change the style of players the threat API considers out of melee range 
- Scaled (100% = aggro) or raw threat percentages (110% melee / 130% range = aggro)

### Warnings
- Sound and/or screen flash when crossing a threat threshold.
- Minimum threat amount, minimum time between warnings and automatic disabling while tanking.

### Styling
- Fully customizable appearance via (LibSharedMedia)
- Class colors or custom colors for yourself, the active tank, off-tanks and other units.
- Supports custom class colors from !ClassColors (via `CUSTOM_CLASS_COLORS`).
- Out of melee coloring: desaturate, darken, fade or overwrite the color.
- Ignite owner indicator (Classic Era only).
- Visibility: hide out of combat, solo, in PvP, in the open world or always.

### Mainline (WoW Forever and Retail) differences

Mainline clients restrict addon access to some combat data, so a few features work differently:

- The target filter list matches **boss encounter names** instead of unit names and applies to all enemies during that encounter.
- Healer mode (target of target) is not available. Target the enemy directly to see its threat list.
- Disabling warnings while tanking uses your specialization role instead of stance/form/aura checks.

## Commands

- `/tc2` opens the options
- `/tc2 toggle` shows or hides the frame
- `/tc2 version` prints the installed version

## Bugs and feature requests

Please submit all feature requests and bugs in this projects [issue tracker](https://github.com/dfherr/ThreatClassic2/issues)

Please check for bugs and feature requests before submitting the same request and participate in the dicussion. Please **do not** email me, comment on commits or raise issues in any other channel, so there is a single place for discussions everyone can see and participate. Thank you for your consideration.

Like the project? Add a star :)

## Download
 - [CurseForge](https://www.curseforge.com/wow/addons/ThreatClassic2)
 - [wago.io](https://addons.wago.io/addons/threatclassic2)
 - [wowinterface](https://www.wowinterface.com/downloads/info25966-ThreatClassic2.html)
 - Manual install from [releases](https://github.com/dfherr/ThreatClassic2/releases)

## FAQ
**Q: Why use ThreatClassic2 instead of ClassicThreatMeter?**

ClassicThreatMeter is outdated and should no longer be used.

**Q: Why am I not seeing other players in the beginning of combat?**
 
A: You can not see a monster's threat data before you are on the monster's threat table (i.e. did damage to it or caused any kind of aoe threat like healing or buffing). This is a restriction of the Blizzard API and cannot be changed.

**Q: Is this addon under active development and will get more features?**

A: Yes! I do accept feature requests and will add new features to the addon. Feel free to open an issue or +1 an existing feature request, so I can see the most sought after features!

## License

[MIT](license/ThreatClassic2)

Copyright (c) 2019 Dennis-Florian Herr
