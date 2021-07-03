local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local AutoVendor = HydraUI:NewModule("Auto Vendor") -- Automatically sell useless items

local select = select
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemLink = GetContainerItemLink
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerItemID = GetContainerItemID
local GetItemInfo = GetItemInfo
local UseContainerItem = UseContainerItem
local PickupMerchantItem = PickupMerchantItem
local GetCoinTextureString = GetCoinTextureString
local CanGuildBankRepair = CanGuildBankRepair
local GetGuildBankWithdrawMoney = GetGuildBankWithdrawMoney

Defaults["auto-vendor-enable"] = true
Defaults["auto-vendor-report"] = true

AutoVendor.Filter = {
	[6196] = true,
}

function HydraUI:GetTrashValue()
	local Profit = 0
	local TotalCount = 0
	
	for Bag = 0, 4 do
		for Slot = 1, GetContainerNumSlots(Bag) do
			local Link, ID = GetContainerItemLink(Bag, Slot), GetContainerItemID(Bag, Slot)
			
			if (Link and ID and not AutoVendor.Filter[ID]) then
				local TotalPrice = 0
				local Quality = select(3, GetItemInfo(Link))
				local AutoVendorPrice = select(11, GetItemInfo(Link))
				local Count = select(2, GetContainerItemInfo(Bag, Slot))
				
				if ((AutoVendorPrice and (AutoVendorPrice > 0)) and Count) then
					TotalPrice = AutoVendorPrice * Count
				end
				
				if ((Quality and Quality <= 0) and TotalPrice > 0) then
					Profit = Profit + TotalPrice
					TotalCount = TotalCount + Count
				end
			end
		end
	end
	
	return TotalCount, Profit
end

function AutoVendor:OnEvent()
	local Profit = 0
	local TotalCount = 0
	
	for Bag = 0, 4 do
		for Slot = 1, GetContainerNumSlots(Bag) do
			local Link = GetContainerItemLink(Bag, Slot)
			local ID = GetContainerItemID(Bag, Slot)
			
			if (Link and ID and not self.Filter[ID]) then
				local TotalPrice = 0
				local Quality = select(3, GetItemInfo(Link))
				local AutoVendorPrice = select(11, GetItemInfo(Link))
				local Count = select(2, GetContainerItemInfo(Bag, Slot))
				
				if ((AutoVendorPrice and (AutoVendorPrice > 0)) and Count) then
					TotalPrice = AutoVendorPrice * Count
				end
				
				if ((Quality and Quality <= 0) and TotalPrice > 0) then
					UseContainerItem(Bag, Slot)
					PickupMerchantItem()
					Profit = Profit + TotalPrice
					TotalCount = TotalCount + Count
				end
			end
		end
	end
	
	if (Profit > 0 and Settings["auto-vendor-report"]) then
		HydraUI:print(format(Language["You sold %d %s for a total of %s"], TotalCount, TotalCount > 0 and "items" or "item", GetCoinTextureString(Profit)))
	end
end

function AutoVendor:Load()
	if Settings["auto-vendor-enable"] then
		self:RegisterEvent("MERCHANT_SHOW")
		self:SetScript("OnEvent", self.OnEvent)
	end
end

local AutoRepair = HydraUI:NewModule("Auto Repair")

Defaults["auto-repair-enable"] = true
Defaults["auto-repair-use-guild"] = true
Defaults["auto-repair-report"] = true

function AutoRepair:OnEvent()
	local Money = GetMoney()
	
	if CanMerchantRepair() then
		local Cost = GetRepairAllCost()
		local CostString = GetCoinTextureString(Cost)
		
		if (Cost == 0) then
			return
		end
		
		if (Money > Cost) then
			RepairAllItems()
			
			if Settings["auto-repair-report"] then
				HydraUI:print(format(Language["Your equipped items have been repaired for %s"], CostString))
			end
		else
			local Required = Cost - Money
			local RequiredString = GetCoinTextureString(Required)
			
			if Settings["auto-repair-report"] then
				HydraUI:print(format(Language["You require %s to repair all equipped items (costs %s total)"], RequiredString, CostString))
			end
		end
	end
end

function AutoRepair:Load()
	if Settings["auto-repair-enable"] then
		self:RegisterEvent("MERCHANT_SHOW")
		self:SetScript("OnEvent", self.OnEvent)
	end
end

local UpdateAutoVendor = function(value)
	if value then
		AutoVendor:RegisterEvent("MERCHANT_SHOW")
	else
		AutoVendor:UnregisterEvent("MERCHANT_SHOW")
	end
end

local UpdateAutoRepair = function(value)
	if value then
		AutoRepair:RegisterEvent("MERCHANT_SHOW")
	else
		AutoRepair:UnregisterEvent("MERCHANT_SHOW")
	end
end

GUI:AddWidgets(Language["General"], Language["General"], function(left, right)
	right:CreateHeader(Language["Merchant"])
	right:CreateSwitch("auto-repair-enable", Settings["auto-repair-enable"], Language["Auto Repair Equipment"], Language["Automatically repair damaged items when visiting a repair merchant"], UpdateAutoRepair)
	right:CreateSwitch("auto-repair-report", Settings["auto-repair-report"], Language["Auto Repair Report"], Language["Report the cost of automatic repairs into the chat"])
	right:CreateSwitch("auto-vendor-enable", Settings["auto-vendor-enable"], Language["Auto Sell Greys"], Language["Automatically sell all |cFF9D9D9D[Poor]|r quality items"], UpdateAutoVendor)
	right:CreateSwitch("auto-vendor-report", Settings["auto-vendor-report"], Language["Auto Sell Report"], Language["Report the profit of automatic sales into the chat"])
end)