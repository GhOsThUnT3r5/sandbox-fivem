fx_version("cerulean")
game("gta5")
lua54("yes")
client_script("@sandbox-base/exports/cl_error.lua")
client_script("@sandbox-pwnzor/client/check.lua")

client_scripts({
	"client/*.lua",
})

server_scripts({
	"server/*.lua",
})

shared_scripts({
	"@ox_lib/init.lua",
	"shared/elevatorConfig.lua",
	"shared/elevators/**/*.lua",
})
