--[[----------------------------------
Creation Date:	07/05/2021
]]------------------------------------
fx_version 'adamant'
game 'gta5'
author 'Leah#0001'
version '1.1.1'
versioncheck 'https://raw.githubusercontent.com/Leah-UK/bixbi_core/main/fxmanifest.lua'

shared_scripts {
	'@es_extended/imports.lua',
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
	"addProp",
	"itemCount"
}