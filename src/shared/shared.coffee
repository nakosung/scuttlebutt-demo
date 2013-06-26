StreamRouter = require 'stream-router'
Model = require 'scuttlebutt/model'
events = require 'events'
MuxDemux = require 'mux-demux'

factory = (path) ->
	[type] = path.split('.')
	Class = factory[type] or Model
	new Class id:path

node = ->
	Entity = ->
		entities = {}
		e = new events.EventEmitter()

		fn = (id) ->
			# if we have it?
			return entities[id] if entities[id]

			console.log 'creating entity', id

			# create a new instance
			m = entities[id] = factory(id)

			# when it is disposed, remove it from dict.
			m.on 'dispose', -> 
				console.log 'entity destroyed', id
				delete entities[id]
				e.emit 'remove', id, m

			# notify
			e.emit 'add', id, m

			m
			
		fn.on = e.on.bind(e)
		fn.removeListener = e.removeListener.bind(e)
		fn.all = entities
		fn

	entity = Entity()
	
	fn = (stream) -> 
		console.log 'got stream connected'
		# tracking in-out models
		streams = {}
		tap = (stream,id) ->
			streams[id] ?= 0
			streams[id]++
			stream.on 'end', -> delete streams[id] if --streams[id] == 0
		
		# only one route!
		router = StreamRouter()
		router.addRoute 'rw/:id', (stream,params) ->						
			{id} = params
			console.log 'getting', id
			tap stream, id
			stream.pipe(entity(id).createStream()).pipe(stream)
		
		mx = MuxDemux(router)		

		# publish our model
		alloc = (id,m) ->			
			return if streams[id]?
			console.log 'publishing', id	
			s = mx.createStream "rw/#{id}"
			tap s, id
			s.pipe(m.createStream()).pipe(s)

		# publish all of current models
		for k,v of entity.all			
			alloc(k,v)

		fnAdd = (id,m) -> alloc(id,m)
		fnCleanup = ->
			console.log 'cleanup'
			entity.removeListener 'add', fnAdd			
		
		# when entity is added, publish it
		entity.on 'add', fnAdd

		# cleanup is always goodness
		stream.on 'end', fnCleanup		

		# when error, destroy the stream
		stream.on 'error', -> mx.destroy()				

		# piping!
		mx.pipe(stream).pipe(mx)		

	fn.entity = entity
	fn

module.exports.node = node
module.exports.factory = factory
module.exports.Model = Model