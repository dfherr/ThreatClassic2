local TC2, C, L, _ = unpack(select(2, ...))


-----------------------------
-- Default Config
-----------------------------
local defaultTexture = "TC2 Default"
local defaultFont = "NotoSans SemiCondensedBold"
-- Adjust fonts for CJK
local locale = GetLocale()
if locale == "koKR" or locale == "zhCN" or locale == "zhTW" then
    defaultFont = "Standard Text Font"
end

local defaultConfig = {}
-- general
defaultConfig.general = {
    welcome               = true,                               -- display welcome message
    updateFreq            = 0.2,                                -- how often the threat bars update
    rawPercent            = false,                              -- use raw percent
    downscaleThreat       = true,                               -- downscale threat so 1 damage = 1 threat
    minimap               = false,                              -- toggle for minimap icon
    ignorePets            = false,                              -- toggle for ignoring pets
    hideOOC               = false,                              -- hide frame when out of combat
    hideSolo              = false,                              -- hide frame when not in a group
    hideOpenWorld         = false,                              -- hide frame when not in an instance
    hideInPVP             = true,                               -- hide frame when in battlegrounds
    hideAlways            = false,                              -- hide frame always
}

-- frame settings
defaultConfig.frame = {
    test                = false,                                    -- toggle for test mode
    scale               = 1,                                        -- global scale
    width               = 217,                                      -- frame width
    height              = 161,                                      -- frame height
    locked              = false,                                    -- toggle for movable
    strata              = "3-MEDIUM",                               -- frame strata
    position            = {"TOPLEFT", "UIParent", "TOPLEFT", 50, -200},    -- frame position
    color               = {0, 0, 0, 0.35},                          -- frame background color
    headerShow          = true,                                     -- show frame header
    headerColor         = {0, 0, 0, 0.8},                           -- frame header color
    growUp              = false,                                    -- grow header and bar upwards
}

-- backdrop settings
defaultConfig.backdrop = {
    texture             = defaultTexture,                       -- backdrop texture
    color               = {0, 0, 0, 1},                         -- backdrop color
    edgeTexture         = defaultTexture,                       -- backdrop edge texture
    edgeColor           = {0, 0, 0, 1},                         -- backdrop edge color
    tile                = false,                                -- backdrop texture tiling
    tileSize            = 0,                                    -- backdrop tile size
    edgeSize            = 1,                                    -- backdrop edge size
    inset               = 0,                                    -- backdrop inset value
}

-- threat bar settings
defaultConfig.bar = {
    count               = 9,                                    -- maximum amount of bars to show
    descend             = true,                                 -- sort bars descending / ascending
    height              = 18,                                   -- bar height
    padding             = 1,                                    -- padding between bars
    texture             = defaultTexture,                       -- texture file location
    alpha               = 1,                                    -- statusbar alpha
    showThreatValue     = true,                                 -- show threat value in bar
    showThreatPercentage = true,                                -- show threat percentage in bar
    showPullAggroBar    = false,                                -- show an extra bar indicating when aggro would be pulled
    pullAggroBarColor   = {0, 0.7, 0, 1},                       -- color of pull aggro bar
    pullAggroBarText    = "Pull aggro at",                      -- text of pull aggro bar
    pullAggroBarGrow    = true,                                 -- grow the pull aggro bar when getting closer to pulling threat
    pullAggroBarPercentage = "RELATIVE",                        -- relative vs absolute (percentage points) number for pull aggro bar
    showIgniteIndicator = true,                                 -- show ignite icon when target has ignite
}

defaultConfig.igniteIndicator = {
    size                = 10,                                   -- ignite indicator icon size
    makeRound           = false,                                -- makes the texture round
}

--bar custom color settings
defaultConfig.customBarColors  = {
    playerEnabled       = false,                                -- enable custom color for player
    activeTankEnabled   = false,                                -- enable custom color for active tank
    offTankEnabled      = false,                                -- enable custom color for off tank
    otherUnitEnabled    = false,                                -- enable custom color for other units
    igniteColorEnabled  = false,                                -- enable custom color for active ignite player
    playerColor         = {0.8, 0, 0, 1},                       -- custom color for player
    activeTankColor     = {0, 0.8, 0, 1},                       -- custom color for active tank
    offTankColor        = {0, 0.5, 0, 1},                       -- custom color for off tank
    otherUnitColor      = {0.3, 0.3, 0.3, 1},                   -- custom color for other units
    igniteColor         = {1.0, 0.6, 0, 1},                     -- custom color for active ignite player
}

-- font settings
defaultConfig.font = {
    name                = defaultFont,                          -- font name
    size                = 12,                                   -- font size
    style               = "OUTLINE",                            -- font style
    color               = {1, 1, 1, 1},                         -- font color
    shadow              = true,                                 -- font dropshadow
}

-- filter settings
defaultConfig.filter = {
    useTargetList               = true,                         -- only filter targets in list
    targetList                  = {},                           -- list of targets to apply filters for
    outOfMelee = {
        hide                    = false,                            -- hide players out of melee range
        color                   = false,                            -- alter color out of melee range
        overwriteColorEnabled   = false,                            -- overwrite out of melee color
        overwriteColor          = {0.2, 0.2, 0.2, 1},               -- overwrite color
        desaturate              = 0.8,                              -- how much to desaturate out of melee range
        darken                  = 0.0,                              -- how much to darken out of melee range
        fade                    = 0.2,                              -- how much to fade out of melee range
        yourself                = false,                            -- apply filter to yourself
    },
}

-- warning settings
defaultConfig.warnings = {
    disableWhileTanking = true,                                 -- disable warnings if considered tanking
    flash               = false,                                -- enable screen flash
    sound               = false,                                -- enable sound
    threshold           = 80,                                   -- alert threshold (of normalized percentage 0-100)
    minThreatAmount     = 2000,
    soundFile           = "You Will Die!",
    soundChannel        = "SFX",
}

TC2.defaultConfig = { profile = defaultConfig }
