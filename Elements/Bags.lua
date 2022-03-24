if (1 == 1) then
	return
end

local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local GetContainerNumSlots = ContainerFrame_GetContainerNumSlots
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetContainerItemInfo = GetContainerItemInfo
local GetCoinTextureString = GetCoinTextureString
local GetMoney = GetMoney
local GetTime = GetTime

local Bags = HydraUI:NewModule("Bags")

Bags.Slots = {}

local Texture, ItemCount, Locked, Quality, Readable, IsFiltered, NoValue, ItemID, _

local HEADER_HEIGHT = 22
local BUTTON_SIZE = 32
local NUM_PER_ROW = 10

function Bags:SkinSlot(slot)
	local Name = slot:GetName()
	local Normal = _G[Name .. "NormalTexture"]
	local Count = _G[Name .. "Count"]
	local Cooldown = _G[Name .. "Cooldown"]
	
	slot:SetParent(self.Frame.SlotContainer)
	slot:SetFrameLevel(self.Frame.SlotContainer:GetFrameLevel() + 1)
	slot:SetFrameStrata("HIGH")
	slot:SetSize(BUTTON_SIZE, BUTTON_SIZE)
	slot:SetScale(1)
	
	if Normal then
		Normal:SetTexture(nil)
	end
	
	if Count then
		Count:ClearAllPoints()
		Count:SetPoint("BOTTOMRIGHT", -1, 1)
		Count:SetJustifyH("RIGHT")
		HydraUI:SetFontInfo(Count, Settings["ui-widget-font"], 12)
	end
	
	if slot.icon then
		slot.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		slot.icon:SetDrawLayer("ARTWORK", 7)
	end
	
	if Cooldown then
		local CooldownText = Cooldown:GetRegions()
		
		if CooldownText then
			HydraUI:SetFontInfo(CooldownText, Settings["action-bars-font"], 18, Settings["action-bars-font-flags"])
		end
	end
	
	slot.Backdrop = slot:CreateTexture(nil, "BACKGROUND")
	slot.Backdrop:SetPoint("TOPLEFT", slot, -1, 1)
	slot.Backdrop:SetPoint("BOTTOMRIGHT", slot, 1, -1)
	slot.Backdrop:SetColorTexture(0, 0, 0)
	
	slot.Backdrop.Texture = slot:CreateTexture(nil, "BACKDROP", 2)
	slot.Backdrop.Texture:SetPoint("TOPLEFT", slot.Backdrop, 1, -1)
	slot.Backdrop.Texture:SetPoint("BOTTOMRIGHT", slot.Backdrop, -1, 1)
	slot.Backdrop.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	slot.Backdrop.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	
	local Highlight = slot:CreateTexture(nil, "ARTWORK")
	Highlight:SetPoint("TOPLEFT", slot, 0, 0)
	Highlight:SetPoint("BOTTOMRIGHT", slot, 0, 0)
	Highlight:SetColorTexture(1, 1, 1)
	Highlight:SetAlpha(0.2)
	
	slot:SetHighlightTexture(Highlight)
	
	local Pushed = slot:CreateTexture(nil, "ARTWORK", 7)
	Pushed:SetPoint("TOPLEFT", slot, 0, 0)
	Pushed:SetPoint("BOTTOMRIGHT", slot, 0, 0)
	Pushed:SetColorTexture(0.2, 0.9, 0.2)
	Pushed:SetAlpha(0.4)
	
	slot:SetPushedTexture(Pushed)
	
	slot.Handled = true
end

function Bags:UpdateBagSpace()
	local TotalSlots = 0
	local FreeSlots = 0
	
	for i = 0, NUM_BAG_SLOTS do
		local NumSlots = GetContainerNumSlots(i)
		
		if NumSlots then
			FreeSlots = FreeSlots + GetContainerNumFreeSlots(i)
			TotalSlots = TotalSlots + NumSlots
		end
	end
	
	self.Frame.Footer.RightText:SetFormattedText("%s/%s", TotalSlots-FreeSlots, TotalSlots)
end

function Bags:UpdateGoldValue()
	self.Frame.Footer.LeftText:SetText(GetCoinTextureString(GetMoney()))
end

