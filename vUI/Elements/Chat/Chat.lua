local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local select = select
local tostring = tostring
local format = string.format
local sub = string.sub
local gsub = string.gsub
local match = string.match

local FRAME_WIDTH = 392
local FRAME_HEIGHT = 104
local BAR_HEIGHT = 22

local SetHyperlink = ItemRefTooltip.SetHyperlink
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
local ChatEdit_ActivateChat = ChatEdit_ActivateChat
local ChatEdit_ParseText = ChatEdit_ParseText
local ChatEdit_UpdateHeader = ChatEdit_UpdateHeader

-- When hovering over a chat frame, fade in the scroll controls

local FormatDiscordHyperlink = function(id)
	return format("|cFF7289DA|Hdiscord:%s|h[%s: %s]|h|r", format("https://discord.gg/%s", id), Language["Discord"], id)
end

local FormatURLHyperlink = function(url)
	return format("|cFF%s|Hurl:%s|h[%s]|h|r", Settings["ui-widget-color"], url, url)
end

local FormatEmailHyperlink = function(address)
	return format("|cFF%s|Hemail:%s|h[%s]|h|r", Settings["ui-widget-color"], address, address)
end

-- This can be b.net or discord, so just calling it a "friend tag" for now.
local FormatFriendHyperlink = function(tag) -- /run print("Player#1111")
	return format("|cFF00AAFF|Hfriend:%s|h[%s]|h|r", tag, tag)
end

local FormatLinks = function(message)
	if (not message) then
		return
	end
	
	if Settings["chat-enable-discord-links"] then
		local NewMessage, Subs = gsub(message, "https://discord.gg/(%S+)", FormatDiscordHyperlink("%1"))
		
		if (Subs > 0) then
			return NewMessage
		end
		
		NewMessage, Subs = gsub(message, "discord.gg/(%S+)", FormatDiscordHyperlink("%1"))
		
		if (Subs > 0) then
			return NewMessage
		end
	end
	
	if Settings["chat-enable-url-links"] then
		if (match(message, "%a+://(%S+)%.%a+/%S+") == "discord") and (not Settings["chat-enable-discord-links"]) then
			return message
		end
		
		local NewMessage, Subs = gsub(message, "(%a+)://(%S+)", FormatURLHyperlink("%1://%2"))
		
		if (Subs > 0) then
			return NewMessage
		end
		
		NewMessage, Subs = gsub(message, "www%.([_A-Za-z0-9-]+)%.(%S+)", FormatURLHyperlink("www.%1.%2"))
		
		if (Subs > 0) then
			return NewMessage
		end
	end
	
	if Settings["chat-enable-email-links"] then
		local NewMessage, Subs = gsub(message, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)", FormatEmailHyperlink("%1@%2%3%4"))
		
		if (Subs > 0) then
			return NewMessage
		end
	end
	
	if Settings["chat-enable-friend-links"] then
		local NewMessage, Subs = gsub(message, "(%a+)#(%d+)", FormatFriendHyperlink("%1#%2"))
		
		if (Subs > 0) then
			return NewMessage
		end
	end
	
	return message
end

local FindLinks = function(self, event, msg, ...)
	msg = FormatLinks(msg)
	
	return false, msg, ...
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND_LEADER", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_CONVERSATION", FindLinks)

--[[ Scooping the GMOTD to see if there's any yummy links.
ChatFrame_DisplayGMOTD = function(frame, message)
	if (message and (message ~= "")) then
		local Info = ChatTypeInfo["GUILD"]
		
		message = format(GUILD_MOTD_TEMPLATE, message)
		message = FormatLinks(message)
		
		frame:AddMessage(message, Info.r, Info.g, Info.b, Info.id)
	end
end]]

local SetEditBoxToLink = function(box, text)
	box:SetText("")
	
	if (not box:IsShown()) then
		ChatEdit_ActivateChat(box)
	else
		ChatEdit_UpdateHeader(box)
	end
	
	box:Insert(text)
	box:HighlightText()
end

ItemRefTooltip.SetHyperlink = function(self, link, text, button, chatFrame)
	if (sub(link, 1, 3) == "url") then
		local EditBox = ChatEdit_ChooseBoxForSend()
		local Link = sub(link, 5)
		
		EditBox:SetAttribute("chatType", "URL")
		
		SetEditBoxToLink(EditBox, Link)
	elseif (sub(link, 1, 5) == "email") then
		local EditBox = ChatEdit_ChooseBoxForSend()
		local Email = sub(link, 7)
		
		EditBox:SetAttribute("chatType", "EMAIL")
		
		SetEditBoxToLink(EditBox, Email)
	elseif (sub(link, 1, 7) == "discord") then
		local EditBox = ChatEdit_ChooseBoxForSend()
		local Link = sub(link, 9)
		
		EditBox:SetAttribute("chatType", "DISCORD")
		
		SetEditBoxToLink(EditBox, Link)
	elseif (sub(link, 1, 6) == "friend") then
		local EditBox = ChatEdit_ChooseBoxForSend()
		local Tag = sub(link, 8)
		
		EditBox:SetAttribute("chatType", "FRIEND")
		
		SetEditBoxToLink(EditBox, Tag)
	elseif (sub(link, 1, 7) == "command") then
		local EditBox = ChatEdit_ChooseBoxForSend()
		local Command = sub(link, 9)
		
		EditBox:SetText("")
		
		if (not EditBox:IsShown()) then
			ChatEdit_ActivateChat(EditBox)
		else
			ChatEdit_UpdateHeader(EditBox)
		end
		
		EditBox:Insert(Command)
		ChatEdit_ParseText(EditBox, 1)
	else
		SetHyperlink(self, link, text, button, chatFrame)
	end
