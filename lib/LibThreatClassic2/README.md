# LibThreatClassic2

Successor project for [https://github.com/EsreverWoW/LibThreatClassic](https://github.com/EsreverWoW/LibThreatClassic)

## How to use

Get the latest revision from LibStub and then register your addon as using LibThreatClassic:

```
local ThreadLib = LibStub("LibThreatClassic2", true)
if ThreadLib then
    ThreadLib:RegisterAddon("YourAddon")
end
```

`:UnreagisterAddon` can be used to send LibThreatClassic into idle, if no other addon is registered.

## Added fixes

* Fixed LibStub versioning system (automatically use newest version if multiple LibThreatClassic2 minor versions are available) thanks [@DDCorkum](https://github.com/DDCorkum)
* fix Execute threat multiplier for Warriors
* fix Revenge rank 5 bonus threat
* fix Maul threat multiplier for Druids

## TODO
* Druid cat form
* Paladin blessings
* Onyxia boss module
* Ragnaros boss module
* Improved voidwalker talent
* SPELL_HEAL / overheal and absorb handling
* ...


## License

[LGPL-2.1](LICENSE)

Copyright (c) 2019 Dennis-Florian Herr

LibThreatClassic2 incorporates work covered by the following copyright holders and permission notice:

Copyright (C) 2019 Alexander Burt (Es / EsreverWoW)
Copyright (C) 2007 Chris Heald and the Threat-1.0/Threat-2.0 teams

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
