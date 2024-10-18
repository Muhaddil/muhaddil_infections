fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Muhaddil'
description 'Sistema de enfermedades con contagios para FiveM'

version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

server_script {
    -- '@async/async.lua',                      -- Uncomment these two lines if you are using mysql-async instead of oxmysql
	-- '@mysql-async/lib/MySQL.lua',
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

client_script {
    'client/*.lua',
}