function Bags:UpdateBagSize()
	local TotalSlots = 0

	for Bag = 0, 4 do
		TotalSlots = TotalSlots + GetContainerNumSlots(Bag)
	end
	
	local NumRows = ceil(TotalSlots / NUM_PER_ROW)
	
	self.Frame:SetWidth((NUM_PER_ROW * BUTTON_SIZE + 4) + (NUM_PER_ROW * 5) - 4)
	self.Frame:SetHeight((NumRows * BUTTON_SIZE + 4) + (NumRows * 4) + 6 + (HEADER_HEIGHT * 2 + 4))
end

function Bags:UpdateSlot(bag, slot)
	local Texture, ItemCount, Locked, Quality, Readable, _, _, IsFiltered, NoValue, ItemID = GetContainerItemInfo(bag - 1, slot:GetID())
	local Name = slot:GetName()
	
	if Texture then
		slot.icon:SetTexture(Texture)
	else
		slot.icon:SetTexture()
	end
	
	_G[Name .. "Count"]:SetText(ItemCount)
	
	if Quality and Quality > 1 then
		local R, G, B = GetItemQualityColor(Quality)
		
		slot.Backdrop:SetColorTexture(R, G, B)
	else
		slot.Backdrop:SetColorTexture(0, 0, 0)
	end
	
	if Locked then
		slot.icon:SetDesaturated(true)
	else
		slot.icon:SetDesaturated(false)
	end
end

function Bags:UpdateSlots()
	local Slot
	
	for Bag = 1, 5 do
		NumSlots = GetContainerNumSlots((Bag - 1))
		
		for SlotID = 1, NumSlots do
			Slot = _G["ContainerFrame" .. Bag .. "Item" .. SlotID]
			
			self:UpdateSlot(Bag, Slot)
		end
	end
end

function Bags:PositionSlots()
	local Index = 1
	local Slot
	local NumSlots
	local LastSlot
	local LastRowStart
	
	for Bag = 1, 5 do
		NumSlots = GetContainerNumSlots(Bag - 1)
		
		for SlotID = 1, NumSlots do
			Slot = _G["ContainerFrame" .. Bag .. "Item" .. SlotID]
			
			if (not Slot.Handled) then
				self:SkinSlot(Slot)
			end
			
			self:UpdateSlot(Bag, Slot)
			
			Slot:ClearAllPoints()
			
			if (Index == 1) then
				Slot:SetPoint("TOPLEFT", self.Frame.SlotContainer, "TOPLEFT", 4, -4)
				--Slot:SetPoint("TOPLEFT", self.Frame.SlotContainer, "TOPLEFT", 4 + BUTTON_SIZE, -(4 + BUTTON_SIZE))
				
				LastRowStart = Slot
			elseif ((Index % NUM_PER_ROW) == 1) then
				Slot:SetPoint("TOP", LastRowStart, "BOTTOM", 0, -4)
				--Slot:SetPoint("TOP", self.Frame.SlotContainer, "BOTTOM", 0, -(4 + BUTTON_SIZE))
				
				LastRowStart = Slot
			else
				Slot:SetPoint("LEFT", LastSlot, "RIGHT", 4, 0)
				--Slot:SetPoint("LEFT", self.Frame.SlotContainer, "RIGHT", 4 + BUTTON_SIZE, 0)
			end
			
			Index = Index + 1
			LastSlot = Slot
		end
	end
end

local CloseOnEnter = function(self)
	self.Cross:SetVertexColor(HydraUI:HexToRGB("C0392B"))
end

local CloseOnLeave = function(self)
	self.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE"))
end

local CloseOnMouseUp = function(self)
	self.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	Bags:Toggle()
end

local CloseOnMouseDown = function(self)
	local R, G, B = HydraUI:HexToRGB(Settings["ui-header-texture-color"])
	
	self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

local BagFadeOnFinished = function(self)
	self.Parent:Hide()
end

