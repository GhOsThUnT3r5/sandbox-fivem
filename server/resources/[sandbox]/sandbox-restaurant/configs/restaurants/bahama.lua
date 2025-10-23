table.insert(Config.Restaurants, {
	Name = "Bahama Mamas",
	Job = "bahama",
	Pickups = {
		{
			id = "bahama-pickup-1",
			coords = vector3(-1398.79, -601.62, 30.32),
			width = 1.0,
			length = 1.0,
			options = {
				heading = 340,
				--debugPoly=true,
				minZ = 29.32,
				maxZ = 31.32,
			},
			data = {
				business = "bahama",
			},
		},
		{
			id = "bahama-pickup-2",
			coords = vector3(-1400.68, -603.29, 30.32),
			width = 1.0,
			length = 1.0,
			options = {
				heading = 13,
				--debugPoly=true,
				minZ = 29.32,
				maxZ = 31.32,
			},
			data = {
				business = "bahama",
			},
		},
	},
	Warmers = {
	},
	Fridges = {
		{
			id = "bahama-fridge-1",
			coords = vector3(-1404.18, -598.65, 30.32),
			width = 0.8,
			length = 1.2,
			options = {
				heading = 33,
				--debugPoly=true,
				minZ = 26.92,
				maxZ = 30.92,
			},
			restrict = {
				jobs = { "bahama" },
			},
			data = {
				business = "bahama",
			},
		},
		{
			id = "bahama-fridge-2",
			coords = vector3(-1401.97, -597.04, 30.32),
			width = 1.0,
			length = 1.2,
			options = {
				heading = 33,
				--debugPoly=true,
				minZ = 27.02,
				maxZ = 31.22,
			},
			restrict = {
				jobs = { "bahama" },
			},
			data = {
				business = "bahama",
			},
		},
	},
})
