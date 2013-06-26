net = require 'net'
{node,Model,factory} = require '../shared/shared'
n = node()

argv = require('optimist')
	.usage('Usage: -c [port] -l [port] -w [port]')	
	.argv

if argv.w?
	port = argv.w
	
	express = require 'express'
	shoe = require 'shoe'
	events = require 'events'
	_ = require 'underscore'

	app = express()
	app.use '/', express.static('public')
	app.use '/', express.static('build/client')
	app.use '/src', express.static('src')

	server = app.listen port
	console.log 'http listens at', port

	sock = shoe n
	sock.install server, '/dnode'

if argv.l?
	port = argv.l
	net.createServer(n).listen port
	console.log 'tcp listens at', port

if argv.c?
	connect = ->
		port = argv.c
		console.log 'connecting to', port
		con = net.connect port, -> 
			console.log 'connected to', port
			n(con)	
		con.on 'close', -> reconnect()
		con.on 'error', -> con.destroy()

	reconnect = -> setTimeout connect, 250
	connect()

	
