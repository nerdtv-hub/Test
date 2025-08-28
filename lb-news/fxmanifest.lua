fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'lb-news'
description 'LB-Phone News App (standalone NUI) - Dark Gray/Orange'
author 'LB News App Generator'
version '1.0.0'

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/style.css',
	'html/app.js',
	'html/logo.svg'
}

client_scripts {
	'client/main.lua'
}

server_scripts {
	'server/main.lua'
}

