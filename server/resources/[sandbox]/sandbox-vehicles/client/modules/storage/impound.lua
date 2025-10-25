local attemptingImpoundOnVehicle = false

AddEventHandler('Vehicles:Client:StartUp', function()
	exports['sandbox-pedinteraction']:Add('veh_impound', `ig_floyd`, vector3(-193.282, -1162.433, 22.7), 270.4, 10.0, {
		{
			icon = "fas fa-truck",
			text = "Impound Release Request",
			event = "Vehicles:Client:TowReleaseMenu",
		},
		{
			icon = "fas fa-truck",
			text = "Request Tow Job",
			event = "Tow:Client:RequestJob",
			groups = { "tow" },
		},
		{
			icon = "fas fa-right-from-bracket",
			text = "Quit Tow Job",
			event = "Tow:Client:QuitJob",
			groups = { "tow" },
			reqOffDuty = true,
		},
		{
			icon = "fas fa-clipboard-check",
			text = "Tow - Go On Duty",
			event = "Tow:Client:OnDuty",
			groups = { "tow" },
			reqOffDuty = true,
		},
		{
			icon = "fas fa-clipboard",
			text = "Tow - Go Off Duty",
			event = "Tow:Client:OffDuty",
			groups = { "tow" },
			reqDuty = true,
		},
	}, 'truck-tow', 'WORLD_HUMAN_CLIPBOARD')
end)

AddEventHandler('Vehicles:Client:CharacterLogin', function()
	if _vehicleImpound then
		exports["sandbox-blips"]:Add('veh_impound', "Impound Yard | Tow Job", _vehicleImpound.coords, 317, 16, 0.6)
	end
end)

AddEventHandler('Vehicles:Client:RequestTow', function(entityData)
	if DoesEntityExist(entityData.entity) and IsVehicleEmpty(entityData.entity) then
		local vState = Entity(entityData.entity).state
		if vState and vState.VIN then
			local character = LocalPlayer.state.Character
			local myDuty = LocalPlayer.state.onDuty

			local canRegularImpound = exports['sandbox-jobs']:HasPermission(_impoundConfig.RequiredPermission)
			local canPoliceImpound = exports['sandbox-jobs']:HasPermission(_impoundConfig.Police
				.RequiredPermission)

			if myDuty and canRegularImpound or canPoliceImpound then
				attemptingImpoundOnVehicle = entityData.entity

				local menu = {
					main = {
						label = 'Impound Vehicle - ' .. vState.VIN,
						items = {
							{
								label = 'Emergency Impound',
								description =
								'Emergency Impound if a Vehicle is Causing Major Issues or is Broken and Needs to be Removed.',
								event = 'Vehicles:Client:Tow',
								data = { type = 'emergency_impound' },
							},
							{
								label = 'Regular Impound',
								description = 'Impound a Vehicle for a Fine of $' .. _impoundConfig.RegularFine,
								event = 'Vehicles:Client:Tow',
								data = { type = 'impound' },
							},
						}
					},
				}

				if canPoliceImpound then
					menu['police'] = {
						label = 'Impound Vehicle - ' .. vState.VIN,
						items = {}
					}

					table.insert(menu.main.items, {
						label = 'Police Impound',
						description = 'Impound For a Specified Time Period and Fine',
						submenu = 'police',
					})

					for k, v in ipairs(_impoundConfig.Police.Levels) do
						local fine = false
						if v.Fine.Percent and vState.Value and type(vState.Value) == 'number' then
							fine = vState.Value * (v.Fine.Percent / 100)
						end

						if not fine or fine <= v.Fine.Min then
							fine = v.Fine.Min
						end

						table.insert(menu.police.items, {
							label = 'Impound Level #' .. k,
							description = string.format('%s$%s Fine %s',
								(v.Holding > 0 and (v.Holding .. ' Hour Holding Time, ') or ''), fine,
								v.Fine.Percent and
								string.format('(%s%% of Est. Vehicle Value OR Min. Fine of $%s)', v.Fine.Percent,
									v.Fine.Min) or ''),
							data = { type = 'police', level = k },
							event = 'Vehicles:Client:Tow',
						})
					end
				end

				exports['sandbox-hud']:ListMenuShow(menu)
			end
		end
	end
end)

