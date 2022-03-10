fx_version 'bodacious'
games{'gta5'}

shared_script '@es_extended/imports.lua'

client_scripts{
    'config.lua',
    'client/client.lua'
}

server_scripts{
    'config.lua',
    'server/server.lua'
}

ui_page('html/ui.html')

files{
    'html/ui.html',
    'html/js/script.js',
    'html/css/style.css',
    'html/img/cursor.png',
    'html/img/radio.png'
}

exports {
	"setRadioDisabled"
}