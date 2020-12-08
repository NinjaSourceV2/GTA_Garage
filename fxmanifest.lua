fx_version 'cerulean'
game 'gta5'

server_scripts {
 	'@mysql-async/lib/MySQL.lua',
    'config/config.lua',
    'server/server.lua'
}

client_scripts {
    "src/RMenu.lua",
    "src/menu/RageUI.lua",
    "src/menu/Menu.lua",
    "src/menu/MenuController.lua",
    "src/components/*.lua",
    "src/menu/elements/*.lua",
    "src/menu/items/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/windows/*.lua",

    'config/config.lua',
    'client/client_utils.lua',
    'client/client_main.lua',
    'client/client_menu.lua'
}