local vUI, GUI, Language = select(2, ...):get()

if (vUI.UserLocale ~= "ruRU") then
	return
end

Language["General"] = "General"
Language["Welcome"] = "Welcome"
Language["Display Welcome Message"] = "Display Welcome Message"
Language["Display Developer Chat Tools"] = "Display Developer Chat Tools"
Language["Move UI"] = "Move UI"
Language["Toggle"] = "Toggle"
Language["Restore"] = "Restore"
Language["Restore To Defaults"] = "Restore To Defaults"
Language["Settings Window"] = "Settings Window"
Language["Hide In Combat"] = "Hide In Combat"
Language["Fade While Moving"] = "Fade While Moving"
Language["Set Faded Opacity"] = "Set Faded Opacity"
Language["Set the opacity of the settings window|n while faded"] = "Set the opacity of the settings window|n while faded"
Language["Welcome to |cFF%svUI|r version |cFF%s%s|r."] = "Welcome to |cFF%svUI|r version |cFF%s%s|r."
Language["Type |cFF%s/vui|r to access the settings window, or click |cFF%s|Hcommand:/vui|h[here]|h|r."] = "Type |cFF%s/vui|r to access the settings window, or click |cFF%s|Hcommand:/vui|h[here]|h|r."