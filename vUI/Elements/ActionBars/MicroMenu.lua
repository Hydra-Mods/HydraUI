local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local MicroButtons = vUI:NewModule("Micro Buttons")
local BagsFrame = vUI:GetModule("Bags Frame")

MicroButtons.Buttons = {
	CharacterMicroButton,
	SpellbookMicroButton,
	TalentMicroButton,
	AchievementMicroButton,
	QuestLogMicroButton,
	GuildMicroButton,
	LFDMicroButton,
	CollectionsMicroButton,
	EJMicroButton,
	StoreMicroButton,
	MainMenuMicroButton,
}

local MicroButtonsButtonOnEnter = function(self)
	if (Settings["micro-buttons-visiblity"] == "MOUSEOVER") then
		self:GetParent():SetAlpha(1)
	end
end

local MicroButtonsButtonOnLeave = function(self)
	if (Settings["micro-buttons-visiblity"] == "MOUSEOVER") then
		self:GetParent():SetAlpha(Settings["micro-buttons-opacity"] / 100)
	end
end

function MicroButtons:UpdateVisibility()
	if (Settings["micro-buttons-visiblity"] == "HIDE") then
		self.Panel:SetScript("OnEnter", nil)
		self.Panel:SetScript("OnLeave", nil)
		self.Panel:SetAlpha(0)
		self.Panel:Hide()
	elseif (Settings["micro-buttons-visiblity"] == "MOUSEOVER") then
		self.Panel:SetScript("OnEnter", BagsFrameOnEnter)
		self.Panel:SetScript("OnLeave", BagsFrameOnLeave)
		self.Panel:SetAlpha(Settings["micro-buttons-opacity"] / 100)
		self.Panel:Show()
	elseif (Settings["micro-buttons-visiblity"] == "SHOW") then
		self.Panel:SetScript("OnEnter", nil)
		self.Panel:SetScript("OnLeave", nil)
		self.Panel:SetAlpha(1)
		self.Panel:Show()
	end
end

function MicroButtons:UpdateMicroButtonsParent()
	for i = 1, #MicroButtons.Buttons do
		MicroButtons.Buttons[i]:SetParent(MicroButtons.Panel)
	end
end

function MicroButtons:MoveMicroButtons()
	for i = 1, #MicroButtons.Buttons do
		MicroButtons.Buttons[i]:ClearAllPoints()
		MicroButtons.Buttons[i]:HookScript("OnEnter", MicroButtonsButtonOnEnter)
		MicroButtons.Buttons[i]:HookScript("OnLeave", MicroButtonsButtonOnLeave)
		
		if (i == 1) then
			MicroButtons.Buttons[i]:SetPoint("LEFT", MicroButtons.Panel, 2, 0)
		else
			MicroButtons.Buttons[i]:SetPoint("LEFT", MicroButtons.Buttons[i-1], "RIGHT", 0, 0)
		end
	end
end

