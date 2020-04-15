local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Bubbles = vUI:NewModule("Chat Bubbles")

local select = select
local GetAllChatBubbles = C_ChatBubbles.GetAllChatBubbles

function Bubbles:RefreshBubble(bubble)
	local R, G, B = vUI:HexToRGB(Settings["ui-window-main-color"])
	
	vUI:SetFontInfo(bubble.Text, Settings["chat-bubbles-font"], Settings["chat-bubbles-font-size"], Settings["chat-bubbles-font-flags"])
	bubble:SetBackdropColor(R, G, B, Settings["chat-bubbles-opacity"] / 100)
	
	self.NeedsRefresh = false	
end

function Bubbles:SkinBubble(bubble)
	for i = 1, bubble:GetNumRegions() do
		local Region = select(i, bubble:GetRegions())
		
		if Region:IsObjectType("Texture") then
			Region:SetTexture(nil)
		elseif Region:IsObjectType("FontString") then
			vUI:SetFontInfo(Region, Settings["chat-bubbles-font"], Settings["chat-bubbles-font-size"], Settings["chat-bubbles-font-flags"])
			
			bubble.Text = Region
		end
	end
	
	local R, G, B = vUI:HexToRGB(Settings["ui-window-main-color"])
	local Scale = vUI:GetSuggestedScale()
	
	bubble:SetBackdrop(vUI.BackdropAndBorder)
	bubble:SetBackdropColor(R, G, B, Settings["chat-bubbles-opacity"] / 100)
	bubble:SetBackdropBorderColor(0, 0, 0)
	
	bubble:SetScale(Scale)
	
	bubble.Top = bubble:CreateTexture(nil, "OVERLAY")
	vUI:SetHeight(bubble.Top, 2)
	bubble.Top:SetTexture(Media:GetTexture("Blank"))
	vUI:SetVertexColorHex(bubble.Top, Settings["ui-window-bg-color"])
	vUI:SetPoint(bubble.Top, "TOPLEFT", bubble, 1, -1)
	vUI:SetPoint(bubble.Top, "TOPRIGHT", bubble, -1, -1)
	
	bubble.Bottom = bubble:CreateTexture(nil, "OVERLAY")
	vUI:SetHeight(bubble.Bottom, 2)
	bubble.Bottom:SetTexture(Media:GetTexture("Blank"))
	vUI:SetVertexColorHex(bubble.Bottom, Settings["ui-window-bg-color"])
	vUI:SetPoint(bubble.Bottom, "BOTTOMLEFT", bubble, 1, 1)
	vUI:SetPoint(bubble.Bottom, "BOTTOMRIGHT", bubble, -1, 1)
	
	bubble.Left = bubble:CreateTexture(nil, "OVERLAY")
	vUI:SetWidth(bubble.Left, 2)
	bubble.Left:SetTexture(Media:GetTexture("Blank"))
	vUI:SetVertexColorHex(bubble.Left, Settings["ui-window-bg-color"])
	vUI:SetPoint(bubble.Left, "BOTTOMLEFT", bubble, 1, 1)
	vUI:SetPoint(bubble.Left, "TOPLEFT", bubble, 1, -1)
	
	bubble.Right = bubble:CreateTexture(nil, "OVERLAY")
	vUI:SetWidth(bubble.Right, 2)
	bubble.Right:SetTexture(Media:GetTexture("Blank"))
	vUI:SetVertexColorHex(bubble.Right, Settings["ui-window-bg-color"])
	vUI:SetPoint(bubble.Right, "BOTTOMRIGHT", bubble, -1, 1)
	vUI:SetPoint(bubble.Right, "TOPRIGHT", bubble, -1, -1)
	
	bubble.InnerBorder = CreateFrame("Frame", nil, bubble)
	vUI:SetPoint(bubble.InnerBorder, "TOPLEFT", bubble, 3, -3)
	vUI:SetPoint(bubble.InnerBorder, "BOTTOMRIGHT", bubble, -3, 3)
	bubble.InnerBorder:SetBackdrop(vUI.Outline)
	bubble.InnerBorder:SetBackdropBorderColor(0, 0, 0)
	
	bubble.Skinned = true
end

function Bubbles:ScanForBubbles()
	local Bubble
	
	for Index, Bubble in pairs(GetAllChatBubbles()) do
		if self.NeedsRefresh then
			self:RefreshBubble(Bubble)
		elseif (not Bubble.Skinned) then
			self:SkinBubble(Bubble)
		end
	end
end

function Bubbles:OnUpdate(elapsed)
	self.Elapsed = self.Elapsed + elapsed
	
	if (self.Elapsed > 0.15) then
		self:ScanForBubbles()
		
		self.Elapsed = 0
	end
end

function Bubbles:Load()
	if (not Settings["chat-bubbles-enable"]) then
		return
	end
	
	self.Elapsed = 0
	self:SetScript("OnUpdate", self.OnUpdate)
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

GUI:AddOptions(function(self)
	local Left, Right = self:GetWindow(Language["Chat"])
	
	Right:CreateHeader(Language["Chat Bubbles"])
	Right:CreateSwitch("chat-bubbles-enable", Settings["chat-bubbles-enable"], Language["Enable Chat Bubbles Module"], "Enable the vUI chat bubbles module", ReloadUI):RequiresReload(true)
	Right:CreateSlider("chat-bubbles-opacity", Settings["chat-bubbles-opacity"], 0, 100, 5, "Background Opacity", "Set the opacity of the chat bubbles background", SetToRefresh, nil, "%")
	Right:CreateDropdown("chat-bubbles-font", Settings["chat-bubbles-font"], Media:GetFontList(), Language["Font"], "Set the font of the chat bubbles", SetToRefresh, "Font")
	Right:CreateSlider("chat-bubbles-font-size", Settings["chat-bubbles-font-size"], 8, 18, 1, "Font Size", "Set the font size of the chat bubbles", SetToRefresh)
	Right:CreateDropdown("chat-bubbles-font-flags", Settings["chat-bubbles-font-flags"], Media:GetFlagsList(), Language["Font Flags"], "Set the font flags of the chat bubbles", SetToRefresh)
	--Right:CreateDropdown("chat-bubbles-show", Settings["chat-bubbles-show"], {[Language["All"]] = "ALL", [Language["None"]] = "NONE", [Language["Exclude Party"]] = "EXCLUDE_PARTY"}, Language["Show Chat Bubbles"], "Set who to display chat bubbles from", UpdateShowBubbles)
end)