name("Sandbox RP Framework Phone")
description("Phone Written For Sandbox RP Framework")
author("[Alzar]")
lua54("yes")
fx_version("cerulean")
game("gta5")
client_script("@sandbox-base/exports/cl_error.lua")
client_script("@sandbox-pwnzor/client/check.lua")

ui_page("ui/dist/index.html")
files({
	"ui/dist/index.html",
	"ui/dist/*.png",
	"ui/dist/*.webp",
	"ui/dist/*.gif",
	"ui/dist/*.gifv",
	"ui/dist/*.js",
	"ui/dist/*.mp3",
	"ui/dist/*.ttf",
})

client_scripts({
	"client/*.lua",
	"client/apps/**/*.lua",
})

server_scripts({
	'@oxmysql/lib/MySQL.lua',
	"server/*.lua",
	"server/apps/**/*.lua",
})
