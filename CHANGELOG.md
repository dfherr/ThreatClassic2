# Changelog

## v2.74
* use WOW_PROJECT_CAMELOT to identify WoW Forever

## v2.73
* add support for WoW Forever and Retail (mainline)
  * target filter list matches boss encounter names on mainline
  * target of target (healer) mode is disabled on mainline
  * tank detection uses spec role on Retail and stances/forms/Righteous Fury on Forever
* add tank mode warnings: warns while you have aggro if another player gets close to you
* add option for minimum time between warnings
* add repeated warnings option
* add spec/dual spec profiles (LibDualSpec)
* improved test mode: simulates a fight with class colors
* fix errors when switching to an older, not yet migrated profile
* target name in the header is now clipped at the frame edge
* add threat per second display option and time to pull aggro option

## v2.72
* fix new aura lookup error (thanks @ngrudnitsky)
* update toc for tbc and classic era

## v2.71
* fix filter bug when having old outOfMelee enabled in config
* improve pullaggrobar percentage display
* bump MOP toc

## v2.70
* improve pull aggro bar behavior
* add options to display percentage points rather than relative threat required

## v2.69
* fix logic error in ignite indicator update
* add filter menu that currently supports filtering out of melee range
* add off tank colors (off tanks are group/raid members marked as maintanks or that have the role tank, but are currently not tanking)
* add pull aggro bar option