end

local CreateChatFramePanels = function()
	local R, G, B = vUI:HexToRGB(Settings["ui-window-main-color"])
	
	local Width = Settings["chat-frame-width"]
	
	local LeftChatFrameBottom = CreateFrame("Frame", "vUIChatFrameBottom", UIParent)
	LeftChatFrameBottom:SetScaledSize(Width, BAR_HEIGHT)
	LeftChatFrameBottom:SetScaledPoint("BOTTOMLEFT", UIParent, 13, 13)
	LeftChatFrameBottom:SetBackdrop(vUI.BackdropAndBorder)
	LeftChatFrameBottom:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	LeftChatFrameBottom:SetBackdropBorderColor(0, 0, 0)
	LeftChatFrameBottom:SetFrameStrata("MEDIUM")
	
	LeftChatFrameBottom.Texture = LeftChatFrameBottom:CreateTexture(nil, "OVERLAY")
	LeftChatFrameBottom.Texture:SetScaledPoint("TOPLEFT", LeftChatFrameBottom, 1, -1)
	LeftChatFrameBottom.Texture:SetScaledPoint("BOTTOMRIGHT", LeftChatFrameBottom, -1, 1)
	LeftChatFrameBottom.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	LeftChatFrameBottom.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	
	local ChatFrameBG = CreateFrame("Frame", "vUIChatFrame", UIParent)
	ChatFrameBG:SetScaledSize(Width, Settings["chat-frame-height"])
	ChatFrameBG:SetScaledPoint("BOTTOMLEFT", LeftChatFrameBottom, "TOPLEFT", 0, 2)
	ChatFrameBG:SetBackdrop(vUI.BackdropAndBorder)
	ChatFrameBG:SetBackdropColor(R, G, B, (Settings["chat-bg-opacity"] / 100))
	ChatFrameBG:SetBackdropBorderColor(0, 0, 0)
	ChatFrameBG:SetFrameStrata("LOW")
	
	local LeftChatFrameTop = CreateFrame("Frame", "vUIChatFrameTop", UIParent)
	LeftChatFrameTop:SetScaledSize(Width, BAR_HEIGHT)
	LeftChatFrameTop:SetScaledPoint("BOTTOM", ChatFrameBG, "TOP", 0, 2)
	LeftChatFrameTop:SetBackdrop(vUI.BackdropAndBorder)
	LeftChatFrameTop:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	LeftChatFrameTop:SetBackdropBorderColor(0, 0, 0)
	LeftChatFrameTop:SetFrameStrata("MEDIUM")
	
	LeftChatFrameTop.Texture = LeftChatFrameTop:CreateTexture(nil, "OVERLAY")
	LeftChatFrameTop.Texture:SetScaledPoint("TOPLEFT", LeftChatFrameTop, 1, -1)
	LeftChatFrameTop.Texture:SetScaledPoint("BOTTOMRIGHT", LeftChatFrameTop, -1, 1)
	LeftChatFrameTop.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	LeftChatFrameTop.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	-- All this just to achieve an empty center :P
	local ChatFrameBGTop = CreateFrame("Frame", nil, ChatFrameBG)
	ChatFrameBGTop:SetScaledPoint("TOPLEFT", LeftChatFrameTop, -3, 3)
	ChatFrameBGTop:SetScaledPoint("BOTTOMRIGHT", LeftChatFrameTop, 3, -3)
	ChatFrameBGTop:SetBackdrop(vUI.BackdropAndBorder)
	ChatFrameBGTop:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	ChatFrameBGTop:SetBackdropBorderColor(0, 0, 0, 0)
	ChatFrameBGTop:SetFrameStrata("LOW")
	
	local ChatFrameBGBottom = CreateFrame("Frame", nil, ChatFrameBG)
	ChatFrameBGBottom:SetScaledPoint("TOPLEFT", LeftChatFrameBottom, -3, 3)
	ChatFrameBGBottom:SetScaledPoint("BOTTOMRIGHT", LeftChatFrameBottom, 3, -3)
	ChatFrameBGBottom:SetBackdrop(vUI.BackdropAndBorder)
	ChatFrameBGBottom:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	ChatFrameBGBottom:SetBackdropBorderColor(0, 0, 0, 0)
	ChatFrameBGBottom:SetFrameStrata("LOW")
	
	local ChatFrameBGLeft = CreateFrame("Frame", nil, ChatFrameBG)
	ChatFrameBGLeft:SetScaledWidth(4)
	ChatFrameBGLeft:SetScaledPoint("TOPLEFT", ChatFrameBGTop, 0, 0)
	ChatFrameBGLeft:SetScaledPoint("BOTTOMLEFT", ChatFrameBGBottom, "TOPLEFT", 0, 0)
	ChatFrameBGLeft:SetBackdrop(vUI.BackdropAndBorder)
	ChatFrameBGLeft:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	ChatFrameBGLeft:SetBackdropBorderColor(0, 0, 0, 0)
	ChatFrameBGLeft:SetFrameStrata("LOW")
	
	local ChatFrameBGRight = CreateFrame("Frame", nil, ChatFrameBG)
	ChatFrameBGRight:SetScaledWidth(4)
	ChatFrameBGRight:SetScaledPoint("TOPRIGHT", ChatFrameBGTop, 0, 0)
	ChatFrameBGRight:SetScaledPoint("BOTTOMRIGHT", ChatFrameBGBottom, 0, 0)
	ChatFrameBGRight:SetBackdrop(vUI.BackdropAndBorder)
	ChatFrameBGRight:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	ChatFrameBGRight:SetBackdropBorderColor(0, 0, 0, 0)
	ChatFrameBGRight:SetFrameStrata("LOW")
	
	local OuterOutline = CreateFrame("Frame", nil, ChatFrameBG)
	OuterOutline:SetScaledPoint("TOPLEFT", ChatFrameBGTop, 0, 0)
	OuterOutline:SetScaledPoint("BOTTOMRIGHT", ChatFrameBGBottom, 0, 0)
	OuterOutline:SetBackdrop(vUI.Outline)
	OuterOutline:SetBackdropBorderColor(0, 0, 0)
	
	local InnerOutline = CreateFrame("Frame", nil, ChatFrameBG)
	InnerOutline:SetScaledPoint("TOPLEFT", ChatFrameBG, 0, 0)
	InnerOutline:SetScaledPoint("BOTTOMRIGHT", ChatFrameBG, 0, 0)
	InnerOutline:SetBackdrop(vUI.Outline)
	InnerOutline:SetBackdropBorderColor(0, 0, 0)
