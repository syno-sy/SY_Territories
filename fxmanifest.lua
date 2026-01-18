fx_version "cerulean"
games {
  "gta5",
  "rdr3"
}

description "Fivem Territories System with Gangs and influence"
author "SYNO"
version '1.0.0'

lua54 'yes'

ui_page 'web/build/index.html'

shared_scripts {
  '@ox_lib/init.lua',
  "shared/**/*"
}
client_scripts { 'modules/framework/client.lua', "client/**/*" }
server_scripts { 'modules/framework/server.lua', "server/**/*"
}
files {
  'locales/*.json',
  'web/build/index.html',
  'web/build/**/*',
}
