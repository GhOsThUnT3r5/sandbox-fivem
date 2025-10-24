local seatbeltExemptVehicles = {
    [8] = true,
    [13] = true,
    [14] = true,
    [15] = true,
    [16] = true,
}

local seatbeltThread = false

local MIN_FLY_NO_SB = math.floor(27 * 2.237)  -- 60mph
local MIN_FLY_BELT = math.floor(49.2 * 2.237) -- 110mph
local MIN_FLY_HARN = math.floor(89.5 * 2.237) -- 200mph

AddEventHandler('Vehicles:Client:StartUp', function()
    exports["sandbox-kbs"]:Add('vehicle_seatbelt', 'b', 'keyboard', 'Vehicle - Toggle Seatbelt / Harness',
        function()
            if VEHICLE_INSIDE and not seatbeltExemptVehicles[VEHICLE_CLASS] then
                local vState = Entity(VEHICLE_INSIDE)
                if vState.state.Harness and vState.state.Harness > 0 and (VEHICLE_SEAT == -1 or VEHICLE_SEAT == 0) then
                    if not VEHICLE_SEATBELT then
                        exports['sandbox-hud']:ProgressWithTickEvent({
                            name = "vehicle_harness",
                            duration = VEHICLE_SEATBELT and 1000 or 2000,
                            label = VEHICLE_SEATBELT and "Removing Harness" or "Applying Harness",
                            tickrate = 1000,
                            useWhileDead = false,
                            canCancel = true,
                            disarm = false,
                            ignoreModifier = true,
                            controlDisables = {
                                disableMovement = false,
                                disableCarMovement = false,
                                disableMouse = false,
                                disableCombat = false,
                            },
                        }, function()
                            if not VEHICLE_INSIDE then
                                exports['sandbox-hud']:ProgressFail()
                            end
                        end, function(cancelled)
                            if not cancelled and VEHICLE_INSIDE then
                                exports["sandbox-sounds"]:PlayOne('seatbelt.ogg', 0.4)
                                if VEHICLE_SEATBELT then
                                    SetFlyThroughWindscreenParams(MIN_FLY_NO_SB, 1.0, 17.0, 1.0)
                                    VEHICLE_SEATBELT = false
                                    VEHICLE_HARNESS = false
                                else
                                    SetFlyThroughWindscreenParams(MIN_FLY_HARN, 1.0, 17.0, 9999999.0)
                                    VEHICLE_SEATBELT = true
                                    VEHICLE_HARNESS = vState.state.Harness
                                end
                                TriggerEvent('Vehicles:Client:Seatbelt', VEHICLE_SEATBELT)
                            end
                        end)
                    else
                        if VEHICLE_INSIDE then
                            exports["sandbox-sounds"]:PlayOne('seatbelt.ogg', 0.4)
                            if VEHICLE_SEATBELT then
                                SetFlyThroughWindscreenParams(MIN_FLY_NO_SB, 1.0, 17.0, 1.0)
                                VEHICLE_SEATBELT = false
                                VEHICLE_HARNESS = false
                            else
                                SetFlyThroughWindscreenParams(MIN_FLY_HARN, 1.0, 17.0, 99999999.0)
                                VEHICLE_SEATBELT = true
                                VEHICLE_HARNESS = vState.state.Harness
                            end
                            TriggerEvent('Vehicles:Client:Seatbelt', VEHICLE_SEATBELT)
                        end
                    end
                else
                    exports["sandbox-sounds"]:PlayOne('seatbelt.ogg', 0.4)
                    VEHICLE_SEATBELT = not VEHICLE_SEATBELT
                    TriggerEvent('Vehicles:Client:Seatbelt', VEHICLE_SEATBELT)
                    if VEHICLE_SEATBELT then
                        SetFlyThroughWindscreenParams(MIN_FLY_BELT, 40.0, 17.0, 500.0)
                        exports["sandbox-hud"]:Notification("success", 'Seatbelt On')
                    else
                        SetFlyThroughWindscreenParams(MIN_FLY_NO_SB, 1.0, 17.0, 1.0)
                        exports["sandbox-hud"]:Notification("error", 'Seatbelt Off')
                    end
                end
            end
        end)

    exports['sandbox-base']:RegisterClientCallback('Vehicles:InstallHarness', function(data, cb)
        local coords = GetEntityCoords(PlayerPedId())
        local maxDistance = 2.0
        local includePlayerVehicle = true

        local target = lib.getClosestVehicle(coords, maxDistance, includePlayerVehicle)

        if target and DoesEntityExist(target) and IsEntityAVehicle(target) then
            if exports['sandbox-vehicles']:UtilsIsCloseToVehicle(target) then
                local vehState = Entity(target).state
                if vehState.Harness and vehState.Harness > 0 then
                    exports['sandbox-hud']:Notification("error", "Vehicle already has a harness installed")
                    cb(false)
                    return
                end

                exports['sandbox-hud']:Progress({
                    name = "vehicle_installing_harness",
                    duration = 25000,
                    label = "Installing Harness",
                    useWhileDead = false,
                    canCancel = true,
                    controlDisables = {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = false,
                    },
                    animation = {
                        anim = "mechanic2",
                    },
                }, function(cancelled)
                    if not cancelled and exports['sandbox-vehicles']:UtilsIsCloseToVehicle(target) then
                        cb(VehToNet(target))
                    else
                        cb(false)
                    end
                end)
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)
end)