end

local UpdateChatFrameSize = function()
	local Width = Settings["chat-frame-width"]
	
	vUIChatFrame:SetScaledSize(Width, Settings["chat-frame-height"])
	
	vUIChatFrameTop:SetScaledSize(Width, BAR_HEIGHT)
	vUIChatFrameBottom:SetScaledSize(Width, BAR_HEIGHT)
end

local Kill = function(object)
	if not object then
		return
	end

	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	
	if (object.GetScript and object:GetScript("OnUpdate")) then
		object:SetScript("OnUpdate", nil)
	end
	
	object.Show = function() end
	object:Hide()
end

local OnMouseWheel = function(self, delta)
	if (delta < 0) then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		else
			self:ScrollDown()
		end
	elseif (delta > 0) then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		else
			self:ScrollUp()
		end
	end
end

local UpdateEditBoxColor = function(editbox)
	local ChatType = editbox:GetAttribute("chatType")
	local Backdrop = editbox.Backdrop
	
	if Backdrop then
		if (ChatType == "CHANNEL") then
			if editbox:GetAttribute("channelTarget") then
				local ID = GetChannelName(editbox:GetAttribute("channelTarget"))
				
				if (ID == 0) then
					Backdrop.Change:SetChange(vUI:HexToRGB(Settings["ui-header-texture-color"]))
				else
					Backdrop.Change:SetChange(ChatTypeInfo[ChatType..ID].r * 0.2, ChatTypeInfo[ChatType..ID].g * 0.2, ChatTypeInfo[ChatType..ID].b * 0.2)
				end
			else
				Backdrop.Change:SetChange(vUI:HexToRGB(Settings["ui-header-texture-color"]))
			end
		else
			Backdrop.Change:SetChange(ChatTypeInfo[ChatType].r * 0.2, ChatTypeInfo[ChatType].g * 0.2, ChatTypeInfo[ChatType].b * 0.2)
		end
		
		Backdrop.Change:Play()
	end
	
	if (not editbox.header) then
		return
	end
	
	local HeaderText = editbox.header:GetText()
	local Subs = 0
	
	HeaderText, Subs = gsub(HeaderText, "%s$", "")
	
	if Subs then
		editbox.header:SetText(HeaderText)
	end
	
	editbox.HeaderBackdrop:SetScaledWidth(editbox.header:GetWidth() + 14)
end

local KillTextures = {
	"TabLeft",
	"TabMiddle",
	"TabRight",
	"TabSelectedLeft",
	"TabSelectedMiddle",
	"TabSelectedRight",
	"TabHighlightLeft",
	"TabHighlightMiddle",
	"TabHighlightRight",
	"ButtonFrameUpButton",
	"ButtonFrameDownButton",
	"ButtonFrameBottomButton",
	"ButtonFrameMinimizeButton",
	"ButtonFrame",
	"EditBoxFocusLeft",
	"EditBoxFocusMid",
	"EditBoxFocusRight",
	"EditBoxLeft",
	"EditBoxMid",
	"EditBoxRight",
}

local OnEditFocusLost = function(self)
	vUIChatFrameBottom:Show()
	
	self:Hide()
end

local OnEditFocusGained = function(self)
	vUIChatFrameBottom:Hide()
end

local CheckForBottom = function(self)
	if (not self:AtBottom() and not self.JumpButton.FadeIn:IsPlaying()) then
		if (self.JumpButton:GetAlpha() == 0) then
			self.JumpButton:Show()
			self.JumpButton.FadeIn:Play()
		end
	elseif (self:AtBottom() and self.JumpButton:IsShown() and not self.JumpButton.FadeOut:IsPlaying()) then
		if (self.JumpButton:GetAlpha() > 0) then
			self.JumpButton.FadeOut:Play()
		end
	end
end

local JumpButtonOnMouseUp = function(self)
	self:GetParent():ScrollToBottom()
