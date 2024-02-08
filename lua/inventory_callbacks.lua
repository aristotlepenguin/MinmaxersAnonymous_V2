local mod = MMAMod

---@param player EntityPlayer
local function getPlayerData(player)
    local index = mod.Name.."_InventoryData"
    local data = player:GetData()
    if not data[index] then
        data[index] = {}
    end
    return data[index]
end

local callbacks = {}    ---@type table<InventoryCallback, table<CollectibleType, function[]>>
local trackedItems = {} ---@type CollectibleType[]

local ItemGrabCallback =
{
    ---@enum InventoryCallback
    InventoryCallback =
    {
        --- Fired when an item is added to the player's inventory
        --- - `player`: EntityPlayer - the player who picked up the item
        --- - `item`: CollectibleType - id of the item that was picked up
        --- - `count`: integer - amount of item that was picked up
        --- - `touched`: boolean - whether the picked up item was picked up before (.Touched property set to true)
        --- - `queued`: boolean - whether the picked up item was picked up from the item queue
        POST_ADD_ITEM = 1,
        --- Fired when an item is removed from the player's inventory
        --- - `player`: EntityPlayer - the player who lost the item
        --- - `item`: CollectibleType - id of the item that was lost
        --- - `count`: integer - amount of item that was lost
        POST_REMOVE_ITEM = 2,
    },
    ---@param callbackId InventoryCallback
    ---@param callbackFunc function
    ---@param item CollectibleType @id of item for which the callback should be fired
    AddCallback = function (self, callbackId, callbackFunc, item)
        assert(type(callbackId) == "number", "callbackId must be a number, got "..type(callbackId).." instead")
        assert(type(callbackFunc) == "function", "callbackFunc must be a function, got "..type(callbackFunc).." instead")
        assert(type(item) == "number", "item must be a number, got "..type(item).." instead")

        if callbacks[callbackId] == nil then
            callbacks[callbackId] = {}
        end

        if callbacks[callbackId][item] == nil then
            callbacks[callbackId][item] = {}

            --- insert item id into the list of tracked items while maintaining ascending order
            if #trackedItems == 0 then
                table.insert(trackedItems, item)
            else
                local inserted = false
                for i=#trackedItems,1,-1 do
                    if trackedItems[i] == item then
                        inserted = true
                        break
                    elseif trackedItems[i] < item then
                        table.insert(trackedItems, i + 1, item)
                        inserted = true
                        break
                    end
                end

                if not inserted then
                    table.insert(trackedItems, 1, item)
                end
            end
        end

        table.insert(callbacks[callbackId][item], callbackFunc)
    end,
    ---@param callbackId InventoryCallback
    ---@param callbackFunc function
    ---@param item CollectibleType
    RemoveCallback = function (self, callbackId, callbackFunc, item)
        assert(type(callbackId) == "number", "callbackId must be a number, got "..type(callbackId).." instead")
        assert(type(callbackFunc) == "function", "callbackFunc must be a function, got "..type(callbackFunc).." instead")
        assert(type(item) == "number", "item must be a number, got "..type(item).." instead")

        if callbacks[callbackId] == nil or callbacks[callbackId][item] == nil then
            return
        end

        for i = 1, #callbacks[callbackId][item] do
            if callbacks[callbackId][item][i] == callbackFunc then
                table.remove(callbacks[callbackId][item], i)
            end
        end

        if #callbacks[callbackId][item] == 0 then
            callbacks[callbackId][item] = nil

            --- remove item id from the list of tracked items
            for i = 1, #trackedItems do
                if trackedItems[i] == item then
                    table.remove(trackedItems, i)
                    break
                end
            end
        end
    end,
    ---@param callbackId InventoryCallback
    ---@param ... any
    FireCallback = function (self, callbackId, ...)
        assert(type(callbackId) == "number", "callbackId must be a number, got "..type(callbackId).." instead")

        local _, item = ...
        if callbacks[callbackId] == nil or callbacks[callbackId][item] == nil then
            return
        end

        for i = 1, #callbacks[callbackId][item] do
            callbacks[callbackId][item][i](...)
        end
    end,
    --- Prevents ADD/REMOVE callbacks from firing for items added directly to the player's inventory next player update.
    --- Items added from queue will still trigger ADD callback.  
    ---@param player EntityPlayer
    CancelInventoryCallbacksNextFrame = function (self, player)
        assert(player:ToPlayer(), "EntityPlayer expected")
        getPlayerData(player).PreventNextInventoryCallback = true
    end,
}

local itemGrab = ItemGrabCallback

---@param player EntityPlayer
---@return table<CollectibleType, integer>
local function getPlayerInventory(player)
    local inventory = {}

    for _, item in ipairs(trackedItems) do
        local colCount = player:GetCollectibleNum(item, true)
        inventory[item] = colCount
    end

    return inventory
end

