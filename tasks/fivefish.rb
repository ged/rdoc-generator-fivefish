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

# Depend on the catenated bootstrap.js built by the bootstrap tasklib
FIVEFISH_SOURCES.include( (ASSETDIR + 'js/bootstrap.js').to_s )

#
# Tasks
#

# Add some targets to the compiled assets
task :assets => [ FIVEFISH_CSS, FIVEFISH_JS ]


file FIVEFISH_CSS => [ CSSDIR.to_s, FIVEFISH_CSS_SRC.to_s ] do |task|
	log( task.name )
	less = Less::Parser.new
	tree = less.parse( File.read(task.prerequisites.last) )
	trace "  %s -> %s" % [ task.prerequisites.first, task.name ]
	File.write( task.name, tree.to_css(compress: !$devmode), encoding: 'utf-8' )
end
CLEAN.include( FIVEFISH_CSS.to_s )


file FIVEFISH_JS => [ JSDIR.to_s, FIVEFISH_JS_SRC, *FIVEFISH_SOURCES ] do |task|
	log( task.name )
	source = ''

	task.prerequisites[2..-1].each do |file|
		trace "  catenating: #{file}"
		source <<
			"\n/* -- #{file} --- */\n" <<
			File.read( file, encoding: 'utf-8' )
	end
	source <<
		"\n/* -- #{task.prerequisites[1]} -- */\n" <<
		File.read( task.prerequisites[1], encoding: 'utf-8' )

	compressed = Uglifier.compile( source, beautify: true, copyright: false )

	File.write( task.name, compressed, encoding: 'utf-8' )
end
CLEAN.include( FIVEFISH_JS.to_s )


