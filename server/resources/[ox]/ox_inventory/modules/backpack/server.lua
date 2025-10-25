local Inventory = require 'modules.inventory.server'
local MySQL = MySQL
local backpackInventories = {} -- Track backpack inventories by backpackId

local backpackSizes = {
    backpack = { slots = 5, maxWeight = 5000 },
    large_backpack = { slots = 10, maxWeight = 10000 },
    military_backpack = { slots = 15, maxWeight = 15000 }
}

-- Save backpack inventory to database
local function saveBackpackInventory(backpackId, inventory)
    if not backpackId or not inventory or not inventory.items then 
        return 
    end
    
    -- Create a clean items array format (same as player inventory)
    local itemsToSave = {}
    local itemCount = 0
    for slot, item in pairs(inventory.items) do
        if item and item.name then
            itemCount = itemCount + 1
            itemsToSave[itemCount] = {
                name = item.name,
                count = item.count,
                slot = slot,
                metadata = next(item.metadata) and item.metadata or nil
            }
        end
    end
    
    local items = json.encode(itemsToSave)
    
    -- Use proper oxmysql async execute
    MySQL.Async.execute('INSERT INTO ox_inventory (owner, name, data) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE data = VALUES(data)', {
        backpackId,
        'backpack',
        items
    }, function(affectedRows)
        -- Backpack saved successfully
    end)
end

-- Load backpack inventory from database
local function loadBackpackInventory(backpackId)
    if not backpackId then return nil end
    
    local Items = require 'modules.items.server'
    
    -- Use synchronous query for loading
    local result = MySQL.Sync.fetchScalar('SELECT data FROM ox_inventory WHERE owner = ? AND name = ?', {
        backpackId,
        'backpack'
    })
    
    if result and result ~= '' then
        local success, itemsArray = pcall(json.decode, result)
        if success and itemsArray and type(itemsArray) == 'table' then
            -- Convert array format [{name, count, slot, metadata}, ...] back to slot-indexed table
            -- Rebuild items properly like player inventory does
            local items = {}
            local itemCount = 0
            local ostime = os.time()
            
            for _, v in pairs(itemsArray) do
                if v.name and v.slot then
                    local item = Items(v.name)
                    
                    if item then
                        v.metadata = Items.CheckMetadata(v.metadata or {}, item, v.name, ostime)
                        local weight = Inventory.SlotWeight(item, v)
                        
                        items[v.slot] = {
                            name = item.name,
                            label = item.label,
                            weight = weight,
                            slot = v.slot,
                            count = v.count,
                            description = item.description,
                            metadata = v.metadata,
                            stack = item.stack,
                            close = item.close
                        }
                        itemCount = itemCount + 1
                    end
                end
            end
            
            return items
        else
            -- Failed to decode backpack data
        end
    end
    
    return nil
end

local function getOrCreateBackpackInventory(playerId, backpackItem, itemSlot)
    local backpackId = backpackItem.metadata?.backpackId
    local needsMetadataUpdate = false
    
    -- Generate unique backpack ID if it doesn't have one
    if not backpackId then
        backpackId = ('BP-%s-%s'):format(playerId, os.time())
        backpackItem.metadata = backpackItem.metadata or {}
        backpackItem.metadata.backpackId = backpackId
        needsMetadataUpdate = true
    end
    
    -- Check if backpack inventory already exists
    local existingInventory = Inventory(backpackId)
    if existingInventory then
        return existingInventory
    end
    
    -- Get backpack size configuration
    local sizeConfig = backpackSizes[backpackItem.name]
    if not sizeConfig then
        print(('[ox_inventory] Unknown backpack type: %s'):format(backpackItem.name))
        return nil
    end
    
    -- Try to load from database
    local savedItems = loadBackpackInventory(backpackId)
    
    -- If we generated a new backpackId, update the player's inventory to persist it
    if needsMetadataUpdate and itemSlot then
        CreateThread(function()
            Wait(100) -- Small delay to ensure inventory is ready
            local playerInventory = Inventory(playerId)
            if playerInventory and playerInventory.items[itemSlot] then
                -- Get current metadata and add backpackId
                local currentMetadata = playerInventory.items[itemSlot].metadata or {}
                currentMetadata.backpackId = backpackId
                
                -- Use proper SetMetadata function to ensure it's saved
                Inventory.SetMetadata(playerId, itemSlot, currentMetadata)
                
                -- Force save the player inventory immediately
                Wait(100)
                Inventory.Save(playerInventory)
            end
        end)
    end
    
    -- Create new backpack inventory
    local inventory = Inventory.Create(
        backpackId,
        backpackItem.label or 'Backpack',
        'backpack',
        sizeConfig.slots,
        0,
        sizeConfig.maxWeight,
        false,
        savedItems or {}
    )
    
    if inventory then
        backpackInventories[backpackId] = {
            owner = playerId,
            itemName = backpackItem.name,
            created = os.time()
        }
        
        -- Only save to database if this is a brand new backpack (no saved items)
        if not savedItems then
            CreateThread(function()
                Wait(500) -- Wait a moment before first save
                saveBackpackInventory(backpackId, inventory)
            end)
        end
    end
    
    return inventory
