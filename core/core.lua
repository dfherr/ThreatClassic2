local TC2, C, L, _ = unpack(select(2, ...))

-----------------------------
-- VARIABLES
-----------------------------
-- upvalues
local _G		= _G
local select	= _G.select
local unpack	= _G.unpack
local tonumber	= _G.tonumber
local type		= _G.type
local floor		= _G.math.floor
local strbyte	= _G.string.byte
local format	= _G.string.format
local strlen	= _G.string.len
local strsub	= _G.string.sub

local ipairs	= _G.ipairs
local pairs		= _G.pairs
local tinsert	= _G.table.insert
local tremove	= _G.table.remove
local sort		= _G.table.sort
local wipe		= _G.table.wipe

local GetNumGroupMembers	= _G.GetNumGroupMembers
local GetNumSubgroupMembers	= _G.GetNumSubgroupMembers
local GetInstanceInfo		= _G.GetInstanceInfo
local InCombatLockdown		= _G.InCombatLockdown
local IsInRaid				= _G.IsInRaid
local UnitAffectingCombat	= _G.UnitAffectingCombat
local UnitClass				= _G.UnitClass
local UnitExists			= _G.UnitExists
local UnitIsFriend			= _G.UnitIsFriend
local UnitIsPlayer			= _G.UnitIsPlayer
local UnitName				= _G.UnitName
local UnitReaction			= _G.UnitReaction
local UnitIsUnit 			= _G.UnitIsUnit


local FACTION_BAR_COLORS	= _G.FACTION_BAR_COLORS
local RAID_CLASS_COLORS		= (_G.CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS)

-- other
TC2.bars = {}
TC2.threatData = {}
TC2.colorFallback = {}
TC2.threatColors = {}
TC2.numGroupMembers = 0
TC2.playerName = ""
TC2.playerTarget = ""

-----------------------------
-- WOW CLASSIC
-----------------------------
-- TC2.classic = _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC -- for testing in retail
TC2.classic = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC

-- depreciation warning for ClassicThreatMeter
C_Timer.After(3, 
  function() 
    if IsAddOnLoaded("ClassicThreatMeter2") then
      print("|cFFFBB709ClassicThreatMeter2|cFFFF6060 was renamed to |cFFFBB709ThreatClassic2|cFFFF6060. Please remove ClassicThreatMeter2 from your Interface\\AddOns folder.")
    end
  end
)

local ThreatLib = TC2.classic and LibStub:GetLibrary("LibThreatClassic2")
assert(ThreatLib, "ThreatClassic2 requires LibThreatClassic2")

local UnitThreatSituation = TC2.classic and function(unit, mob)
	return ThreatLib:UnitThreatSituation(unit, mob)
end or _G.UnitThreatSituation

local UnitDetailedThreatSituation = TC2.classic and function(unit, mob)
	return ThreatLib:UnitDetailedThreatSituation(unit, mob)
end or _G.UnitDetailedThreatSituation

-----------------------------
-- FUNCTIONS
-----------------------------
local function CopyDefaults(t1, t2)
	if type(t1) ~= "table" then return {} end
	if type(t2) ~= "table" then t2 = {} end

	for k, v in pairs(t1) do
		if type(v) == "table" then
			t2[k] = CopyDefaults(v, t2[k])
		elseif type(v) ~= type(t2[k]) then
			t2[k] = v
		end
	end

	return t2
end

local function CreateBackdrop(parent, cfg)
	local f = CreateFrame("Frame", nil, parent)
	f:SetPoint("TOPLEFT", parent, "TOPLEFT", -cfg.inset, cfg.inset)
	f:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", cfg.inset, -cfg.inset)
	-- Backdrop Settings
	local backdrop = {
		bgFile = cfg.bgFile,
		edgeFile = cfg.edgeFile,
		tile = cfg.tile,
		tileSize = cfg.tileSize,
		edgeSize = cfg.edgeSize,
		insets = {
			left = cfg.inset,
			right = cfg.inset,
			top = cfg.inset,
			bottom = cfg.inset,
		},
	}
	f:SetBackdrop(backdrop)
	f:SetBackdropColor(unpack(cfg.bgColor))
	f:SetBackdropBorderColor(unpack(cfg.edgeColor))

	parent.backdrop = f
end

local function CreateFS(parent)
	local fs = parent:CreateFontString(nil, "ARTWORK")
	fs:SetFont(C.font.family, C.font.size, C.font.style)
	return fs
end

local function CreateStatusBar(parent, header)
	-- StatusBar
	local bar = CreateFrame("StatusBar", nil, parent)
	bar:SetMinMaxValues(0, 100)
	-- Backdrop
	CreateBackdrop(bar, C.backdrop)

	if not header then
		-- BG
		bar.bg = bar:CreateTexture(nil, "BACKGROUND", nil, -6)
		bar.bg:SetAllPoints(bar)
		-- Name
		bar.name = CreateFS(bar)
		bar.name:SetJustifyH("LEFT")
		-- Perc
		bar.perc = CreateFS(bar)
		bar.perc:SetJustifyH("RIGHT")
		-- Value
		bar.val = CreateFS(bar)
		bar.val:SetJustifyH("RIGHT")

		bar:Hide()
	end
	return bar
