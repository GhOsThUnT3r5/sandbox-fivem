if not lib then return end

local Items = require 'modules.items.server'
local Inventory = require 'modules.inventory.server'
local Shops = {}
local locations = shared.target and 'targets' or 'locations'

---@class OxShopItem
---@field slot number
---@field weight number

local function getLocationSpecificName(shop, coords, location)
    if location and location.name then
        return location.name
    end
    return shop.name
end

local function setupShopItems(id, shopType, shopName, groups)
    local shop = id and Shops[shopType][id] or Shops[shopType] --[[@as OxShop]]

    for i = 1, shop.slots do
        local slot = shop.items[i]

        if slot.grade and not groups then
            print(('^1attempted to restrict slot %s (%s) to grade %s, but %s has no job restriction^0'):format(id,
                slot.name, json.encode(slot.grade), shopName))
            slot.grade = nil
        end

        local Item = Items(slot.name)

        if Item then
            ---@type OxShopItem
            slot = {
                name = Item.name,
                slot = i,
                weight = Item.weight,
                count = slot.count,
                price = (server.randomprices and (not slot.currency or slot.currency == 'money')) and
                    (math.ceil(slot.price * (math.random(80, 120) / 100))) or slot.price or 0,
                metadata = slot.metadata,
                license = slot.license,
                qualification = slot.qualification,
                currency = slot.currency,
                grade = slot.grade,
                job = slot.job
            }

            if slot.metadata then
                slot.weight = Inventory.SlotWeight(Item, slot, true)
            end

            shop.items[i] = slot
        end
    end
end

---@param shopType string
---@param properties OxShop
local function registerShopType(shopType, properties)
    local shopLocations = properties[locations] or properties.locations

    if shopLocations then
        Shops[shopType] = properties
    else
        Shops[shopType] = {
            label = properties.name,
            id = shopType,
            groups = properties.groups or properties.jobs,
            items = properties.inventory,
            slots = #properties.inventory,
            type = 'shop',
        }

        setupShopItems(nil, shopType, properties.name, properties.groups or properties.jobs)
    end
end

---@param shopType string
---@param id number
local function createShop(shopType, id)
    local shop = Shops[shopType]

    if not shop then return end

    local store = (shop[locations] or shop.locations)?[id]

    if not store then return end

    local groups = shop.groups or shop.jobs
    local coords

    if shared.target then
        if store.length then
            local z = store.loc.z + math.abs(store.minZ - store.maxZ) / 2
            coords = vec3(store.loc.x, store.loc.y, z)
        else
            coords = store.coords or store.loc
        end
    else
        coords = store.coords or store
    end

    local locationName = getLocationSpecificName(shop, coords, store)

    shop[id] = {
        label = locationName,
        id = shopType .. ' ' .. id,
        groups = groups,
        workplace = shop.workplace,
        reqDuty = shop.reqDuty,
        items = table.clone(shop.inventory),
        slots = #shop.inventory,
        type = 'shop',
        coords = coords,
        distance = shared.target and shop.targets?[id]?.distance,
    }

    setupShopItems(id, shopType, locationName, groups)

    return shop[id]
end

for shopType, shopDetails in pairs(lib.load('data.shops') or {}) do
    registerShopType(shopType, shopDetails)
end

---@param shopType string
---@param shopDetails OxShop
exports('RegisterShop', function(shopType, shopDetails)
    registerShopType(shopType, shopDetails)
end)