end

lib.callback.register('ox_inventory:getBackpackInventory', function(source, backpackId)
    local playerInventory = Inventory(source)
    if not playerInventory then return nil end
    
    -- Get backpack item from slot 6
    local backpackItem = playerInventory.items[6]
    if not backpackItem or not backpackItem.name then return nil end
    
    -- Check if it's a valid backpack
    if not backpackSizes[backpackItem.name] then return nil end
    
    -- Get or create backpack inventory (pass slot 6)
    local backpackInventory = getOrCreateBackpackInventory(source, backpackItem, 6)
    if not backpackInventory then return nil end
    
    return {
        id = backpackInventory.id,
        label = backpackInventory.label,
        type = backpackInventory.type,
        slots = backpackInventory.slots,
        weight = backpackInventory.weight,
        maxWeight = backpackInventory.maxWeight,
        items = backpackInventory.items
    }
end)

-- Save backpack when items change
AddEventHandler('ox_inventory:swapItems', function(payload)
    CreateThread(function()
        -- Wait a moment for the inventory to fully update
        Wait(500)
        
        -- Save backpack inventory if it's being modified
        if payload.toType == 'backpack' or payload.fromType == 'backpack' then
            local playerInventory = Inventory(payload.source)
            if playerInventory then
                local backpackItem = playerInventory.items[6]
                if backpackItem and backpackItem.metadata?.backpackId then
                    local backpackInventory = Inventory(backpackItem.metadata.backpackId)
                    if backpackInventory then
                        saveBackpackInventory(backpackItem.metadata.backpackId, backpackInventory)
                    end
                end
            end
        end
        
        -- Handle backpack slot changes (equip/unequip)
        if payload.fromSlot == 6 or payload.toSlot == 6 then
            local playerInventory = Inventory(payload.source)
            if playerInventory then
                local backpackItem = playerInventory.items[6]
                
                -- If no backpack in slot 6, inventory persists in database
                if not backpackItem or not backpackSizes[backpackItem.name] then
                    -- Backpack removed
                elseif backpackItem.metadata?.backpackId then
                    -- Backpack equipped, ensure metadata is saved to player inventory
                    Inventory.Save(playerInventory)
                    
                    -- Also save the backpack inventory
                    local backpackInventory = Inventory(backpackItem.metadata.backpackId)
                    if backpackInventory then
                        saveBackpackInventory(backpackItem.metadata.backpackId, backpackInventory)
                    end
                end
            end
        end
    end)
end)

-- Save backpack when player closes inventory
AddEventHandler('ox_inventory:closedInventory', function(playerId, inventoryId)
    CreateThread(function()
        Wait(100)
        local playerInventory = Inventory(playerId)
        if not playerInventory or not playerInventory.items then 
            return 
        end
        
        -- Save ALL backpacks in the player's inventory, not just slot 6
        local savedAny = false
        for slot, item in pairs(playerInventory.items) do
            if item and backpackSizes[item.name] then
                -- Ensure backpack has an ID
                if not item.metadata or not item.metadata.backpackId then
                    local backpackId = ('BP-%s-%s'):format(playerId, os.time())
                    item.metadata = item.metadata or {}
                    item.metadata.backpackId = backpackId
                end
                
                -- Save backpack contents if it's been opened
                if item.metadata.backpackId then
                    local backpackInventory = Inventory(item.metadata.backpackId)
                    if backpackInventory then
                        saveBackpackInventory(item.metadata.backpackId, backpackInventory)
                        savedAny = true
                    end
                end
            end
        end
        
        -- Save player inventory if any backpack metadata was updated
        if savedAny then
            Inventory.Save(playerInventory)
        end
    end)
end)

-- Periodic save for all active backpacks
CreateThread(function()
    while true do
        Wait(60000) -- Save every minute
        
        for backpackId, data in pairs(backpackInventories) do
            local inventory = Inventory(backpackId)
            if inventory then
                saveBackpackInventory(backpackId, inventory)
            end
        end
    end
end)

return {
    getOrCreateBackpackInventory = getOrCreateBackpackInventory,
    backpackInventories = backpackInventories
}