end

local function Compare(a, b)
	return a.scaledPercent > b.scaledPercent
end

local function NumFormat(v)
	if v > 1e10 then
		return (floor(v / 1e9)) .. "b"
	elseif v > 1e9 then
		return (floor((v / 1e9) * 10) / 10) .. "b"
	elseif v > 1e7 then
		return (floor(v / 1e6)) .. "m"
	elseif v > 1e6 then
		return (floor((v / 1e6) * 10) / 10) .. "m"
	elseif v > 1e4 then
		return (floor(v / 1e3)) .. "k"
	elseif v > 1e3 then
		return (floor((v / 1e3) * 10) / 10) .. "k"
	else
		return v
	end
end

local function TruncateString(str, i, ellipsis)
	if not str then return end
	local bytes = strlen(str)
	if bytes <= i then
		return str
	else
		local length, pos = 0, 1
		while (pos <= bytes) do
			length = length + 1
			local c = strbyte(str, pos)
			if c > 0 and c <= 127 then
				pos = pos + 1
			elseif c >= 192 and c <= 223 then
				pos = pos + 2
			elseif c >= 224 and c <= 239 then
				pos = pos + 3
			elseif c >= 240 and c <= 247 then
				pos = pos + 4
			end
			if length == i then break end
		end
		if length == i and pos <= bytes then
			return strsub(str, 1, pos - 1) .. (ellipsis and "..." or "")
		else
			return str
		end
	end
end

local function GetColor(unit)
	if unit then
		local colorUnit = {}
		
		if C.playerBarCustomColor.enabled and UnitIsUnit(unit, "player") then
			return C.playerBarCustomColor.color
		elseif UnitIsPlayer(unit) then
			colorUnit = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
		else
			colorUnit = FACTION_BAR_COLORS[UnitReaction(unit, "player")]
		end
		colorUnit = {colorUnit.r, colorUnit.g, colorUnit.b, C.bar.alpha}
		return colorUnit
	else
		return TC2.colorFallback
	end
end

function TC2:UpdateThreatBars()
	-- sort the threat table
	sort(self.threatData, Compare)

	-- update view
	for i = 1, C.bar.count do
		-- get values out of table
		local data = self.threatData[i]
		local bar = self.bars[i]
		if data and data.threatValue > 0 then
			if bar == self.bars[1] then data.scaledPercent = 100 end -- temporary?
			bar.name:SetText(UnitName(data.unit) or UNKNOWN)
			bar.val:SetText(NumFormat(data.threatValue))
			bar.perc:SetText(floor(data.scaledPercent).."%")
			bar:SetValue(data.scaledPercent)
			local color = GetColor(data.unit)
			bar:SetStatusBarColor(unpack(color))
			bar.bg:SetVertexColor(color[1] * C.bar.colorMod, color[2] * C.bar.colorMod, color[3] * C.bar.colorMod, C.bar.alpha)
			bar.backdrop:SetBackdropColor(unpack(C.backdrop.bgColor))
			bar.backdrop:SetBackdropBorderColor(unpack(C.backdrop.edgeColor))

			bar:Show()
		else
			bar:Hide()
		end
	end
end

local function CheckVisibility()
	local instanceType = select(2, GetInstanceInfo())
	local hide = C.general.hideAlways or (C.general.hideOOC and not InCombatLockdown()) or (C.general.hideSolo and TC2.numGroupMembers == 0) or (C.general.hideInPVP and (instanceType == "arena" or instanceType == "pvp"))

	if hide then
		return TC2.frame:Hide()
	else
		return TC2.frame:Show()
	end
end

local function UpdateThreatData(unit)
	if not UnitExists(unit) then return end
	local _, _, scaledPercent, _, threatValue = UnitDetailedThreatSituation(unit, TC2.playerTarget)
	if threatValue and threatValue < 0 then
		threatValue = threatValue + 410065408
	end
	tinsert(TC2.threatData, {
		unit			= unit,
		scaledPercent	= scaledPercent or 0,
		threatValue		= threatValue or 0,
	})
end

local function UpdatePlayerTarget()
	if UnitExists("target") and not UnitIsFriend("player", "target") then
		TC2.playerTarget = "target"
	elseif UnitExists("targettarget") and not UnitIsFriend("player", "targettarget") then
		TC2.playerTarget = "targettarget"
	else
		TC2.playerTarget = "target"
	end
end

