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
	Left:CreateLine("JDoubleU00")
	
	-- |cFFA335EE |cFF0070DD |cFF1EFF00
	
	Right:CreateHeader("Patrons")
	Right:CreateDoubleLine("|cFFA335EESmelly|r", "|cFFA335EETrix|r")
	Right:CreateDoubleLine("|cFFA335EEEerieroot|r", "|cFFA335EEwolimazo|r")
	Right:CreateDoubleLine("|cFF1EFF00Ryex|r", "|cFF1EFF00sylvester|r")
	Right:CreateDoubleLine("|cFF1EFF00Maski|r", "|cFF1EFF00Innie|r")
	
	Left:CreateFooter()
	Left:CreateMessage("Thank you to all of these amazing people who have supported the development of this project!")
end)
