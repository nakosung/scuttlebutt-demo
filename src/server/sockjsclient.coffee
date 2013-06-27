sjsc = require 'sockjs-client'
{node,Model,factory} = require '../shared/shared'

module.exports = (url,n) ->
	n = n or node()		

	connect = ->		
		con = sjsc.create url
		con.on 'connection', ->
			console.log 'connection'
			Stream = require('stream')
			stream = new Stream
			stream.readable = stream.writable = true
			stream.write = (msg) ->
				con.write msg
			stream.end = ->
				stream.writable = false
				con.close()
			stream.destroy = ->
				stream._ended = true
				stream.writable = stream.readable = false
				con.close()
			con.on 'data', (e) ->				
				stream.emit 'data', e
			n(stream)
			stream.emit 'connect'
			if stream._ended 
				stream.end()			
		con.on 'close', -> reconnect()
		con.on 'error', -> 
			stream.emit 'end'
			stream.writable = false
			stream.readable = false

	reconnect = -> setTimeout connect, 250
	connect()

	
