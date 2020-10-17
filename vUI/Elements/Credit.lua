local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

GUI:AddOptions(function(self)
	self:CreateSpacer("ZZZ")
	
	local Left, Right = self:CreateWindow(Language["Credits"], nil, "zzzCredits")
	
	Left:CreateHeader(Language["Scripting Help & Mentoring"])
	Left:CreateMessage("Tukz, Foof, Eclipse, nightcracker, Elv, Smelly, Azilroka, AlleyKat, Zork, Simpy")
	
	Left:CreateHeader("oUF")
	Left:CreateLine("haste, lightspark, p3lim, Rainrider")
	
	Left:CreateHeader("AceSerializer")
	Left:CreateLine("Nevcairiel")
	
	Right:CreateHeader("LibStub")
	Right:CreateMessage("Kaelten, Cladhaire, ckknight, Mikk, Ammo, Nevcairiel, joshborke")
	
	Right:CreateHeader("LibSharedMedia")
	Right:CreateLine("Elkano, funkehdude")
	
	Right:CreateHeader("LibDeflate")
	Right:CreateLine("yoursafety")
	
	Left:CreateHeader("vUI")
	Left:CreateLine("Hydra")
	
	-- Supporters
	local Left, Right = self:CreateWindow(Language["Supporters"], nil, "zzzSupporters")
	
	Left:CreateSupportHeader(Language["Hall of Legends"])
	Left:CreateDoubleLine("Innie", "Brightsides")
	Left:CreateDoubleLine("Erthelmi", "Gene")
	Left:CreateDoubleLine("JDoubleU00", "Duds")
	Left:CreateDoubleLine("Shazlen", "Shawna W.")
	
	Right:CreateHeader("Patrons")
	Right:CreateDoubleLine("|cFFFF8000Erieeroot|r", "|cFFFF8000SwoopCrown|r")
	Right:CreateDoubleLine("|cFFFF8000Quivera|r", "|cFFA335EESmelly|r")
	Right:CreateDoubleLine("|cFFA335EETrix|r", "|cFFA335EEwolimazo|r")
	Right:CreateDoubleLine("|cFFA335EEAri|r", "|cFFA335EEMrPoundsign|r")
	Right:CreateDoubleLine("|cFF0070DDMisse Far|r", "|cFF1EFF00Ryex|r")
	Right:CreateDoubleLine("|cFF1EFF00JDoubleU00|r", "|cFF1EFF00sylvester|r")
	Right:CreateDoubleLine("|cFF1EFF00Maski|r", "|cFF1EFF00Innie|r")
	Right:CreateDoubleLine("|cFF1EFF00Mcbooze|r", "|cFF1EFF00Aaron B.|r")
	Right:CreateDoubleLine("|cFF1EFF00Chris B.|r", "|cFF1EFF00Suppabad|r")
	Right:CreateDoubleLine("|cFF1EFF00Steve R.|r", "|cFF1EFF00Angel|r")
	Right:CreateDoubleLine("|cFF1EFF00FrankPatten|r", "|cFF1EFF00Dellamaik|r")
	Right:CreateDoubleLine("|cFF1EFF00stko|r", "madmaddy")
	
	Left:CreateFooter()
	Left:CreateMessage("Thank you to all of these amazing people who have supported the development of this project!")
end)