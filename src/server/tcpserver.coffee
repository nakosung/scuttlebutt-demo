net = require 'net'
{node,Model,factory} = require '../shared/shared'

module.exports = (port,n) ->
	n = n or node()	
	net.createServer(n).listen port
	console.log 'tcp listens at', port