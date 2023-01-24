local HydraUI, Language, Assets, Settings, Defaults = select(2, ...):get()
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")

local Fonts = {}
local Textures = {}
local Styles = {}
local Palettes = {}
--local Sounds = {}

local FontList = {}
local FontIsPixel = {}
local TextureList = {}
local StyleList = {}
local PaletteList = {}
--local SoundList = {}

local OutlineList = {
	["Outline"] = "OUTLINE",
	["Thick Outline"] = "THICKOUTLINE",
	["Monochrome"] = "MONOCHROME",
	["Monochrome Outline"] = "MONOCHROME, OUTLINE",
	["None"] = "",
}

function Assets:GetFlagsList()
	return OutlineList
end

-- Fonts
function Assets:SetFont(name, path, ispixel)
	if Fonts[name] then
		return
	end

	Fonts[name] = path
	FontList[name] = path

	if ispixel then
		FontIsPixel[name] = true
	end

	SharedMedia:Register("font", name, path)
end

function Assets:GetFont(name)
	if Fonts[name] then
		return Fonts[name], FontIsPixel[name]
	else
		return Fonts["PT Sans"]
	end
end

function Assets:GetFontList()
	return FontList
end

-- Textures
function Assets:SetTexture(name, path, silent)
	if Textures[name] then
		return
	end

	Textures[name] = path

	if (not silent) then
		TextureList[name] = path

		SharedMedia:Register("statusbar", name, path)
	end
end

function Assets:GetTexture(name)
	if Textures[name] then
		return Textures[name]
	else
		return Textures["Blank"]
	end
end

function Assets:GetTextureList()
	return TextureList
end

-- Style templates
function Assets:SetStyle(name, info, silent)
	if Styles[name] then
		return
	end

	Styles[name] = info

	if (not silent) then
		local Key = name

		-- Just sprinkling on some flavor. Really rub it in.
		if info["ui-widget-color"] then
			Key = format("|cFF%s%s|r", info["ui-widget-color"], name)
		end

		StyleList[Key] = name
	end
end

function Assets:GetStyle(name)
	if Styles[name] then
		return Styles[name]
	else
		return Styles["|cFFFFC44DHydraUI|r"]
	end
end

function Assets:GetStyleList()
	return StyleList
end

function Assets:ApplyStyle(name)
	if (not Styles[name]) then
		return HydraUI:print(format(Language['No style exists with the name "%s"'], name))
	end

	local Profile = HydraUI:GetActiveProfile()

	if Profile then
		for ID, Value in next, Styles[name] do
			if (Value ~= Defaults[ID]) then
				Profile[ID] = Value
			else
				Profile[ID] = nil
			end

			Settings[ID] = Value
		end
	end
end

-- Palettes
function Assets:SetPalette(name, info, silent)
	if Palettes[name] then
		return
	end

	Palettes[name] = info

	if (not silent) then
		PaletteList[name] = info
	end
end

function Assets:GetPalette(name)
	if Palettes[name] then
		return Palettes[name]
	else
		return Palettes["Default"]
	end
end

function Assets:GetPaletteList()
	return PaletteList
end

function HydraUI:LoadSharedAssets()
	for Name, Path in next, SharedMedia:HashTable("font") do
		Assets:SetFont(Name, Path)
	end

	for Name, Path in next, SharedMedia:HashTable("statusbar") do
		Assets:SetTexture(Name, Path)
	end
end

-- Some pre-loaded goodness.

-- Fonts
Assets:SetFont("PT Sans", "Interface\\Addons\\HydraUI\\Elements\\Assets\\Fonts\\PTSans.ttf")
Assets:SetFont("Roboto", "Interface\\Addons\\HydraUI\\Elements\\Assets\\Fonts\\Roboto.ttf")
Assets:SetFont("Prototype", "Interface\\Addons\\HydraUI\\Elements\\Assets\\Fonts\\Prototype.ttf")
Assets:SetFont("Mosk", "Interface\\Addons\\HydraUI\\Elements\\Assets\\Fonts\\MoskBold.ttf")
Assets:SetFont("Matthan", "Interface\\Addons\\HydraUI\\Elements\\Assets\\Fonts\\MatthanSans.ttf")
Assets:SetFont("Expressway", "Interface\\Addons\\HydraUI\\Elements\\Assets\\Fonts\\Expressway.ttf")
Assets:SetFont("Noto Sans", "Interface\\Addons\\HydraUI\\Elements\\Assets\\Fonts\\NotoSansCondensedSemiBold.ttf")
Assets:SetFont("Visitor", "Interface\\Addons\\HydraUI\\Elements\\Assets\\Fonts\\Visitor.ttf", true)
Assets:SetFont("Pixel Arial", "Interface\\Addons\\HydraUI\\Elements\\Assets\\Fonts\\PixelArial.ttf", true)

