local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Tiers = {"FF8000", "A335EE", "0070DD", "1EFF00", "FFFFFF"}

local Patrons = {
	{"Erieeroot", "Dragonhawk", "Halven"},
	{},
	{"Dillan", "deck"},
	{"JDoubleU00", "sylvester", "Innie", "Dellamaik", "Blom", "Oxymorphone", "Ryex", "Rytok", "protocol7"},
	{},
}

local Previous = {
	{"SwoopCrown", "Cheeso_76", "last"},
	{"Smelly", "Trix", "wolimazo", "Ari", "MrPoundsign"},
	{"Euphoria", "Mitooshin", "MisseFar", "FrankPatten"},
	{"Maski", "Raze", "Ingrimmosch", "Chris B.", "Suppabad", "Aaron B.", "Steve R.", "Angel", "Jeor", "Mcbooze", "stko", "Syn"},
	{"Akab00m", "OzzFreak", "madmaddy", "Uzify", "Erthelmi"},
}

local Donors = {"Innie", "Brightsides", "Erthelmi", "Gene", "JDoubleU00", "Duds", "Shazlen", "Shawna W.", "Dillan", "Bruce N.", "last", "Wrynn", "Ryxân", "Andrei B.", "Anthony M.", "AtticaOnline"}

GUI:AddWidgets(Language["Info"], Language["Credits"], function(left, right)
	left:CreateHeader(Language["Scripting Help & Inspiration"])
	left:CreateMessage("", "Tukz, Foof, Eclipse, nightcracker, Elv, Smelly, Azilroka, AlleyKat, Zork, Simpy, Safturento, Dandruff")
	
	left:CreateHeader("oUF")
	left:CreateLine("", "haste, lightspark, p3lim, Rainrider")
	
	left:CreateHeader("AceSerializer")
	left:CreateLine("", "Nevcairiel")
	
	right:CreateHeader("LibStub")
	right:CreateMessage("", "Kaelten, Cladhaire, ckknight, Mikk, Ammo, Nevcairiel, joshborke")
	
	right:CreateHeader("LibSharedMedia")
	right:CreateLine("", "Elkano, funkehdude")
	
	right:CreateHeader("LibDeflate")
	right:CreateLine("", "yoursafety")
	
	left:CreateHeader("HydraUI")
	left:CreateLine("", "Hydra")
end)

GUI:AddWidgets(Language["Info"], Language["Supporters"], function(left, right)
	left:CreateHeader(Language["Patreon Supporters"])
	
	local List = {}
	local R, G, B = HydraUI:HexToRGB(Tiers[1])
	
	for i = 2, #Patrons do
		for n = 1, #Patrons[i] do
			List[#List + 1] = "|cFF" .. Tiers[i] .. Patrons[i][n] .. "|r"
		end
	end
	
	for n = 1, #Patrons[1], 2 do
		if Patrons[1][n + 1] then
			left:CreateAnimatedDoubleLine("", "|cFF" .. Tiers[1] .. Patrons[1][n] .. "|r", "|cFF" .. Tiers[1] .. Patrons[1][n + 1] .. "|r", R, G, B)
		else
			local Name = tremove(List, 1)
			
			left:CreateAnimatedLine("", "|cFF" .. Tiers[1] .. Patrons[1][n] .. "|r", Name, R, G, B)
		end
	end
	
	for i = 1, #List, 2 do
		if List[i + 1] then
			left:CreateDoubleLine("", List[i], List[i + 1])
		else
			left:CreateLine("", List[i])
		end
	end
	
	local ExPatrons = ""
	
	for i = 1, #Previous do
		for n = 1, #Previous[i] do
			ExPatrons = ExPatrons .. "|cFF" .. Tiers[i] .. Previous[i][n] .. "|r "
		end
	end
	
	left:CreateHeader(Language["Former Patreon Supporters"])
	left:CreateMessage("", ExPatrons)
	
	right:CreateHeader(Language["Donors"])
	
	for i = 1, #Donors, 2 do
		if Donors[i + 1] then
			right:CreateDoubleLine("", Donors[i], Donors[i + 1])
		else
			right:CreateLine("", Donors[i])
		end
	end
	
	right:CreateHeader("Thank you so much!")
	right:CreateMessage("", "Thank you to all of these amazing people for their support, through donations and Patreon pledges! This generosity allows me to spend so much of my time developing the interface for everyone.")
end)