local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local AutoVendor = vUI:NewModule("Auto Vendor") -- Automatically sell useless items

AutoVendor.Filter = {
	[6196] = true,
}

function vUI:GetTrashValue()
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
			local Link, ID = GetContainerItemLink(Bag, Slot), GetContainerItemID(Bag, Slot)
			
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
		vUI:print(format(Language["You sold %d %s for a total of %s"], TotalCount, TotalCount > 0 and "items" or "item", GetCoinTextureString(Profit)))
	end
end

function AutoVendor:Load()
	if Settings["auto-vendor-enable"] then
		self:RegisterEvent("MERCHANT_SHOW")
		self:SetScript("OnEvent", self.OnEvent)
	end
end

local AutoRepair = vUI:NewModule("Auto Repair")

function AutoRepair:OnEvent()
	local Money = GetMoney()
	
	if CanMerchantRepair() then
		local Cost = GetRepairAllCost()
		local CostString = GetCoinTextureString(Cost)
		
		if (Cost > 0) then
			if (Money > Cost) then
				RepairAllItems()
				
				if Settings["auto-repair-report"] then
					vUI:print(format(Language["Your equipped items have been repaired for %s"], CostString))
				end
			else
				local Required = Cost - Money
				local RequiredString = GetCoinTextureString(Required)
				
				if Settings["auto-repair-report"] then
					vUI:print(format(Language["You require %s to repair all equipped items (costs %s total)"], RequiredString, CostString))
				end
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

GUI:AddOptions(function(self)
	local Left = self:GetWindow(Language["General"])
	
	Left:CreateHeader(Language["Merchant"])
	Left:CreateSwitch("auto-repair-enable", Settings["auto-repair-enable"], Language["Auto Repair Equipment"], "Automatically repair damaged items|nwhen visiting a repair merchant", UpdateAutoRepair)
	Left:CreateSwitch("auto-repair-report", Settings["auto-repair-report"], Language["Auto Repair Report"], "Report the cost of automatic repairs into the chat")
	Left:CreateSwitch("auto-vendor-enable", Settings["auto-vendor-enable"], Language["Auto Vendor Greys"], "Automatically sell all |cFF9D9D9D[Poor]|r quality items", UpdateAutoVendor)
	Left:CreateSwitch("auto-vendor-report", Settings["auto-vendor-report"], Language["Auto Vendor Report"], "Report the profit of automatic vendoring into the chat")
end)