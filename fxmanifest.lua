fx_version 'bodacious'
game 'gta5'


files {
    'json/**/*'
}

dependencies {'ghmattimysql'}
server_script 'server.lua'

client_scripts {
	'config/config.lua',
	'client.lua'
}