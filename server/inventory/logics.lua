
local items = config.items

--[[ 
id = Server ID
item = Item name, not label
count = Item count to add

/!\ This do not check player weight befor giving the item /!\
]]--
function AddItem(id, item, count)
    Citizen.CreateThread(function() -- Working in async, maybe that could fix inv issue i got without working in async, need testing i guess
        if items[item] ~= nil then
            if PlayersCache[id].inv[item] == nil then -- Item do not exist in inventory, creating it
                PlayersCache[id].inv[item] = {}
                PlayersCache[id].inv[item].label = items[item].label
                PlayersCache[id].inv[item].count = count
            else -- Item do exist, adding count
                PlayersCache[id].inv[item].count = PlayersCache[id].inv[item].count + count
            end
            TriggerClientEvent(config.prefix.."OnGetItem", id, items[item].label, count)
        else
            -- Item do not exist, should do some kind of error notification
            ErrorHandling(id, 1)
        end
    end)
end

--[[ 
id = Server ID
item = Item name, not label
count = Item count to remove
]]--
function RemoveItem(id, item, count)
    Citizen.CreateThread(function()
        if items[item] ~= nil then
            if PlayersCache[id].inv[item] ~= nil then -- Item do not exist in inventory
                if PlayersCache[id].inv[item].count - count <= 0 then -- If count < or = 0 after removing item count, then deleting it from player inv
                    PlayersCache[id].inv[item] = nil
                else
                    PlayersCache[id].inv[item].count = PlayersCache[id].inv[item].count - count
                end
                TriggerClientEvent(config.prefix.."OnRemoveItem", id, items[item].label, count)
            else
                ErrorHandling(id, 2)
            end
        else
            ErrorHandling(id, 1)
        end
    end)
end

--[[ 
id = Server ID
item = Item name, not label
count = Item count to add

/!\ This **do** check player weight befor giving the item /!\
]]--
function AddItemIf(id, item, count)
    Citizen.CreateThread(function() -- Working in async, maybe that could fix inv issue i got without working in async, need testing i guess
        if items[item] ~= nil then
            local iWeight = GetInvWeight(PlayersCache[id].inv)
            if iWeight + items[item].weight <= config.defaultWeightLimit then
                if PlayersCache[id].inv[item] == nil then -- Item do not exist in inventory, creating it
                    PlayersCache[id].inv[item] = {}
                    PlayersCache[id].inv[item].label = items[item].label
                    PlayersCache[id].inv[item].count = count
                else -- Item do exist, adding count
                    PlayersCache[id].inv[item].count = PlayersCache[id].inv[item].count + count
                end
                TriggerClientEvent(config.prefix.."OnGetItem", id, items[item].label, count)
            else
                -- Need to do error notification to say, you can't hold the object
            end
        else
            -- Item do not exist, should do some kind of error notification
            ErrorHandling(id, 1)
        end
    end)
end


--[[ 
inv = Player inventory
return = weight (int) but could be float
]]--
function GetInvWeight(inv)
    local weight = 0
    for k,v in pairs(inv) do
        weight = items[k].weight * v.count
    end
    return weight
end