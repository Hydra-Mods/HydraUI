local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

GUI:AddOptions(function(self)
	self:CreateSpacer("ZZZ")
	
	local Left, Right = self:CreateWindow(Language["Credits"], nil, "zzzCredits")
	
	Left:CreateHeader(Language["Scripting Help & Mentoring"])
	Left:CreateDoubleLine("Tukz", "Foof")
	Left:CreateDoubleLine("Eclipse", "nightcracker")
	Left:CreateDoubleLine("Elv", "Smelly")
	Left:CreateDoubleLine("Azilroka", "AlleyKat")
	Left:CreateDoubleLine("Zork", "Simpy")
	
	Left:CreateHeader("oUF")
	Left:CreateDoubleLine("haste", "lightspark")
	Left:CreateDoubleLine("p3lim", "Rainrider")
	
	Left:CreateHeader("AceSerializer")
	Left:CreateLine("Nevcairiel")
	
	Right:CreateHeader("LibStub")
	Right:CreateDoubleLine("Kaelten", "Cladhaire")
	Right:CreateDoubleLine("ckknight", "Mikk")
	Right:CreateDoubleLine("Ammo", "Nevcairiel")
	Right:CreateLine("joshborke")
	
	Right:CreateHeader("LibSharedMedia")
	Right:CreateDoubleLine("Elkano", "funkehdude")
	
	Right:CreateHeader("LibDeflate")
	Right:CreateLine("yoursafety")
	
	Right:CreateHeader("vUI")
	Right:CreateLine("Hydra")
	
	-- Supporters
	local Left, Right = self:CreateWindow(Language["Supporters"], nil, "zzzSupporters")
	
	Left:CreateSupportHeader(Language["Hall of Legends"])
	Left:CreateDoubleLine("Innie", "Brightsides")
	Left:CreateDoubleLine("Erthelmi", "Gene")
	Left:CreateDoubleLine("JDoubleU00", "Paul D.")
	
	Right:CreateHeader("Patrons")
	Right:CreateLine("|cFFFF8000Erieeroot|r")
	Right:CreateDoubleLine("|cFFA335EESmelly|r", "|cFFA335EETrix|r")
	Right:CreateDoubleLine("|cFFA335EEwolimazo|r", "|cFFA335EEAri|r")
	Right:CreateDoubleLine("|cFF1EFF00Ryex|r", "|cFF1EFF00sylvester|r")
	Right:CreateDoubleLine("|cFF1EFF00Maski|r", "|cFF1EFF00Innie|r")
	Right:CreateDoubleLine("|cFF1EFF00Raze|r", "|cFF1EFF00Aaron B.|r")
	Right:CreateDoubleLine("|cFF1EFF00JDoubleU00|r", "|cFF1EFF00Ingrimmosch|r")
	Right:CreateDoubleLine("|cFF1EFF00MrPoundsign|r", "|cFF1EFF00Syn|r")
	
	Left:CreateFooter()
	Left:CreateMessage("Thank you to all of these amazing people who have supported the development of this project!")
end)
