fx_version 'adamant'
game 'gta5'


files {
    'json/**/*'
}

dependencies {'ghmattimysql'}
server_script 'server/server.lua'

client_scripts {
	'blacklist/blacklist.lua',
	'client/client.lua'
}