end

local JumpButtonOnEnter = function(self)
	self.Arrow:SetVertexColorHex("FFFFFF")
end

local JumpButtonOnLeave = function(self)
	self.Arrow:SetVertexColorHex("00CC66")
end

local JumpButtonOnFinished = function(self)
	self.Parent:Hide()
end

local TabOnEnter = function(self)
	self.TabText:_SetTextColor(vUI:HexToRGB(Settings["chat-tab-font-color-mouseover"]))
end

local TabOnLeave = function(self)
	self.TabText:_SetTextColor(vUI:HexToRGB(Settings["chat-tab-font-color"]))
end

local StyleChatFrame = function(frame)
	if frame.Styled then
		return
	end
	
	local FrameName = frame:GetName()
	local Tab = _G[FrameName.."Tab"]
	local TabText = _G[FrameName.."TabText"]
	local EditBox = _G[FrameName.."EditBox"]
	
	if frame.ScrollBar then
		Kill(frame.ScrollBar)
		Kill(frame.ScrollToBottomButton)
		Kill(_G[FrameName.."ThumbTexture"])
	end
	
	if Tab.conversationIcon then
		Kill(Tab.conversationIconKill)
	end
	
	-- Hide editbox every time we click on a tab
	Tab:HookScript("OnClick", function()
		EditBox:Hide()
	end)
	
	-- Tabs Alpha
	Tab.mouseOverAlpha = 1
	Tab.noMouseAlpha = 1
	Tab:SetAlpha(1)
	Tab.SetAlpha = UIFrameFadeRemoveFrame
	Tab.TabText = TabText
	
	Tab:HookScript("OnEnter", TabOnEnter)
	Tab:HookScript("OnLeave", TabOnLeave)
	
	TabText:SetFontInfo(Settings["chat-tab-font"], Settings["chat-tab-font-size"], Settings["chat-tab-font-flags"])
	--TabText.SetFont = function() end
	
	TabText:SetTextColorHex(Settings["chat-tab-font-color"])
	TabText._SetTextColor = TabText.SetTextColor
	TabText.SetTextColor = function() end
	
	if Tab.glow then
		Tab.glow:SetScaledPoint("CENTER", Tab, 0, 1)
		Tab.glow:SetScaledWidth(TabText:GetWidth() + 6)
	end
	
	frame:SetFrameStrata("MEDIUM")
	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:SetClampedToScreen(false)
	frame:SetFading(false)
	frame:SetScript("OnMouseWheel", OnMouseWheel)
	frame:SetScaledSize(vUIChatFrame:GetWidth() - 8, vUIChatFrame:GetHeight() - 8)
	frame:SetFrameLevel(vUIChatFrame:GetFrameLevel() + 1)
	frame:SetFrameStrata("MEDIUM")
	frame:SetJustifyH("LEFT")
	frame:SetFading(Settings["chat-enable-fading"])
	frame:SetTimeVisible(Settings["chat-fade-time"])
	frame:Hide()
	
	FCF_SetChatWindowFontSize(nil, frame, 12)
	
	if (not frame.isLocked) then
		FCF_SetLocked(frame, 1)
	end
	
	EditBox:ClearAllPoints()
	EditBox:SetScaledPoint("TOPLEFT", vUIChatFrameBottom, 5, -2)
	EditBox:SetScaledPoint("BOTTOMRIGHT", vUIChatFrameBottom, -1, 2)
	EditBox:SetFontInfo(Settings["chat-font"], Settings["chat-font-size"], Settings["chat-font-flags"])
	EditBox:SetAltArrowKeyMode(false)
	EditBox:Hide()
	EditBox:HookScript("OnEditFocusLost", OnEditFocusLost)
	EditBox:HookScript("OnEditFocusGained", OnEditFocusGained)
	
	EditBox.HeaderBackdrop = CreateFrame("Frame", nil, EditBox)
	EditBox.HeaderBackdrop:SetBackdrop(vUI.BackdropAndBorder)
	EditBox.HeaderBackdrop:SetBackdropColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	EditBox.HeaderBackdrop:SetBackdropBorderColor(0, 0, 0)
	EditBox.HeaderBackdrop:SetScaledSize(60, 22)
	EditBox.HeaderBackdrop:SetScaledPoint("LEFT", vUIChatFrameBottom, 0, 0)
	EditBox.HeaderBackdrop:SetFrameStrata("HIGH")
	EditBox.HeaderBackdrop:SetFrameLevel(1)
	
	EditBox.HeaderBackdrop.Tex = EditBox.HeaderBackdrop:CreateTexture(nil, "BORDER")
	EditBox.HeaderBackdrop.Tex:SetScaledPoint("TOPLEFT", EditBox.HeaderBackdrop, 1, -1)
	EditBox.HeaderBackdrop.Tex:SetScaledPoint("BOTTOMRIGHT", EditBox.HeaderBackdrop, -1, 1)
	EditBox.HeaderBackdrop.Tex:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	EditBox.HeaderBackdrop.Tex:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	EditBox.Backdrop = CreateFrame("Frame", nil, EditBox)
	EditBox.Backdrop:SetBackdrop(vUI.BackdropAndBorder)
	EditBox.Backdrop:SetBackdropColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	EditBox.Backdrop:SetBackdropBorderColor(0, 0, 0)
	EditBox.Backdrop:SetScaledPoint("TOPLEFT", EditBox.HeaderBackdrop, "TOPRIGHT", 2, 0)
	EditBox.Backdrop:SetScaledPoint("BOTTOMRIGHT", vUIChatFrameBottom, 0, 0)
	EditBox.Backdrop:SetFrameStrata("HIGH")
	EditBox.Backdrop:SetFrameLevel(1)
	
	EditBox.Backdrop.Tex = EditBox.Backdrop:CreateTexture(nil, "BORDER")
	EditBox.Backdrop.Tex:SetScaledPoint("TOPLEFT", EditBox.Backdrop, 1, -1)
	EditBox.Backdrop.Tex:SetScaledPoint("BOTTOMRIGHT", EditBox.Backdrop, -1, 1)
	EditBox.Backdrop.Tex:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	EditBox.Backdrop.Tex:SetVertexColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	
	local AnimGroup = CreateAnimationGroup(EditBox.Backdrop.Tex)
	
	EditBox.Backdrop.Change = AnimGroup:CreateAnimation("Color")
	EditBox.Backdrop.Change:SetColorType("vertex")
	EditBox.Backdrop.Change:SetEasing("in")
	EditBox.Backdrop.Change:SetDuration(0.2)
	
	EditBox.header:ClearAllPoints()
	EditBox.header:SetScaledPoint("CENTER", EditBox.HeaderBackdrop, 0, 0)
	EditBox.header:SetFontInfo(Settings["chat-font"], Settings["chat-font-size"], Settings["chat-font-flags"])
	EditBox.header:SetJustifyH("CENTER")
	
	-- Scroll to bottom
	local JumpButton = CreateFrame("Frame", nil, frame)
	JumpButton:SetScaledSize(20, 20)
	JumpButton:SetScaledPoint("BOTTOMRIGHT", frame, 0, 0)
	JumpButton:SetBackdrop(vUI.BackdropAndBorder)
	JumpButton:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	JumpButton:SetBackdropBorderColor(0, 0, 0)
	JumpButton:SetFrameStrata("HIGH")
	JumpButton:SetScript("OnMouseUp", JumpButtonOnMouseUp)
	JumpButton:SetScript("OnEnter", JumpButtonOnEnter)
	JumpButton:SetScript("OnLeave", JumpButtonOnLeave)
	JumpButton:SetAlpha(0)
	JumpButton:Hide()
	
	JumpButton.Texture = JumpButton:CreateTexture(nil, "ARTWORK")
	JumpButton.Texture:SetScaledPoint("TOPLEFT", JumpButton, 1, -1)
	JumpButton.Texture:SetScaledPoint("BOTTOMRIGHT", JumpButton, -1, 1)
	JumpButton.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	JumpButton.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	JumpButton.Arrow = JumpButton:CreateTexture(nil, "OVERLAY")
	JumpButton.Arrow:SetScaledPoint("CENTER", JumpButton, 0, 0)
	JumpButton.Arrow:SetScaledSize(16, 16)
	JumpButton.Arrow:SetTexture(Media:GetTexture("Arrow Down"))
	JumpButton.Arrow:SetVertexColorHex("00CC66")
	
	JumpButton.Fade = CreateAnimationGroup(JumpButton)
	
	JumpButton.FadeIn = JumpButton.Fade:CreateAnimation("Fade")
	JumpButton.FadeIn:SetEasing("in")
	JumpButton.FadeIn:SetDuration(0.15)
	JumpButton.FadeIn:SetChange(1)
	
	JumpButton.FadeOut = JumpButton.Fade:CreateAnimation("Fade")
	JumpButton.FadeOut:SetEasing("out")
	JumpButton.FadeOut:SetDuration(0.15)
	JumpButton.FadeOut:SetChange(0)
	JumpButton.FadeOut:SetScript("OnFinished", JumpButtonOnFinished)
	
	frame.JumpButton = JumpButton
	
	-- Remove textures
	for i = 1, #CHAT_FRAME_TEXTURES do
		_G[FrameName..CHAT_FRAME_TEXTURES[i]]:SetTexture(nil)
	end
	
	for i = 1, #KillTextures do
		Kill(_G[FrameName..KillTextures[i]])
	end
	
	hooksecurefunc(frame, "SetScrollOffset", CheckForBottom)
	
	frame.Styled = true
