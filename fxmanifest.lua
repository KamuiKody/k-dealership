lua54 'yes'
fx_version 'cerulean'
game 'gta5'

shared_script 'config.lua'

client_scripts {
    'client/*.lua'
} 

server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'server.lua',
    --'server2.lua' -- only uncomment this option and comment out the one above this for jg-advancedgarages
}
