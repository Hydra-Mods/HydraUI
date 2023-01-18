local HydraUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local Cooldowns = HydraUI:NewModule("Cooldowns")

-- Default settings values
Defaults["cooldowns-enable"] = true
Defaults["cooldowns-size"] = 60
Defaults["cooldowns-hold"] = 1.4
Defaults["cooldowns-text"] = false

local GetItemCooldown = GetItemCooldown
local GetSpellCooldown = GetSpellCooldown
local GetSpellTexture = GetSpellTexture
local GetItemInfo = GetItemInfo
local GetTime = GetTime
local tinsert = table.insert
local tremove = table.remove

if C_Container then
	GetItemCooldown = C_Container.GetItemCooldown
end

local ActiveCount = 0
local MinTreshold = 14
local Running = false
local Elapsed = 0
local Delay = 0.33
local ActiveSpells = {}
local ActiveItems = {}
local ItemTables = {}
local Spells = {}
local Remaining
local SpellName
local Now
local ContainerItemID

if C_Container then
	ContainerItemID = C_Container.GetContainerItemID
else
	ContainerItemID = GetContainerItemID
end

Cooldowns.Blacklist = {
	item = {
		[6948] = true, -- Hearthstone
		[140192] = true, -- Dalaran Hearthstone
		[110560] = true, -- Garrison Hearthstone
	},

	player = {
		[125439] = true, -- Revive Battle Pets
	},
}

Cooldowns.TextureFilter = {
	[136235] = true
}

function Cooldowns:GetTexture(cd, id)
	local Texture

	if (cd == "item") then
		Texture = select(10, GetItemInfo(id))
	else
		Texture = GetSpellTexture(id)
	end

	if (not self.TextureFilter[Texture]) then
		return Texture
	end
end