end

local StyleTemporaryWindow = function()
	local Frame = FCF_GetCurrentChatFrame()
	
	if (not Frame.Styled) then
		StyleChatFrame(Frame)
	end
end

local MoveChatFrames = function()
	for i = 1, NUM_CHAT_WINDOWS do
		local Frame = _G["ChatFrame"..i]
		
		Frame:SetScaledSize(vUIChatFrame:GetWidth() - 8, vUIChatFrame:GetHeight() - 8)
		Frame:SetFrameLevel(vUIChatFrame:GetFrameLevel() + 1)
		Frame:SetFrameStrata("MEDIUM")
		Frame:SetJustifyH("LEFT")
		
		if (Frame:GetID() == 1) then
			Frame:ClearAllPoints()
			Frame:SetScaledPoint("TOPLEFT", vUIChatFrame, 4, -4)
			Frame:SetScaledPoint("BOTTOMRIGHT", vUIChatFrame, -4, 4)
		end
		
		if (not Frame.isLocked) then
			FCF_SetLocked(Frame, 1)
		end
		
		FCF_SetChatWindowFontSize(nil, Frame, Settings["chat-font-size"])
		
		local Font, IsPixel = Media:GetFont(Settings["chat-font"])
		
		if IsPixel then
			Frame:SetFont(Font, Settings["chat-font-size"], "MONOCHROME, OUTLINE")
			Frame:SetShadowColor(0, 0, 0, 0)
		else
			Frame:SetFont(Font, Settings["chat-font-size"], Settings["chat-font-flags"])
			Frame:SetShadowColor(0, 0, 0)
			Frame:SetShadowOffset(1, -1)
		end
	end
	
	GeneralDockManager:ClearAllPoints()
	GeneralDockManager:SetScaledWidth(FRAME_WIDTH + 16)
	--GeneralDockManager:SetScaledPoint("CENTER", vUIChatFrameTop, 0, 6)
	GeneralDockManager:SetScaledPoint("LEFT", vUIChatFrameTop, 0, 6)
	GeneralDockManager:SetFrameStrata("MEDIUM")
	
	DEFAULT_CHAT_FRAME:SetUserPlaced(true)
