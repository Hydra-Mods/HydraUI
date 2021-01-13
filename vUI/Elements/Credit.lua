local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Tiers = {"FF8000", "A335EE", "0070DD", "1EFF00", "FFFFFF"}

local Patrons = {
	{"Erieeroot", "Dragonhawk"}, -- 20
	{"Ari", "MrPoundsign"}, -- 15
	{"Dillan", "FrankPatten", "deck"}, -- 10
	{"Ryex", "JDoubleU00", "Syn", "sylvester", "Innie", "Mcbooze", "Aaron B.", "Angel", "Dellamaik", "stko", "Jeor"}, -- 5
	{"madmaddy", "Dustin S."}, -- 3
}

local Previous = {
	{"SwoopCrown"},
	{"Smelly", "Trix", "wolimazo"},
	{"Euphoria", "Mitooshin", "MisseFar"},
	{"Maski", "Raze", "Ingrimmosch", "Chris B.", "Suppabad", "Steve R."},
	{"Akab00m", "OzzFreak"},
}

local Donors = {"Innie", "Brightsides", "Erthelmi", "Gene", "JDoubleU00", "Duds", "Shazlen", "Shawna W.", "Dillan", "Bruce N."}

GUI:AddWidgets(Language["Info"], Language["Credits"], function(left, right)
	left:CreateHeader(Language["Scripting Help & Inspiration"])
	left:CreateMessage("Tukz, Foof, Eclipse, nightcracker, Elv, Smelly, Azilroka, AlleyKat, Zork, Simpy, Safturento, Dandruff")
	
	left:CreateHeader("oUF")
	left:CreateLine("haste, lightspark, p3lim, Rainrider")
	
	left:CreateHeader("AceSerializer")
	left:CreateLine("Nevcairiel")
	
	right:CreateHeader("LibStub")
	right:CreateMessage("Kaelten, Cladhaire, ckknight, Mikk, Ammo, Nevcairiel, joshborke")
	
	right:CreateHeader("LibSharedMedia")
	right:CreateLine("Elkano, funkehdude")
	
	right:CreateHeader("LibDeflate")
	right:CreateLine("yoursafety")
	
	left:CreateHeader("vUI")
	left:CreateLine("Hydra")
end)

GUI:AddWidgets(Language["Info"], Language["Supporters"], function(left, right)
	left:CreateHeader("Patreon Supporters")
	
	local r, g, b = vUI:HexToRGB("FF8000")
	
	for n = 1, #Patrons[1], 2 do
		if Patrons[1][n+1] then
			left:CreateAnimatedDoubleLine("|cFF" .. Tiers[1] .. Patrons[1][n] .. "|r", "|cFF" .. Tiers[1] .. Patrons[1][n+1] .. "|r", r, g, b)
		else
			left:CreateAnimatedLine("|cFF" .. Tiers[1] .. Patrons[1][n] .. "|r", r, g, b)
		end
	end
	
	local List = {}
	
	for i = 2, #Patrons do
		for n = 1, #Patrons[i] do
			List[#List + 1] = "|cFF" .. Tiers[i] .. Patrons[i][n] .. "|r"
		end
	end
	
	for i = 1, #List, 2 do
		if List[i+1] then
			left:CreateDoubleLine(List[i], List[i+1])
		else
			left:CreateLine(List[i])
		end
	end
	
	local ExPatrons = ""
	
	for i = 1, #Previous do
		for n = 1, #Previous[i] do
			ExPatrons = ExPatrons .. "|cFF" .. Tiers[i] .. Previous[i][n] .. "|r "
		end
	end
	
	left:CreateHeader("Former Patreon Supporters")
	left:CreateMessage(ExPatrons)
	
	right:CreateHeader(Language["Hall of Legends"])
	
	for i = 1, #Donors, 2 do
		if Donors[i+1] then
			right:CreateDoubleLine(Donors[i], Donors[i+1])
		else
			right:CreateLine(Donors[i])
		end
	end
	
	right:CreateFooter()
	right:CreateMessage("Thank you to all of these amazing people for their support, through donations and Patreon pledges! This generosity allows me to spend so much of my time developing the interface for everyone.")
	right:CreateLine("")
	
	local Patreon = right:CreateLine("|cFFF96854www.patreon.com/hydramods|r")
	local PayPal = right:CreateLine("|cFF009CDEwww.paypal.me/vuiaddon|r")
	
	Patreon = Patreon:GetParent()
	PayPal = PayPal:GetParent()
	
	Patreon:SetScript("OnEnter", function(self)
		self.Text:SetText("|cFFEEEEEEwww.patreon.com/hydramods|r")
	end)
	
	Patreon:SetScript("OnLeave", function(self) 
		self.Text:SetText("|cFFF96854www.patreon.com/hydramods|r")
	end)
	
	PayPal:SetScript("OnEnter", function(self)
		self.Text:SetText("|cFFEEEEEEwww.paypal.me/vuiaddon|r")
	end)
	
	PayPal:SetScript("OnLeave", function(self) 
		self.Text:SetText("|cFF009CDEwww.paypal.me/vuiaddon|r")
	end)
	
	Patreon:SetScript("OnMouseUp", function() print("https://www.patreon.com/hydramods") end)
	PayPal:SetScript("OnMouseUp", function() print("https://www.paypal.me/vuiaddon") end)
end)