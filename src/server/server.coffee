net = require 'net'
{node,Model,factory} = require '../shared/shared'
n = node()
_ = require 'underscore'

argv = require('optimist')
	.usage('Usage: -c [port] -l [port] -w [port]')	
	.argv

each = (x,y) ->
	if x?
		if _.isArray(x)
			x.forEach y
		else
			y(x)

each argv.w, (p) -> require('./web')(p,n)
each argv.l, (p) -> require('./tcpserver')(p,n)
each argv.c, (p) -> require('./tcpclient')(p,n)