local function CheckStatus()
	if C.frame.test then return end

	CheckVisibility()
	UpdatePlayerTarget()

	if UnitExists(TC2.playerTarget) then -- and UnitAffectingCombat(TC2.playerTarget) then
		-- wipe
		wipe(TC2.threatData)

		if IsInRaid() then
			for i = 1, TC2.numGroupMembers do
				UpdateThreatData(TC2.raidUnits[i])
				UpdateThreatData(TC2.raidPetUnits[i])
			end
		else
			if TC2.numGroupMembers > 0 then
				for i = 1, TC2.numGroupMembers do
					UpdateThreatData(TC2.partyUnits[i])
					UpdateThreatData(TC2.partyPetUnits[i])
				end
			end
			-- solo / party player & pet units
			UpdateThreatData("player")
			UpdateThreatData("pet")
		end

		TC2:UpdateThreatBars()

		-- set header unit name
		local targetName = (": " .. UnitName(TC2.playerTarget)) or ""
		targetName = TruncateString(targetName, floor(TC2.frame.header:GetWidth() / (C.font.size * 0.85)), true)
		TC2.frame.header.text:SetText(format("%s%s", L.gui_threat, targetName))
	else
		-- clear header text of unit name
		TC2.frame.header.text:SetText(format("%s%s", L.gui_threat, ""))
		-- hide bars when no target
		for i = 1, 40 do
			TC2.bars[i]:Hide()
		end
	end
end

-----------------------------
-- UPDATE FRAME
-----------------------------
local function SetPosition(f)
	local a1, _, a2, x, y = f:GetPoint()
	C.frame.position = {a1, "UIParent", a2, x, y}
end

local function OnDragStart(f)
	f = f:GetParent()
	f:StartMoving()
end

local function OnDragStop(f)
	f = f:GetParent()
	f:StopMovingOrSizing()
	SetPosition(f)
end

local function UpdateSize(f)
	C.frame.width = f:GetWidth() - 2
	C.frame.height = f:GetHeight()

	local maxBarCount = floor(C.frame.height / (C.bar.height + C.bar.padding)) + 1
	-- if C.bar.count > maxBarCount then C.bar.count = maxBarCount end
	C.bar.count = maxBarCount

	for i = 1, 40 do
		if i <= C.bar.count and TC2.threatData[i] then
			TC2.bars[i]:Show()
		else
			TC2.bars[i]:Hide()
		end
	end

	TC2:UpdateFrame()
end

local function OnMouseDown(f)
	f = f:GetParent()
	f:SetMinResize(64, 64)
	f:SetMaxResize(512, 1024)
	TC2.sizing = true
	f:SetScript("OnSizeChanged", UpdateSize)
	f:StartSizing()
end

local function OnMouseUp(f)
	f = f:GetParent()
	TC2.sizing = false
	f:SetScript("OnSizeChanged", nil)
	f:StopMovingOrSizing()
end

local function UpdateFont(fs)
	fs:SetFont(C.font.family, C.font.size, C.font.style)
	fs:SetVertexColor(unpack(C.font.color))
	fs:SetShadowOffset(C.font.shadow and 1 or 0, C.font.shadow and -1 or 0)
end

function TC2:UpdateFrame()
	local frame = self.frame

	if not TC2.sizing then
		frame:SetSize(C.frame.width + 2, C.frame.height)
	end
	frame:ClearAllPoints()
	frame:SetPoint(unpack(C.frame.position))
	frame:SetScale(C.frame.scale)
	frame:SetFrameStrata(strsub(C.frame.strata, 3))

	if not C.frame.locked then
		frame:SetMovable(true)
		frame:SetResizable(true)
		frame:SetClampedToScreen(true)

		frame.resize:Show()
		frame.resize:EnableMouse(true)
		frame.resize:SetMovable(true)
		frame.resize:RegisterForDrag("LeftButton")
		frame.resize:SetScript("OnDragStart", OnMouseDown)
		frame.resize:SetScript("OnDragStop", OnMouseUp)

		frame.header:SetMovable(true)
		frame.header:SetClampedToScreen(true)
		frame.header:RegisterForDrag("LeftButton")
		frame.header:SetScript("OnDragStart", OnDragStart)
		frame.header:SetScript("OnDragStop", OnDragStop)
	else
		frame:SetMovable(false)
		frame:SetResizable(false)
		frame.resize:Hide()
		frame.resize:SetMovable(false)
		frame.header:SetMovable(false)
	end

	-- Background
	frame.bg:SetAllPoints()
	frame.bg:SetVertexColor(unpack(C.frame.color))

	-- Header
	if C.frame.headerShow then
		frame.header:SetSize(C.frame.width + 2, C.bar.height)
		frame.header:SetStatusBarTexture(C.bar.texture)

		frame.header:SetPoint("TOPLEFT", frame, 0, C.bar.height - 1)
		frame.header:SetStatusBarColor(unpack(C.frame.headerColor))

		frame.header.backdrop:SetBackdropColor(0, 0, 0, 0) -- ugly, but okay for now
		frame.header.backdrop:SetBackdropBorderColor(0, 0, 0, C.frame.headerColor[4]) -- adjust alpha for border

		frame.header.text:SetText(format("%s%s", L.gui_threat, ""))

		UpdateFont(frame.header.text)

		frame.header:Show()
	else
		frame.header:Hide()
	end

	self:UpdateBars()
