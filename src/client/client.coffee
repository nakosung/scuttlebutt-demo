shoe = require 'shoe'
_ = require 'underscore'
{node,Model,factory} = require '../shared/shared'

ng = angular.module('mb',[])

extrapolate = (m) ->
	p = m.get('pos')
	v = m.get('vel')

	return undefined unless p and v

	p = p.map Number
	v = v.map Number

	time = Math.max( Number(m.store['pos'][1]), Number(m.store['vel'][1]) )
	dt = (Date.now() - time) / 1000

	[ p[0] + v[0] * dt, p[1] + v[1] * dt ]

paper = null

class factory.pawn extends Model
	constructor : ->				
		super
		
		animating = false
		draw = => 			
			@sync()
			return unless animating
			process.nextTick draw

		@on 'change:pos', draw
		@on 'change:vel', (v) ->
			moving = not (v[0] == 0 and v[1] == 0)
			shouldDraw = not animating and draw
			animating = moving
			
			draw() if shouldDraw
			
		@on 'dispose', => 
			@p.remove()
			animating = false

	sync : ->
		unless @p? 
			return unless paper
			@p = paper.set()			
			rect = paper.rect(-12,-12,24,24)
			rect.attr 'fill':'red'
			text = paper.text(0,-5,@id)
			text.hide()
			rect.hover (-> text.show()), (-> text.hide())
			@p.push rect, text

		pos = extrapolate @
		if pos 
			@p
				.attr('x',pos[0])
				.attr('y',pos[1])


ng.factory 'node', ->	
	n = node()	
	-> n
		
ng.directive 'raphael', ($rootScope,node) ->		
	link : (scope,element,attrs) ->				
		e = node().entity		

		paper = Raphael(element[0],320,200)	

		for k,v of e.all
			v.sync?()

ng.factory 'mypawn', (node) ->
	e = node().entity
	rand_id = Math.random().toString(36).substr(2,5)
	p = e("pawn.#{rand_id}")	
	-> p

ng.factory 'controller', (mypawn) ->
	p = mypawn()
	set_vel = (x,y) ->
		pos = extrapolate p
		vel = [x,y]
		p.set 'pos', pos if pos
		p.set 'vel', vel if vel	

	alt_v = (i,cond,v) ->
		vel = p.get('vel').map Number
		if vel[i] == cond
			vel[i] = v
			set_vel vel...

	speed = 50

	keys = left:37, up:38, right:39, down:40
	actions = 
		left: [0,-1]
		right: [0,+1]
		up: [1,-1]
		down: [1,+1]

	act = (k,down) ->
		if down
			alt_v actions[k][0], 0, actions[k][1] * speed
		else
			alt_v actions[k][0], actions[k][1] * speed, 0

	keyhandler = (down) ->
		(e) ->
			for k,v of keys
				act(k,down) if e.keyCode == v
			
	document.onkeydown = keyhandler(true)
	document.onkeyup = keyhandler(false)

ng.controller 'MainCtrl', ($scope,mypawn,controller,node) ->	
	p = mypawn()
	$scope.id = p.id
	p.set 'pos', [Math.random() * 100,Math.random() * 100]
	p.set 'vel', [0,0]

	connection = null

	$scope.is_connected = -> connection?
	
	$scope.connect = ->
		return if connection

		connection = shoe '/dnode'		
		connection.on 'end', ->
			console.log 'DISCONNECTED'
			$scope.$apply -> connection = null			
		node()(connection)

	$scope.disconnect = ->
		return unless connection

		connection.destroy()
		connection = null

	$scope.connect()