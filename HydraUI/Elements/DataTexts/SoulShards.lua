local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local GetContainerNumSlots = GetContainerNumSlots
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local select = select
local Label = Language["Soul Shards"]

local Update = function(self)
	local ShardCount = 0
	
	for Bag = 0, NUM_BAG_SLOTS do
		local NumSlots = GetContainerNumSlots(Bag)
		
		for Slot = 1, NumSlots do
			local ID = GetContainerItemID(Bag, Slot)
			
			if (ID and ID == 6265) then
				local Count = select(2, GetContainerItemInfo(Bag, Slot))
				
				ShardCount = ShardCount + Count
			end
		end
	end
	
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], ShardCount)
end

local OnEnable = function(self)
	self:RegisterEvent("BAG_UPDATE")
	self:SetScript("OnEvent", Update)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("BAG_UPDATE")
	self:SetScript("OnEvent", nil)
	
	self.Text:SetText("")
end

HydraUI:AddDataText("Soul Shards", OnEnable, OnDisable, Update)