end

function TC2:UpdateBars()
	for i = 1, 40 do
		if not self.bars[i] then
			self.bars[i] = CreateStatusBar(self.frame)
		end

		local bar = self.bars[i]

		if i == 1 then
			bar:SetPoint("TOP", 0, 0)
		else
			bar:SetPoint("TOP", self.bars[i - 1], "BOTTOM", 0, -C.bar.padding + 1)
		end
		bar:SetSize(C.frame.width + 2, C.bar.height)
		bar:SetStatusBarTexture(C.bar.texture)

		-- BG
		bar.bg:SetTexture(C.bar.texture)
		-- Name
		bar.name:SetPoint("LEFT", bar, 4, 0)
		UpdateFont(bar.name)
		-- Perc
		bar.perc:SetPoint("RIGHT", bar, -2, 0)
		UpdateFont(bar.perc)
		-- Value
		-- bar.val:SetPoint("RIGHT", bar, -40, 0)
		bar.val:SetPoint("RIGHT", bar, -(C.font.size * 3.5), 0)
		UpdateFont(bar.val)

		-- Adjust Name
		bar.name:SetPoint("RIGHT", bar.val, "LEFT", -10, 0) -- right point of name is left point of value
	end
end

-----------------------------
-- TEST MODE
-----------------------------
function TC2:TestMode()
	if InCombatLockdown() then return end

	C.frame.test = true
	wipe(TC2.threatData)
	for i = 1, C.bar.count do
		self.threatData[i] = {
			unit = self.playerName,
			scaledPercent = i / C.bar.count * 100,
			threatValue = i * 1e4,
		}
		tinsert(self.bars, i)
	end
	self:UpdateThreatBars()
end

-----------------------------
-- NAMEPLATES
-----------------------------
local function UpdateNameplateThreat(self)
	if not InCombatLockdown() or not C.general.nameplateThreat then return end
	local unit = self.unit
	if not unit then return end
	if not unit:match("nameplate%d?$") then return end
	if UnitIsPlayer(unit) or UnitIsFriend("player", unit) then return end -- prevent coloring player/friendly NPC nameplates
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	if not nameplate then return end
	local status = UnitThreatSituation("player", unit)
	if status then
		if C.general.invertColors then
			if status == 3 then
				status = 0
			elseif status == 0 then
				status = 3
			end
		end
		self.healthBar:SetStatusBarColor(unpack(TC2.threatColors[status]))
	end
end

if TC2.classic then
	-- since UNIT_THREAT_LIST_UPDATE isn't a thing in Classic, health color doesn't update nearly as frequently
	-- we'll instead hook the range check since it is OnUpdate - gross, but it works for now
	hooksecurefunc("CompactUnitFrame_UpdateInRange", UpdateNameplateThreat)
else
	hooksecurefunc("CompactUnitFrame_UpdateHealthColor", UpdateNameplateThreat)
	hooksecurefunc("CompactUnitFrame_UpdateAggroFlash", UpdateNameplateThreat)
end

-----------------------------
-- VERSION CHECK
-----------------------------
local group = {}
local groupSort = {}

local function CheckVersion(onlyOutdated)
	if onlyOutdated then
		print(L.version_list_outdated)
	else
		print(L.version_list)
	end
	local latestRevision = ThreatLib.latestSeenRevision
	local revisions = ThreatLib.partyMemberRevisions
	local agents = ThreatLib.partyMemberAgents
	for k, _ in pairs(group) do
		group[k] = nil
	end
	if TC2.numGroupMembers > 0 then
		local unit = IsInRaid() and "raid" or "party"
		for i = 1, TC2.numGroupMembers do
			local name = UnitName(unit .. i)
			if name then
				group[name] = true
			end
		end
		for i = 1, #groupSort do
			tremove(groupSort)
		end
		for k, _ in pairs(group) do
			tinsert(groupSort, k)
		end
		table.sort(groupSort)
		print(L.version_divider)
		for _, v in ipairs(groupSort) do
			if not onlyOutdated or (not revisions[v] or revisions[v] < (latestRevision or 0)) then
				print(("%s: %s / %s %s"):format(v, agents[v] or ("|cff666666" .. UNKNOWN .. "|r"), revisions[v] or ("|cff666666" .. UNKNOWN .. "|r"), ThreatLib:IsCompatible(v) and "" or " - |cffff0000" .. L.version_incompatible))
			end
		end
	end
end

