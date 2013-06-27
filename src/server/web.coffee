{node,Model,factory} = require '../shared/shared'

express = require 'express'
shoe = require 'shoe'

module.exports = (port,n) ->
	n = n or node()
	app = express()
	app.use '/', express.static('public')
	app.use '/', express.static('build/client')
	app.use '/src', express.static('src')

	server = app.listen port
	console.log 'http listens at', port

	sock = shoe n
	sock.install server, '/dnode'