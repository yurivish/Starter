all: node_modules static/js/main.js static/css/main.css

node_modules: package.json
	npm install
	touch node_modules

static/js/main.js: lib/coffee/*.coffee
	node_modules/.bin/coffee --compile --output static/js/ lib/coffee/

static/css/main.css: lib/styl/*.styl
	node_modules/.bin/stylus --use nib -I lib/styl < lib/styl/main.styl > static/css/main.css
