local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local Bubbles = HydraUI:NewModule("Chat Bubbles")

local pairs = pairs
local select = select
local GetAllChatBubbles = C_ChatBubbles.GetAllChatBubbles

Defaults["chat-bubbles-enable"] = true
Defaults["chat-bubbles-opacity"] = 70
Defaults["chat-bubbles-font"] = "PT Sans"
Defaults["chat-bubbles-font-size"] = 14
Defaults["chat-bubbles-font-flags"] = ""

function Bubbles:RefreshBubble(bubble)
	local R, G, B = HydraUI:HexToRGB(Settings["ui-window-main-color"])
	
	HydraUI:SetFontInfo(bubble:GetChildren().Text, Settings["chat-bubbles-font"], Settings["chat-bubbles-font-size"], Settings["chat-bubbles-font-flags"])
	bubble:SetBackdropColor(R, G, B, Settings["chat-bubbles-opacity"] / 100)
	
	self.NeedsRefresh = false	
end

function Bubbles:SkinBubble(bubble)
	local Child = bubble:GetChildren()
	
	if (Child and Child:IsForbidden()) then
		return
	end
	
	Child.Tail:Hide()
	Child:DisableDrawLayer("BORDER")
	
	if Child.SetBackdrop then
		Child:SetBackdrop(nil)
	end
	
	HydraUI:SetFontInfo(Child.String, Settings["chat-bubbles-font"], Settings["chat-bubbles-font-size"], Settings["chat-bubbles-font-flags"])
	
	local R, G, B = HydraUI:HexToRGB(Settings["ui-window-main-color"])
	local Scale = HydraUI:GetSuggestedScale()
	
	bubble.Backdrop = CreateFrame("Frame", nil, Child, "BackdropTemplate")
	bubble.Backdrop:SetPoint("TOPLEFT", Child, 4, -4)
	bubble.Backdrop:SetPoint("BOTTOMRIGHT", Child, -4, 4)
	bubble.Backdrop:SetBackdrop(HydraUI.BackdropAndBorder)
	bubble.Backdrop:SetBackdropColor(R, G, B, Settings["chat-bubbles-opacity"] / 100)
	bubble.Backdrop:SetBackdropBorderColor(0, 0, 0)
	bubble.Backdrop:SetFrameStrata("LOW")
	
	bubble:SetScale(Scale)
	
	bubble.Skinned = true
end

function Bubbles:OnUpdate(elapsed)
	self.Elapsed = self.Elapsed + elapsed
	
	if (self.Elapsed > 0.15) then
		for Index, Bubble in pairs(GetAllChatBubbles()) do
			if self.NeedsRefresh then
				self:RefreshBubble(Bubble)
			elseif (not Bubble.Skinned) then
				self:SkinBubble(Bubble)
			end
		end
		
		self.Elapsed = 0
	end
end

Bubbles.Players = {}

function Bubbles:ScanPlayers()
	if UnitExists("raid1") then
		
	elseif UnitExists("party1") then
		
	end
end

function Bubbles:OnEvent(event)
	local Name, Type = GetInstanceInfo()
	
	if (Type == "none") then
		self:SetScript("OnUpdate", self.OnUpdate)
	else
		self:SetScript("OnUpdate", nil)
	end
end

function Bubbles:Load()
	if (not Settings["chat-bubbles-enable"]) then
		return
	end
	
	self.Elapsed = 0
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:SetScript("OnEvent", self.OnEvent)
	self:OnEvent()
end

local SetToRefresh = function()
	Bubbles.NeedsRefresh = true
end

local UpdateShowBubbles = function(value)
	if (value == "ALL") then
		SetCVar("chatBubbles", 1)
		SetCVar("chatBubblesParty", 1)
	elseif (value == "EXCLUDE_PARTY") then
		SetCVar("chatBubbles", 1)
		SetCVar("chatBubblesParty", 0)
	else -- "NONE"
		SetCVar("chatBubbles", 0)
		SetCVar("chatBubblesParty", 0)
	end
end

GUI:AddWidgets(Language["General"], Language["Chat"], function(left, right)
	right:CreateHeader(Language["Chat Bubbles"])
	right:CreateSwitch("chat-bubbles-enable", Settings["chat-bubbles-enable"], Language["Enable Chat Bubbles"], Language["Enable the HydraUI chat bubbles module"], ReloadUI):RequiresReload(true)
	right:CreateSlider("chat-bubbles-opacity", Settings["chat-bubbles-opacity"], 0, 100, 5, Language["Background Opacity"], Language["Set the opacity of the chat bubbles background"], SetToRefresh, nil, "%")
	right:CreateDropdown("chat-bubbles-font", Settings["chat-bubbles-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the chat bubbles"], SetToRefresh, "Font")
	right:CreateSlider("chat-bubbles-font-size", Settings["chat-bubbles-font-size"], 8, 32, 1, Language["Font Size"], Language["Set the font size of the chat bubbles"], SetToRefresh)
	right:CreateDropdown("chat-bubbles-font-flags", Settings["chat-bubbles-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the chat bubbles"], SetToRefresh)
	--right:CreateDropdown("chat-bubbles-show", Settings["chat-bubbles-show"], {[Language["All"]] = "ALL", [Language["None"]] = "NONE", [Language["Exclude Party"]] = "EXCLUDE_PARTY"}, Language["Show Chat Bubbles"], "Set who to display chat bubbles from", UpdateShowBubbles)
end)