local function NotifyOldClients()
	if not ThreatLib:IsGroupOfficer("player") then
		print(L.message_leader)
		return
	end
	local latestRevision = ThreatLib.latestSeenRevision
	local revisions = ThreatLib.partyMemberRevisions
	local agents = ThreatLib.partyMemberAgents
	if TC2.numGroupMembers > 0 then
		local unit = IsInRaid() and "raid" or "party"
		for i = 1, TC2.numGroupMembers do
			local name = UnitName(unit .. i)
			if name then
				if ThreatLib:IsCompatible(name) then
					if revisions[name] and revisions[name] < latestRevision then
						SendChatMessage(L.message_outdated, "WHISPER", nil, name)
					end
				else
					SendChatMessage(L.message_incompatible, "WHISPER", nil, name)
				end
			end
		end
	end
end

--[[
local function CheckVersionOLD(self, event, prefix, msg, channel, sender)
	if event == "CHAT_MSG_ADDON" then
		if prefix ~= "TC2Ver" or sender == playerName then return end
		if tonumber(msg) ~= nil and tonumber(msg) > tonumber(TC2.version) then
			print("|cffff0000"..L.outdated.."|r")
			self.frame:UnregisterEvent("CHAT_MSG_ADDON")
		end
	else
		if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			C_ChatInfo.SendAddonMessage("TC2Ver", tonumber(TC2.version), "INSTANCE_CHAT")
		elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
			C_ChatInfo.SendAddonMessage("TC2Ver", tonumber(TC2.version), "RAID")
		elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
			C_ChatInfo.SendAddonMessage("TC2Ver", tonumber(TC2.version), "PARTY")
		elseif IsInGuild() then
			C_ChatInfo.SendAddonMessage("TC2Ver", tonumber(TC2.version), "GUILD")
		end
	end
end
--]]

-----------------------------
-- EVENTS
-----------------------------
TC2.frame = CreateFrame("Frame", TC2.addonName.."BarFrame", UIParent)

TC2.frame:RegisterEvent("PLAYER_LOGIN")
TC2.frame:SetScript("OnEvent", function(self, event, ...)
	return TC2[event] and TC2[event](TC2, event, ...)
end)

function TC2:PLAYER_ENTERING_WORLD(...)
	self.playerName = UnitName("player")

	self.numGroupMembers = IsInRaid() and GetNumGroupMembers() or GetNumSubgroupMembers()

	-- CheckVersionOLD(self, ...)
	CheckStatus()
end

function TC2:PLAYER_TARGET_CHANGED(...)
	C.frame.test = false
	CheckStatus()
end

function TC2:GROUP_ROSTER_UPDATE(...)
	self.numGroupMembers = IsInRaid() and GetNumGroupMembers() or GetNumSubgroupMembers()

	-- CheckVersionOLD(self, ...)
	CheckStatus()
end

function TC2:PLAYER_REGEN_DISABLED(...)
	C.frame.test = false
	ThreatLib.RegisterCallback(self, "ThreatUpdated", CheckStatus)
	CheckStatus()
end

function TC2:PLAYER_REGEN_ENABLED(...)
	-- collectgarbage()
	C.frame.test = false
	ThreatLib.UnregisterCallback(self, "ThreatUpdated", CheckStatus)
	CheckStatus()
end

function TC2:UNIT_THREAT_LIST_UPDATE(...)
	C.frame.test = false
	CheckStatus()
end

function TC2:PLAYER_LOGIN()
	-- C_ChatInfo.RegisterAddonMessagePrefix("TC2Ver")

	TC2_Options = TC2_Options or {}
	C = CopyDefaults(self.defaultConfig, TC2_Options)

	-- Minimum of 1 Row
	if not C.bar.count or C.bar.count < 1 then
		C.bar.count = 1
	end

	-- Adjust C.bar.count if it exceed the frame height
	local maxBarCount = floor(C.frame.height / (C.bar.height + C.bar.padding - 1))
	if C.bar.count > maxBarCount then C.bar.count = maxBarCount end

	-- Adjust fonts for CJK
	if self.locale == "koKR" or self.locale == "zhCN" or self.locale == "zhTW" then
		C.font.family = _G.STANDARD_TEXT_FONT
	end

	self:SetupUnits()
	self:SetupFrame()
	self:SetupMenu()

	-- Get Colors
	TC2.colorFallback = {0.8, 0, 0.8, C.bar.alpha}

	TC2.threatColors = {
		[0] = C.general.threatColors.good,
		[1] = C.general.threatColors.neutral,
		[2] = C.general.threatColors.neutral,
		[3] = C.general.threatColors.bad
	}

	-- Test Mode
	C.frame.test = false

	if C.general.welcome then
		print("|c00FFAA00"..self.addonName.." v"..self.version.." - "..L.message_welcome.."|r")
	end

	self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
	-- self.frame:RegisterEvent("CHAT_MSG_ADDON")
	self.frame:RegisterEvent("PLAYER_TARGET_CHANGED")
	self.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")

	if self.classic then
		ThreatLib.RegisterCallback(self, "Activate", CheckStatus)
		ThreatLib.RegisterCallback(self, "Deactivate", CheckStatus)
		ThreatLib.RegisterCallback(self, "ThreatUpdated", CheckStatus)
		ThreatLib:RequestActiveOnSolo(true)
	else
		self.frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
	end

	-- Setup Config
	self:SetupConfig()

	self.frame:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end

