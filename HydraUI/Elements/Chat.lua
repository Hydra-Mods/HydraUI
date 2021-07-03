local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

-- Default setting values
Defaults["chat-enable"] = true
Defaults["chat-bg-opacity"] = 70
Defaults["chat-enable-url-links"] = true
Defaults["chat-enable-discord-links"] = true
Defaults["chat-enable-email-links"] = true
Defaults["chat-enable-friend-links"] = true
Defaults["chat-font"] = "PT Sans"
Defaults["chat-font-size"] = 12
Defaults["chat-font-flags"] = ""
Defaults["chat-tab-font"] = "Roboto"
Defaults["chat-tab-font-size"] = 12
Defaults["chat-tab-font-flags"] = ""
Defaults["chat-tab-font-color"] = "FFFFFF"
Defaults["chat-tab-font-color-mouseover"] = "FFCE54"
Defaults["chat-frame-width"] = 392
Defaults["chat-frame-height"] = 104
Defaults["chat-enable-fading"] = false
Defaults["chat-fade-time"] = 15
Defaults["chat-link-tooltip"] = true
Defaults["chat-shorten-channels"] = true

local select = select
local tostring = tostring
local format = string.format
local sub = string.sub
local gsub = string.gsub
local match = string.match

local BarHeight = 22 -- Potential setting

local SetHyperlink = ItemRefTooltip.SetHyperlink
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
local ChatEdit_ActivateChat = ChatEdit_ActivateChat
local ChatEdit_ParseText = ChatEdit_ParseText
local ChatEdit_UpdateHeader = ChatEdit_UpdateHeader

local Chat = HydraUI:NewModule("Chat")

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