-- Bar Textures
Assets:SetTexture("Blank", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUIBlank.tga")
Assets:SetTexture("HydraUI 1", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUI1.tga")
Assets:SetTexture("HydraUI 2", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUI2.tga")
Assets:SetTexture("HydraUI 3", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUI3.tga")
Assets:SetTexture("HydraUI 4", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUI4.tga")
Assets:SetTexture("Bettina", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\Bettina.tga")
Assets:SetTexture("Ferous", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\Ferous.tga")
Assets:SetTexture("Halycon", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\Halycon.tga")
Assets:SetTexture("Kola", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\Kola.tga")
Assets:SetTexture("Ferous 27", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\fer27.tga")
Assets:SetTexture("pHishTex5", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\pHishTex5.tga")
Assets:SetTexture("pHishTex6", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\pHishTex6.tga")
Assets:SetTexture("pHishTex7", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\pHishTex7.tga")
Assets:SetTexture("pHishTex11", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\pHishTex11.tga")
Assets:SetTexture("pHishTex12", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\pHishTex12.tga")
Assets:SetTexture("Ferous 14", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\fer14.tga")

-- Shapes and highlights
Assets:SetTexture("noInterrupt", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\noInterrupt.tga", true)
Assets:SetTexture("RenHorizonUp", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\RenHorizonUp.tga", true)
Assets:SetTexture("RenHorizonDown", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\RenHorizonDown.tga", true)
Assets:SetTexture("RenaitreTunnel", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\RenaitreTunnel.tga", true)
Assets:SetTexture("Mail", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUIMail.tga", true)
Assets:SetTexture("Mail 2", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUIMailTextured.tga", true)
Assets:SetTexture("Close", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUIClose.tga", true)
Assets:SetTexture("pHishTex28", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\pHishTex28.tga", true)
Assets:SetTexture("Warning", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUIWarning.tga", true)
Assets:SetTexture("WarningInner", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\WarningInner.tga", true)
Assets:SetTexture("Leader", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUILeader.tga", true)
Assets:SetTexture("Assist", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUIAssist.tga", true)
Assets:SetTexture("Heart", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUIHeart.tga", true)
Assets:SetTexture("Arrow Down", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUIArrowDown.tga", true)
Assets:SetTexture("Arrow Up", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUIArrowUp.tga", true)
Assets:SetTexture("Arrow Left", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUIArrowLeft.tga", true)
Assets:SetTexture("Arrow Left Large", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUIArrowLeftLarge.tga", true)
Assets:SetTexture("Arrow Left Huge", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUIArrowLeftHuge.tga", true)
Assets:SetTexture("Arrow Right", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUIArrowRight.tga", true)
Assets:SetTexture("Arrow Right Large", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUIArrowRightLarge.tga", true)
Assets:SetTexture("Arrow Right Huge", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUIArrowRightHuge.tga", true)
Assets:SetTexture("Skull", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUISkull.tga", true)
Assets:SetTexture("Small Star", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUISmallStar.tga", true)
Assets:SetTexture("Copy", "Interface\\AddOns\\HydraUI\\Elements\\Assets\\Textures\\HydraUICopy.tga", true)

-- Palettes - Yes, doing these did take forever. And yes it was worth it.

Assets:SetPalette("Default", { -- https://www.materialui.co/colors
	{"FFEBEE", "FCE4EC", "F3E5F5", "EDE7F6", "E8EAF6", "E3F2FD", "E1F5FE", "E0F7FA", "E0F2F1", "E8F5E9", "F1F8E9", "F9FBE7", "FFFDE7", "FFF8E1", "FFF3E0", "FBE9E7", "EFEBE9", "FAFAFA", "ECEFF1"},
	{"FFCDD2", "F8BBD0", "E1BEE7", "D1C4E9", "C5CAE9", "BBDEFB", "B3E5FC", "B2EBF2", "B2DFDB", "C8E6C9", "DCEDC8", "F0F4C3", "FFF9C4", "FFECB3", "FFE0B2", "FFCCBC", "D7CCC8", "F5F5F5", "CFD8DC"},
	{"EF9A9A", "F48FB1", "CE93D8", "B39DDB", "9FA8DA", "90CAF9", "81D4FA", "80DEEA", "80CBC4", "A5D6A7", "C5E1A5", "E6EE9C", "FFF59D", "FFE082", "FFCC80", "FFAB91", "BCAAA4", "EEEEEE", "B0BEC5"},
	{"E57373", "F06292", "BA68C8", "9575CD", "7986CB", "64B5F6", "4FC3F7", "4DD0E1", "4DB6AC", "81C784", "AED581", "DCE775", "FFF176", "FFD54F", "FFB74D", "FF8A65", "A1887F", "E0E0E0", "90A4AE"},
	{"EF5350", "EC407A", "AB47BC", "7E57C2", "5C6BC0", "42A5F5", "29B6F6", "26C6DA", "26A69A", "66BB6A", "9CCC65", "D4E157", "FFEE58", "FFCA28", "FFA726", "FF7043", "8D6E63", "BDBDBD", "78909C"},
	{"F44336", "E91E63", "9C27B0", "673AB7", "3F51B5", "2196F3", "03A9F4", "00BCD4", "009688", "4CAF50", "8BC34A", "CDDC39", "FFEB3B", "FFC107", "FF9800", "FF5722", "795548", "9E9E9E", "607D8B"},
	{"E53935", "D81B60", "8E24AA", "5E35B1", "3949AB", "1E88E5", "039BE5", "00ACC1", "00897B", "43A047", "7CB342", "C0CA33", "FDD835", "FFB300", "FB8C00", "F4511E", "6D4C41", "757575", "546E7A"},
	{"D32F2F", "C2185B", "7B1FA2", "512DA8", "303F9F", "1976D2", "0288D1", "0097A7", "00796B", "388E3C", "689F38", "AFB42B", "FBC02D", "FFA000", "F57C00", "E64A19", "5D4037", "616161", "455A64"},
	{"C62828", "AD1457", "6A1B9A", "4527A0", "283593", "1565C0", "0277BD", "00838F", "00695C", "2E7D32", "558B2F", "9E9D24", "F9A825", "FF8F00", "EF6C00", "D84315", "4E342E", "424242", "37474F"},
	{"B71C1C", "880E4F", "4A148C", "311B92", "1A237E", "0D47A1", "01579B", "006064", "004D40", "1B5E20", "33691E", "827717", "F57F17", "FF6F00", "E65100", "BF360C", "3E2723", "212121", "263238"}
})

Assets:SetPalette("Flat", {
	{"1ABC9C", "2ECC71", "3498DB", "9B59B6", "34495E"},
	{"16A085", "27AE60", "2980B9", "8E44AD", "2C3E50"},
	{"F1C40F", "E67E22", "E74C3C", "ECF0F1", "95A5A6"},
	{"F39C12", "D35400", "E0392B", "BDC3C7", "7F8C8D"}
})

Assets:SetPalette("Fluent", { -- https://fluentcolors.com/
	{"FFB900", "E74856", "0078D7", "0099BC", "7A7574", "767676"},
	{"FF8C00", "E81123", "0063B1", "2D7D9A", "5D5A58", "4C4A48"},
	{"F7630C", "EA005E", "8E8CD8", "00B7C3", "68768A", "69797E"},
	{"CA5010", "C30052", "6B69D6", "038387", "515C6B", "4A5459"},
	{"DA3B01", "E3008C", "8764B8", "00B294", "567C73", "647C64"},
	{"EF6950", "BF0077", "744DA9", "018574", "486860", "525E54"},
	{"D13438", "C239B3", "B146C2", "00CC6A", "498205", "847545"},
	{"FF4343", "9A0089", "881798", "10893E", "107C10", "7E735F"}
})

Assets:SetPalette("Large", { -- https://htmlcolorcodes.com/
	{"F9EBEA", "FDEDEC", "F5EEF8", "F4ECF7", "EAF2F8", "EBF5FB", "E8F8F5", "E8F6F3", "E9F7EF","EAFAF1", "FEF9E7", "FEF5E7", "FDF2E9", "FBEEE6", "FDFEFE", "F8F9F9", "F4F6F6", "F2F4F4", "EBEDEF", "EAECEE"},
	{"F2D7D5", "FADBD8", "EBDEF0", "E8DAEF", "D4E6F1", "D6EAF8", "D1F2EB", "D0ECE7", "D4EFDF", "D5F5E3", "FCF3CF", "FDEBD0", "FAE5D3", "F6DDCC", "FBFCFC", "F2F3F4", "EAEDED", "E5E8E8", "D6DBDF", "D5D8DC"},
	{"E6B0AA", "F5B7B1", "D7BDE2", "D2B4DE", "A9CCE3", "AED6F1", "A3E4D7", "A2D9CE", "A9DFBF", "ABEBC6", "F9E79F", "FAD7A0", "F5CBA7", "EDBB99", "F7F9F9", "E5E7E9", "D5DBDB", "CCD1D1", "AEB6BF", "ABB2B9"},
	{"D98880", "F1948A", "C39BD3", "BB8FCE", "7FB3D5", "85C1E9", "76D7C4", "73C6B6", "7DCEA0", "82E0AA", "F7DC6F", "F8C471", "F0B27A", "E59866", "F4F6F7", "D7DBDD", "BFC9CA", "B2BABB", "85929E", "808B96"},
	{"CD6155", "EC7063", "AF7AC5", "A569BD", "5499C7", "5DADE2", "48C9B0", "45B39D", "52BE80", "58D68D", "F4D03F", "F5B041", "EB984E", "DC7633", "F0F3F4", "D7DBDD", "BFC9CA", "B2BABB", "85929E", "808B96"},
	{"C0392B", "E74C3C", "9B59B6", "8E44AD", "2980B9", "3498DB", "1ABC9C", "16A085", "27AE60", "2ECC71", "F1C40F", "F39C12", "E67E22", "D35400", "ECF0F1", "BDC3C7", "95A5A6", "7F8C8D", "34495E", "2C3E50"},
	{"A93226", "CB4335", "884EA0", "7D3C98", "2471A3", "2E86C1", "17A589", "138D75", "229954", "28B463", "D4AC0D", "D68910", "CA6F1E", "BA4A00", "D0D3D4", "A6ACAF", "839192", "707B7C", "2E4053", "273746"},
	{"922B21", "B03A2E", "76448A", "6C3483", "1F618D", "2874A6", "148F77", "117A65", "1E8449", "239B56", "B7950B", "B9770E", "AF601A", "A04000", "B3B6B7", "909497", "717D7E", "616A6B", "283747", "212F3D"},
	{"7B241C", "943126", "633974", "5B2C6F", "1A5276", "21618C", "117864", "0E6655", "196F3D", "1D8348", "9A7D0A", "9C640C", "935116", "873600", "979A9A", "797D7F", "5F6A6A", "515A5A", "212F3C", "1C2833"},
	{"641E16", "78281F", "512E5F", "4A235A", "154360", "1B4F72", "0E6251", "0B5345", "145A32", "186A3B", "7D6608", "7E5109", "784212", "6E2C00", "7B7D7D", "626567", "4D5656", "424949", "1B2631", "17202A"}
})

Assets:SetPalette("Lite", {
	{"F17171", "FFA071", "FFD071", "A2D471", "71E2D0", "71D0FF", "7EA9FF", "B38DFF", "FF71B7", "A2ADB8"},
	{"EE4D4D", "FF884D", "FFC44D", "8BC94D", "4DDBC4", "4DC4FF", "5E94FF", "AD71FF", "FF4dA5", "8B98A6"},
	{"D64545", "E57A45", "E5B045", "4C9900", "45C5B0", "45B0E5", "5485E5", "9065E5", "E54594", "7D8995"}
})

Assets:SetPalette("Rapid", { -- https://www.rapidtables.com/web/color/RGB_Color.html
	{"330000", "331900", "333300", "193300", "003300", "003319", "003333", "001933", "000033", "190033", "330033", "330019", "000000"},
	{"660000", "663300", "666600", "336600", "006600", "006633", "006666", "003366", "000066", "330066", "660066", "660033", "202020"},
	{"990000", "994C00", "999900", "4C9900", "009900", "00994C", "009999", "004C99", "000099", "4C0099", "990099", "99004C", "404040"},
	{"CC0000", "CC6600", "CCCC00", "66CC00", "00CC00", "00CC66", "00CCCC", "0066CC", "0000CC", "6600CC", "CC00CC", "CC0066", "606060"},
	{"FF0000", "FF8000", "FFFF00", "80FF00", "00FF00", "00FF80", "00FFFF", "0080FF", "0000FF", "7F00FF", "FF00FF", "FF007F", "808080"},
	{"FF3333", "FF9933", "FFFF33", "99FF33", "33FF33", "33FF99", "33FFFF", "3399FF", "3333FF", "9933FF", "FF33FF", "FF3399", "A0A0A0"},
	{"FF6666", "FFB266", "FFFF66", "B2FF66", "66FF66", "66FFB2", "66FFFF", "66B2FF", "6666FF", "B266FF", "FF66FF", "FF66B2", "C0C0C0"},
	{"FF9999", "FFCC99", "FFFF99", "CCFF99", "99FF99", "99FFCC", "99FFFF", "99CCFF", "9999FF", "CC99FF", "FF99FF", "FF99CC", "E0E0E0"},
	{"FFCCCC", "FFE5CC", "FFFFCC", "E5FFCC", "CCFFCC", "CCFFE5", "CCFFFF", "CCE5FF", "CCCCFF", "E5CCFF", "FFCCFF", "FFCCE5", "FFFFFF"}
})