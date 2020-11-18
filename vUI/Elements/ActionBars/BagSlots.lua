local vUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local BagsFrame = vUI:NewModule("Bags Frame")

-- Default settings values
Defaults["bags-loot-from-left"] = false
Defaults["bags-frame-visiblity"] = "SHOW"
Defaults["bags-frame-opacity"] = 40
Defaults["bags-frame-max"] = 100

BagsFrame.Objects = {
	CharacterBag3Slot,
	CharacterBag2Slot,
	CharacterBag1Slot,
	CharacterBag0Slot,
	MainMenuBarBackpackButton,
}

local BagsFrameButtonOnEnter = function(self)
	if (Settings["bags-frame-visiblity"] == "MOUSEOVER") then
		self:GetParent():SetAlpha(Settings["bags-frame-max"] / 100)
	end
end

local BagsFrameOnEnter = function(self)
	self:SetAlpha(Settings["bags-frame-max"] / 100)
end

local BagsFrameButtonOnLeave = function(self)
	if (Settings["bags-frame-visiblity"] == "MOUSEOVER") then
		self:GetParent():SetAlpha(Settings["bags-frame-opacity"] / 100)
	end
end

local BagsFrameOnLeave = function(self)
	self:SetAlpha(Settings["bags-frame-opacity"] / 100)
end

function BagsFrame:UpdateVisibility()
	if (Settings["bags-frame-visiblity"] == "HIDE") then
		self.Panel:SetScript("OnEnter", nil)
		self.Panel:SetScript("OnLeave", nil)
		self.Panel:SetAlpha(0)
		self.Panel:Hide()
	elseif (Settings["bags-frame-visiblity"] == "MOUSEOVER") then
		self.Panel:SetScript("OnEnter", BagsFrameOnEnter)
		self.Panel:SetScript("OnLeave", BagsFrameOnLeave)
		self.Panel:SetAlpha(Settings["bags-frame-opacity"] / 100)
		self.Panel:Show()
	elseif (Settings["bags-frame-visiblity"] == "SHOW") then
		self.Panel:SetScript("OnEnter", nil)
		self.Panel:SetScript("OnLeave", nil)
		self.Panel:SetAlpha(Settings["bags-frame-max"] / 100)
		self.Panel:Show()
	end
end

function BagsFrame:Load()
	if (not Settings["ab-enable"]) then
		return
	end
	
	self.Panel = CreateFrame("Frame", "vUI Bags Window", vUI.UIParent, "BackdropTemplate")
	self.Panel:SetSize(184, 40)
	self.Panel:SetPoint("BOTTOMRIGHT", vUI:GetModule("Micro Buttons").Panel, "TOPRIGHT", 0, 3)
	self.Panel:SetBackdrop(vUI.BackdropAndBorder)
	self.Panel:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.Panel:SetBackdropBorderColor(0, 0, 0)
	self.Panel:SetFrameStrata("LOW")
	
	vUI:CreateMover(self.Panel)
	
	local Object
	
	for i = 1, #self.Objects do
		Object = self.Objects[i]
		
		Object:SetParent(self.Panel)
		Object:ClearAllPoints()
		Object:SetSize(32, 32)
		Object:HookScript("OnEnter", BagsFrameButtonOnEnter)
		Object:HookScript("OnLeave", BagsFrameButtonOnLeave)
		
		local Name = Object:GetName()
		local Normal = _G[Name .. "NormalTexture"]
		local Count = _G[Name .. "Count"]
		local Stock = _G[Name .. "Stock"]
		
		Object.IconBorder:SetAlpha(0)
		
		if Normal then
			Normal:SetTexture(nil)
		end
		
		if Count then
			Count:ClearAllPoints()
			Count:SetPoint("BOTTOMRIGHT", 0, 2)
			Count:SetJustifyH("RIGHT")
			vUI:SetFontInfo(Count, Settings["ui-widget-font"], Settings["ui-font-size"])
		end
		
		if Stock then
			Stock:ClearAllPoints()
			Stock:SetPoint("TOPLEFT", 0, -2)
			Stock:SetJustifyH("LEFT")
			vUI:SetFontInfo(Stock, Settings["ui-widget-font"], Settings["ui-font-size"])
		end
		
		if Object.icon then
			Object.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		end
		
		Object.BG = Object:CreateTexture(nil, "BACKGROUND")
		Object.BG:SetPoint("TOPLEFT", Object, -1, 1)
		Object.BG:SetPoint("BOTTOMRIGHT", Object, 1, -1)
		Object.BG:SetColorTexture(0, 0, 0)
		
		--[[local Checked = Object:CreateTexture(nil, "ARTWORK")
		Checked:SetPoint("TOPLEFT", Object, 0, 0)
		Checked:SetPoint("BOTTOMRIGHT", Object, 0, 0)
		Checked:SetColorTexture(0.1, 0.8, 0.1)
		Checked:SetAlpha(0.2)
		
		Object:SetCheckedTexture(Checked)]]
		
		local Highlight = Object:CreateTexture(nil, "ARTWORK")
		Highlight:SetPoint("TOPLEFT", Object, 0, 0)
		Highlight:SetPoint("BOTTOMRIGHT", Object, 0, 0)
		Highlight:SetColorTexture(1, 1, 1)
		Highlight:SetAlpha(0.2)
		
		Object:SetHighlightTexture(Highlight)
		
		local Pushed = Object:CreateTexture(nil, "ARTWORK", 7)
		Pushed:SetPoint("TOPLEFT", Object, 0, 0)
		Pushed:SetPoint("BOTTOMRIGHT", Object, 0, 0)
		Pushed:SetColorTexture(0.2, 0.9, 0.2)
		Pushed:SetAlpha(0.4)
		
		Object:SetPushedTexture(Pushed)
		
		if (i == 1) then
			Object:SetPoint("LEFT", self.Panel, 4, 0)
		else
			Object:SetPoint("LEFT", self.Objects[i-1], "RIGHT", 4, 0)
		end
	end
	
	SetInsertItemsLeftToRight(Settings["bags-loot-from-left"])
	
	self:UpdateVisibility()
end

local UpdateBagVisibility = function()
	BagsFrame:UpdateVisibility()
end

--GUI:AddOptions(function(self)
GUI:AddSettings(Language["General"], Language["Action Bars"], function(left, right)
	right:CreateHeader(Language["Bags Frame"])
	right:CreateDropdown("bags-frame-visiblity", Settings["bags-frame-visiblity"], {[Language["Hide"]] = "HIDE", [Language["Mouseover"]] = "MOUSEOVER", [Language["Show"]] = "SHOW"}, Language["Set Visibility"], Language["Set the visibility of the bag frame"], UpdateBagVisibility)
	right:CreateSlider("bags-frame-opacity", Settings["bags-frame-opacity"], 0, 100, 10, Language["Set Faded Opacity"], Language["Set the opacity of the bags frame when visiblity is set to Mouseover"], UpdateBagVisibility, nil, "%")
	right:CreateSlider("bags-frame-max", Settings["bags-frame-max"], 0, 100, 10, Language["Set Max Opacity"], Language["Set the max opacity of the bags frame when visiblity is set to Mouseover"], UpdateBagVisibility, nil, "%")
	right:CreateSwitch("bags-loot-from-left", Settings["bags-loot-from-left"], Language["Loot Left To Right"], Language["When looting, new items will be placed into the leftmost bag"], SetInsertItemsLeftToRight)
end)