local currentBackpack = nil
local backpackSlot = 6 -- Slot 6 is the backpack slot
local backpackItems = {
    backpack = true,
    large_backpack = true,
    military_backpack = true
}

local function isBackpackItem(itemName)
    return backpackItems[itemName] == true
end

local function getBackpackInSlot()
    if not PlayerData or not PlayerData.inventory then return nil end
    
    local item = PlayerData.inventory[backpackSlot]
    if item and item.name and isBackpackItem(item.name) then
        return item
    end
    
    return nil
end

local function updateBackpackDisplay()
    local backpack = getBackpackInSlot()
    
    if backpack then
        -- Backpack is equipped, show it
        if not currentBackpack or currentBackpack.metadata?.backpackId ~= backpack.metadata?.backpackId then
            currentBackpack = backpack
            
            -- Request backpack inventory from server
            lib.callback.await('ox_inventory:getBackpackInventory', false, backpack.metadata?.backpackId or backpack.slot)
        end
    else
        -- No backpack equipped, hide it
        if currentBackpack then
            currentBackpack = nil
            SendNUIMessage({
                action = 'setupInventory',
                data = {
                    containerInventory = nil
                }
            })
        end
    end
end

-- Monitor inventory changes
RegisterNetEvent('ox_inventory:updateSlots', function(slots, weight, maxWeight)
    -- Check if backpack slot was updated
    for i = 1, #slots do
        local slotData = slots[i]
        if slotData.item and slotData.item.slot == backpackSlot then
            -- Backpack slot changed, update display
            SetTimeout(100, updateBackpackDisplay)
            break
        end
    end
end)

-- Update when inventory opens
AddEventHandler('ox_inventory:openInventory', function()
    SetTimeout(200, updateBackpackDisplay)
end)

return {
    updateBackpackDisplay = updateBackpackDisplay,
    getCurrentBackpack = function() return currentBackpack end,
    isBackpackItem = isBackpackItem
}

