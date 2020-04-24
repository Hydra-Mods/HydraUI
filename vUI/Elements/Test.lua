local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

--[[local AnimTest = vUI:NewModule("Anim Test")

local OnMouseUp = function(self)
	if self.Animation:IsPlaying() then
		self.Animation:Stop()
	else
		self.Animation:Play()
	end
end

function AnimTest:Load()
	vUI:SetSize(self, 45, 45)
	vUI:SetPoint(self, "CENTER", UIParent, 0, 120)
	self:SetScript("OnMouseUp", OnMouseUp)
	
	self.Texture = self:CreateTexture(nil, "OVERLAY")
	vUI:SetPoint(self.Texture, "CENTER", UIParent, 0, 120)
	vUI:SetSize(self.Texture, 45, 45)
	self.Texture:SetTexture("Interface\\LFGFrame\\LFG-Eye")
	
	self.Animation = CreateAnimationGroup(self.Texture):CreateAnimation("Frames")
	self.Animation:SetTextureSize(512, 256)
	self.Animation:SetFrameSize(64)
	self.Animation:SetNumFrames(29)
	self.Animation:SetFrameDelay(0.1)
	self.Animation:SetDuration(10)
end]]

--[[
local IconSize = 40
local IconHeight = floor(IconSize * 0.6)
local IconRatio = (1 - (IconHeight / IconSize)) / 2

local Icon = CreateFrame("Frame", nil, UIParent)
Icon:SetScaledPoint("CENTER")
Icon:SetScaledSize(IconSize, IconHeight)
Icon:SetBackdrop(vUI.Backdrop)
Icon:SetBackdropColor(0, 0, 0)

Icon.t = Icon:CreateTexture(nil, "OVERLAY")
Icon.t:SetScaledPoint("TOPLEFT", Icon, 1, -1)
Icon.t:SetScaledPoint("BOTTOMRIGHT", Icon, -1, 1)
Icon.t:SetTexture("Interface\\ICONS\\spell_warlock_soulburn")
Icon.t:SetTexCoord(0.1, 0.9, 0.1 + IconRatio, 0.9 - IconRatio)]]