function Bags:CreateBagFrame()
	local Frame = CreateFrame("Frame", "HydraUI Bags", HydraUI.UIParent, "BackdropTemplate")
	Frame:SetSize(390, 300)
	--Frame:SetPoint("BOTTOMRIGHT", HydraUI.UIParent, -13, 13)
	Frame:SetPoint("BOTTOMLEFT", HydraUI.UIParent, "LEFT", 60, -130)
	Frame:SetBackdrop(HydraUI.BackdropAndBorder)
	Frame:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	Frame:SetBackdropBorderColor(0, 0, 0)
	Frame:SetFrameStrata("HIGH")
	Frame:EnableMouse(true)
	Frame:SetMovable(true)
	Frame:RegisterForDrag("LeftButton")
	Frame:SetScript("OnDragStart", Frame.StartMoving)
	Frame:SetScript("OnDragStop", Frame.StopMovingOrSizing)
	Frame:SetClampedToScreen(true)
	--Frame:Hide()
	
	-- This just makes the animation look better. That's all. ಠ_ಠ
	Frame.BlackTexture = Frame:CreateTexture(nil, "BACKGROUND", -7)
	Frame.BlackTexture:SetDrawLayer("BACKGROUND", -7)
	Frame.BlackTexture:SetPoint("TOPLEFT", Frame, 0, 0)
	Frame.BlackTexture:SetPoint("BOTTOMRIGHT", Frame, 0, 0)
	Frame.BlackTexture:SetTexture(Assets:GetTexture("Blank"))
	Frame.BlackTexture:SetVertexColor(0, 0, 0)
	
	Frame.Fade = CreateAnimationGroup(Frame)
	
	Frame.FadeIn = Frame.Fade:CreateAnimation("Fade")
	Frame.FadeIn:SetEasing("in")
	Frame.FadeIn:SetDuration(0.15)
	Frame.FadeIn:SetChange(1)
	
	Frame.FadeOut = Frame.Fade:CreateAnimation("Fade")
	Frame.FadeOut:SetEasing("out")
	Frame.FadeOut:SetDuration(0.15)
	Frame.FadeOut:SetChange(0)
	Frame.FadeOut:SetScript("OnFinished", BagFadeOnFinished)
	
	-- Close button
	local CloseButton = CreateFrame("Frame", nil, Frame, "BackdropTemplate")
	CloseButton:SetSize(22, 22)
	CloseButton:SetPoint("TOPRIGHT", Frame, -3, -3)
	CloseButton:SetBackdrop(HydraUI.BackdropAndBorder)
	CloseButton:SetBackdropColor(0, 0, 0, 0)
	CloseButton:SetBackdropBorderColor(0, 0, 0)
	CloseButton:SetScript("OnEnter", CloseOnEnter)
	CloseButton:SetScript("OnLeave", CloseOnLeave)
	CloseButton:SetScript("OnMouseUp", CloseOnMouseUp)
	CloseButton:SetScript("OnMouseDown", CloseOnMouseDown)
	
	CloseButton.Texture = CloseButton:CreateTexture(nil, "ARTWORK")
	CloseButton.Texture:SetPoint("TOPLEFT", CloseButton, 1, -1)
	CloseButton.Texture:SetPoint("BOTTOMRIGHT", CloseButton, -1, 1)
	CloseButton.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	CloseButton.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	CloseButton.Cross = CloseButton:CreateTexture(nil, "OVERLAY")
	CloseButton.Cross:SetPoint("CENTER", CloseButton, 0, 0)
	CloseButton.Cross:SetSize(16, 16)
	CloseButton.Cross:SetTexture(Assets:GetTexture("Close"))
	CloseButton.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE"))
	
	-- Header
	local Header = CreateFrame("Frame", nil, Frame, "BackdropTemplate")
	Header:SetHeight(22)
	Header:SetPoint("TOPLEFT", Frame, 3, -3)
	Header:SetPoint("TOPRIGHT", CloseButton, "TOPLEFT", -2, -3)
	Header:SetBackdrop(HydraUI.BackdropAndBorder)
	Header:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	Header:SetBackdropBorderColor(0, 0, 0)
	
	Header.Texture = Header:CreateTexture(nil, "OVERLAY")
	Header.Texture:SetPoint("TOPLEFT", Header, 1, -1)
	Header.Texture:SetPoint("BOTTOMRIGHT", Header, -1, 1)
	Header.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	Header.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	Header.Text = Header:CreateFontString(nil, "OVERLAY")
	Header.Text:SetPoint("LEFT", Header, 5, 0)
	HydraUI:SetFontInfo(Header.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	Header.Text:SetJustifyH("LEFT")
	Header.Text:SetText("Inventory")
	
	-- Footer
	local Footer = CreateFrame("Frame", nil, Frame, "BackdropTemplate")
	Footer:SetHeight(22)
	Footer:SetPoint("BOTTOMLEFT", Frame, 3, 3)
	Footer:SetPoint("BOTTOMRIGHT", Frame, -3, 3)
	Footer:SetBackdrop(HydraUI.BackdropAndBorder)
	Footer:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	Footer:SetBackdropBorderColor(0, 0, 0)
	
	Footer.Texture = Footer:CreateTexture(nil, "OVERLAY")
	Footer.Texture:SetPoint("TOPLEFT", Footer, 1, -1)
	Footer.Texture:SetPoint("BOTTOMRIGHT", Footer, -1, 1)
	Footer.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	Footer.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	
	Footer.LeftText = Footer:CreateFontString(nil, "OVERLAY")
	Footer.LeftText:SetPoint("LEFT", Footer, 5, 0)
	HydraUI:SetFontInfo(Footer.LeftText, Settings["ui-widget-font"], Settings["ui-font-size"])
	Footer.LeftText:SetJustifyH("LEFT")
	
	Footer.RightText = Footer:CreateFontString(nil, "OVERLAY")
	Footer.RightText:SetPoint("RIGHT", Footer, -5, 0)
	HydraUI:SetFontInfo(Footer.RightText, Settings["ui-widget-font"], Settings["ui-font-size"])
	Footer.RightText:SetJustifyH("RIGHT")
	
	-- Slots
	local SlotContainer = CreateFrame("Frame", nil, Frame, "BackdropTemplate")
	SlotContainer:SetPoint("TOPLEFT", Header, "BOTTOMLEFT", 0, -2)
	SlotContainer:SetPoint("BOTTOMRIGHT", Footer, "TOPRIGHT", 0, 2)
	SlotContainer:SetBackdrop(HydraUI.BackdropAndBorder)
	SlotContainer:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	SlotContainer:SetBackdropBorderColor(0, 0, 0)
	
	Frame.CloseButton = CloseButton
	Frame.Header = Header
	Frame.Footer = Footer
	Frame.SlotContainer = SlotContainer
	
	self.Frame = Frame
	
	self:PositionSlots()
	self:UpdateBagSize()
	
	self.Exists = true
end

function Bags:Open()
	self:UpdateSlots()
	
	if (not self.Frame:IsShown()) then
		self.Frame:SetAlpha(0)
		self.Frame:Show()
		self.Frame.FadeIn:Play()
	end
end

function Bags:Close()
	if self.Frame:IsShown() then
		self.Frame.FadeOut:Play()
	end
end

function Bags:Toggle()
	if self.Frame:IsShown() then
		self.Frame.FadeOut:Play()
		
		PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
	else
		-- Update information
		self:UpdateSlots()
		self:UpdateGoldValue()
		self:UpdateBagSpace()
		
		self.Frame:SetAlpha(0)
		self.Frame:Show()
		self.Frame.FadeIn:Play()
		
		PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
	end
end

function Bags:ReplaceFunctions()
	OpenBag = function()
		self:Open()
	end
	
	OpenAllBags = function()
		self:Open()
	end
	
	CloseAllBags = function()
		self:Close()
	end
	
	ToggleBag = function()
		self:Toggle()
	end
	
	ToggleBackpack = function()
		self:Toggle()
	end
end

function Bags:BAG_UPDATE()
	self:UpdateSlots()
end

function Bags:PLAYER_MONEY()
	self:UpdateGoldValue()
end

function Bags:BAG_UPDATE_COOLDOWN()
	self:UpdateSlots()
end

function Bags:ITEM_LOCK_CHANGED()
	self:UpdateSlots()
end

function Bags:BAG_NEW_ITEMS_UPDATED()
	self:UpdateSlots()
end

function Bags:BAG_SLOT_FLAGS_UPDATED()
	self:UpdateSlots()
end

function Bags:UNIT_INVENTORY_CHANGED()
	self:UpdateSlots()
end

local OnEvent = function(self, event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

function Bags:AddEvents()
	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("PLAYER_MONEY")
	self:RegisterEvent("BAG_UPDATE_COOLDOWN")
	self:RegisterEvent("ITEM_LOCK_CHANGED")
	self:RegisterEvent("BAG_NEW_ITEMS_UPDATED")
	self:RegisterEvent("BAG_SLOT_FLAGS_UPDATED")
	self:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
	self:SetScript("OnEvent", OnEvent)
end

function Bags:Load()
	OpenAllBags()
	CloseAllBags()
	
	self:ReplaceFunctions()
	self:CreateBagFrame()
	self:UpdateSlots()
	self:AddEvents()
end