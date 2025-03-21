fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'BELUGA'
description 'AFK Management System with ox_lib UI'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'es_extended',
    'ox_lib'
} 