-----------------------------
-- SETUP
-----------------------------
function TC2:SetupUnits()
	self.partyUnits = {}
	self.partyPetUnits = {}
	self.raidUnits = {}
	self.raidPetUnits = {}
	for i = 1, 4 do
		self.partyUnits[i] = format("party%d", i)
		self.partyPetUnits[i] = format("partypet%d", i)
	end
	for i = 1, 40 do
		self.raidUnits[i] = format("raid%d", i)
		self.raidPetUnits[i] = format("raidpet%d", i)
	end
end

function TC2:SetupFrame()
	self.frame:SetFrameLevel(1)
	self.frame:ClearAllPoints()
	self.frame:SetPoint(unpack(C.frame.position))

	self.frame.bg = self.frame:CreateTexture(nil, "BACKGROUND", nil, -8)
	self.frame.bg:SetColorTexture(1, 1, 1, 1)

	self.frame.resize = CreateFrame("Frame", self.addonName.."Resize", self.frame)
	self.frame.resize:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 0, 0)
	self.frame.resize:SetSize(12, 12)
	self.frame.resizeTexture = self.frame.resize:CreateTexture()
	self.frame.resizeTexture:SetTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Up]])
	self.frame.resizeTexture:SetDesaturated(true)
	self.frame.resizeTexture:SetPoint("TOPLEFT", self.frame.resize)
	self.frame.resizeTexture:SetPoint("BOTTOMRIGHT", self.frame.resize, "BOTTOMRIGHT", 0, 0)

	-- Setup Header
	self.frame.header = CreateStatusBar(self.frame, true)
	self.frame.header:SetScript("OnMouseUp", function(self, button)
		if button == "RightButton" then
			EasyMenu(TC2.menuTable, TC2.menu, "cursor", 0, 0, "MENU")
		end
	end)
	self.frame.header:EnableMouse(true)

	self.frame.header.text = CreateFS(self.frame.header)
	self.frame.header.text:SetPoint("LEFT", self.frame.header, 4, -1)
	self.frame.header.text:SetJustifyH("LEFT")

	self:UpdateFrame()
end

function TC2:SetupMenu()
	self.menu = CreateFrame("Frame", self.addonName.."MenuFrame", UIParent, "UIDropDownMenuTemplate")

	TC2.menuTable = {
		{text = L.frame_lock, notCheckable = false, checked = function() return C.frame.locked end, func = function()
			C.frame.locked = not C.frame.locked
			TC2:UpdateFrame()
		end},
		{text = L.frame_test, notCheckable = false, checked = function() return C.frame.test end, func = function()
			C.frame.test = not C.frame.test
			if C.frame.test then
				TC2:TestMode()
			else
				CheckStatus()
			end
		end},
		{text = L.version_check_all, notCheckable = true, func = function()
			CheckVersion()
		end},
		{text = L.version_check, notCheckable = true, func = function()
			CheckVersion(true)
		end},
		{text = L.gui_config, notCheckable = true, func = function()
			LibStub("AceConfigDialog-3.0"):Open("ThreatClassic2")
		end},
	}
end

-----------------------------
-- CONFIG
-----------------------------
function TC2:SetupConfig()
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(TC2.addonName, self.configTable)

	local ACD = LibStub("AceConfigDialog-3.0")
	self.config = {}
	self.config.general = ACD:AddToBlizOptions(TC2.addonName, TC2.addonName, nil, "general")
	self.config.appearance = ACD:AddToBlizOptions(TC2.addonName, L.appearance, TC2.addonName, "appearance")
	-- self.config.warnings = ACD:AddToBlizOptions(TC2.addonName, L.warnings, TC2.addonName, "warnings")
	self.config.version = ACD:AddToBlizOptions(TC2.addonName, L.version, TC2.addonName, "version")
end