Chat.RemoveTextures = {
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

function Chat:CreateChatWindow()
	local R, G, B = HydraUI:HexToRGB(Settings["ui-window-main-color"])
	local Width = Settings["chat-frame-width"]
	
	self:SetSize(Width + 4, Settings["chat-frame-height"] + (BarHeight * 2) + (4 * 2))
	self:SetPoint("BOTTOMLEFT", HydraUI.UIParent, 11, 11)
	self:SetBackdrop(HydraUI.BackdropAndBorder)
	self:SetBackdropColor(R, G, B, (Settings["chat-bg-opacity"] / 100))
	self:SetBackdropBorderColor(0, 0, 0)
	self:SetFrameStrata("LOW")
	
	-- All this just to achieve an empty center :P
	self.Top = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.Top:SetHeight(BarHeight + 4)
	self.Top:SetPoint("TOPLEFT", self, 0, 0)
	self.Top:SetPoint("TOPRIGHT", self, 0, 0)
	self.Top:SetBackdrop(HydraUI.BackdropAndBorder)
	self.Top:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.Top:SetBackdropBorderColor(0, 0, 0, 0)
	self.Top:SetFrameStrata("LOW")
	
	self.Bottom = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.Bottom:SetHeight(BarHeight + 4)
	self.Bottom:SetPoint("BOTTOMLEFT", self, 0, 0)
	self.Bottom:SetPoint("BOTTOMRIGHT", self, 0, 0)
	self.Bottom:SetBackdrop(HydraUI.BackdropAndBorder)
	self.Bottom:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.Bottom:SetBackdropBorderColor(0, 0, 0, 0)
	self.Bottom:SetFrameStrata("LOW")
	
	self.Left = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.Left:SetWidth(2)
	self.Left:SetPoint("TOPLEFT", self, 0, 0)
	self.Left:SetPoint("BOTTOMLEFT", self, 0, 0)
	self.Left:SetBackdrop(HydraUI.BackdropAndBorder)
	self.Left:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.Left:SetBackdropBorderColor(0, 0, 0, 0)
	self.Left:SetFrameStrata("LOW")
	
	self.Right = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.Right:SetWidth(2)
	self.Right:SetPoint("TOPRIGHT", self, 0, 0)
	self.Right:SetPoint("BOTTOMRIGHT", self, 0, 0)
	self.Right:SetBackdrop(HydraUI.BackdropAndBorder)
	self.Right:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.Right:SetBackdropBorderColor(0, 0, 0, 0)
	self.Right:SetFrameStrata("LOW")
	
	self.TopBar = CreateFrame("Frame", "HydraUIChatFrameTop", HydraUI.UIParent, "BackdropTemplate")
	self.TopBar:SetHeight(BarHeight)
	self.TopBar:SetPoint("TOPLEFT", self, 2, -2)
	self.TopBar:SetPoint("TOPRIGHT", self, -2, -2)
	self.TopBar:SetBackdrop(HydraUI.BackdropAndBorder)
	self.TopBar:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.TopBar:SetBackdropBorderColor(0, 0, 0)
	self.TopBar:SetFrameStrata("MEDIUM")
	
	self.TopBar.Texture = self.TopBar:CreateTexture(nil, "OVERLAY")
	self.TopBar.Texture:SetPoint("TOPLEFT", self.TopBar, 1, -1)
	self.TopBar.Texture:SetPoint("BOTTOMRIGHT", self.TopBar, -1, 1)
	self.TopBar.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.TopBar.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	
	self.BottomBar = CreateFrame("Frame", "HydraUIChatFrameBottom", HydraUI.UIParent, "BackdropTemplate")
	self.BottomBar:SetHeight(BarHeight)
	self.BottomBar:SetPoint("BOTTOMLEFT", self, 2, 2)
	self.BottomBar:SetPoint("BOTTOMRIGHT", self, -2, 2)
	self.BottomBar:SetBackdrop(HydraUI.BackdropAndBorder)
	self.BottomBar:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	self.BottomBar:SetBackdropBorderColor(0, 0, 0)
	self.BottomBar:SetFrameStrata("MEDIUM")
	
	self.BottomBar.Texture = self.BottomBar:CreateTexture(nil, "OVERLAY")
	self.BottomBar.Texture:SetPoint("TOPLEFT", self.BottomBar, 1, -1)
	self.BottomBar.Texture:SetPoint("BOTTOMRIGHT", self.BottomBar, -1, 1)
	self.BottomBar.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.BottomBar.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	
	self.Anchor = CreateFrame("Frame", nil, self)
	self.Anchor:SetPoint("TOPLEFT", self.TopBar, "BOTTOMLEFT", 0, -2)
	self.Anchor:SetPoint("BOTTOMRIGHT", self.BottomBar, "TOPRIGHT", 0, 2)
	
	self.OuterOutline = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.OuterOutline:SetPoint("TOPLEFT", self.TopBar, -3, 3)
	self.OuterOutline:SetPoint("BOTTOMRIGHT", self.BottomBar, 3, -3)
	self.OuterOutline:SetBackdrop(HydraUI.Outline)
	self.OuterOutline:SetBackdropBorderColor(0, 0, 0)
	
	self.InnerOutline = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.InnerOutline:SetPoint("TOPLEFT", self.TopBar, "BOTTOMLEFT", 0, -2)
	self.InnerOutline:SetPoint("BOTTOMRIGHT", self.BottomBar, "TOPRIGHT", 0, 2)
	self.InnerOutline:SetBackdrop(HydraUI.Outline)
	self.InnerOutline:SetBackdropBorderColor(0, 0, 0)
	
	HydraUI:CreateMover(self, 2)
end

local Disable = function(object)
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
			--self:ScrollToBottom()
			ChatFrame_ScrollToBottom()
		else
			self:ScrollDown()
			ChatFrame_ScrollDown()
		end
	elseif (delta > 0) then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		else
			--self:ScrollUp()
			ChatFrame_ScrollUp()
		end
	end
end

Chat.ChatEdit_UpdateHeader = function(editbox)
	local ChatType = editbox:GetAttribute("chatType")
	local Backdrop = editbox.Backdrop
	
	if Backdrop then
		if (ChatType == "CHANNEL") then
			if editbox:GetAttribute("channelTarget") then
				local ID = GetChannelName(editbox:GetAttribute("channelTarget"))
				
				if (ID == 0) then
					Backdrop.Change:SetChange(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
				else
					Backdrop.Change:SetChange(ChatTypeInfo[ChatType..ID].r * 0.2, ChatTypeInfo[ChatType..ID].g * 0.2, ChatTypeInfo[ChatType..ID].b * 0.2)
				end
			else
				Backdrop.Change:SetChange(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
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
	
	if editbox.HeaderBackdrop then
		editbox.HeaderBackdrop:SetWidth(editbox.header:GetWidth() + 14)
	end
end

local OnEditFocusLost = function(self)
	Chat.BottomBar:Show()
	
	self:Hide()
end

local OnEditFocusGained = function(self)
	Chat.BottomBar:Hide()
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
	self.Arrow:SetVertexColor(1, 1, 1)
end

local JumpButtonOnLeave = function(self)
	self.Arrow:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
end

local JumpButtonOnFinished = function(self)
	self.Parent:Hide()
end

local TabOnEnter = function(self)
	self.TabText:_SetTextColor(HydraUI:HexToRGB(Settings["chat-tab-font-color-mouseover"]))
end

local TabOnLeave = function(self)
	self.TabText:_SetTextColor(HydraUI:HexToRGB(Settings["chat-tab-font-color"]))
end

local CopyWindowOnEnterPressed = function(self)
	self:SetAutoFocus(false)
	self:ClearFocus()
end

local CopyWindowOnMouseDown = function(self)
	self:SetAutoFocus(true)
end

local FadeOnFinished = function(self)
	self.Parent:Hide()
end

function Chat:CreateCopyWindow()
	if self.CopyWindow then
		return
	end
	
	local Window = CreateFrame("Frame", nil, HydraUI.UIParent, "BackdropTemplate")
	Window:SetSize(Settings["chat-frame-width"] + 6, Settings["chat-frame-height"] + 6)
	Window:SetPoint("BOTTOM", self, "TOP", 0, 3)
	Window:SetBackdrop(HydraUI.BackdropAndBorder)
	Window:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	Window:SetBackdropBorderColor(0, 0, 0)
	Window:SetFrameStrata("DIALOG")
	Window:SetMovable(true)
	Window:EnableMouse(true)
	Window:RegisterForDrag("LeftButton")
	Window:SetScript("OnDragStart", Window.StartMoving)
	Window:SetScript("OnDragStop", Window.StopMovingOrSizing)
	Window:SetClampedToScreen(true)
	Window:SetAlpha(0)
	Window:Hide()
	
	-- Header
	Window.Header = CreateFrame("Frame", nil, Window, "BackdropTemplate")
	Window.Header:SetHeight(20)
	Window.Header:SetPoint("TOPLEFT", Window, 3, -3)
	Window.Header:SetPoint("TOPRIGHT", Window, -((3 + 2) + 20), -3)
	Window.Header:SetBackdrop(HydraUI.BackdropAndBorder)
	Window.Header:SetBackdropColor(0, 0, 0)
	Window.Header:SetBackdropBorderColor(0, 0, 0)
	
	Window.HeaderTexture = Window.Header:CreateTexture(nil, "OVERLAY")
	Window.HeaderTexture:SetPoint("TOPLEFT", Window.Header, 1, -1)
	Window.HeaderTexture:SetPoint("BOTTOMRIGHT", Window.Header, -1, 1)
	Window.HeaderTexture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	Window.HeaderTexture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	Window.Header.Text = Window.Header:CreateFontString(nil, "OVERLAY")
	Window.Header.Text:SetPoint("LEFT", Window.Header, 5, -1)
	HydraUI:SetFontInfo(Window.Header.Text, Settings["chat-tab-font"], Settings["chat-tab-font-size"])
	Window.Header.Text:SetJustifyH("LEFT")
	Window.Header.Text:SetText("|cFF" .. Settings["chat-tab-font-color"] .. Language["Copy text"] .. "|r")
	
	-- Close button
	Window.CloseButton = CreateFrame("Frame", nil, Window, "BackdropTemplate")
	Window.CloseButton:SetSize(20, 20)
	Window.CloseButton:SetPoint("TOPRIGHT", Window, -3, -3)
	Window.CloseButton:SetBackdrop(HydraUI.BackdropAndBorder)
	Window.CloseButton:SetBackdropColor(0, 0, 0, 0)
	Window.CloseButton:SetBackdropBorderColor(0, 0, 0)
	Window.CloseButton:SetScript("OnEnter", function(self) self.Cross:SetVertexColor(HydraUI:HexToRGB("C0392B")) end)
	Window.CloseButton:SetScript("OnLeave", function(self) self.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE")) end)
	Window.CloseButton:SetScript("OnMouseUp", function(self)
		self.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
		
		self:GetParent().FadeOut:Play()
	end)
	
	Window.CloseButton:SetScript("OnMouseDown", function(self)
		local R, G, B = HydraUI:HexToRGB(Settings["ui-header-texture-color"])
		
		self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
	end)
	
	Window.CloseButton.Texture = Window.CloseButton:CreateTexture(nil, "ARTWORK")
	Window.CloseButton.Texture:SetPoint("TOPLEFT", Window.CloseButton, 1, -1)
	Window.CloseButton.Texture:SetPoint("BOTTOMRIGHT", Window.CloseButton, -1, 1)
	Window.CloseButton.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	Window.CloseButton.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	Window.CloseButton.Cross = Window.CloseButton:CreateTexture(nil, "OVERLAY")
	Window.CloseButton.Cross:SetPoint("CENTER", Window.CloseButton, 0, 0)
	Window.CloseButton.Cross:SetSize(16, 16)
	Window.CloseButton.Cross:SetTexture(Assets:GetTexture("Close"))
	Window.CloseButton.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE"))
	
	Window.Inner = CreateFrame("Frame", nil, Window, "BackdropTemplate")
	Window.Inner:SetPoint("TOPLEFT", Window.Header, "BOTTOMLEFT", 0, -2)
	Window.Inner:SetPoint("BOTTOMRIGHT", Window, -3, 3)
	Window.Inner:SetBackdrop(HydraUI.BackdropAndBorder)
	Window.Inner:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	Window.Inner:SetBackdropBorderColor(0, 0, 0)
	
	Window.Input = CreateFrame("EditBox", nil, Window.Inner)
	HydraUI:SetFontInfo(Window.Input, Settings["ui-widget-font"], Settings["ui-font-size"])
	Window.Input:SetPoint("TOPLEFT", Window.Inner, 3, -3)
	Window.Input:SetPoint("BOTTOMRIGHT", Window.Inner, -3, 3)
	Window.Input:SetFrameStrata("DIALOG")
	Window.Input:SetJustifyH("LEFT")
	Window.Input:SetAutoFocus(false)
	Window.Input:EnableKeyboard(true)
	Window.Input:EnableMouse(true)
	Window.Input:SetMultiLine(true)
	Window.Input:SetMaxLetters(255)
	Window.Input:SetCursorPosition(0)
	
	Window.Input:SetScript("OnEnterPressed", CopyWindowOnEnterPressed)
	Window.Input:SetScript("OnEscapePressed", CopyWindowOnEnterPressed)
	Window.Input:SetScript("OnMouseDown", CopyWindowOnMouseDown)
	
	-- This just makes the animation look better. That's all. ಠ_ಠ
	Window.BlackTexture = Window:CreateTexture(nil, "BACKGROUND", -7)
	Window.BlackTexture:SetPoint("TOPLEFT", Window, 0, 0)
	Window.BlackTexture:SetPoint("BOTTOMRIGHT", Window, 0, 0)
	Window.BlackTexture:SetTexture(Assets:GetTexture("Blank"))
	Window.BlackTexture:SetVertexColor(0, 0, 0, 0)
	
	Window.Fade = CreateAnimationGroup(Window)
	
	Window.FadeIn = Window.Fade:CreateAnimation("Fade")
	Window.FadeIn:SetEasing("in")
	Window.FadeIn:SetDuration(0.15)
	Window.FadeIn:SetChange(1)
	
	Window.FadeOut = Window.Fade:CreateAnimation("Fade")
	Window.FadeOut:SetEasing("out")
	Window.FadeOut:SetDuration(0.15)
	Window.FadeOut:SetChange(0)
	Window.FadeOut:SetScript("OnFinished", FadeOnFinished)
	
	self.CopyWindow = Window
	
	return Window
end

local OnTextCopied = function(self, text)
	if (not Chat.CopyWindow) then
		Chat:CreateCopyWindow()
	end
	
	if (not Chat.CopyWindow:IsVisible()) then
		Chat.CopyWindow:SetAlpha(0)
		Chat.CopyWindow:Show()
		Chat.CopyWindow.FadeIn:Play()
	end
	
	Chat.CopyWindow.Input:SetText(text)
	Chat.CopyWindow.Input:HighlightText()
	Chat.CopyWindow.Input:SetAutoFocus(true)
end

local CopyButtonOnMouseUp = function(self)
	local Parent = self:GetParent()
	
	if Parent:IsTextCopyable() then
		Parent:SetTextCopyable(false)
		
		Parent.CopyHighlight:SetAlpha(0)
	else
		Parent:SetTextCopyable(true)
		
		Parent.CopyHighlight:SetAlpha(0.1)
	end
end

local ChatFrameOnEnter = function(self)
	self.CopyButton:SetAlpha(1)
end

local ChatFrameOnLeave = function(self)
	self.CopyButton:SetAlpha(0)
end

local ValidLinkTypes = {
	["item"] = true,
	["spell"] = true,
}

local OnHyperlinkEnter = function(self, link, text, button)
	local LinkType = match(link, "^(%a+):")
	
	if (not ValidLinkTypes[LinkType]) then
		return
	end
	
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	GameTooltip:SetHyperlink(link)
	GameTooltip:Show()
end

local OnHyperlinkLeave = function(self)
	GameTooltip:Hide()
end

function Chat:OverrideAddMessage(msg, ...)
	msg = gsub(msg, "|h%[(%d+)%.%s.-%]|h", "|h[%1]|h")
	
	self.OldAddMessage(self, msg, ...)
end

function Chat:StyleChatFrame(frame)
	if frame.Styled then
		return
	end
	
	if Settings["chat-shorten-channels"] then
		frame.OldAddMessage = frame.AddMessage
		frame.AddMessage = Chat.OverrideAddMessage
	end
	
	local FrameName = frame:GetName()
	local Tab = _G[FrameName.."Tab"]
	local TabText = _G[FrameName.."TabText"]
	local EditBox = _G[FrameName.."EditBox"]
	
	if frame.ScrollBar then
		Disable(frame.ScrollBar)
		Disable(frame.ScrollToBottomButton)
		Disable(_G[FrameName.."ThumbTexture"])
	end
	
	if Tab.conversationIcon then
		Disable(Tab.conversationIconKill)
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
	
	HydraUI:SetFontInfo(TabText, Settings["chat-tab-font"], Settings["chat-tab-font-size"], Settings["chat-tab-font-flags"])
	--TabText.SetFont = function() end
	
	TabText:SetTextColor(HydraUI:HexToRGB(Settings["chat-tab-font-color"]))
	TabText._SetTextColor = TabText.SetTextColor
	TabText.SetTextColor = function() end
	
	if Tab.glow then
		Tab.glow:SetPoint("CENTER", Tab, 0, 1)
		Tab.glow:SetWidth(TabText:GetWidth() + 6)
	end
	
	frame:SetFrameStrata("MEDIUM")
	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:SetClampedToScreen(false)
	frame:SetFading(false)
	--frame:SetMovable(true)
	frame:SetScript("OnMouseWheel", OnMouseWheel)
	frame:SetSize(self:GetWidth() - 8, self:GetHeight() - 8)
	frame:SetFrameLevel(self:GetFrameLevel() + 1)
	frame:SetFrameStrata("MEDIUM")
	frame:SetJustifyH("LEFT")
	frame:SetFading(Settings["chat-enable-fading"])
	frame:SetTimeVisible(Settings["chat-fade-time"])
	frame:HookScript("OnEnter", ChatFrameOnEnter)
	frame:HookScript("OnLeave", ChatFrameOnLeave)
	frame:Hide()
	
	if Settings["chat-link-tooltip"] then
		frame:SetScript("OnHyperlinkEnter", OnHyperlinkEnter)
		frame:SetScript("OnHyperlinkLeave", OnHyperlinkLeave)
	end
	
	FCF_SetChatWindowFontSize(nil, frame, 12)
	
	if (not frame.isLocked) then
		FCF_SetLocked(frame, 1)
	end
	
	EditBox:ClearAllPoints()
	EditBox:SetPoint("TOPLEFT", self.BottomBar, 5, -2)
	EditBox:SetPoint("BOTTOMRIGHT", self.BottomBar, -1, 2)
	HydraUI:SetFontInfo(EditBox, Settings["chat-font"], Settings["chat-font-size"], Settings["chat-font-flags"])
	EditBox:SetAltArrowKeyMode(false)
	EditBox:Hide()
	EditBox:HookScript("OnEditFocusLost", OnEditFocusLost)
	EditBox:HookScript("OnEditFocusGained", OnEditFocusGained)
	
	EditBox.HeaderBackdrop = CreateFrame("Frame", nil, EditBox, "BackdropTemplate")
	EditBox.HeaderBackdrop:SetBackdrop(HydraUI.BackdropAndBorder)
	EditBox.HeaderBackdrop:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	EditBox.HeaderBackdrop:SetBackdropBorderColor(0, 0, 0)
	EditBox.HeaderBackdrop:SetSize(60, 22)
	EditBox.HeaderBackdrop:SetPoint("LEFT", self.BottomBar, 0, 0)
	EditBox.HeaderBackdrop:SetFrameStrata("HIGH")
	EditBox.HeaderBackdrop:SetFrameLevel(1)
	
	EditBox.HeaderBackdrop.Tex = EditBox.HeaderBackdrop:CreateTexture(nil, "BORDER")
	EditBox.HeaderBackdrop.Tex:SetPoint("TOPLEFT", EditBox.HeaderBackdrop, 1, -1)
	EditBox.HeaderBackdrop.Tex:SetPoint("BOTTOMRIGHT", EditBox.HeaderBackdrop, -1, 1)
	EditBox.HeaderBackdrop.Tex:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	EditBox.HeaderBackdrop.Tex:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	EditBox.Backdrop = CreateFrame("Frame", nil, EditBox, "BackdropTemplate")
	EditBox.Backdrop:SetBackdrop(HydraUI.BackdropAndBorder)
	EditBox.Backdrop:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	EditBox.Backdrop:SetBackdropBorderColor(0, 0, 0)
	EditBox.Backdrop:SetPoint("TOPLEFT", EditBox.HeaderBackdrop, "TOPRIGHT", 2, 0)
	EditBox.Backdrop:SetPoint("BOTTOMRIGHT", HydraUIChatFrameBottom, 0, 0)
	EditBox.Backdrop:SetFrameStrata("HIGH")
	EditBox.Backdrop:SetFrameLevel(1)
	
	EditBox.Backdrop.Tex = EditBox.Backdrop:CreateTexture(nil, "BORDER")
	EditBox.Backdrop.Tex:SetPoint("TOPLEFT", EditBox.Backdrop, 1, -1)
	EditBox.Backdrop.Tex:SetPoint("BOTTOMRIGHT", EditBox.Backdrop, -1, 1)
	EditBox.Backdrop.Tex:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	EditBox.Backdrop.Tex:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	
	local AnimGroup = CreateAnimationGroup(EditBox.Backdrop.Tex)
	
	EditBox.Backdrop.Change = AnimGroup:CreateAnimation("Color")
	EditBox.Backdrop.Change:SetColorType("vertex")
	EditBox.Backdrop.Change:SetEasing("in")
	EditBox.Backdrop.Change:SetDuration(0.2)
	
	EditBox.header:ClearAllPoints()
	EditBox.header:SetPoint("CENTER", EditBox.HeaderBackdrop, 0, 0)
	HydraUI:SetFontInfo(EditBox.header, Settings["chat-font"], Settings["chat-font-size"], Settings["chat-font-flags"])
	EditBox.header:SetJustifyH("CENTER")
	
	-- Scroll to bottom
	local JumpButton = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	JumpButton:SetSize(20, 20)
	JumpButton:SetPoint("BOTTOMRIGHT", frame, 0, 0)
	JumpButton:SetBackdrop(HydraUI.BackdropAndBorder)
	JumpButton:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	JumpButton:SetBackdropBorderColor(0, 0, 0)
	JumpButton:SetFrameStrata("HIGH")
	JumpButton:SetScript("OnMouseUp", JumpButtonOnMouseUp)
	JumpButton:SetScript("OnEnter", JumpButtonOnEnter)
	JumpButton:SetScript("OnLeave", JumpButtonOnLeave)
	JumpButton:SetAlpha(0)
	JumpButton:Hide()
	
	JumpButton.Texture = JumpButton:CreateTexture(nil, "ARTWORK")
	JumpButton.Texture:SetPoint("TOPLEFT", JumpButton, 1, -1)
	JumpButton.Texture:SetPoint("BOTTOMRIGHT", JumpButton, -1, 1)
	JumpButton.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	JumpButton.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	JumpButton.Arrow = JumpButton:CreateTexture(nil, "OVERLAY")
	JumpButton.Arrow:SetPoint("CENTER", JumpButton, 0, 0)
	JumpButton.Arrow:SetSize(16, 16)
	JumpButton.Arrow:SetTexture(Assets:GetTexture("Arrow Down"))
	JumpButton.Arrow:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	
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
	
	frame.CopyHighlight = frame:CreateTexture(nil, "ARTWORK")
	frame.CopyHighlight:SetPoint("TOPLEFT", frame, -3, 2)
	frame.CopyHighlight:SetPoint("BOTTOMRIGHT", frame, 3, -2)
	frame.CopyHighlight:SetTexture(Assets:GetTexture("Blank"))
	frame.CopyHighlight:SetVertexColor(0.9, 0.9, 0.9)
	frame.CopyHighlight:SetAlpha(0)
	
	-- Copy chat
	local CopyButton = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	CopyButton:SetSize(24, 24)
	CopyButton:SetPoint("TOPRIGHT", frame, 0, 0)
	CopyButton:SetBackdrop(HydraUI.BackdropAndBorder)
	CopyButton:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	CopyButton:SetBackdropBorderColor(0, 0, 0)
	CopyButton:SetFrameStrata("HIGH")
	CopyButton:SetScript("OnMouseUp", CopyButtonOnMouseUp)
	CopyButton:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
	CopyButton:SetScript("OnLeave", function(self) self:SetAlpha(0) end)
	CopyButton:SetAlpha(0)
	
	CopyButton.Texture = CopyButton:CreateTexture(nil, "ARTWORK")
	CopyButton.Texture:SetPoint("CENTER", CopyButton, 0, 0)
	CopyButton.Texture:SetSize(16, 16)
	CopyButton.Texture:SetTexture(Assets:GetTexture("Copy"))
	
	frame.CopyButton = CopyButton
	
	-- Remove textures
	for i = 1, #CHAT_FRAME_TEXTURES do
		_G[FrameName..CHAT_FRAME_TEXTURES[i]]:SetTexture(nil)
	end
	
	for i = 1, #self.RemoveTextures do
		Disable(_G[FrameName..self.RemoveTextures[i]])
	end
	
	hooksecurefunc(frame, "SetScrollOffset", CheckForBottom)
	
	FCFTab_UpdateAlpha(frame)
	
	frame:SetOnTextCopiedCallback(OnTextCopied)
	
	frame.Styled = true
end

Chat.FCF_OpenTemporaryWindow = function()
	local Frame = FCF_GetCurrentChatFrame()
	
	if (_G[Frame:GetName().."Tab"]:GetText() == PET_BATTLE_COMBAT_LOG) then
		return FCF_Close(Frame)
	end
	
	if (not Frame.Styled) then
		Chat:StyleChatFrame(Frame)
	end
end

function Chat:MoveChatFrames()
	for i = 1, NUM_CHAT_WINDOWS do
		local Frame = _G["ChatFrame"..i]
		
		Frame:SetSize(self.Anchor:GetWidth() - 8, self.Anchor:GetHeight() - 8)
		Frame:SetFrameLevel(self.Anchor:GetFrameLevel() + 1)
		Frame:SetFrameStrata("MEDIUM")
		Frame:SetJustifyH("LEFT")
		
		if (Frame:GetID() == 1) then
			Frame:ClearAllPoints()
			Frame:SetPoint("TOPLEFT", self.Anchor, 4, -3)
			Frame:SetPoint("BOTTOMRIGHT", self.Anchor, -4, 3)
		end
		
		if (not Frame.isLocked) then
			FCF_SetLocked(Frame, 1)
		end
		
		FCF_SetChatWindowFontSize(nil, Frame, Settings["chat-font-size"])
		
		local Font, IsPixel = Assets:GetFont(Settings["chat-font"])
		
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
	GeneralDockManager:SetPoint("LEFT", self.TopBar, 0, 6)
	GeneralDockManager:SetPoint("RIGHT", self.TopBar, 0, 6)
	GeneralDockManager:SetFrameStrata("MEDIUM")
	
	GeneralDockManagerOverflowButton:ClearAllPoints()
	GeneralDockManagerOverflowButton:SetPoint("RIGHT", self.TopBar, -2, 0)
	
	DEFAULT_CHAT_FRAME:SetUserPlaced(true)
end

function Chat:StyleChatFrames()
	for i = 1, NUM_CHAT_WINDOWS do
		local Frame = _G["ChatFrame"..i]
		
		self:StyleChatFrame(Frame)
	end
	
	Disable(ChatConfigFrameDefaultButton)
	Disable(ChatFrameMenuButton)
	Disable(QuickJoinToastButton)
	
	Disable(ChatFrameChannelButton)
	Disable(ChatFrameToggleVoiceDeafenButton)
	Disable(ChatFrameToggleVoiceMuteButton)
	
	-- Restyle Combat Log objects
	CombatLogQuickButtonFrame_Custom:ClearAllPoints()
	CombatLogQuickButtonFrame_Custom:SetHeight(26)
	CombatLogQuickButtonFrame_Custom:SetPoint("TOPLEFT", Chat.TopBar, "BOTTOMLEFT", 0, -2)
	CombatLogQuickButtonFrame_Custom:SetPoint("TOPRIGHT", Chat.TopBar, "BOTTOMRIGHT", 0, -2)
	
	CombatLogQuickButtonFrame_CustomProgressBar:ClearAllPoints()
	CombatLogQuickButtonFrame_CustomProgressBar:SetPoint("BOTTOMLEFT", CombatLogQuickButtonFrame_Custom, 1, 1)
	CombatLogQuickButtonFrame_CustomProgressBar:SetPoint("BOTTOMRIGHT", CombatLogQuickButtonFrame_Custom, -1, 1)
	CombatLogQuickButtonFrame_CustomProgressBar:SetHeight(3)
	CombatLogQuickButtonFrame_CustomProgressBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	
	for i = 1, CombatLogQuickButtonFrame_Custom:GetNumChildren() do
		local Child = select(i, CombatLogQuickButtonFrame_Custom:GetChildren())
		
		for i = 1, Child:GetNumRegions() do
			local Region = select(i, Child:GetRegions())
			
			if (Region:GetObjectType() == "FontString") then
				HydraUI:SetFontInfo(Region, Settings["chat-tab-font"], Settings["chat-tab-font-size"], Settings["chat-tab-font-flags"])
			end
		end
	end
end

function Chat:Install()
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
	
	C_CVar.SetCVar("chatMouseScroll", 1)
	C_CVar.SetCVar("chatStyle", "im")
	C_CVar.SetCVar("WholeChatWindowClickable", 0)
	C_CVar.SetCVar("WhisperMode", "inline")
	--C_CVar.SetCVar("BnWhisperMode", "inline")
	C_CVar.SetCVar("removeChatDelay", 1)
	C_CVar.SetCVar("colorChatNamesByClass", 1)
	
	--Chat:MoveChatFrames()
	FCF_SelectDockFrame(ChatFrame1)
end

function Chat:AddMessageFilters()
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
end

function Chat:SetChatTypeInfo()
	_G["CHAT_DISCORD_SEND"] = Language["Discord: "]
	_G["CHAT_URL_SEND"] = Language["URL: "]
	_G["CHAT_EMAIL_SEND"] = Language["Email: "]
	_G["CHAT_FRIEND_SEND"] = Language["Friend Tag:"]
	
	ChatTypeInfo["URL"] = {sticky = 0, r = 255/255, g = 206/255,  b = 84/255}
	ChatTypeInfo["EMAIL"] = {sticky = 0, r = 102/255, g = 187/255,  b = 106/255}
	ChatTypeInfo["DISCORD"] = {sticky = 0, r = 114/255, g = 137/255,  b = 218/255}
	ChatTypeInfo["FRIEND"] = {sticky = 0, r = 0, g = 170/255,  b = 255/255}
	
	ChatTypeInfo["WHISPER"].sticky = 1
	ChatTypeInfo["BN_WHISPER"].sticky = 1
	ChatTypeInfo["OFFICER"].sticky = 1
	ChatTypeInfo["RAID_WARNING"].sticky = 1
	ChatTypeInfo["CHANNEL"].sticky = 1
	
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
	
	if (C_CVar.GetCVar("colorChatNamesByClass") ~= 1) then
		C_CVar.SetCVar("colorChatNamesByClass", 1)
	end
end

function Chat:Load()
	if (not Settings["chat-enable"]) then
		return
	end
	
	self:AddMessageFilters()
	self:CreateChatWindow()
	self:StyleChatFrames()
	
	if (not HydraUIData) then
		HydraUIData = {}
	end
	
	if (not HydraUIData.ChatInstalled) then
		self:Install()
		
		HydraUIData.ChatInstalled = true
	end
	
	self:MoveChatFrames()
	self:SetChatTypeInfo()
	
	self:Hook("ChatEdit_UpdateHeader")
	self:Hook("FCF_OpenTemporaryWindow")
	
	self:RegisterEvent("UI_SCALE_CHANGED")
	self:SetScript("OnEvent", self.MoveChatFrames)
end

HydraUI.FormatLinks = FormatLinks

local UpdateChatFrameSize = function()
	local Width = Settings["chat-frame-width"]
	
	Chat:SetSize(Width + 4, Settings["chat-frame-height"] + (BarHeight * 2) + (4 * 2))
	
	Chat.TopBar:ClearAllPoints()
	Chat.TopBar:SetPoint("TOPLEFT", Chat, 2, -2)
	Chat.TopBar:SetPoint("TOPRIGHT", Chat, -2, -2)
	
	Chat.BottomBar:ClearAllPoints()
	Chat.BottomBar:SetPoint("BOTTOMLEFT", Chat, 2, 2)
	Chat.BottomBar:SetPoint("BOTTOMRIGHT", Chat, -2, 2)
	
	-- Update data text width
	local DT = HydraUI:GetModule("DataText")
	
	DT:GetAnchor("Chat-Left"):SetWidth(Width / 3)
	DT:GetAnchor("Chat-Middle"):SetWidth(Width / 3)
	DT:GetAnchor("Chat-Right"):SetWidth(Width / 3)
end

local UpdateOpacity = function(value)
	local R, G, B = HydraUI:HexToRGB(Settings["ui-window-main-color"])
	
	Chat:SetBackdropColor(R, G, B, (value / 100))
end

local UpdateChatFont = function()
	for i = 1, NUM_CHAT_WINDOWS do
		local Frame = _G["ChatFrame"..i]

		FCF_SetChatWindowFontSize(nil, Frame, Settings["chat-font-size"])
		
		local Font, IsPixel = Assets:GetFont(Settings["chat-font"])
		
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
	local R, G, B = HydraUI:HexToRGB(Settings["chat-tab-font-color"])

	for i = 1, NUM_CHAT_WINDOWS do
		local TabText = _G["ChatFrame" .. i .. "TabText"]
		local Font, IsPixel = Assets:GetFont(Settings["chat-tab-font"])
		
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
	Chat:Install()
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

local UpdateEnableLinks = function(value)
	for i = 1, NUM_CHAT_WINDOWS do
		if value then
			_G["ChatFrame"..i]:SetScript("OnHyperlinkEnter", OnHyperlinkEnter)
			_G["ChatFrame"..i]:SetScript("OnHyperlinkLeave", OnHyperlinkLeave)
		else
			_G["ChatFrame"..i]:SetScript("OnHyperlinkEnter", nil)
			_G["ChatFrame"..i]:SetScript("OnHyperlinkLeave", nil)
		end
	end
end

local UpdateShortenChannels = function(value)
	local Frame
	
	if value then
		for i = 1, NUM_CHAT_WINDOWS do
			Frame = _G["ChatFrame"..i]
			
			Frame.OldAddMessage = Frame.AddMessage
			Frame.AddMessage = Chat.OverrideAddMessage
		end
	else
		for i = 1, NUM_CHAT_WINDOWS do
			Frame = _G["ChatFrame"..i]
			
			Frame.AddMessage = Frame.OldAddMessage
		end
	end
end

GUI:AddWidgets(Language["General"], Language["Chat"], function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("chat-enable", Settings["chat-enable"], Language["Enable Chat Module"], Language["Enable the HydraUI chat module"], ReloadUI):RequiresReload(true)
	
	left:CreateHeader(Language["General"])
	left:CreateSlider("chat-frame-width", Settings["chat-frame-width"], 300, 650, 1, Language["Chat Width"], Language["Set the width of the chat frame"], UpdateChatFrameSize)
	left:CreateSlider("chat-frame-height", Settings["chat-frame-height"], 40, 350, 1, Language["Chat Height"], Language["Set the height of the chat frame"], UpdateChatFrameSize)
	left:CreateSlider("chat-bg-opacity", Settings["chat-bg-opacity"], 0, 100, 5, Language["Background Opacity"], Language["Set the opacity of the chat background"], UpdateOpacity, nil, "%")
	left:CreateSlider("chat-fade-time", Settings["chat-enable-fading"], 0, 60, 5, Language["Set Fade Time"], Language["Set the duration to display text before fading out"], UpdateFadeTime, nil, "s")
	left:CreateSwitch("chat-enable-fading", Settings["chat-enable-fading"], Language["Enable Text Fading"], Language["Set the text to fade after the set amount of time"], UpdateEnableFading)
	left:CreateSwitch("chat-link-tooltip", Settings["chat-link-tooltip"], Language["Show Link Tooltips"], Language["Display a tooltip when hovering over links in chat"], UpdateEnableLinks)
	left:CreateSwitch("chat-shorten-channels", Settings["chat-shorten-channels"], Language["Shorten Channel Names"], Language["Shorten chat channel names to their channel number"], UpdateShortenChannels)
	
	right:CreateHeader(Language["Install"])
	right:CreateButton("", Language["Install"], Language["Install Chat Defaults"], Language["Set default channels and settings related to chat"], RunChatInstall):RequiresReload(true)
	
	left:CreateHeader(Language["Links"])
	left:CreateSwitch("chat-enable-url-links", Settings["chat-enable-url-links"], Language["Enable URL Links"], Language["Enable URL links in the chat frame"])
	left:CreateSwitch("chat-enable-discord-links", Settings["chat-enable-discord-links"], Language["Enable Discord Links"], Language["Enable Discord links in the chat frame"])
	left:CreateSwitch("chat-enable-email-links", Settings["chat-enable-email-links"], Language["Enable Email Links"], Language["Enable email links in the chat frame"])
	left:CreateSwitch("chat-enable-friend-links", Settings["chat-enable-friend-links"], Language["Enable Friend Tag Links"], Language["Enable friend tag links in the chat frame"])
	
	right:CreateHeader(Language["Chat Frame Font"])
	right:CreateDropdown("chat-font", Settings["chat-font"], Assets:GetFontList(), Language["Font"], "Set the font of the chat frame", UpdateChatFont, "Font")
	right:CreateSlider("chat-font-size", Settings["chat-font-size"], 8, 32, 1, "Font Size", "Set the font size of the chat frame", UpdateChatFont)
	right:CreateDropdown("chat-font-flags", Settings["chat-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], "Set the font flags of the chat frame", UpdateChatFont)
	
	right:CreateHeader(Language["Tab Font"])
	right:CreateDropdown("chat-tab-font", Settings["chat-tab-font"], Assets:GetFontList(), Language["Font"], "Set the font of the chat frame tabs", UpdateChatTabFont, "Font")
	right:CreateSlider("chat-tab-font-size", Settings["chat-tab-font-size"], 8, 32, 1, "Font Size", "Set the font size of the chat frame tabs", UpdateChatTabFont)
	right:CreateDropdown("chat-tab-font-flags", Settings["chat-tab-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], "Set the font flags of the chat frame tabs", UpdateChatTabFont)
	right:CreateColorSelection("chat-tab-font-color", Settings["chat-tab-font-color"], Language["Font Color"], "Set the color of the chat frame tabs", UpdateChatTabFont)
	right:CreateColorSelection("chat-tab-font-color-mouseover", Settings["chat-tab-font-color-mouseover"], Language["Font Color Mouseover"], "Set the color of the chat frame tab while mousing over it")
end)