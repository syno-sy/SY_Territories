fx_version "cerulean"
games {
  "gta5",
  "rdr3"
}

description "React + Mantine Boilerplate"
author "SYNO"
version '1.0.0'

lua54 'yes'

ui_page 'web/build/index.html'

shared_scripts {
  '@ox_lib/init.lua',
  '@qbx_core/modules/lib.lua',
  "shared/**/*"
}
client_scripts { '@qbx_core/modules/playerdata.lua', "client/**/*" }
server_script "server/**/*"

files {
  'locales/*.json',
  'web/build/index.html',
  'web/build/**/*',
}