TC2.configTable = {
	type = "group",
	name = TC2.addonName,
	get = function(info)
		return C[info[1]][info[2]]
	end,
	set = function(info, value) C[info[1]][info[2]] = value end,
	args = {
		general = {
			order = 1,
			type = "group",
			name = L.general,
			args = {
				general = {
					order = 1,
					name = L.general,
					type = "header",
				},
				welcome = {
					order = 2,
					name = L.general_welcome,
					type = "toggle",
					width = "full",
				},
				--[[
				minimap = {
					order = 3,
					name = L.general_test,
					type = "toggle",
					width = "full",
				},
				--]]
				--[[
				ignorePets = {
					order = 4,
					name = L.general_ignorePets,
					type = "toggle",
					width = "full",
				},
				--]]
				visibility = {
					order = 5,
					name = L.visibility,
					type = "header",
				},
				hideOOC = {
					order = 6,
					name = L.visibility_hideOOC,
					type = "toggle",
					width = "full",
					set = function(info, value)
						C[info[1]][info[2]] = value
						CheckStatus()
					end,
				},
				hideSolo = {
					order = 7,
					name = L.visibility_hideSolo,
					type = "toggle",
					width = "full",
					set = function(info, value)
						C[info[1]][info[2]] = value
						CheckStatus()
					end,
				},
				hideInPVP = {
					order = 8,
					name = L.visibility_hideInPvP,
					type = "toggle",
					width = "full",
					set = function(info, value)
						C[info[1]][info[2]] = value
						CheckStatus()
					end,
				},
				hideAlways = {
					order = 9,
					name = L.visibility_hideAlways,
					type = "toggle",
					width = "full",
					set = function(info, value)
						C[info[1]][info[2]] = value
						CheckStatus()
					end,
				},
				nameplates = {
					order = 10,
					name = L.nameplates,
					type = "header",
				},
				nameplateThreat = {
					order = 11,
					name = L.nameplates_enable,
					type = "toggle",
					width = "full",
				},
				invertColors = {
					order = 12,
					name = L.nameplates_invert,
					type = "toggle",
					width = "full",
				},
				threatColors = {
					order = 13,
					name = L.nameplates_colors,
					type = "group",
					inline = true,
					get = function(info)
						return unpack(C[info[1]][info[2]][info[3]])
					end,
					set = function(info, r, g, b)
						local cfg = C[info[1]][info[2]][info[3]]
						cfg[1] = r
						cfg[2] = g
						cfg[3] = b
					end,

					args = {
						good = {
							order = 1,
							name = L.color_good,
							type = "color",
							hasAlpha = false,
						},
						neutral = {
							order = 2,
							name = L.color_neutral,
							type = "color",
							hasAlpha = false,
						},
						bad = {
							order = 3,
							name = L.color_bad,
							type = "color",
							hasAlpha = false,
						},
					},
				},
			},
		},
		appearance = {
			order = 2,
			type = "group",
			name = L.appearance,
			get = function(info)
				return C[info[2]][info[3]]
			end,
			set = function(info, value)
				C[info[2]][info[3]] = value
				C.frame.height = ((C.bar.height + C.bar.padding - 1) * C.bar.count) - C.bar.padding
				TC2:UpdateFrame()
			end,
			args = {
				frame = {
					order = 1,
					name = L.frame,
					type = "group",
					inline = true,
					args = {
						test = {
							order = 1,
							name = L.frame_test,
							type = "execute",
							func = function(info, value)
								C.frame.test = not C.frame.test
								if C.frame.test then
									TC2:TestMode()
								else
									CheckStatus()
								end
							end,
						},
						locked = {
							order = 2,
							name = L.frame_lock,
							type = "toggle",
						},
						strata = {
							order = 3,
							name = L.frame_strata,
							type = "select",
							values = {
								["1-BACKGROUND"] = "BACKGROUND",
								["2-LOW"] = "LOW",
								["3-MEDIUM"] = "MEDIUM",
								["4-HIGH"] = "HIGH",
								["5-DIALOG"] = "DIALOG",
								["6-FULLSCREEN"] = "FULLSCREEN",
								["7-FULLSCREEN_DIALOG"] = "FULLSCREEN_DIALOG",
								["8-TOOLTIP"] = "TOOLTIP",
							},
							style = "dropdown",
						},
						-- width here
						headerShow = {
							order = 4,
							name = L.frame_headerShow,
							type = "toggle",
						},
						scale = {
							order = 5,
							name = L.frame_scale,
							type = "range",
							min = 50,
							max = 300,
							step = 1,
							bigStep = 10,
							get = function(info)
								return C[info[2]][info[3]] * 100
							end,
							set = function(info, value)
								C[info[2]][info[3]] = value / 100
								TC2:UpdateFrame()
							end,
						},
						frameColors = {
							order = 6,
							name = L.color,
							type = "group",
							inline = true,
							get = function(info)
								return unpack(C[info[2]][info[4]])
							end,
							set = function(info, r, g, b, a)
								local cfg = C[info[2]][info[4]]
								cfg[1] = r
								cfg[2] = g
								cfg[3] = b
								cfg[4] = a
								TC2:UpdateFrame()
							end,

							args = {
								color = {
									order = 1,
									name = L.frame_bg,
									type = "color",
									hasAlpha = true,
								},
								headerColor = {
									order = 2,
									name = L.frame_header,
									type = "color",
									hasAlpha = true,
								},
							},
						},
					},
				},
				bar = {
					order = 2,
					name = L.bar,
					type = "group",
					inline = true,
					args = {
						count = {
							order = 1,
							name = L.bar_count,
							type = "range",
							min = 1,
							max = 40,
							step = 1,
							set = function(info, value)
								local prev = C[info[2]][info[3]]
								C[info[2]][info[3]] = value
								if prev > value then
									for i = value + 1, prev do
										TC2.bars[i]:Hide()
									end
								end
								C.frame.height = ((C.bar.height + C.bar.padding - 1) * C.bar.count) - C.bar.padding
								TC2:UpdateFrame()
							end,
						},
						-- growth direction
						height = {
							order = 3,
							name = L.bar_height,
							type = "range",
							min = 6,
							max = 64,
							step = 1,
						},
						padding = {
							order = 4,
							name = L.bar_padding,
							type = "range",
							min = 0,
							max = 16,
							step = 1,
						},
						
						-- marker
						-- texture
						-- custom color / class color
						-- alpha (for when using class colors)
						-- color / colormod
					},
				},
				playerBarCustomColor = {
					order = 3,
					name = L.playerBarCustomColor,
					type = "group",
					inline = true,
					args = {
						enabled = {
							order = 1,
							name = L.playerBarCustomColor_enabled,
							type = "toggle",
						},
						barColor = {
							order = 2,
							name = L.color,
							type = "group",
							inline = false,
							get = function(info)
								return unpack(C[info[2]][info[4]])
							end,
							set = function(info, r, g, b, a)
								local cfg = C[info[2]][info[4]]
								cfg[1] = r
								cfg[2] = g
								cfg[3] = b
								cfg[4] = a
								TC2:UpdateFrame()
							end,
							
							args = {
								color = {
									order = 1,
									name = L.playerBarCustomColor_color,
									type = "color",
									hasAlpha = true,
								},
							},
						},
					},
				},
				font = {
					order = 4,
					name = L.font,
					type = "group",
					inline = true,
					args = {
						-- name
						size = {
							order = 2,
							name = L.font_size,
							type = "range",
							min = 6,
							max = 64,
							step = 1,
						},
						style = {
							order = 3,
							name = L.font_style,
							type = "select",
							values = {
								[""] = "NONE",
								["OUTLINE"] = "OUTLINE",
								["THICKOUTLINE"] = "THICKOUTLINE",
							},
							style = "dropdown",
						},
						shadow = {
							order = 4,
							name = L.font_shadow,
							type = "toggle",
							width = "full",
						},
					},
				},
				reset = {
					order = 5,
					name = L.reset,
					type = "execute",
					func = function(info, value)
						TC2_Options = {}
						C = CopyDefaults(TC2.defaultConfig, TC2_Options)
						TC2:UpdateFrame()
					end,
				},
			},
		},
		--[[
		warnings = {
			order = 3,
			type = "group",
			name = L.warnings,
			args = {
				visual = {
					order = 1,
					name = L.warnings_visual,
					type = "toggle",
					width = "full",
				},
				sounds = {
					order = 2,
					name = L.warnings_sounds,
					type = "toggle",
					width = "full",
				},
				threshold = {
					order = 3,
					name = L.warnings_threshold,
					type = "range",
					min = 50,
					max = 100,
					step = 1,
					bigStep = 10,
					-- get / set
				},
				warningFile = {
					order = 4,
					name = L.sound_warningFile,
					type = "toggle",
					width = "full",
				},
				pulledFile = {
					order = 5,
					name = L.sound_pulledFile,
					type = "toggle",
					width = "full",
				},
			},
		},
		--]]
		version = {
			order = 4,
			type = "group",
			name = L.version,
			args = {
				version = {
					order = 1,
					name = L.version,
					type = "header",
				},
				version_check = {
					order = 2,
					name = L.version_check,
					type = "execute",
					func = function(info, value)
						CheckVersion()
					end,
				},
				version_check_all = {
					order = 3,
					name = L.version_check_all,
					type = "execute",
					func = function(info, value)
						CheckVersion(true)
					end,
				},
				version_notify = {
					order = 4,
					name = L.version_notify,
					type = "execute",
					func = function(info, value)
						NotifyOldClients()
					end,
				},
			},
		},
	},
}

SLASH_TC2_SLASHCMD1 = "/tc2"
SLASH_TC2_SLASHCMD2 = "/threat2"
SLASH_TC2_SLASHCMD2 = "/threatclassic2"
SlashCmdList["TC2_SLASHCMD"] = function(arg)
	if arg == "toggle" then
		C.general.hideAlways = not C.general.hideAlways
		CheckStatus();
	else
		LibStub("AceConfigDialog-3.0"):Open("ThreatClassic2")
	end	
end
