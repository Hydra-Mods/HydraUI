local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

if 1 == 1 then return end

local Loot = HydraUI:NewModule("Loot")

local GetNumLootItems = GetNumLootItems
local GetLootInfo = GetLootInfo
local GetLootSlotInfo = GetLootSlotInfo

local Icon, Name, Quantity, CurrencyID, Quality, Locked, QuestItem, QuestID, IsActive

function Loot:LOOT_OPENED(autoloot) -- autoloot
	local LootInfo = GetLootInfo()
	
	if (not LootInfo) then
		return
	end
	
	for i = 1, #LootInfo do
		Icon, Name, Quantity, CurrencyID, Quality, Locked, QuestItem, QuestID, IsActive = GetLootSlotInfo(i)
		
		
	end
end

function Loot:OnEvent(event, ...)
	self[event](self)
end

--Loot:RegisterEvent("LOOT_READY")
Loot:RegisterEvent("LOOT_OPENED")
Loot:SetScript("OnEvent", Loot.OnEvent)