function EMSItems()
	-- exports.ox_inventory:RegisterUse("tourniquet", "MedicalItems", function(source, item)
	-- 	local char = exports['sandbox-characters']:FetchCharacterSource(source)
	-- 	if char:GetData("Damage").Bleed > 0 then
	-- 		if exports.ox_inventory:RemoveSlot(item.Owner, item.Name, 1, item.Slot, 1) then
	-- 			Player(source).state.tourniquet = (
	-- 					GetGameTimer() + ((1000 * 60 * 5) / char:GetData("Damage").Bleed or 1)
	-- 				)
	-- 		end
	-- 	else
	-- 		exports['sandbox-hud']:Notification(source, "error", "You're Not Bleeding")
	-- 	end
	-- end)

    exports.ox_inventory:RegisterUse("morphine", "MedicalItems", function(source, item)
	    exports['sandbox-damage']:EffectsPainkiller(source, 1)
    end)

    exports.ox_inventory:RegisterUse("oxy", "MedicalItems", function(source, item)
	    local char = exports['sandbox-characters']:FetchCharacterSource(source)
	    local pState = Player(source).state

	    exports['sandbox-damage']:EffectsPainkiller(source, 2)

	    if pState.healTicks ~= nil then
		    local f = pState.healTicks
		    for i = 1, 5 do
			    table.insert(f, "5")
		    end
		    pState.healTicks = f
	    else
		    pState.healTicks = { "5", "5", "5", "5", "5" }
	    end

	    Wait(100)
	    TriggerClientEvent("Damage:Client:Ticks:Heal", source)
    end)

	exports.ox_inventory:RegisterUse("bandage", "MedicalItems", function(source, item)
		local ped = GetPlayerPed(source)
		local curr = GetEntityHealth(ped)
		local max = GetEntityMaxHealth(ped)
		local pState = Player(source).state

		local healAmount = 10
		if curr < (max * 0.75) then
			local p = promise.new()
			exports["sandbox-base"]:ClientCallback(source, "EMS:Heal", healAmount, function(s)
			p:resolve(s)
		end)
		Citizen.Wait(p)
	end

	if pState.healTicks then
		table.insert(pState.healTicks, "5")
		table.insert(pState.healTicks, "5")
	else
		pState.healTicks = { "5", "5" }
	end

	Wait(100)
	TriggerClientEvent("Damage:Client:Ticks:Heal", source)
	end)

    exports.ox_inventory:RegisterUse("firstaid", "MedicalItems", function(source, item)
	    local char = exports['sandbox-characters']:FetchCharacterSource(source)
	    local ped = GetPlayerPed(source)
	    local curr = GetEntityHealth(ped)
	    local max = GetEntityMaxHealth(ped)
	    local pState = Player(source).state

	    local p = promise.new()
	    local heal = 15
	    if curr + heal > max then
		    heal = max - curr
	    end
	    exports["sandbox-base"]:ClientCallback(source, "EMS:Heal", heal, function(s)
		    p:resolve(s)
	    end)
	    Citizen.Await(p)

	    if pState.healTicks ~= nil then
		    local f = pState.healTicks
		    for i = 1, 2 do
			    table.insert(f, "10")
		    end
		    table.insert(f, "5")
		    pState.healTicks = f
	    else
		    pState.healTicks = { "10", "10", "5" }
	    end

	    Wait(100)
	    TriggerClientEvent("Damage:Client:Ticks:Heal", source)
    end)

    exports.ox_inventory:RegisterUse("ifak", "MedicalItems", function(source, item)
	    local char = exports['sandbox-characters']:FetchCharacterSource(source)
	    local ped = GetPlayerPed(source)
	    local curr = GetEntityHealth(ped)
	    local max = GetEntityMaxHealth(ped)
	    local pState = Player(source).state

	    local p = promise.new()
	    local heal = 30
	    if curr + heal > max then
		    heal = max - curr
	    end
	    exports["sandbox-base"]:ClientCallback(source, "EMS:Heal", heal, function(s)
		    p:resolve(s)
	    end)
	    Citizen.Await(p)

	    if pState.healTicks ~= nil then
		    local f = pState.healTicks
		    for i = 1, 2 do
			    table.insert(f, "15")
		    end
		    table.insert(f, "10")
		    for i = 1, 2 do
			    table.insert(f, "5")
		    end
		    pState.healTicks = f
	    else
		    pState.healTicks = { "15", "15", "10", "5", "5" }
	    end

	    Wait(100)
	    TriggerClientEvent("Damage:Client:Ticks:Heal", source)
    end)

	-- exports.ox_inventory:RegisterUse("gauze", "MedicalItems", function(source, item)
	-- 	local char = exports['sandbox-characters']:FetchCharacterSource(source)
	-- 	if exports.ox_inventory:RemoveSlot(item.Owner, item.Name, 1, item.Slot, 1) then
	-- 		local dmg = char:GetData("Damage")
	-- 		if dmg.Bleed > 1 then
	-- 			dmg.Bleed = dmg.Bleed - 1
	-- 			char:SetData("Damage", dmg)
	-- 		else
	-- 			exports['sandbox-hud']:Notification(source, "error", "You continue bleeding through the gauze")
	-- 		end
	-- 	end
	-- end)

    exports.ox_inventory:RegisterUse("medicalkit", "MedicalItems", function(source, item)
	    local char = exports['sandbox-characters']:FetchCharacterSource(source)

	    if exports['sandbox-jobs']:HasJob(source, "ems", false, false, 2) then
		    local myCoords = GetEntityCoords(GetPlayerPed(source))

		    for k, v in pairs(exports['sandbox-characters']:FetchAllCharacters()) do
			    if v ~= nil then
				    local targetSource = v:GetData("Source")
				    if targetSource ~= source and Player(targetSource).state.isHospitalized then
					    local tPos = GetEntityCoords(GetPlayerPed(targetSource))
					    local dist = #(myCoords - tPos)
					    if dist <= 2.5 then
						    TriggerClientEvent("EMS:Client:TreatWounds", source, targetSource)
						    return
					    end
				    end
			    end
		    end

		    exports['sandbox-hud']:Notification(source, "error", "Not Near Any Hospitalized Patients")
	    else
		    exports['sandbox-hud']:Notification(source, "error", "You're not trained to use this")
	    end
    end)
end

RegisterNetEvent('ox_inventory:ready', function()
	if GetResourceState(GetCurrentResourceName()) == 'started' then
		EMSItems()
	end
end)