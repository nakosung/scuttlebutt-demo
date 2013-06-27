net = require 'net'
{node,Model,factory} = require '../shared/shared'
n = node()

argv = require('optimist')
	.usage('Usage: -c [port] -l [port] -w [port]')	
	.argv

if argv.w?	
	require('./web')(argv.w,n)

if argv.l?
	require('./tcpserver')(argv.l,n)

if argv.c?
	require('./tcpclient')(argv.c,n)