---@param inv1 table<CollectibleType, integer>
---@param inv2 table<CollectibleType, integer>
---@return table<CollectibleType, integer>
local function getInventoryDiff(inv1, inv2)
    local out = {}

    for item, count in pairs(inv1) do
        local diff = count - (inv2[item] or 0)
        out[item] = diff
    end

    return out
end

---@class PlayerInventoryData
---@field PrevItems table<CollectibleType, integer>?
---@field PrevQueue ItemConfig_Item?
---@field PrevTouched boolean?

---@param player EntityPlayer
---@return PlayerInventoryData
local function getPlayerInvData(player)
    local data = getPlayerData(player)
    if data.PlayerInventoryData == nil then
        data.PlayerInventoryData = {
            PrevItems = getPlayerInventory(player),
            PrevQueue = nil,
            PrevTouched = nil,
        }
    end
    return data.PlayerInventoryData
end

---@param player EntityPlayer
local function PostPlayerUpdate(_, player)
    if player:IsCoopGhost() then
        return
    end

    local invData = getPlayerInvData(player)
    local inventory = getPlayerInventory(player)
    local diff = getInventoryDiff(inventory, invData.PrevItems)
    local queueItem = player.QueuedItem.Item
    local prevQueueItem = invData.PrevQueue

    if queueItem == nil and prevQueueItem ~= nil then
        if diff[prevQueueItem.ID] and diff[prevQueueItem.ID] > 0 then
            -- print("item got picked up from queue, id =", prevQueueItem.ID, "touched =", invData.PrevTouched)
            itemGrab:FireCallback(itemGrab.InventoryCallback.POST_ADD_ITEM, player, prevQueueItem.ID, diff[prevQueueItem.ID], invData.PrevTouched, true)
            diff[prevQueueItem.ID] = 0
        end
    end

    if not getPlayerData(player).PreventNextInventoryCallback then
        local addedItems = {}
        local removedItems = {}

        for _, item in ipairs(trackedItems) do
            if diff[item] > 0 then
                addedItems[#addedItems+1] = {ID = item, Count = diff[item]}
            elseif diff[item] < 0 then
                removedItems[#removedItems+1] = {ID = item, Count = -diff[item]}
            end
        end

        -- Item add callbacks are fired first
        for i=1, #addedItems do
            local item = addedItems[i]
            itemGrab:FireCallback(itemGrab.InventoryCallback.POST_ADD_ITEM, player, item.ID, item.Count, false, false)
        end

        for i=1, #removedItems do
            local item = removedItems[i]
            itemGrab:FireCallback(itemGrab.InventoryCallback.POST_REMOVE_ITEM, player, item.ID, item.Count)
        end
    else
        getPlayerData(player).PreventNextInventoryCallback = false
    end

    invData.PrevItems = inventory
    invData.PrevQueue = queueItem
    invData.PrevTouched = player.QueuedItem.Touched

end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerUpdate)

---@param cmd string
---@param prm string
local function OnCommand(_, cmd, prm)
    if cmd ~= "itemgrab" then
        return
    end

    local params = {}
    for s in prm:gmatch("%S+") do
        table.insert(params, s)
    end

    -- Spawns item pedestal with id as first parameter and .Touched set to true if second parameter is 1 or greater.
    if params[1] == "spwn" then
        local id = tonumber(params[2]) or 0
        local touched = tonumber(params[3]) or 0

        local room = Game():GetRoom()
        local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
        local pickup = Isaac.Spawn(5, PickupVariant.PICKUP_COLLECTIBLE, id, pos, Vector.Zero, nil):ToPickup()

        if touched >= 1 then
            pickup.Touched = true
        end
    -- Prints currently tracked items.
    elseif params[1] == "tracked" then
        print("Currently tracked items:")
        for i, item in ipairs(trackedItems) do
            print(i, item)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, OnCommand)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function (_, item, rng, player)
    if item == CollectibleType.COLLECTIBLE_D4 then
        itemGrab:CancelInventoryCallbacksNextFrame(player)
        -- print("d4 used at frame", Game():GetFrameCount())
    elseif item == CollectibleType.COLLECTIBLE_D100 then
        itemGrab:CancelInventoryCallbacksNextFrame(player)
        -- print("d100 used at frame", Game():GetFrameCount())
    end
end)

-- USAGE EXAMPLE
-- Spawn a rotten heart when picking up Yuck Heart for the first time
-- or when getting it directly (through console or player:AddCollectible())
-- itemGrab:AddCallback(itemGrab.InventoryCallback.POST_ADD_ITEM, function (player, item, count, touched, fromQueue)
--     if not touched or not fromQueue then
--         for i=1,count do
--             local pos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true)
--             Isaac.Spawn(5, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN, pos, Vector.Zero, player)
--         end
--     end
-- end, CollectibleType.COLLECTIBLE_YUCK_HEART)

return ItemGrabCallback