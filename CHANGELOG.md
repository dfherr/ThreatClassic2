# Changelog

## v2.12

* Delay updates up to 0.2 seconds to address performance issues
* Only update frame on changes for current target
* Bump LibThreatClassic2 to revision 9
    - Add cleave threat modifier
    - Fix Paladin Greater Blessing bug on pets
    - Blacklist various enemies in BWL
* Update player target, if target target changes
* Added option to hide when not in an instance (also hides world bosses!)
* Improved Version checks
* Added zhTW translations

## v2.11

* Update LibThreatClassic to revision 8. Brings better threat sync interval and blacklist Lashlayer trash whelps.
* Fix some lib loading issues.
* added a /tc2 debug command to toggle LibThreatClassic2 debug output
* added a /tc2 runSolo command to toggle LibThreatClassic2 runSolo option
* added a /tc2 logThreat command to toggle LibThreatClassic2 logThreat option

## v2.10

* Use "target" as a fallback for player target, if other options make no sense (e.g. at vael)

## v2.09

* Update LibThreatClassic2 to revision 7
* Added option to change color of the player bar
* enable support for custom class colors addon
* save variables per character
* fix friendly units turning hostile

## v2.08-alpha1

Removed LibThreatClassic2 from files
added pkgmeta
embed LibThreatClassic2-r6-alpha1

## v2.07

First relase as ThreatClassic2 with LibThreatClassic2-r5