lib.callback.register('ox_inventory:openShop', function(source, data)
    local left, shop = Inventory(source)

    if not left then return end

    if data then
        shop = Shops[data.type]

        if not shop then return end

        if not shop.items then
            shop = (data.id and shop[data.id] or createShop(data.type, data.id))

            if not shop then return end
        end

        ---@cast shop OxShop

        if shop.groups then
            local group = server.hasGroup(left, shop.groups)
            if not group then return end
        end

        if shop.workplace then
            local workplace = server.hasWorkplace(left, shop.workplace)
            if not workplace then return end
        end

        if shop.reqDuty then
            local group = server.hasGroup(left, shop.groups)
            if group then
                local onDuty = server.isOnDuty(source, group)
                if not onDuty then return end
            end
        end

        if type(shop.coords) == 'vector3' and #(GetEntityCoords(GetPlayerPed(source)) - shop.coords) > 10 then
            return
        end

        local playerJobs = {}
        local playerInv = Inventory(source)
        if playerInv and playerInv.player and playerInv.player.groups then
            for jobName, _ in pairs(playerInv.player.groups) do
                playerJobs[jobName] = true
            end
        end

        local filteredShop = table.clone(shop)
        local filteredItems = {}

        for i = 1, #shop.items do
            local item = shop.items[i]
            if item and (not item.job or playerJobs[item.job]) then
                filteredItems[#filteredItems + 1] = item
            end
        end

        filteredShop.items = filteredItems
        filteredShop.slots = #filteredItems

        ---@diagnostic disable-next-line: assign-type-mismatch
        left:openInventory(left)
        left.currentShop = shop.id

        return {
                label = left.label,
                type = left.type,
                slots = left.slots,
                weight = left.weight,
                maxWeight = left.maxWeight
            },
            filteredShop
    end

    return { label = left.label, type = left.type, slots = left.slots, weight = left.weight, maxWeight = left.maxWeight },
        shop
end)

local function canAffordItem(inv, currency, price, source)
    local canAfford = false
    local currencyLabel
    
    if currency == 'money' then
        canAfford = price >= 0 and Inventory.GetItemCount(inv, currency) >= price
        currencyLabel = locale('$') .. math.groupdigits(price)
    elseif currency == 'bank' then
        -- Use sandbox-finance system for bank money
        local char = exports['sandbox-characters']:FetchCharacterSource(source)
        if char then
            local bankAccount = exports['sandbox-finance']:AccountsGetPersonal(char:GetData("SID"))
            if bankAccount then
                canAfford = bankAccount.Balance >= price
            end
        end
        currencyLabel = locale('$') .. math.groupdigits(price)
    else
        canAfford = price >= 0 and Inventory.GetItemCount(inv, currency) >= price
        local item = Items(currency)
        currencyLabel = math.groupdigits(price) .. ' ' .. (item and item.label or currency)
    end

    return canAfford or {
        type = 'error',
        description = locale('cannot_afford', currencyLabel)
    }
end

local function removeCurrency(inv, currency, price, source)
    if currency == 'money' then
        Inventory.RemoveItem(inv, currency, price)
    elseif currency == 'bank' then
        -- Use sandbox-finance system for bank money
        local char = exports['sandbox-characters']:FetchCharacterSource(source)
        if char then
            local bankAccount = exports['sandbox-finance']:AccountsGetPersonal(char:GetData("SID"))
            if bankAccount then
                exports['sandbox-finance']:BalanceWithdraw(bankAccount.Account, price, {
                    type = 'purchase',
                    title = "Shop Purchase",
                    description = "Purchased items from shop"
                })
            end
        end
    else
        Inventory.RemoveItem(inv, currency, price)
    end
end

local TriggerEventHooks = require 'modules.hooks.server'

local function isRequiredGrade(grade, rank)
    if type(grade) == "table" then
        for i = 1, #grade do
            if grade[i] == rank then
                return true
            end
        end
        return false
    else
        return rank >= grade
    end
end

lib.callback.register('ox_inventory:buyItem', function(source, data)
    -- Disabled: Use shopping cart instead
    return false, false, { type = 'error', description = 'Use the shopping cart to purchase items' }
    --[[
    if data.toType == 'player' then
        if data.count == nil then data.count = 1 end

        local playerInv = Inventory(source)

        if not playerInv or not playerInv.currentShop then return end

        local shopType, shopId = playerInv.currentShop:match('^(.-) (%d-)$')

        if not shopType then shopType = playerInv.currentShop end

        if shopId then shopId = tonumber(shopId) end

        local shop = shopId and Shops[shopType][shopId] or Shops[shopType]
        local fromData = shop.items[data.fromSlot]
        local toData = playerInv.items[data.toSlot]

        if fromData then
            if fromData.count then
                if fromData.count == 0 then
                    return false, false, { type = 'error', description = locale('shop_nostock') }
                elseif data.count > fromData.count then
                    data.count = fromData.count
                end
            end

            if fromData.license and server.hasLicense then
                local hasRequiredLicense = false

                if type(fromData.license) == 'table' then
                    hasRequiredLicense = true
                    for i = 1, #fromData.license do
                        if not server.hasLicense(source, fromData.license[i]) then
                            hasRequiredLicense = false
                            break
                        end
                    end
                else
                    hasRequiredLicense = server.hasLicense(source, fromData.license)
                end

                if not hasRequiredLicense then
                    return false, false, { type = 'error', description = locale('item_unlicensed') }
                end
            end

            if fromData.qualification and server.hasQualification and not server.hasQualification(source, fromData.qualification) then
                return false, false, { type = 'error', description = locale('item_unqualified') }
            end

            if fromData.job then
                local hasJob = playerInv and playerInv.player and playerInv.player.groups and
                    playerInv.player.groups[fromData.job]
                if not hasJob then
                    return false, false,
                        {
                            type = 'error',
                            description = ('You need to be employed at %s to purchase this item'):format(
                                fromData.job)
                        }
                end
            end

            if fromData.grade then
                local _, rank = server.hasGroup(playerInv, shop.groups)
                if not isRequiredGrade(fromData.grade, rank) then
                    return false, false, { type = 'error', description = locale('stash_lowgrade') }
                end
            end

            local currency = fromData.currency or 'money'
            local fromItem = Items(fromData.name)

            local result = fromItem.cb and fromItem.cb('buying', fromItem, playerInv, data.fromSlot, shop)
            if result == false then return false end

            local toItem = toData and Items(toData.name)

            local metadata, count = Items.Metadata(playerInv, fromItem,
                fromData.metadata and table.clone(fromData.metadata) or {}, data.count)
            local price = count * fromData.price

            if toData == nil or (fromItem.name == toItem?.name and fromItem.stack and table.matches(toData.metadata, metadata)) then
                local newWeight = playerInv.weight + (fromItem.weight + (metadata?.weight or 0)) * count

                if newWeight > playerInv.maxWeight then
                    return false, false, { type = 'error', description = locale('cannot_carry') }
                end

                local canAfford = canAffordItem(playerInv, currency, price)

                if canAfford ~= true then
                    return false, false, canAfford
                end

                if not TriggerEventHooks('buyItem', {
                        source = source,
                        shopType = shopType,
                        shopId = shopId,
                        toInventory = playerInv.id,
                        toSlot = data.toSlot,
                        fromSlot = fromData,
                        itemName = fromData.name,
                        metadata = metadata,
                        count = count,
                        price = fromData.price,
                        totalPrice = price,
                        currency = currency,
                    }) then
                    return false
                end

                Inventory.SetSlot(playerInv, fromItem, count, metadata, data.toSlot)
                playerInv.weight = newWeight
                removeCurrency(playerInv, currency, price, source)

                if fromData.count then
                    shop.items[data.fromSlot].count = fromData.count - count
                end

                if server.syncInventory then server.syncInventory(playerInv) end

                local message = locale('purchased_for', count, metadata?.label or fromItem.label,
                    (currency == 'money' and locale('$') or math.groupdigits(price)),
                    (currency == 'money' and math.groupdigits(price) or ' ' .. Items(currency).label))

                if server.loglevel > 0 then
                    if server.loglevel > 1 or fromData.price >= 500 then
                        lib.logger(playerInv.owner, 'buyItem', ('"%s" %s'):format(playerInv.label, message:lower()),
                            ('shop:%s'):format(shop.label))
                    end
                end

                return true,
                    { data.toSlot, playerInv.items[data.toSlot], shop.items[data.fromSlot].count and
                    shop.items[data.fromSlot], playerInv.weight }, { type = 'success', description = message }
            end

            return false, false, { type = 'error', description = locale('unable_stack_items') }
        end
    end
    ]]--
end)

lib.callback.register('ox_inventory:purchaseItems', function(source, data)
    local playerInv = Inventory(source)
    
    if not playerInv or not playerInv.currentShop then 
        return false, false, { type = 'error', description = 'No shop open' }
    end
    
    local shopType, shopId = playerInv.currentShop:match('^(.-) (%d-)$')
    if not shopType then shopType = playerInv.currentShop end
    if shopId then shopId = tonumber(shopId) end
    
    local shop = shopId and Shops[shopType][shopId] or Shops[shopType]
    if not shop then
        return false, false, { type = 'error', description = 'Shop not found' }
    end
    
    local items = data.items or {}
    if #items == 0 then
        return false, false, { type = 'error', description = 'No items to purchase' }
    end
    
    local paymentMethod = data.paymentMethod or 'cash'
    
    -- Calculate total price and verify all items
    local totalPrice = 0
    local currency = nil
    local purchaseData = {}
    
    for i = 1, #items do
        local cartItem = items[i]
        local shopItem = shop.items[cartItem.slot]
        
        if not shopItem or shopItem.name ~= cartItem.name then
            return false, false, { type = 'error', description = 'Invalid item in cart' }
        end
        
        if shopItem.count and shopItem.count < cartItem.count then
            return false, false, { type = 'error', description = locale('shop_nostock') }
        end
        
        -- Check licenses, qualifications, jobs, grades for each item
        if shopItem.license and server.hasLicense then
            local hasRequiredLicense = false
            if type(shopItem.license) == 'table' then
                hasRequiredLicense = true
                for j = 1, #shopItem.license do
                    if not server.hasLicense(source, shopItem.license[j]) then
                        hasRequiredLicense = false
                        break
                    end
                end
            else
                hasRequiredLicense = server.hasLicense(source, shopItem.license)
            end
            
            if not hasRequiredLicense then
                return false, false, { type = 'error', description = locale('item_unlicensed') }
            end
        end
        
        if shopItem.qualification and server.hasQualification and not server.hasQualification(source, shopItem.qualification) then
            return false, false, { type = 'error', description = locale('item_unqualified') }
        end
        
        if shopItem.job then
            local hasJob = playerInv and playerInv.player and playerInv.player.groups and playerInv.player.groups[shopItem.job]
            if not hasJob then
                return false, false, { type = 'error', description = ('You need to be employed at %s to purchase this item'):format(shopItem.job) }
            end
        end
        
        if shopItem.grade then
            local _, rank = server.hasGroup(playerInv, shop.groups)
            if not isRequiredGrade(shopItem.grade, rank) then
                return false, false, { type = 'error', description = locale('stash_lowgrade') }
            end
        end
        
        local itemCurrency = shopItem.currency or 'money'
        if currency and currency ~= itemCurrency then
            return false, false, { type = 'error', description = 'Cannot mix payment methods' }
        end
        currency = itemCurrency
        
        local itemPrice = cartItem.count * shopItem.price
        totalPrice = totalPrice + itemPrice
        
        purchaseData[i] = {
            shopItem = shopItem,
            cartItem = cartItem,
            item = Items(shopItem.name)
        }
    end
    
    -- Check if player can afford total (use correct payment method)
    local checkCurrency = currency
    if paymentMethod == 'bank' and currency == 'money' then
        checkCurrency = 'bank'
    end
    
    -- Debug logging
    print(string.format("^3[SHOP DEBUG] Payment Method: %s, Currency: %s, Check Currency: %s, Price: %d^0", 
        paymentMethod, currency, checkCurrency, totalPrice))
    
    if checkCurrency == 'bank' then
        local char = exports['sandbox-characters']:FetchCharacterSource(source)
        if char then
            local bankAccount = exports['sandbox-finance']:AccountsGetPersonal(char:GetData("SID"))
            if bankAccount then
                print(string.format("^3[SHOP DEBUG] Player has %d bank money^0", bankAccount.Balance))
            else
                print("^3[SHOP DEBUG] No bank account found^0")
            end
        else
            print("^3[SHOP DEBUG] No character found^0")
        end
    else
        print(string.format("^3[SHOP DEBUG] Player has %d %s^0", 
            Inventory.GetItemCount(playerInv, checkCurrency), checkCurrency))
    end
    
    local canAfford = canAffordItem(playerInv, checkCurrency, totalPrice, source)
    if canAfford ~= true then
        return false, false, canAfford
    end
    
    -- Check weight
    local totalWeight = playerInv.weight
    for i = 1, #purchaseData do
        local pd = purchaseData[i]
        local metadata = Items.Metadata(playerInv, pd.item, pd.shopItem.metadata and table.clone(pd.shopItem.metadata) or {}, pd.cartItem.count)
        totalWeight = totalWeight + (pd.item.weight + (metadata?.weight or 0)) * pd.cartItem.count
    end
    
    if totalWeight > playerInv.maxWeight then
        return false, false, { type = 'error', description = locale('cannot_carry') }
    end
    
    -- All checks passed, proceed with purchase
    -- Use the selected payment method (cash or bank)
    local actualCurrency = currency
    if paymentMethod == 'bank' then
        -- If paying with bank, override currency to use bank account
        if currency == 'money' then
            actualCurrency = 'bank' -- Use bank instead of cash
        end
    end
    
    removeCurrency(playerInv, actualCurrency, totalPrice, source)
    
    local shopItems = {}
    
    for i = 1, #purchaseData do
        local pd = purchaseData[i]
        local metadata = Items.Metadata(playerInv, pd.item, pd.shopItem.metadata and table.clone(pd.shopItem.metadata) or {}, pd.cartItem.count)
        
        TriggerEventHooks('buyItem', {
            source = source,
            shopType = shopType,
            shopId = shopId,
            toInventory = playerInv.id,
            fromSlot = pd.shopItem,
            itemName = pd.shopItem.name,
            metadata = metadata,
            count = pd.cartItem.count,
            price = pd.shopItem.price,
            totalPrice = pd.cartItem.count * pd.shopItem.price,
            currency = actualCurrency,
        })
        
        -- Add item to player inventory
        local slot, count = Inventory.AddItem(playerInv, pd.item.name, pd.cartItem.count, metadata)
        
        if not slot then
            return false, false, { type = 'error', description = 'No inventory space available' }
        end
        
        -- Update shop stock
        if pd.shopItem.count then
            shop.items[pd.cartItem.slot].count = pd.shopItem.count - pd.cartItem.count
            shopItems[#shopItems + 1] = {
                item = shop.items[pd.cartItem.slot],
                inventory = 'shop'
            }
        end
    end
    
    if server.syncInventory then server.syncInventory(playerInv) end
    
    local itemsText = #items > 1 and #items .. ' items' or '1 item'
    local priceText = (actualCurrency == 'money' or actualCurrency == 'bank') and ('$' .. math.groupdigits(totalPrice)) or (math.groupdigits(totalPrice) .. ' ' .. actualCurrency)
    local message = 'Purchased ' .. itemsText .. ' for ' .. priceText
    
    if server.loglevel > 0 and totalPrice >= 500 then
        lib.logger(playerInv.owner, 'purchaseItems', ('"%s" %s'):format(playerInv.label, message:lower()),
            ('shop:%s'):format(shop.label))
    end
    
    return true, {
        shopItems = shopItems
    }, { type = 'success', description = message }
end)

server.shops = Shops
