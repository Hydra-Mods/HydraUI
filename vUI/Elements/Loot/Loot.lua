local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Loot = vUI:NewModule("Loot")

local GetNumLootItems = GetNumLootItems
local GetLootInfo = GetLootInfo

function Loot:LOOT_READY()
	local LootInfo = GetLootInfo()
	
	if (not LootInfo) then
		return
	end
	
	for i = 1, #LootInfo do
		
	end
end

function Loot:OnEvent(event)
	
end

Loot:RegisterEvent("LOOT_READY")
Loot:SetScript("OnEvent", Loot.LOOT_READY)