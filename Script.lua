local mt = getrawmetatable(game)
setreadonly(mt, false)
local old = mt.__namecall
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF = game:GetService("ReplicatedStorage").Remotes.CommF_
local ItemReplicationService = require(ReplicatedStorage.ItemReplicationService)
local ItemId = require(ReplicatedStorage.Economy.ItemId)
local ItemConfig = require(ReplicatedStorage.ItemConfig)

local function getInventory()
    local Items = {}

    for _, v in ipairs(ItemReplicationService:GetItems()) do
        local itemId = v.ItemId
        local entry = Items[itemId]

        if not entry then
            local dataResult = ItemId.getDataFromId(itemId) -- was called twice before
            if dataResult:isOk() then
                local ItemData = dataResult:unwrap()
				local ItemConfigData = ItemConfig.match(itemId):unwrap()
                local Type
				local Rarity 

                if ItemData.Type == "Accessory" or ItemData.Type == "Material" or ItemData.Type == "Title" then
                    Type = ItemData.Type
                elseif ItemData.Type == "Moveset" then
                    Type = ItemConfigData.Moveset.Type
                elseif ItemData.Type == "PhysicalMoveset" then
                    Type = ItemConfigData.Inventory.Brackets[1]
                else
                    Type = ItemData.Type
                end

				if ItemConfigData.Quality and ItemConfigData.Quality.RarityValue then 
					Rarity = ItemConfigData.Quality.RarityValue
				end



                entry = {
                    Type = Type,
                    Name = ItemData.StorageKey,
                    ItemId = itemId,
                    NetworkedUID = v.NetworkedUID,
					Rarity = Rarity
                }
                Items[itemId] = entry
            end
        end

        if entry then
            entry[v.Key] = v.Value
        end
    end

    return Items
end

mt.__namecall = function (self, ...)
	if self == CommF and getnamecallmethod() == "InvokeServer" then 
		local args = {...}
		if args[1] == 'getInventory' then 
			return getInventory()
		end
	end
	return old(self, ...)
end