function MicroButtons:Load()
	if (not Settings["ab-enable"]) then
		return
	end
	
	self.Panel = CreateFrame("Frame", "vUI Micro Buttons", vUI.UIParent)
	self.Panel:SetSize(312, 40)
	self.Panel:SetPoint("BOTTOMRIGHT", BagsFrame.Panel, "BOTTOMLEFT", -2, 0)
	self.Panel:SetBackdrop(vUI.BackdropAndBorder)
	self.Panel:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.Panel:SetBackdropBorderColor(0, 0, 0)
	self.Panel:SetFrameStrata("LOW")
	
	vUI:CreateMover(self.Panel)
	
	for i = 1, #self.Buttons do
		self.Buttons[i]:SetParent(self.Panel)
		self.Buttons[i]:ClearAllPoints()
		self.Buttons[i]:HookScript("OnEnter", MicroButtonsButtonOnEnter)
		self.Buttons[i]:HookScript("OnLeave", MicroButtonsButtonOnLeave)
		
		self.Buttons[i].BG = self.Buttons[i]:CreateTexture(nil, "BACKGROUND")
		self.Buttons[i].BG:SetPoint("TOPLEFT", self.Buttons[i], 1, -1)
		self.Buttons[i].BG:SetPoint("BOTTOMRIGHT", self.Buttons[i], -1, 1)
		self.Buttons[i].BG:SetTexture(Assets:GetTexture("Blank"))
		self.Buttons[i].BG:SetVertexColor(0, 0, 0)
		
		local Normal = self.Buttons[i]:GetNormalTexture()
		local Pushed = self.Buttons[i]:GetPushedTexture()
		local Disabled = self.Buttons[i]:GetDisabledTexture()
		local Highlight = self.Buttons[i]:GetHighlightTexture()
		
		Normal:SetTexCoord(0.22, 0.82, 0.22, 0.82)
		Normal:ClearAllPoints()
		Normal:SetPoint("TOPLEFT", self.Buttons[i], 2, -2)
		Normal:SetPoint("BOTTOMRIGHT", self.Buttons[i], -2, 2)
		
		Pushed:SetTexCoord(0.22, 0.82, 0.22, 0.82)
		Pushed:ClearAllPoints()
		Pushed:SetPoint("TOPLEFT", self.Buttons[i], 2, -2)
		Pushed:SetPoint("BOTTOMRIGHT", self.Buttons[i], -2, 2)
		
		if Disabled then
			Disabled:SetTexCoord(0.22, 0.82, 0.22, 0.82)
			Disabled:ClearAllPoints()
			Disabled:SetPoint("TOPLEFT", self.Buttons[i], 2, -2)
			Disabled:SetPoint("BOTTOMRIGHT", self.Buttons[i], -2, 2)
		end
		
		Highlight:ClearAllPoints()
		Highlight:SetPoint("TOPLEFT", self.Buttons[i], 2, -2)
		Highlight:SetPoint("BOTTOMRIGHT", self.Buttons[i], -2, 2)
		Highlight:SetTexture(Assets:GetTexture("Blank"))
		Highlight:SetVertexColor(1, 1, 1, 0.2)
		
		if (i == 1) then
			self.Buttons[i]:SetPoint("LEFT", self.Panel, 2, 0)
		else
			self.Buttons[i]:SetPoint("LEFT", self.Buttons[i-1], "RIGHT", 0, 0)
		end
	end
	
	MicroButtonPortrait:ClearAllPoints()
	MicroButtonPortrait:SetPoint("TOPLEFT", CharacterMicroButton, 2, -2)
	MicroButtonPortrait:SetPoint("BOTTOMRIGHT", CharacterMicroButton, -2, 2)
	
	MainMenuBarPerformanceBar:Hide()
	
	if (not Settings["micro-buttons-show"]) then
		self.Panel:Hide()
	end
	
	self:Hook("UpdateMicroButtonsParent")
	self:Hook("MoveMicroButtons")
	
	self:UpdateVisibility()
end

local UpdateMicroVisibility = function(value)
	MicroButtons:UpdateVisibility()
end

GUI:AddOptions(function(self)
	local Left = self:GetWindow(Language["Action Bars"])
	
	Left:CreateHeader(Language["Micro Menu Buttons"])
	Left:CreateDropdown("micro-buttons-visiblity", Settings["micro-buttons-visiblity"], {[Language["Hide"]] = "HIDE", [Language["Mouseover"]] = "MOUSEOVER", [Language["Show"]] = "SHOW"}, Language["Set Visibility"], Language["Set the visibility of the micro menu buttons"], UpdateMicroVisibility)
	Left:CreateSlider("micro-buttons-opacity", Settings["micro-buttons-opacity"], 0, 100, 10, Language["Set Faded Opacity"], Language["Set the opacity of the micro menu buttons when visiblity is set to Mouseover"], UpdateMicroVisibility, nil, "%")
end)