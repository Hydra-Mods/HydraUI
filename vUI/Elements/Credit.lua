local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Patrons = {
	[1] = {"madmaddy", "Dustin S.", "OzzFreak"},
	[2] = {"Ryex", "JDoubleU00", "sylvester", "Innie", "Mcbooze", "Aaron B.", "Steve R.", "Angel", "FrankPatten", "Dellamaik", "stko"},
	--[3] = {},
	[4] = {"Smelly", "Ari", "MrPoundsign"},
	[5] = {"Erieeroot", "Quivera"},
}

local Tiers = {
	[1] = {"", Language["Common Patrons"]},
	[2] = {"|cFF1EFF00", Language["Uncommon Patrons"]},
	[3] = {"|cFF0070DD", Language["Rare Patrons"]},
	[4] = {"|cFFA335EE", Language["Epic Patrons"]},
	[5] = {"|cFFFF8000", Language["Legendary Patrons"]},
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
	left:CreateSupportHeader(Language["Hall of Legends"])
	left:CreateDoubleLine("Innie", "Brightsides")
	left:CreateDoubleLine("Erthelmi", "Gene")
	left:CreateDoubleLine("JDoubleU00", "Duds")
	left:CreateDoubleLine("Shazlen", "Shawna W.")
	
	for i = #Patrons, 1, -1 do
		if Patrons[i] then
			table.sort(Patrons[i], function(a, b)
				return a < b
			end)
			
			local Message = ""
			local First
			
			right:CreateHeader(Tiers[i][2])
			
			for n = 1, #Patrons[i] do
				if (not First) then
					if (n == 1) then
						Message = Tiers[i][1] .. Patrons[i][n] .. "|r"
						First = true
					else
						Message = Message .. " " .. Tiers[i][1] .. Patrons[i][n] .. "|r"
					end
				else
					Message = Message .. " " .. Tiers[i][1] .. Patrons[i][n] .. "|r"
				end
			end
			
			right:CreateMessage(Message)
		end
	end
	
	left:CreateFooter()
	left:CreateMessage("Thank you to all of these amazing people for their support, through donations and Patreon pledges! This generosity allows me to spend so much of my time developing the interface for everyone.")
	left:CreateLine("")
	left:CreateLine(format("- |cFF%sHydra|r", Settings["ui-header-font-color"]))
end)