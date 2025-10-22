AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		Startup()
	end
end)

function Startup()
	exports.ox_target:addBoxZone({
		id = "burgershot-clockinoff",
		coords = vector3(-1177.08, -896.98, 13.79),
		size = vector3(0.4, 0.4, 2.0),
		rotation = 35,
		debug = false,
		minZ = 13.39,
		maxZ = 14.59,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "burgershot" })
				end,
				groups = { "burgershot" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "burgershot" })
				end,
				groups = { "burgershot" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "rustybrowns-clockinoff",
		coords = vector3(164.9, 247.96, 107.05),
		size = vector3(1, 0.8, 2.0),
		rotation = 340,
		debug = false,
		minZ = 103.65,
		maxZ = 107.65,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "rustybrowns" })
				end,
				groups = { "rustybrowns" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "rustybrowns" })
				end,
				groups = { "rustybrowns" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "lasttrain-clockinoff",
		coords = vector3(-384.8, 268.03, 86.46),
		size = vector3(1, 0.8, 2.0),
		rotation = 305,
		debug = false,
		minZ = 86.41,
		maxZ = 87.41,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "lasttrain" })
				end,
				groups = { "lasttrain" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "lasttrain" })
				end,
				groups = { "lasttrain" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "triad-clockinoff",
		coords = vector3(-830.56, -730.64, 28.06),
		size = vector3(1, 1, 2.0),
		rotation = 0,
		debug = false,
		minZ = 27.06,
		maxZ = 28.66,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "triad" })
				end,
				groups = { "triad" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "triad" })
				end,
				groups = { "triad" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "uwu-clockinoff",
		coords = vector3(-593.97, -1053.52, 22.34),
		size = vector3(0.6, 2.8, 2.0),
		rotation = 90,
		debug = false,
		minZ = 21.94,
		maxZ = 23.94,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "uwu" })
				end,
				groups = { "uwu" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "uwu" })
				end,
				groups = { "uwu" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "pizza_this-clockinoff",
		coords = vector3(804.4, -760.87, 31.27),
		size = vector3(1, 1, 2.0),
		rotation = 0,
		debug = false,
		minZ = 30.27,
		maxZ = 32.07,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "pizza_this" })
				end,
				groups = { "pizza_this" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "pizza_this" })
				end,
				groups = { "pizza_this" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "avast_arcade-clockinoff",
		coords = vector3(-1659.51, -1061.26, 12.16),
		size = vector3(1, 1, 2.0),
		rotation = 46,
		debug = false,
		minZ = 11.56,
		maxZ = 13.36,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "avast_arcade" })
				end,
				groups = { "avast_arcade" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "avast_arcade" })
				end,
				groups = { "avast_arcade" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "bballs-clockinoff",
		coords = vector3(755.73, -775.51, 26.34),
		size = vector3(1.0, 0.6, 2.0),
		rotation = 0,
		debug = false,
		minZ = 26.34,
		maxZ = 27.14,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "bowling" })
				end,
				groups = { "bowling" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "bowling" })
				end,
				groups = { "bowling" },
				reqDuty = true,
			},
			{
				icon = "tv",
				label = "Set TV Link",
				onSelect = function()
					TriggerEvent("Bowling:Client:SetTV")
				end,
				groups = { "bowling" },
				reqDuty = true,
			},
			{
				icon = "bowling-pins",
				label = "Reset All Lanes",
				onSelect = function()
					TriggerEvent("Bowling:Client:ResetAll", { job = "bowling" })
				end,
				groups = { "bowling" },
				reqDuty = true,
			},
			{
				icon = "bowling-pins",
				label = "Clear Pins",
				onSelect = function()
					TriggerEvent("Bowling:Client:ClearPins")
				end,
				groups = { "bowling" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "beanmachine-clockinoff",
		coords = vector3(126.86, -1035.47, 29.28),
		size = vector3(2.0, 0.4, 2.0),
		rotation = 340,
		debug = false,
		minZ = 28.48,
		maxZ = 31.48,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "beanmachine" })
				end,
				groups = { "beanmachine" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "beanmachine" })
				end,
				groups = { "beanmachine" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "vu-clockinoff",
		coords = vector3(133.06, -1286.17, 29.27),
		size = vector3(0.9, 0.7, 2.0),
		rotation = 30,
		debug = false,
		minZ = 29.07,
		maxZ = 30.07,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "unicorn" })
				end,
				groups = { "unicorn" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "unicorn" })
				end,
				groups = { "unicorn" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "vu-clockinoff2",
		coords = vector3(102.0, -1299.66, 28.77),
		size = vector3(1, 1, 2.0),
		rotation = 30,
		debug = false,
		minZ = 28.37,
		maxZ = 30.77,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "unicorn" })
				end,
				groups = { "unicorn" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "unicorn" })
				end,
				groups = { "unicorn" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "bahama-clockinoff",
		coords = vector3(-1398.88, -600.11, 30.32),
		size = vector3(0.6, 0.6, 2.0),
		rotation = 11,
		debug = false,
		minZ = 29.32,
		maxZ = 31.32,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "bahama" })
				end,
				groups = { "bahama" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "bahama" })
				end,
				groups = { "bahama" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "bahama-clockinoff2",
		coords = vector3(-1402.88, -602.59, 30.32),
		size = vector3(0.6, 0.4, 2.0),
		rotation = 145.994,
		debug = false,
		minZ = 29.32,
		maxZ = 31.32,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "bahama" })
				end,
				groups = { "bahama" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "bahama" })
				end,
				groups = { "bahama" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "bakery-clockinoff",
		coords = vector3(-1264.53, -291.36, 37.39),
		size = vector3(0.6, 1, 2.0),
		rotation = 20,
		debug = false,
		minZ = 36.39,
		maxZ = 37.99,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "bakery" })
				end,
				groups = { "bakery" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "bakery" })
				end,
				groups = { "bakery" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "noodle-clockinoff",
		coords = vector3(-1185.77, -1149.25, 7.67),
		size = vector3(0.8, 2, 2.0),
		rotation = 15,
		debug = false,
		minZ = 6.67,
		maxZ = 8.87,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "noodle" })
				end,
				groups = { "noodle" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "noodle" })
				end,
				groups = { "noodle" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "tequila-clockinoff",
		coords = vector3(-562.95, 283.25, 82.18),
		size = vector3(1, 1, 2.0),
		rotation = 0,
		debug = false,
		minZ = 81.58,
		maxZ = 83.38,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "tequila" })
				end,
				groups = { "tequila" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "tequila" })
				end,
				groups = { "tequila" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "rockford_records-clockinoff",
		coords = vector3(-1004.61, -269.61, 39.04),
		size = vector3(1.2, 2.2, 2.0),
		rotation = 20,
		debug = false,
		minZ = 38.44,
		maxZ = 40.24,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "rockford_records" })
				end,
				groups = { "rockford_records" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "rockford_records" })
				end,
				groups = { "rockford_records" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "rockford_records-clockinoff2",
		coords = vector3(-990.76, -279.55, 38.2),
		size = vector3(0.8, 3.0, 2.0),
		rotation = 25,
		debug = false,
		minZ = 37.6,
		maxZ = 39.4,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "rockford_records" })
				end,
				groups = { "rockford_records" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "rockford_records" })
				end,
				groups = { "rockford_records" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "prego-clockinoff",
		coords = vector3(-1122.19, -1456.06, 5.11),
		size = vector3(0.6, 1.6, 2.0),
		rotation = 35,
		debug = false,
		minZ = 4.71,
		maxZ = 6.71,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "prego" })
				end,
				groups = { "prego" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "prego" })
				end,
				groups = { "prego" },
				reqDuty = true,
			},
		}
	})