AddEventHandler('Vehicles:Client:RequestImpound', function(entityData)
	if DoesEntityExist(entityData.entity) and IsVehicleEmpty(entityData.entity) then
		local vState = Entity(entityData.entity).state
		if vState and vState.VIN then
			local character = LocalPlayer.state.Character
			local myDuty = LocalPlayer.state.onDuty

			local canRegularImpound = exports['sandbox-jobs']:HasPermission(_impoundConfig.RequiredPermission)
			local canPoliceImpound = exports['sandbox-jobs']:HasPermission(_impoundConfig.Police
				.RequiredPermission)

			if myDuty and canRegularImpound or canPoliceImpound then
				attemptingImpoundOnVehicle = entityData.entity

				local menu = {
					main = {
						label = 'Impound Vehicle - ' .. vState.VIN,
						items = {
							{
								label = 'Emergency Impound',
								description =
								'Emergency Impound if a Vehicle is Causing Major Issues or is Broken and Needs to be Removed.',
								event = 'Vehicles:Client:Impound',
								data = { type = 'emergency_impound' },
							},
							{
								label = 'Regular Impound',
								description = 'Impound a Vehicle for a Fine of $' .. _impoundConfig.RegularFine,
								event = 'Vehicles:Client:Impound',
								data = { type = 'impound' },
							},
						}
					},
				}

				if canPoliceImpound then
					menu['police'] = {
						label = 'Impound Vehicle - ' .. vState.VIN,
						items = {}
					}

					table.insert(menu.main.items, {
						label = 'Police Impound',
						description = 'Impound For a Specified Time Period and Fine',
						submenu = 'police',
					})

					for k, v in ipairs(_impoundConfig.Police.Levels) do
						local fine = false
						if v.Fine.Percent and vState.Value and type(vState.Value) == 'number' then
							fine = vState.Value * (v.Fine.Percent / 100)
						end

						if not fine or fine <= v.Fine.Min then
							fine = v.Fine.Min
						end

						table.insert(menu.police.items, {
							label = 'Impound Level #' .. k,
							description = string.format('%s$%s Fine %s',
								(v.Holding > 0 and (v.Holding .. ' Hour Holding Time, ') or ''), fine,
								v.Fine.Percent and
								string.format('(%s%% of Est. Vehicle Value OR Min. Fine of $%s)', v.Fine.Percent,
									v.Fine.Min) or ''),
							data = { type = 'police', level = k },
							event = 'Vehicles:Client:Impound',
						})
					end
				end

				exports['sandbox-hud']:ListMenuShow(menu)
			end
		end
	end
end)