AddEventHandler('Vehicles:Client:EnterVehicle', function(v, seat)
    local vehicleHasSeatbelt = true
    if not seatbeltExemptVehicles[VEHICLE_CLASS] then
        TriggerEvent('Vehicles:Client:Seatbelt', false)
        seatbeltThread = true

        local speedBuffers = {}
        local velBuffers = {}

        SetPedConfigFlag(LocalPlayer.state.ped, 32, true)
        SetFlyThroughWindscreenParams(MIN_FLY_NO_SB, 1.0, 17.0, 1.0)

        CreateThread(function()
            local speedBuffers = {}
            local velBuffers = {}
            local minSpeed = 80 / 3.6
            local minSpeedBelt = 110 / 3.6

            while seatbeltThread do
                speedBuffers[2] = speedBuffers[1]
                speedBuffers[1] = GetEntitySpeed(VEHICLE_INSIDE)

                local minSpeedActual = minSpeed
                if VEHICLE_SEATBELT then
                    minSpeedActual = minSpeedBelt
                end

                if speedBuffers[2] ~= nil and GetEntitySpeedVector(VEHICLE_INSIDE, true).y > 1.0 and (speedBuffers[1] >= minSpeedActual) and ((speedBuffers[2] - speedBuffers[1]) > (speedBuffers[1] * 0.8)) then
                    -- if not VEHICLE_HARNESS or (VEHICLE_HARNESS and VEHICLE_HARNESS <= 0) then
                    --     if not VEHICLE_SEATBELT then
                    --         exports["sandbox-hud"]:Notification("info", 'Maybe You Should be Wearing a Seatbelt...', 8000)
                    --     end

                    --     local pedCoords = GetEntityCoords(GLOBAL_PED)
                    --     local fw = GetEntityForwardVector(GLOBAL_PED)
                    --     SetEntityCoords(GLOBAL_PED, pedCoords.x + fw.x, pedCoords.y + fw.y, pedCoords.z - 0.2, true, true, true)
                    --     SetEntityVelocity(GLOBAL_PED, velBuffers[2].x, velBuffers[2].y, velBuffers[2].z)
                    --     Wait(1)
                    --     SetPedToRagdoll(GLOBAL_PED, 1000, 1000, 0, 0, 0, 0)

                    --     local model = GetEntityModel(VEHICLE_INSIDE)

                    --     if IsThisModelAPlane(model) then
                    --         exports['sandbox-mdt']:EmergencyAlertsCreateIfReported(300.0, "planeaccident", true)
                    --     elseif IsThisModelAHeli(model) then
                    --         exports['sandbox-mdt']:EmergencyAlertsCreateIfReported(300.0, "heliaccident", true)
                    --     elseif IsThisModelABoat(model) or IsThisModelAJetski(model) then
                    --         exports['sandbox-mdt']:EmergencyAlertsCreateIfReported(300.0, "boataccident", true)
                    --     else
                    --         exports['sandbox-mdt']:EmergencyAlertsCreateIfReported(300.0, "caraccident", true)
                    --     end
                    -- else
                    --     print('harness get facked')
                    --     TriggerServerEvent('Vehicles:Server:HarnessDamage')
                    --     VEHICLE_HARNESS = VEHICLE_HARNESS - 1

                    --     if VEHICLE_HARNESS <= 0 then
                    --         VEHICLE_SEATBELT = false
                    --         VEHICLE_HARNESS = false

                    --         TriggerEvent('Vehicles:Client:Seatbelt', VEHICLE_SEATBELT)
                    --     end
                    -- end

                    if VEHICLE_HARNESS and VEHICLE_HARNESS > 0 then
                        -- print('harness get facked')
                        TriggerServerEvent('Vehicles:Server:HarnessDamage')
                        VEHICLE_HARNESS = VEHICLE_HARNESS - 1

                        if VEHICLE_HARNESS <= 0 then
                            VEHICLE_SEATBELT = false
                            VEHICLE_HARNESS = false

                            TriggerEvent('Vehicles:Client:Seatbelt', VEHICLE_SEATBELT)
                        end
                    end
                end

                velBuffers[2] = velBuffers[1]
                velBuffers[1] = GetEntityVelocity(VEHICLE_INSIDE)

                Wait(100)
            end
        end)
    end
end)

function GetEntityForwardVector(entity)
    local hr = GetEntityHeading(entity) + 90.0
    if hr < 0.0 then hr = 360.0 + hr end
    hr = hr * 0.0174533
    return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
end

AddEventHandler('Vehicles:Client:ExitVehicle', function()
    -- if GetEntitySpeed(LocalPlayer.state.ped) > 10.0 then
    --     print('flew out')
    -- end

    seatbeltThread = false
    VEHICLE_SEATBELT = false
    VEHICLE_HARNESS = false
end)

AddEventHandler('Vehicles:Client:CharacterLogout', function()
    VEHICLE_SEATBELT = false
    VEHICLE_HARNESS = false
    seatbeltThread = false
end)
