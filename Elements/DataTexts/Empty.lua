local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Update = function()

end

local OnEnable = function(self)
	self.Text:SetText("")
end

local OnDisable = function()

end

HydraUI:AddDataText("Empty", OnEnable, OnDisable, Update)