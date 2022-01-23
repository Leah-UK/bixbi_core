--[[----------------------------------
Creation Date:	07/05/2021
]]------------------------------------
fx_version 'adamant'
game 'gta5'
author 'Leah#0001'
version '1.2.2'
versioncheck 'https://raw.githubusercontent.com/Leah-UK/bixbi_core/main/fxmanifest.lua'
lua54 'yes'

shared_scripts {
	'@es_extended/imports.lua', -- Remove if you're using a version before ESX 1.3
	'config.lua'
}

server_scripts {
	'server.lua'
}

client_scripts {
    'client.lua'
}

exports {
	"Notify",
	"Loading",
	"playAnim",
	"addProp"
}