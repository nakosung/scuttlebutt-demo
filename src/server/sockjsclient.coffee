shoe = require 'shoe'
{node,Model,factory} = require '../shared/shared'

module.exports = (url,n) ->
	n = n or node()		

	connect = ->		
		con = shoe url
		con.on 'close', -> reconnect()
		con.on 'error', -> con.destroy()

	reconnect = -> setTimeout connect, 250
	connect()

	
