local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

GUI:AddOptions(function(self)
	self:CreateSpacer("ZZZ")
	
	local Left, Right = self:CreateWindow(Language["Credits"], nil, "zzzCredits")
	
	Left:CreateHeader(Language["Scripting Help & Mentoring"])
	Left:CreateDoubleLine("Tukz", "Foof")
	Left:CreateDoubleLine("Eclipse", "nightcracker")
	Left:CreateDoubleLine("Elv", "Azilroka")
	Left:CreateDoubleLine("Smelly", "AlleyKat")
	Left:CreateDoubleLine("Zork", "Simpy")
	
	Left:CreateHeader("oUF")
	Left:CreateDoubleLine("Haste", "lightspark")
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
	
	Left:CreateSupportHeader(Language["Supporters"])
	Left:CreateDoubleLine("Innie", "Brightsides")
	
	Right:CreateHeader(Language["Acknowledgements"])
	Right:CreateMessage("Thank you to the following people who have supported the development of this project! It has taken immense time and effort, and the support of these people helps make it possible.")
end)