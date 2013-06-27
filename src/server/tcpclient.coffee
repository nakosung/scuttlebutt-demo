net = require 'net'
{node,Model,factory} = require '../shared/shared'

module.exports = (port,n) ->
	n = n or node()

	connect = ->		
		console.log 'connecting to', port
		con = net.connect port, -> 
			console.log 'connected to', port
			n(con)	
		con.on 'close', -> reconnect()
		con.on 'error', -> con.destroy()

	reconnect = -> setTimeout connect, 250
	connect()

	
