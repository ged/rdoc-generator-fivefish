# -*- rake -*-

require 'uri'
require 'less'
require 'uglifier'

# Tasks for composing Fivefish web assets out of the source files in assets/
FIVEFISH_CSS     = CSSDIR + 'fivefish.min.css'
FIVEFISH_CSS_SRC = ASSETDIR + 'css/fivefish.css'

FIVEFISH_JS      = JSDIR + 'fivefish.min.js'
FIVEFISH_JS_SRC  = ASSETDIR + 'js/fivefish.js'
FIVEFISH_SOURCES = FileList[ (ASSETDIR + 'js/jquery.*.js').to_s ]
FIVEFISH_SOURCES.include( (ASSETDIR + 'js/stringscore.js').to_s )

#
# Tasks
#

# Add some targets to the compiled assets
task :assets => [ FIVEFISH_CSS, FIVEFISH_JS ]


file FIVEFISH_CSS => [ CSSDIR.to_s, FIVEFISH_CSS_SRC.to_s ] do |task|
	log( task.name )
	# less = Less::Parser.new
	css = File.read( task.prerequisites.last )
	# tree = less.parse( css )
	trace "  %s -> %s" % [ task.prerequisites.first, task.name ]
	# File.write( task.name, tree.to_css(compress: !$devmode), encoding: 'utf-8' )
	File.write( task.name, css, encoding: 'utf-8' )
end
CLEAN.include( FIVEFISH_CSS.to_s )


file FIVEFISH_JS => [ JSDIR.to_s, *FIVEFISH_SOURCES, FIVEFISH_JS_SRC ] do |task|
	log( task.name )
	source = ''

	task.prerequisites[1..-1].each do |file|
		trace "  catenating: #{file}"
		rawsrc = File.read( file, encoding: 'utf-8' )
		source << Uglifier.compile( rawsrc, beautify: $devmode, copyright: true ) << "\n"
	end

	File.write( task.name, source, encoding: 'utf-8' )
end
CLEAN.include( FIVEFISH_JS.to_s )