AddEventHandler('Vehicles:Client:Tow', function(data)
	if attemptingImpoundOnVehicle and DoesEntityExist(attemptingImpoundOnVehicle) then
		if #(GetEntityCoords(attemptingImpoundOnVehicle) - GetEntityCoords(GLOBAL_PED)) <= 10.0 and IsVehicleEmpty(attemptingImpoundOnVehicle) then
			exports['sandbox-hud']:ProgressWithTickEvent({
				name = 'veh_impound',
				duration = 3 * 1000,
				label = 'Requesting Tow',
				useWhileDead = false,
				canCancel = true,
				vehicle = false,
				disarm = false,
				ignoreModifier = true,
				controlDisables = {
					disableMovement = true,
					disableCarMovement = true,
					disableMouse = false,
					disableCombat = true,
				},
				animation = {
					anim = 'cop3',
				},
			}, function()
				if not DoesEntityExist(attemptingImpoundOnVehicle) or (#(GetEntityCoords(attemptingImpoundOnVehicle) - GetEntityCoords(GLOBAL_PED)) > 10.0) or not IsVehicleEmpty(attemptingImpoundOnVehicle) then
					exports['sandbox-hud']:ProgressCancel()
				end
			end, function(cancelled)
				if not cancelled and DoesEntityExist(attemptingImpoundOnVehicle) and (#(GetEntityCoords(attemptingImpoundOnVehicle) - GetEntityCoords(GLOBAL_PED)) <= 10.0) and IsVehicleEmpty(attemptingImpoundOnVehicle) then
					exports["sandbox-base"]:ServerCallback("Vehicles:Impound:TagVehicle", {
						vNet = VehToNet(attemptingImpoundOnVehicle),
						type = data.type,
						level = data.level,
						requester = LocalPlayer.state.Character:GetData("SID"),
					}, function()
						TriggerServerEvent("EmergencyAlerts:Server:DoPredefined", "towRequest")
						exports["sandbox-hud"]:Notification("success", 'Tow Requested')
					end)
				else
					exports["sandbox-hud"]:Notification("error", 'Tow Request Failed')
				end
			end)
		else
			exports["sandbox-hud"]:Notification("error", 'Cannot Request Tow On That Vehicle Anymore...')
		end
	end
end)

AddEventHandler('Vehicles:Client:Impound', function(data)
	if attemptingImpoundOnVehicle and DoesEntityExist(attemptingImpoundOnVehicle) then
		if #(GetEntityCoords(attemptingImpoundOnVehicle) - GetEntityCoords(GLOBAL_PED)) <= 10.0 and IsVehicleEmpty(attemptingImpoundOnVehicle) then
			exports['sandbox-hud']:ProgressWithTickEvent({
				name = 'veh_impound',
				duration = 10 * 1000,
				label = 'Impounding Vehicle',
				useWhileDead = false,
				canCancel = true,
				vehicle = false,
				disarm = false,
				ignoreModifier = true,
				controlDisables = {
					disableMovement = true,
					disableCarMovement = true,
					disableMouse = false,
					disableCombat = true,
				},
				animation = {
					anim = 'cop3',
				},
			}, function()
				if not DoesEntityExist(attemptingImpoundOnVehicle) or (#(GetEntityCoords(attemptingImpoundOnVehicle) - GetEntityCoords(GLOBAL_PED)) > 10.0) or not IsVehicleEmpty(attemptingImpoundOnVehicle) then
					exports['sandbox-hud']:ProgressCancel()
				end
			end, function(cancelled)
				if not cancelled and DoesEntityExist(attemptingImpoundOnVehicle) and (#(GetEntityCoords(attemptingImpoundOnVehicle) - GetEntityCoords(GLOBAL_PED)) <= 10.0) and IsVehicleEmpty(attemptingImpoundOnVehicle) then
					exports["sandbox-base"]:ServerCallback('Vehicles:Impound', {
						vNet = VehToNet(attemptingImpoundOnVehicle),
						type = data.type,
						level = data.level,
					}, function(success)
						if success then
							exports["sandbox-hud"]:Notification("success", 'Vehicle Impounded')
						else
							exports["sandbox-hud"]:Notification("error", 'Impound Failed')
						end
					end)
				else
					exports["sandbox-hud"]:Notification("error", 'Impound Failed')
				end
			end)
		else
			exports["sandbox-hud"]:Notification("error", 'Cannot Impound That Vehicle Anymore...')
		end
	end
end)

AddEventHandler('Vehicles:Client:TowReleaseMenu', function()
	exports["sandbox-base"]:ServerCallback('Vehicles:GetVehiclesInImpound', {}, function(vehicleData, time)
		if vehicleData and #vehicleData > 0 then
			local impoundMenu = {
				main = {
					label = 'Impounded Vehicles',
					items = {},
				}
			}

			local cash = LocalPlayer.state.Character:GetData('Cash')

			local function createVehicleSubmenu(vehicle)
				local vehItems = {}

				table.insert(vehItems, {
					label = 'Vehicle\'s Identification',
					description = string.format('VIN: %s, Plate: %s', vehicle.VIN, vehicle.RegisteredPlate or 'N/A'),
					event = false,
				})

				local passHoldingCheck = false
				local passFineCheck = false

				if vehicle.Seized then
					table.insert(vehItems, {
						label = 'This Vehicle Has Been Seized',
						description = 'This vehicle has been seized, pay your loan and it will be released.',
						event = false,
					})
				else
					if vehicle.Storage.TimeHold then
						local timeRemaining = vehicle.Storage.TimeHold.ExpiresAt - time
						local totalTimeString = GetFormattedTimeFromSeconds(vehicle.Storage.TimeHold.Length)
						if timeRemaining > 0 then
							local timeString = GetFormattedTimeFromSeconds(timeRemaining)
							table.insert(vehItems, {
								label = 'Impound - Holding Time',
								description = string.format('%s remaining (Total of %s)', timeString, totalTimeString),
								event = false,
							})
						else
							table.insert(vehItems, {
								label = 'Impound - Holding Time',
								description = string.format('No time remaining (Total of %s)', totalTimeString),
								event = false,
							})
							passHoldingCheck = true
						end
					else
						passHoldingCheck = true
					end

					if vehicle.Storage.Fine and vehicle.Storage.Fine > 0 then
						if cash >= vehicle.Storage.Fine then
							passFineCheck = true
						end

						table.insert(vehItems, {
							label = 'Impound - Fine',
							description = string.format('$%d Fine %s', vehicle.Storage.Fine,
								(not passFineCheck and ' (Not Enough Cash)' or '')),
							event = false,
						})
					else
						passFineCheck = true
					end
				end

				local canRetrieve = false
				if passHoldingCheck and passFineCheck and not vehicle.Seized then
					canRetrieve = true
				end

				local description = 'Pay Fees & Retrieve Vehicle'
				if not passFineCheck then
					description = 'Cannot Retrieve Vehicle - Not Enough Cash'
				end

				if not passHoldingCheck then
					description = 'Cannot Retrieve Vehicle - Still in Holding'
				end

				if vehicle.Seized then
					description = 'Cannot Retrieve Vehicle - Vehicle Seized'
				end

				table.insert(vehItems, {
					label = 'Retrieve From Impound',
					description = description,
					event = 'Vehicles:Client:TowRequestRelease',
					data = { VIN = vehicle.VIN },
					disabled = not canRetrieve
				})

				impoundMenu[vehicle.VIN] = {
					label = vehicle.Make .. ' ' .. vehicle.Model,
					items = vehItems
				}
			end

			for k, v in ipairs(vehicleData) do
				createVehicleSubmenu(v)
				local description = ''
				if v.RegisteredPlate then
					description = 'Plate: ' .. v.RegisteredPlate .. ' VIN: ' .. v.VIN
				else
					description = 'Type: ' .. (v.Type == 1 and 'Boat' or 'Aircraft')
				end

				table.insert(impoundMenu.main.items, {
					label = v.Make .. ' ' .. v.Model,
					description = description,
					submenu = v.VIN,
				})
			end

			exports['sandbox-hud']:ListMenuShow(impoundMenu)
		else
			exports["sandbox-hud"]:Notification("info", 'None of Your Vehicles Are Impounded')
		end
	end)
end)

AddEventHandler('Vehicles:Client:TowRequestRelease', function(data)
	if data and data.VIN then
		local pedCoords = GetEntityCoords(GLOBAL_PED)
		local freeImpoundSpace = GetClosestAvailableParkingSpace(pedCoords, _vehicleImpound.spaces)
		if freeImpoundSpace and #(pedCoords - freeImpoundSpace.xyz) <= 50.0 then
			exports["sandbox-base"]:ServerCallback('Vehicles:RetrieveVehicleFromImpound', {
				VIN = data.VIN,
				coords = freeImpoundSpace.xyz,
				heading = freeImpoundSpace.w,
			}, function(success)
				if success then
					exports["sandbox-hud"]:Notification("success",
						'Vehicle Retrieved From Impound. It is Parked in the Lot Outside', 10000)
				else
					exports["sandbox-hud"]:Notification("error", 'Error Retrieving From Impound')
				end
			end)
		else
			exports["sandbox-hud"]:Notification("error", 'Impound Parking Lot Full')
		end
	end
end)