end

RegisterNetEvent("Restaurant:Client:CreatePoly", function(pickups, warmersList, onSpawn)
	for k, v in ipairs(pickups) do
		local data = GlobalState[string.format("Restaurant:Pickup:%s", v)]
		if data ~= nil then
			exports.ox_target:addBoxZone({
				id = data.id,
				coords = data.coords,
				size = vector3(data.width, data.length, 2.0),
				rotation = data.options.heading or 0,
				debug = false,
				minZ = data.options.minZ,
				maxZ = data.options.maxZ,
				options = {
					{
						icon = "fork-knife",
						label = string.format("Pickup Order (#%s)", data.num),
						onSelect = function()
							TriggerEvent("Restaurant:Client:Pickup", data.data)
						end,
						distance = data.driveThru and 5.0 or 2.0,
					},
					{
						icon = "money-check-dollar-pen",
						label = "Set Contactless Payment",
						onSelect = function()
							TriggerEvent("Businesses:Client:CreateContactlessPayment", data)
						end,
						groups = { data.job },
						canInteract = function()
							return not GlobalState[string.format("PendingContactless:%s", data.id)]
						end,
					},
					{
						icon = "money-check-dollar-pen",
						label = "Clear Contactless Payment",
						onSelect = function()
							TriggerEvent("Businesses:Client:ClearContactlessPayment", data)
						end,
						groups = { data.job },
						canInteract = function()
							return GlobalState[string.format("PendingContactless:%s", data.id)]
						end,
					},
					{
						icon = "money-check-dollar",
						label = function()
							if GlobalState[string.format("PendingContactless:%s", data.id)] and GlobalState[string.format("PendingContactless:%s", data.id)] > 0 then
								return string.format("Pay Contactless ($%s)",
									GlobalState[string.format("PendingContactless:%s", data.id)])
							end
						end,
						onSelect = function()
							TriggerEvent("Businesses:Client:PayContactlessPayment", data)
						end,
						item = "phone",
						distance = data.driveThru and 5.0 or 2.0,
						canInteract = function()
							return GlobalState[string.format("PendingContactless:%s", data.id)] and
								GlobalState[string.format("PendingContactless:%s", data.id)] > 0
						end,
					},
				}
			})
		end
	end

	for k, v in ipairs(warmersList) do
		for k2, v2 in ipairs(v) do
			local data = GlobalState[string.format("Restaurant:Warmers:%s", v2)]
			if data ~= nil then
				local icon = data.fridge and "refrigerator" or "oven"
				exports.ox_target:addBoxZone({
					id = data.id,
					coords = data.coords,
					size = vector3(data.width, data.length, 2.0),
					rotation = data.options.heading or 0,
					debug = false,
					minZ = data.options.minZ,
					maxZ = data.options.maxZ,
					options = {
						{
							icon = icon,
							label = data.fridge and "Open Fridge" or "Open Warmer",
							onSelect = function()
								TriggerEvent("Restaurant:Client:Pickup", data.data)
							end,
							groups = { data.job },
							reqDuty = true,
						},
					}
				})
			end
		end
	end
end)

AddEventHandler("Restaurant:Client:Pickup", function(entity, data)
	exports.ox_inventory:openInventory(data.inventory)
end)

AddEventHandler("Restaurant:Client:ClockIn", function(data)
	if data and data.job then
		exports['sandbox-jobs']:DutyOn(data.job)
	end
end)

AddEventHandler("Restaurant:Client:ClockOut", function(data)
	if data and data.job then
		exports['sandbox-jobs']:DutyOff(data.job)
	end
end)
