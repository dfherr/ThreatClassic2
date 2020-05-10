local TC2, C, L, _ = unpack(select(2, ...))

-----------------------------
--	enUS and enGB clients
-----------------------------
-- main frame
L.gui_threat			= "Threat"
L.gui_config			= "Open Config"

-- config frame
L.reset					= "Reset to Defaults"

-- messages
L.message_welcome		= "Type /tc2 for options."
L.message_leader		= "You must be the group leader or have assist to do this."
L.message_outdated		= "New version of LibThreatClassic2 available! Please download the latest version. Latest version is always available in ThreatClassic2 and shortly after in DBM, Details and some other addons."
L.message_incompatible	= "TC2/LibThreatClassic2 is out of date and will not be compatible for this group. Please upgrade immediately."

-- version check
L.version				= "Version Check"
L.version_check			= "Check Outdated"
L.version_check_all		= "Check All"
L.version_notify		= "Notify Outdated"
L.version_list			= "Version Check: All Clients"
L.version_list_outdated	= "Version Check: Outdated Clients"
L.version_divider		= "--------------------------------"
L.version_incompatible	= "Not compatible!"

L.general				= "General"
L.general_welcome		= "Display welcome message when logging in."
L.general_rawPercent    = "Show raw threat percentage (aggro at 110% melee / 130% range)"
L.general_updateFreq    = "Time (in seconds) between updates."
L.general_test			= "Enable test mode."
L.general_minimap		= "Toggle minimap icon."
L.general_ignorePets	= "Ignore threat from player pets."

L.visibility			= "Visibility"
L.visibility_hideOOC	= "Hide frame when out of combat."
L.visibility_hideSolo	= "Hide frame when not in a group."
L.visibility_hideInPvP	= "Hide frame when in battlegrounds."
L.visibility_hideOpenWorld	= "Hide frame when not in an instance (also hides world bosses!)."
L.visibility_hideAlways	= "Hide frame always. /tc2 toggle"

L.nameplates			= "Nameplates"
L.nameplates_enable		= "Enable threat coloring (only for Blizzard nameplates)."
L.nameplates_invert		= "Invert threat coloring (intended for tanks)."
L.nameplates_colors		= "Threat Colors"

L.profiles              = "Profiles"

L.color					= "Colors"
L.color_good			= "Good"
L.color_neutral			= "Neutral"
L.color_bad				= "Bad"

L.appearance			= "Appearance"

L.frame					= "Frame"
L.frame_header			= "Header"
L.frame_bg				= "Background"
L.frame_test			= "Test Mode"
L.frame_strata			= "Strata"
L.frame_scale			= "Scale"
L.frame_lock			= "Lock"
L.frame_headerShow		= "Show Header"
L.frame_headerColor		= "Header Color"
L.frame_position		= "Position"
L.frame_width			= "Width"
L.frame_height			= "Height"
L.frame_xOffset         = "X Offset"
L.frame_yOffset         = "Y Offset"

L.bar					= "Bars"
L.bar_count				= "Maximum Count"
L.bar_descend			= "Reverse Growth"
L.bar_height			= "Height"
L.bar_padding			= "Padding"
L.bar_marker			= "Player Threat in Red"
L.bar_texture			= "Texture"
L.bar_classColor		= "Use Class Color"
L.bar_defaultColor		= "Custom Color"
L.bar_alpha				= "Bar Alpha (default colors)"
L.bar_colorMod			= "Color Modifier"

L.customBarColors 			        = "Custom Bar Colors"
L.customBarColorsPlayer_enabled	    = "Enable Custom Player Color"
L.customBarColorsActiveTank_enabled	= "Enable Custom Active Tank Color"
L.customBarColorsOtherUnit_enabled 	= "Enable Custom Other Unit Color"
L.customBarColorsPlayer_color 	    = "Player Color"
L.customBarColorsActiveTank_color 	= "Active Tank Color"
L.customBarColorsOtherUnit_color 	= "Other Unit Color"

L.font					= "Font"
L.font_name			    = "Name"
L.font_size				= "Size"
L.font_style			= "Style"
L.font_shadow			= "Dropshadow"

L.warnings				= "Warnings"
L.warnings_flash		= "Enable screen flashing."
L.warnings_sound		= "Enable sounds."
L.warnings_threshold	= "Warning threshold (100% = aggro)."
L.warnings_minThreatAmount = "Minimum threat to trigger warnings."

L.warnings_soundFile	= "Sound file"
L.warnings_soundChannel	= "Sound channel"

L.soundChannel_master = "Master"
L.soundChannel_sfx = "SFX"
L.soundChannel_ambience = "Ambience"
L.soundChannel_music = "Music"
