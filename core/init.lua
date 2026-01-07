-----------------------------
-- Init
-----------------------------
local parent, ns = ...
ns[1] = {} -- TC2, Functions
ns[2] = {} -- C, Config
ns[3] = {} -- L, Localization

-----------------------------
-- AddOn Info
-----------------------------
ns[1].addonName     = parent
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

ns[1].version       = GetAddOnMetadata(parent, "Version")
ns[1].locale        = GetLocale()
