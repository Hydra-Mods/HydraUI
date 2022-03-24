local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

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
local pairs = pairs

Cooldowns.Spells = {}
Cooldowns.ActiveCount = 0
Cooldowns.MinTreshold = 14
Cooldowns.Running = false
Cooldowns.Elapsed = 0

local CurrentTime
local Remaining
local SpellName
local Delay = 0.5

Cooldowns.ActiveCDs = {
	["item"] = {},
	["player"] = {},
}

Cooldowns.Blacklist = {
	["item"] = {
		[6948] = true, -- Hearthstone
		[140192] = true, -- Dalaran Hearthstone
		[110560] = true, -- Garrison Hearthstone
	},
	
	["player"] = {
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
	self.Elapsed = self.Elapsed + ela
	
	if (self.Elapsed < Delay) then
		return
	end
	
	CurrentTime = GetTime()
	
	for CDType, Data in pairs(self.ActiveCDs) do
		for Position, ID in pairs(Data) do
			local Start, Duration = ((CDType == "item") and GetItemCooldown or GetSpellCooldown)(ID)
			
			if (Start ~= nil) then
				Remaining = Start + Duration - CurrentTime
				
				if (Remaining <= 0) then
					local Texture = self:GetTexture(CDType, ID)
					
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
					
					tremove(Data, Position)
					self.ActiveCount = self.ActiveCount - 1
				end
			end
		end
	end
	
	if (self.ActiveCount <= 0) then
		self:SetScript("OnUpdate", nil)
		self.Running = false
	end
	
	self.Elapsed = 0
end

-- UNIT_SPELLCAST_SUCCEEDED fetches casts, and then SPELL_UPDATE_COOLDOWN checks them after the GCD is done (Otherwise GetSpellCooldown detects GCD)
function Cooldowns:SPELL_UPDATE_COOLDOWN()
	for i = #self.Spells, 1, -1 do
		local Start, Duration = GetSpellCooldown(self.Spells[i])
		
		if (Duration >= self.MinTreshold) then
			tinsert(self.ActiveCDs.player, self.Spells[i])
			self.ActiveCount = self.ActiveCount + 1
			
			if (self.ActiveCount > 0 and not self.Running) then
				self:SetScript("OnUpdate", self.OnUpdate)
				self.Running = true
			end
		end
		
		tremove(self.Spells, i)
	end
end

function Cooldowns:UNIT_SPELLCAST_SUCCEEDED(unit, guid, id)
	if (unit == "player") then
		if self.Blacklist["player"][id] then
			return
		end
		
		tinsert(self.Spells, id)
	end
end

local StartItem = function(id)
	if Cooldowns.Blacklist["item"][id] then
		return
	end
	
	local Start, Duration = GetItemCooldown(id)
	
	if (Duration and Duration > Cooldowns.MinTreshold) then
		tinsert(Cooldowns.ActiveCDs.item, id)
		Cooldowns.ActiveCount = Cooldowns.ActiveCount + 1
		
		if (Cooldowns.ActiveCount > 0 and not Cooldowns.Running) then
			Cooldowns:SetScript("OnUpdate", Cooldowns.OnUpdate)
			Cooldowns.Running = true
		end
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
	local ItemID = GetContainerItemID(bag, slot)
	
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
	hooksecurefunc("UseContainerItem", UseContainerItem)
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

GUI:AddWidgets(Language["General"], Language["General"], function(left, right)
	right:CreateHeader(Language["Cooldown Alert"])
	right:CreateSwitch("cooldowns-enable", Settings["cooldowns-enable"], Language["Enable Cooldown Alert"], Language["When an ability comes off cooldown the icon will flash as an alert"], UpdateEnableCooldownFlash)
	right:CreateSwitch("cooldowns-text", Settings["cooldowns-text"], Language["Enable Cooldown Text"], Language["Display text on the cooldown alert"])
	right:CreateSlider("cooldowns-size", Settings["cooldowns-size"], 18, 100, 2, Language["Set Size"], Language["Set the size of the cooldown alert"], UpdateCooldownSize)
	right:CreateSlider("cooldowns-hold", Settings["cooldowns-hold"], 0.2, 3, 0.1, Language["Set Hold Time"], Language["Set how long the alert will display before fading away"], UpdateCooldownHold, nil, "s")
end)