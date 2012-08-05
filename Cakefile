{exec} = require 'child_process'
{print} = require 'util'

srcFiles = ("#{file}.coffee" for file in ['./app','./public/javascripts/index','./routes/index']).join ' '

task 'watch', 'Watches src/ for any changes, compiles and minifies', ->
	coffee = exec "coffee -cw #{srcFiles}"
	sv = exec "node app.js"

	coffee.stderr.on "data", (data) ->
		process.stderr.write data.toString()

	coffee.stdout.on "data", (data) ->
		print data.toString()

	sv.stderr.on "data", (data) ->
		process.stderr.write data.toString()

	sv.stdout.on "data", (data) ->
		print data.toString()

task 'build', 'Builds src/ to lib/', ->

	coffee = exec "coffee -j lib/server.js -c #{srcFiles}"
	#min = exec "uglifyjs -o lib/server.min.js lib/app.js"

	coffee.stderr.on "data", (data) ->
		process.stderr.write data.toString()

	coffee.stdout.on "data", (data) ->
		print data.toString()

	coffee.on "exit", (code) ->
		callback?() if code is 0