function Cooldowns:OnUpdate(ela)
	Elapsed = Elapsed + ela

	if (Elapsed < Delay) then
		return
	end

	Now = GetTime()
	local ID

	if (#ActiveSpells > 0) then
		for i = #ActiveSpells, 1, -1 do
			ID = ActiveSpells[i]

			local Start, Duration = GetSpellCooldown(ID)

			if (Start ~= nil) then
				Remaining = Start + Duration - Now

				if (Remaining <= 0) then
					local Texture = self:GetTexture("spell", ID)

					if Texture then
						self.Icon:SetTexture(Texture)
						self.AnimIn:Play()
						self.Hold:Play()

						if Settings["cooldowns-text"] then
							SpellName = GetSpellInfo(ID)

							if SpellName then
								self.Text:SetText(format(Language["|cff%s%s|r is ready!"], Settings["ui-widget-color"], SpellName))

								SpellName = nil
							end
						else
							self.Text:SetText("")
						end
					end

					tremove(ActiveSpells, i)
					ActiveCount = ActiveCount - 1
				end
			end
		end
	end

	if (#ActiveItems > 0) then
		for i = #ActiveItems, 1, -1 do
			local Info = ActiveItems[i]
			local Start, Duration = GetItemCooldown(Info.ID)

			if (Start ~= nil) then
				if (Info.Dur == 0 and Duration > MinTreshold) then
					Info.Dur = Duration
				elseif (Info.Dur > 0 and Duration == 0) then
					local Texture = self:GetTexture("item", Info.ID)

					if Texture then
						self.Icon:SetTexture(Texture)
						self.AnimIn:Play()
						self.Hold:Play()

						if Settings["cooldowns-text"] then
							SpellName = GetItemInfo(Info.ID)

							if SpellName then
								self.Text:SetText(format(Language["|cff%s%s|r is ready!"], Settings["ui-widget-color"], SpellName))

								SpellName = nil
							end
						else
							self.Text:SetText("")
						end
					end

					tinsert(ItemTables, tremove(ActiveItems, i))
					ActiveCount = ActiveCount - 1
				end
			end
		end
	end

	if (ActiveCount <= 0) then
		self:SetScript("OnUpdate", nil)
		Running = false
	end

	Elapsed = 0
end

-- UNIT_SPELLCAST_SUCCEEDED fetches casts, and then SPELL_UPDATE_COOLDOWN checks them after the GCD is done (Otherwise GetSpellCooldown detects GCD)
function Cooldowns:SPELL_UPDATE_COOLDOWN()
	for i = #Spells, 1, -1 do
		local Start, Duration = GetSpellCooldown(Spells[i])

		if (Duration >= MinTreshold) then
			tinsert(ActiveSpells, Spells[i])
			ActiveCount = ActiveCount + 1

			if (ActiveCount > 0 and not Running) then
				self:SetScript("OnUpdate", self.OnUpdate)
				Running = true
			end
		end

		tremove(Spells, i)
	end
end

function Cooldowns:UNIT_SPELLCAST_SUCCEEDED(unit, guid, id)
	if (unit == "player") then
		if self.Blacklist["player"][id] then
			return
		end

		tinsert(Spells, id)
	end
end

local StartItem = function(id)
	if Cooldowns.Blacklist["item"][id] then
		return
	end

	local Info = ItemTables[1] and tremove(ItemTables, 1) or {}

	Info.ID = id
	Info.Dur = 0

	tinsert(ActiveItems, Info)
	ActiveCount = ActiveCount + 1

	if (ActiveCount > 0 and not Running) then
		Cooldowns:SetScript("OnUpdate", Cooldowns.OnUpdate)
		Running = true
	end
end

local UseAction = function(slot)
	local ActionType, ItemID = GetActionInfo(slot)

	if (ActionType == "item") then
		StartItem(ItemID)
	end
end

local UseInventoryItem = function(slot)
	local ItemID = GetInventoryItemID("player", slot)

	if ItemID then
		StartItem(ItemID)
	end
end

local UseContainerItem = function(bag, slot)
	local ItemID = ContainerItemID(bag, slot)

	if ItemID then
		StartItem(ItemID)
	end
end

local OnFinished = function(self)
	self.Parent.AnimOut:Play()
end

function Cooldowns:OnEvent(event, ...)
	self[event](self, ...)
end

function Cooldowns:Load()
	if (not Settings["cooldowns-enable"]) then
		return
	end

	self.Anchor = CreateFrame("Frame", "HydraUI Cooldown Flash", HydraUI.UIParent)
	self.Anchor:SetSize(Settings["cooldowns-size"], Settings["cooldowns-size"])
	self.Anchor:SetPoint("CENTER", HydraUI.UIParent, "CENTER", 0, 100)

	self:SetSize(Settings["cooldowns-size"], Settings["cooldowns-size"])
	self:SetPoint("CENTER", self.Anchor, "CENTER", 0, 0)
	self:SetBackdrop(HydraUI.Backdrop)
	self:SetFrameStrata("HIGH")
	self:SetBackdropColor(0, 0, 0)
	self:SetAlpha(0)

	self.Icon = self:CreateTexture(nil, "OVERLAY")
	self.Icon:SetPoint("TOPLEFT", self, 1, -1)
	self.Icon:SetPoint("BOTTOMRIGHT", self, -1, 1)
	self.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

	self.Text = self:CreateFontString(nil, "OVERLAY")
	self.Text:SetPoint("TOP", self, "BOTTOM", 0, -5)
	HydraUI:SetFontInfo(self.Text, Settings["ui-widget-font"], 16)
	self.Text:SetWidth(Settings["cooldowns-size"] * 2.5)
	self.Text:SetJustifyH("CENTER")

	self.Anim = CreateAnimationGroup(self)

	self.AnimIn = self.Anim:CreateAnimation("Fade")
	self.AnimIn:SetChange(1)
	self.AnimIn:SetDuration(0.2)
	self.AnimIn:SetEasing("in")

	self.AnimOut = self.Anim:CreateAnimation("Fade")
	self.AnimOut:SetChange(0)
	self.AnimOut:SetDuration(0.6)
	self.AnimOut:SetEasing("out")

	self.Hold = self.Anim:CreateAnimation("Sleep")
	self.Hold:SetDuration(Settings["cooldowns-hold"] + 0.2)
	self.Hold:SetScript("OnFinished", OnFinished)

	HydraUI:CreateMover(self.Anchor)

	self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:SetScript("OnEvent", self.OnEvent)

	hooksecurefunc("UseAction", UseAction)
	hooksecurefunc("UseInventoryItem", UseInventoryItem)

	if (C_Container and C_Container.UseContainerItem) then
		hooksecurefunc(C_Container, "UseContainerItem", UseContainerItem)
	elseif (UseContainerItem and type(UseContainerItem) == "function") then
		hooksecurefunc("UseContainerItem", UseContainerItem)
	end
end

local UpdateEnableCooldownFlash = function(value)
	if value then
		Cooldowns:RegisterEvent("SPELL_UPDATE_COOLDOWN")
		Cooldowns:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	else
		Cooldowns:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
		Cooldowns:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	end
end

local UpdateCooldownSize = function(value)
	Cooldowns:SetSize(value, value)
	Cooldowns.Anchor:SetSize(value, value)
end

local UpdateCooldownHold = function(value)
	Cooldowns.Hold:SetDuration(value + 0.2)
end

local TestCooldown = function()
	if Settings["cooldowns-text"] then
		Cooldowns.Text:SetText(format(Language["|cff%s%s|r is ready!"], Settings["ui-widget-color"], GetItemInfo(6948)))
	else
		Cooldowns.Text:SetText("")
	end

	Cooldowns.Icon:SetTexture(select(10, GetItemInfo(6948)))
	Cooldowns.AnimIn:Play()
	Cooldowns.Hold:Play()
end

HydraUI:GetModule("GUI"):AddWidgets(Language["General"], Language["General"], function(left, right)
	right:CreateHeader(Language["Cooldown Alert"])
	right:CreateSwitch("cooldowns-enable", Settings["cooldowns-enable"], Language["Enable Cooldown Alert"], Language["When an ability comes off cooldown the icon will flash as an alert"], UpdateEnableCooldownFlash)
	right:CreateSwitch("cooldowns-text", Settings["cooldowns-text"], Language["Enable Cooldown Text"], Language["Display text on the cooldown alert"])
	right:CreateSlider("cooldowns-size", Settings["cooldowns-size"], 18, 100, 2, Language["Set Size"], Language["Set the size of the cooldown alert"], UpdateCooldownSize)
	right:CreateSlider("cooldowns-hold", Settings["cooldowns-hold"], 0.2, 3, 0.1, Language["Set Hold Time"], Language["Set how long the alert will display before fading away"], UpdateCooldownHold, nil, "s")
	right:CreateButton("", Language["Test"], Language["Test Cooldown"], Language["Test the cooldown alert"], TestCooldown)
end)