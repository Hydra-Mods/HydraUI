local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Patrons = {
	[1] = {"madmaddy", "Akab00m", "Dustin S."},
	[2] = {"Ryex", "JDoubleU00", "sylvester", "Innie", "Mcbooze", "Aaron B.", "Steve R.", "Angel", "FrankPatten", "Dellamaik", "stko"},
	[3] = {},
	[4] = {"Smelly", "Ari", "MrPoundsign"},
	[5] = {"Erieeroot", "Quivera", "SwoopCrown"},
}

local Tiers = {
	[1] = "", -- Common
	[2] = "|cFF1EFF00", -- Uncommon
	[3] = "|cFF0070DD", -- Rare
	[4] = "|cFFA335EE", -- Epic
	[5] = "|cFFFF8000", -- Legendary
}

local GetPatrons = function()
	local Message = ""
	local First
	
	for i = 5, 1, -1 do
		if Patrons[i] then
			table.sort(Patrons[i], function(a, b)
				return a < b
			end)
			
			for n = 1, #Patrons[i] do
				if (not First) then
					if (n == 1) then
						Message = Tiers[i] .. Patrons[i][n] .. "|r"
						First = true
					else
						Message = Message .. " " .. Tiers[i] .. Patrons[i][n] .. "|r"
					end
				else
					Message = Message .. " " .. Tiers[i] .. Patrons[i][n] .. "|r"
				end
			end
		end
	end
	
	return Message
end

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
	left:CreateSupportHeader(Language["Hall of Legends"])
	left:CreateDoubleLine("Innie", "Brightsides")
	left:CreateDoubleLine("Erthelmi", "Gene")
	left:CreateDoubleLine("JDoubleU00", "Duds")
	left:CreateDoubleLine("Shazlen", "Shawna W.")
	
	right:CreateSupportHeader("Patrons")
	--[[Right:CreateDoubleLine("|cFFFF8000Erieeroot|r", "|cFFFF8000SwoopCrown|r")
	Right:CreateDoubleLine("|cFFFF8000Quivera|r", "|cFFA335EESmelly|r")
	Right:CreateDoubleLine("|cFFA335EETrix|r", "|cFFA335EEwolimazo|r")
	Right:CreateDoubleLine("|cFFA335EEAri|r", "|cFFA335EEMrPoundsign|r")
	Right:CreateDoubleLine("|cFF0070DDMisse Far|r", "|cFF1EFF00Ryex|r")
	Right:CreateDoubleLine("|cFF1EFF00JDoubleU00|r", "|cFF1EFF00sylvester|r")
	Right:CreateDoubleLine("|cFF1EFF00Maski|r", "|cFF1EFF00Innie|r")
	Right:CreateDoubleLine("|cFF1EFF00Mcbooze|r", "|cFF1EFF00Aaron B.|r")
	Right:CreateDoubleLine("|cFF1EFF00Steve R.|r", "|cFF1EFF00Angel|r")
	Right:CreateDoubleLine("|cFF1EFF00FrankPatten|r", "|cFF1EFF00Dellamaik|r")
	Right:CreateDoubleLine("|cFF1EFF00stko|r", "madmaddy")
	Right:CreateLine("Akab00m")]]
	right:CreateMessage(GetPatrons())
	
	left:CreateFooter()
	left:CreateMessage("Thank you to all of these amazing people for their support, through donations and Patreon pledges! This generosity allows me to spend so much of my time developing the interface for everyone.")
	left:CreateLine("")
	left:CreateLine(format("- |cFF%sHydra|r", Settings["ui-header-font-color"]))
end)