end

local Setup = function()
	for i = 1, NUM_CHAT_WINDOWS do
		local Frame = _G["ChatFrame"..i]
		
		StyleChatFrame(Frame)
		FCFTab_UpdateAlpha(Frame)
	end
	
	ChatTypeInfo.WHISPER.sticky = 1
	ChatTypeInfo.BN_WHISPER.sticky = 1
	ChatTypeInfo.OFFICER.sticky = 1
	ChatTypeInfo.RAID_WARNING.sticky = 1
	ChatTypeInfo.CHANNEL.sticky = 1
	
	Kill(ChatConfigFrameDefaultButton)
	Kill(ChatFrameMenuButton)
	Kill(QuickJoinToastButton)
	
	Kill(ChatFrameChannelButton)
	Kill(ChatFrameToggleVoiceDeafenButton)
	Kill(ChatFrameToggleVoiceMuteButton)
end

local Install = function()
	-- General
	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_SetWindowName(ChatFrame1, Language["General"])
	ChatFrame1:Show()
	
	-- Combat Log
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)
	FCF_SetWindowName(ChatFrame2, Language["Combat"])
	ChatFrame2:Show()
	
	-- Whispers
	FCF_OpenNewWindow(Language["Whispers"])
	FCF_SetLocked(ChatFrame3, 1)
	FCF_DockFrame(ChatFrame3)
	ChatFrame3:Show()
	
	-- Trade
	FCF_OpenNewWindow(Language["Trade"])
	FCF_SetLocked(ChatFrame4, 1)
	FCF_DockFrame(ChatFrame4)
	ChatFrame4:Show()
	
	-- Loot
	FCF_OpenNewWindow(Language["Loot"])
	FCF_SetLocked(ChatFrame5, 1)
	FCF_DockFrame(ChatFrame5)
	ChatFrame5:Show()
	
	-- General
	ChatFrame_RemoveAllMessageGroups(ChatFrame1)
	ChatFrame_RemoveChannel(ChatFrame1, TRADE)
	ChatFrame_RemoveChannel(ChatFrame1, GENERAL)
	ChatFrame_RemoveChannel(ChatFrame1, "LocalDefense")
	ChatFrame_RemoveChannel(ChatFrame1, "GuildRecruitment")
	ChatFrame_RemoveChannel(ChatFrame1, "LookingForGroup")
	
	ChatFrame_AddMessageGroup(ChatFrame1, "SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD")
	ChatFrame_AddMessageGroup(ChatFrame1, "OFFICER")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_HORDE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_ALLIANCE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_NEUTRAL")
	ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
	ChatFrame_AddMessageGroup(ChatFrame1, "ERRORS")
	ChatFrame_AddMessageGroup(ChatFrame1, "AFK")
	ChatFrame_AddMessageGroup(ChatFrame1, "DND")
	ChatFrame_AddMessageGroup(ChatFrame1, "IGNORED")
	ChatFrame_AddMessageGroup(ChatFrame1, "ACHIEVEMENT")
	
	-- Whispers
	ChatFrame_RemoveAllMessageGroups(ChatFrame3)
	ChatFrame_AddMessageGroup(ChatFrame3, "WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame3, "BN_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame3, "BN_CONVERSATION")
	
	-- Trade
	ChatFrame_RemoveAllMessageGroups(ChatFrame4)
	ChatFrame_AddChannel(ChatFrame4, TRADE)
	ChatFrame_AddChannel(ChatFrame4, GENERAL)
	
	-- Loot
	ChatFrame_RemoveAllMessageGroups(ChatFrame5)
	ChatFrame_AddMessageGroup(ChatFrame5, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame5, "COMBAT_HONOR_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame5, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddMessageGroup(ChatFrame5, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame5, "MONEY")
	ChatFrame_AddMessageGroup(ChatFrame5, "SKILL")
	
	DEFAULT_CHAT_FRAME:SetUserPlaced(true)
	
	SetCVar("chatMouseScroll", 1)
	SetCVar("chatStyle", "im")
	SetCVar("WholeChatWindowClickable", 0)
	SetCVar("WhisperMode", "inline")
	--SetCVar("BnWhisperMode", "inline")
	SetCVar("removeChatDelay", 1)
	
	--MoveChatFrames()
	FCF_SelectDockFrame(ChatFrame1)
end

RAID_CLASS_COLORS["SHAMAN"].r = 0
RAID_CLASS_COLORS["SHAMAN"].g = 0.44
RAID_CLASS_COLORS["SHAMAN"].b = 0.87
RAID_CLASS_COLORS["SHAMAN"].colorStr = "ff0070DE"

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("PLAYER_LOGIN")
EventFrame:SetScript("OnEvent", function(self, event)
	if self[event] then
		self[event](self, event)
	end
end)

EventFrame["UI_SCALE_CHANGED"] = MoveChatFrames

EventFrame["PLAYER_LOGIN"] = function(self, event)
	if (not Settings["chat-enable"]) then
		self:UnregisterEvent(event)
		
		return
	end
	
	CreateChatFramePanels()
	Setup()
	
	if (not vUIData) then
		vUIData = {}
	end
	
	if (not vUIData.ChatInstalled) then
		Install()
		
		vUIData.ChatInstalled = true
	end
	
	MoveChatFrames()
	
	_G["CHAT_DISCORD_SEND"] = Language["Discord: "]
	_G["CHAT_URL_SEND"] = Language["URL: "]
	_G["CHAT_EMAIL_SEND"] = Language["Email: "]
	_G["CHAT_FRIEND_SEND"] = Language["Friend Tag:"]
	
	ChatTypeInfo["URL"] = {sticky = 0, r = 255/255, g = 206/255,  b = 84/255}
	ChatTypeInfo["EMAIL"] = {sticky = 0, r = 102/255, g = 187/255,  b = 106/255}
	ChatTypeInfo["DISCORD"] = {sticky = 0, r = 114/255, g = 137/255,  b = 218/255}
	ChatTypeInfo["FRIEND"] = {sticky = 0, r = 0, g = 170/255,  b = 255/255}
	
	ChatTypeInfo["SAY"].colorNameByClass = true
	ChatTypeInfo["YELL"].colorNameByClass = true
	ChatTypeInfo["GUILD"].colorNameByClass = true
	ChatTypeInfo["OFFICER"].colorNameByClass = true
	ChatTypeInfo["WHISPER"].colorNameByClass = true
	ChatTypeInfo["WHISPER_INFORM"].colorNameByClass = true
	ChatTypeInfo["PARTY"].colorNameByClass = true
	ChatTypeInfo["PARTY_LEADER"].colorNameByClass = true
	ChatTypeInfo["RAID"].colorNameByClass = true
	ChatTypeInfo["RAID_LEADER"].colorNameByClass = true
	ChatTypeInfo["RAID_WARNING"].colorNameByClass = true
	--ChatTypeInfo["BATTLEGROUND"].colorNameByClass = true
	--ChatTypeInfo["BATTLEGROUND_LEADER"].colorNameByClass = true
	ChatTypeInfo["EMOTE"].colorNameByClass = true
	ChatTypeInfo["CHANNEL1"].colorNameByClass = true
	ChatTypeInfo["CHANNEL2"].colorNameByClass = true
	ChatTypeInfo["CHANNEL3"].colorNameByClass = true
	ChatTypeInfo["CHANNEL4"].colorNameByClass = true
	ChatTypeInfo["CHANNEL5"].colorNameByClass = true
	ChatTypeInfo["CHANNEL6"].colorNameByClass = true
	ChatTypeInfo["CHANNEL7"].colorNameByClass = true
	ChatTypeInfo["CHANNEL8"].colorNameByClass = true
	ChatTypeInfo["CHANNEL9"].colorNameByClass = true
	ChatTypeInfo["CHANNEL10"].colorNameByClass = true
	ChatTypeInfo["CHANNEL11"].colorNameByClass = true
	ChatTypeInfo["CHANNEL12"].colorNameByClass = true
	ChatTypeInfo["CHANNEL13"].colorNameByClass = true
	ChatTypeInfo["CHANNEL14"].colorNameByClass = true
	ChatTypeInfo["CHANNEL15"].colorNameByClass = true
	ChatTypeInfo["CHANNEL16"].colorNameByClass = true
	ChatTypeInfo["CHANNEL17"].colorNameByClass = true
	ChatTypeInfo["CHANNEL18"].colorNameByClass = true
	ChatTypeInfo["CHANNEL19"].colorNameByClass = true
	ChatTypeInfo["CHANNEL20"].colorNameByClass = true
	
	if (GetCVar("colorChatNamesByClass") == 0) then
		SetCVar("colorChatNamesByClass", 1)
	end
	
	hooksecurefunc("ChatEdit_UpdateHeader", UpdateEditBoxColor)
	hooksecurefunc("FCF_OpenTemporaryWindow", StyleTemporaryWindow)
	
	self:RegisterEvent("UI_SCALE_CHANGED")
	self:UnregisterEvent(event)
end

vUI.FormatLinks = FormatLinks

local UpdateOpacity = function(value)
	local R, G, B = vUI:HexToRGB(Settings["ui-window-main-color"])
	
	vUIChatFrame:SetBackdropColor(R, G, B, (value / 100))
end

local UpdateChatFont = function()
	for i = 1, NUM_CHAT_WINDOWS do
		local Frame = _G["ChatFrame"..i]

		FCF_SetChatWindowFontSize(nil, Frame, Settings["chat-font-size"])
		
		local Font, IsPixel = Media:GetFont(Settings["chat-font"])
		
		if IsPixel then
			Frame:SetFont(Font, Settings["chat-font-size"], "MONOCHROME, OUTLINE")
			Frame:SetShadowColor(0, 0, 0, 0)
		else
			Frame:SetFont(Font, Settings["chat-font-size"], Settings["chat-font-flags"])
			Frame:SetShadowColor(0, 0, 0)
			Frame:SetShadowOffset(1, -1)
		end
	end
end

local UpdateChatTabFont = function()
	local R, G, B = vUI:HexToRGB(Settings["chat-tab-font-color"])

	for i = 1, NUM_CHAT_WINDOWS do
		local TabText = _G["ChatFrame" .. i .. "TabText"]
		local Font, IsPixel = Media:GetFont(Settings["chat-tab-font"])
		
		TabText:_SetTextColor(R, G, B)
		
		if IsPixel then
			TabText:SetFont(Font, Settings["chat-tab-font-size"], "MONOCHROME, OUTLINE")
			TabText:SetShadowColor(0, 0, 0, 0)
		else
			TabText:SetFont(Font, Settings["chat-tab-font-size"], Settings["chat-tab-font-flags"])
			TabText:SetShadowColor(0, 0, 0)
			TabText:SetShadowOffset(1, -1)
		end
	end
end

local RunChatInstall = function()
	Install()
	ReloadUI()
end

local UpdateEnableFading = function(value)
	for i = 1, NUM_CHAT_WINDOWS do
		_G["ChatFrame"..i]:SetFading(value)
	end
end

local UpdateFadeTime = function(value)
	for i = 1, NUM_CHAT_WINDOWS do
		_G["ChatFrame"..i]:SetTimeVisible(value)
	end
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Chat"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("chat-enable", Settings["chat-enable"], Language["Enable Chat Module"], "Enable the vUI chat module", ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["General"])
	Left:CreateSlider("chat-frame-width", Settings["chat-frame-width"], 300, 650, 1, "Chat Width", "Set the width of the chat frame", UpdateChatFrameSize)
	Left:CreateSlider("chat-frame-height", Settings["chat-frame-height"], 40, 350, 1, "Chat Height", "Set the height of the chat frame", UpdateChatFrameSize)
	Left:CreateSlider("chat-bg-opacity", Settings["chat-bg-opacity"], 0, 100, 5, "Background Opacity", "Set the opacity of the chat background", UpdateOpacity, nil, "%")
	Left:CreateSlider("chat-fade-time", Settings["chat-enable-fading"], 0, 60, 5, "Set Fade Time", "Set the duration to display text before fading out", UpdateFadeTime, nil, "s")
	Left:CreateSwitch("chat-enable-fading", Settings["chat-enable-fading"], "Enable Text Fading", "Set the text to fade after the set amount of time", UpdateEnableFading)
	
	Right:CreateHeader(Language["Install"])
	Right:CreateButton(Language["Install"], Language["Install Chat Defaults"], "Set default channels and settings related to chat", RunChatInstall):RequiresReload(true)
	
	Left:CreateHeader(Language["Links"])
	Left:CreateSwitch("chat-enable-url-links", Settings["chat-enable-url-links"], Language["Enable URL Links"], "Enable URL links in the chat frame")
	Left:CreateSwitch("chat-enable-discord-links", Settings["chat-enable-discord-links"], Language["Enable Discord Links"], "Enable Discord links in the chat frame")
	Left:CreateSwitch("chat-enable-email-links", Settings["chat-enable-email-links"], Language["Enable Email Links"], "Enable email links in the chat frame")
	Left:CreateSwitch("chat-enable-friend-links", Settings["chat-enable-friend-links"], Language["Enable Friend Tag Links"], "Enable friend tag links in the chat frame")
	
	Right:CreateHeader(Language["Chat Frame Font"])
	Right:CreateDropdown("chat-font", Settings["chat-font"], Media:GetFontList(), Language["Font"], "Set the font of the chat frame", UpdateChatFont, "Font")
	Right:CreateSlider("chat-font-size", Settings["chat-font-size"], 8, 18, 1, "Font Size", "Set the font size of the chat frame", UpdateChatFont)
	Right:CreateDropdown("chat-font-flags", Settings["chat-font-flags"], Media:GetFlagsList(), Language["Font Flags"], "Set the font flags of the chat frame", UpdateChatFont)
	
	Right:CreateHeader(Language["Tab Font"])
	Right:CreateDropdown("chat-tab-font", Settings["chat-tab-font"], Media:GetFontList(), Language["Font"], "Set the font of the chat frame tabs", UpdateChatTabFont, "Font")
	Right:CreateSlider("chat-tab-font-size", Settings["chat-tab-font-size"], 8, 18, 1, "Font Size", "Set the font size of the chat frame tabs", UpdateChatTabFont)
	Right:CreateDropdown("chat-tab-font-flags", Settings["chat-tab-font-flags"], Media:GetFlagsList(), Language["Font Flags"], "Set the font flags of the chat frame tabs", UpdateChatTabFont)
	Right:CreateColorSelection("chat-tab-font-color", Settings["chat-tab-font-color"], Language["Font Color"], "Set the color of the chat frame tabs", UpdateChatTabFont)
	Right:CreateColorSelection("chat-tab-font-color-mouseover", Settings["chat-tab-font-color-mouseover"], Language["Font Color Mouseover"], "Set the color of the chat frame tab while mousing over it")
end)