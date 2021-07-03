local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

--[[ 
	Delete cheapest item
	clear item space when you need to make room for more important items
	To be fully implemented when I write my own bags module
--]]

local select = select
local match = string.match
local GetItemInfo = GetItemInfo
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemLink = GetContainerItemLink
local GetContainerItemID = GetContainerItemID
local GetContainerItemInfo = GetContainerItemInfo

local Delete = HydraUI:NewModule("Delete")

Delete.FilterIDs = {}
Delete.FilterClassIDs = {}

function Delete:UpdateFilterConsumable(value)
	self.FilterClassIDs[0] = value
end

function Delete:UpdateFilterContainer(value)
	self.FilterClassIDs[1] = value
end

function Delete:UpdateFilterWeapon(value)
	self.FilterClassIDs[2] = value
end

function Delete:UpdateFilterArmor(value)
	self.FilterClassIDs[4] = value
end

function Delete:UpdateFilterReagent(value)
	self.FilterClassIDs[5] = value
end

function Delete:UpdateFilterTradeskill(value)
	self.FilterClassIDs[7] = value
end

function Delete:UpdateFilterQuest(value)
	self.FilterClassIDs[12] = value
end

function Delete:EvaluateItem(link)
	local ItemType, ItemSubType, _, _, _, _, ClassID, SubClassID = select(6, GetItemInfo(link))
	local ID = match(link, ":(%w+)")
	
	if (self.FilterIDs[ID] or self.FilterClassIDs[ClassID]) then
		return
	end
	
	return true
end

function Delete:GetCheapestItem()
	local CheapestItem
	local CheapestValue
	local CheapestBag
	local CheapestSlot
	local CheapestCount
	
	for Bag = 0, 4 do
		for Slot = 1, GetContainerNumSlots(Bag) do
			local Link, ID = GetContainerItemLink(Bag, Slot), GetContainerItemID(Bag, Slot)
			
			if (Link and ID) then
				local SellPrice = select(11, GetItemInfo(Link))
				
				if (SellPrice and (SellPrice > 0) and self:EvaluateItem(Link)) then
					local Count = select(2, GetContainerItemInfo(Bag, Slot))
					
					if Count then
						SellPrice = SellPrice * Count
					end
					
					if ((not CheapestValue) or (SellPrice < CheapestValue)) then
						CheapestItem = Link
						CheapestValue = SellPrice
						CheapestCount = Count
						CheapestBag = Bag
						CheapestSlot = Slot
					end
				end
			end
		end
	end
	
	return CheapestItem, CheapestValue, CheapestCount, CheapestBag, CheapestSlot
end

function Delete:PrintCheapestItem()
	local Item, Value, Count = self:GetCheapestItem()
	
	if (Item and Value) then
		if (Count > 1) then
			HydraUI:print(format(Language["The cheapest sellable item in your inventory is currently %sx%s worth %s"], Item, Count, GetCoinTextureString(Value)))
		else
			HydraUI:print(format(Language["The cheapest sellable item in your inventory is currently %s worth %s"], Item, GetCoinTextureString(Value)))
		end
	else
		HydraUI:print(Language["No valid items were found"])
	end
end

function Delete:DeleteCheapestItem()
	local Item, Value, Count, Bag, Slot = self:GetCheapestItem()
	
	if (Bag and Slot) then
		PickupContainerItem(Bag, Slot)
		DeleteCursorItem()
		
		if (Count > 1) then
			HydraUI:print(format(Language["Deleted %sx%s worth %s"], Item, Count, GetCoinTextureString(Value)))
		else
			HydraUI:print(format(Language["Deleted %s worth %s"], Item, GetCoinTextureString(Value)))
		end
	else
		HydraUI:print(Language["No valid items were found"])
	end
end

local UpdateDeleteFilterConsumable = function(value)
	Delete:UpdateFilterConsumable(value)
end

local UpdateFilterContainer = function(value)
	Delete:UpdateFilterContainer(value)
end

local UpdateFilterWeapon = function(value)
	Delete:UpdateFilterWeapon(value)
end

local UpdateFilterArmor = function(value)
	Delete:UpdateFilterArmor(value)
end

local UpdateFilterReagent = function(value)
	Delete:UpdateFilterReagent(value)
end

local UpdateFilterTradeskill = function(value)
	Delete:UpdateFilterTradeskill(value)
end

local UpdateFilterQuest = function(value)
	Delete:UpdateFilterQuest(value)
end

function Delete:Load()
	self:UpdateFilterConsumable(Settings["delete-filter-consumable"])
	self:UpdateFilterContainer(Settings["delete-filter-container"])
	self:UpdateFilterWeapon(Settings["delete-filter-weapon"])
	self:UpdateFilterArmor(Settings["delete-filter-armor"])
	self:UpdateFilterReagent(Settings["delete-filter-reagent"])
	self:UpdateFilterTradeskill(Settings["delete-filter-tradeskill"])
	self:UpdateFilterQuest(Settings["delete-filter-quest"])
end

local PrintCheapest = function()
	Delete:PrintCheapestItem()
end

local OnAccept = function(self)
	Delete:DeleteCheapestItem()
end

local DeleteCheapest = function()
	local Item, Value, Count = Delete:GetCheapestItem()
	
	if (Item and Count) then
		if (Count > 1) then
			HydraUI:DisplayPopup(Language["Attention"], format(Language["Are you sure that you want to delete %sx%s?"], Item, Count), "Accept", OnAccept, "Cancel", nil)
		else
			HydraUI:DisplayPopup(Language["Attention"], format(Language["Are you sure that you want to delete %s?"], Item), "Accept", OnAccept, "Cancel", nil)
		end
	end
end

GUI:AddWidgets(Language["General"], Language["General"], function(left, right)
	right:CreateHeader(Language["Inventory"])
	right:CreateButton("", Language["Search"], Language["Find Cheapest Item"], Language["Find the cheapest item currently in your inventory"], PrintCheapest)
	right:CreateButton("", Language["Delete"], Language["Delete Cheapest Item"], Language["Delete the cheapest item currently in your inventory"], DeleteCheapest)
	right:CreateSwitch("delete-filter-consumable", Settings["delete-filter-consumable"], Language["Filter Consumables"], Language["Exclude consumables"], UpdateDeleteFilterConsumable)
	right:CreateSwitch("delete-filter-container", Settings["delete-filter-container"], Language["Filter Containers"], Language["Exclude container items"], UpdateFilterContainer)
	right:CreateSwitch("delete-filter-weapon", Settings["delete-filter-weapon"], Language["Filter Weapons"], Language["Exclude weapons items"], UpdateFilterWeapon)
	right:CreateSwitch("delete-filter-armor", Settings["delete-filter-armor"], Language["Filter Armor"], Language["Exclude armor items"], UpdateFilterArmor)
	right:CreateSwitch("delete-filter-reagent", Settings["delete-filter-reagent"], Language["Filter Reagents"], Language["Exclude reagent related items"], UpdateFilterReagent)
	right:CreateSwitch("delete-filter-tradeskill", Settings["delete-filter-tradeskill"], Language["Filter Tradeskills"], Language["Exclude tradeskill related items"], UpdateFilterTradeskill)
	right:CreateSwitch("delete-filter-quest", Settings["delete-filter-quest"], Language["Filter Quest Items"], Language["Exclude quest related items"], UpdateFilterQuest)
end)