local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Tiers = {"FF8000", "A335EE", "0070DD", "1EFF00", "FFFFFF"}

local Patrons = {
	{"Erieeroot", "Dragonhawk"}, -- 20
	{"Ari", "MrPoundsign"}, -- 15
	{"Dillan", "FrankPatten", "deck"}, -- 10
	{"Ryex", "JDoubleU00", "sylvester", "Innie", "Mcbooze", "Aaron B.", "Angel", "Dellamaik", "stko", "Jeor"}, -- 5
	{"madmaddy", "Dustin S."}, -- 3
}

local Previous = {
	{"SwoopCrown"},
	{"Smelly", "Trix", "wolimazo"},
	{"Euphoria", "Mitooshin"},
	{"Maski", "Raze", "Ingrimmosch", "Chris B.", "Suppabad", "Steve R."},
	{"Akab00m", "OzzFreak"},
}

GUI:AddSettings(Language["Info"], Language["Credits"], function(left, right)
	left:CreateHeader(Language["Scripting Help & Mentoring"])
	left:CreateMessage("Tukz, Foof, Eclipse, nightcracker, Elv, Smelly, Azilroka, AlleyKat, Zork, Simpy")
	
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

GUI:AddSettings(Language["Info"], Language["Supporters"], function(left, right)
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
	right:CreateDoubleLine("Innie", "Brightsides")
	right:CreateDoubleLine("Erthelmi", "Gene")
	right:CreateDoubleLine("JDoubleU00", "Duds")
	right:CreateDoubleLine("Shazlen", "Shawna W.")
	right:CreateDoubleLine("Dillan", "Bruce N.")
	
	right:CreateFooter()
	right:CreateMessage("Thank you to all of these amazing people for their support, through donations and Patreon pledges! This generosity allows me to spend so much of my time developing the interface for everyone.")
	right:CreateLine("")
	right:CreateLine(format("|cFF%s- Hydra|r", Settings["ui-widget-color"]))
end)