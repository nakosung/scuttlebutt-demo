module.exports = (grunt) ->
	grunt.initConfig
		watch:
			client:
				files: 'src/client/*.coffee'
				tasks: ['client']
				options:
					interrupt:yes
			shared:
				files: 'src/shared/*.coffee'
				tasks: ['shared']
				options:
					interrupt:yes
		coffee:
			shared:
				options:
					bare:yes
					sourceMap:true
				expand:true
				cwd:'src'
				src:['shared/*.coffee']
				dest:'build/'
				ext:'.js'
			client:
				options:
					bare:yes
					sourceMap:true
				expand:true
				cwd:'src'
				src:['client/*.coffee']
				dest:'build/'
				ext:'.js'
		shell:
			browserify:
				command: 'browserify -d build/client/client.js -o build/client/bundle.js'
				#command: "browserify -d -t coffeeify src/client/app.coffee -o public/lib/bundle.js"
				options:
					stdout:true
					stderr:true
					failOnError:true
			run:
				command: 'nodemon src/server/server.coffee --w 3000 --l 4000'
				options:
					stdout:true
					stderr:true
					failOnError:true
					async:true		
		mochaTest:
			all : ['test/**/*.*']		


	grunt.loadNpmTasks 'grunt-contrib-watch'	
	grunt.loadNpmTasks 'grunt-contrib-coffee'	
	grunt.loadNpmTasks 'grunt-mocha-test'
	grunt.loadNpmTasks 'grunt-shell-spawn'

	grunt.registerTask 'mkdir_build', ->
		grunt.file.mkdir 'build/public'
		
	grunt.registerTask 'client', ['coffee:client','zip']	
	grunt.registerTask 'shared', ['coffee:shared','zip']
	grunt.registerTask 'test', ['shell:test']
	grunt.registerTask 'zip', ['mkdir_build','shell:browserify']
	grunt.registerTask 'default', ['make','shell:run','watch']
	grunt.registerTask 'make', ['coffee','zip']

	# watching server folder
	