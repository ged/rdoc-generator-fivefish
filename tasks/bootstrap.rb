# -*- rake -*-

require 'rake/clean'
require 'less'

# Tasks for checking out, updating, and compiling Fivefish assets from
# the Bootstrap project.

BOOTSTRAP_BASE            = ASSETDIR + 'bootstrap'
BOOTSTRAP_VC_URI          = 'http://bitbucket.org/ged/bootstrap-fivefish'
BOOTSTRAP_BOOKMARK        = 'fivefish'
BOOTSTRAP_CSSLIB          = BOOTSTRAP_BASE + 'less'
BOOTSTRAP_JSLIB           = BOOTSTRAP_BASE + 'js'
BOOTSTRAP_IMGLIB          = BOOTSTRAP_BASE + 'img'

BOOTSTRAP_LESS            = BOOTSTRAP_CSSLIB + 'bootstrap.less'
BOOTSTRAP_CSS             = CSSDIR + 'bootstrap.min.css'

BOOTSTRAP_RESPONSIVE_LESS = BOOTSTRAP_CSSLIB + 'responsive.less'
BOOTSTRAP_RESPONSIVE      = CSSDIR + 'bootstrap-responsive.min.css'

# Dependency Order: transition alert button carousel collapse dropdown modal 
#                   tooltip popover scrollspy tab typeahead

BOOTSTRAP_SOURCES         = FileList.new
BOOTSTRAP_MODULES         = %w[transition modal tooltip popover typeahead]
BOOTSTRAP_JS              = JSDIR + 'bootstrap.min.js'

BOOTSTRAP_IMGSRC          = FileList[ (BOOTSTRAP_IMGLIB + '*.png').to_s ]
BOOTSTRAP_IMAGES          = BOOTSTRAP_IMGSRC.pathmap( (IMGDIR + '%f').to_s )

BOOTSTRAP_MODULES.each do |mod|
	modfile = BOOTSTRAP_JSLIB + "bootstrap-#{mod}.js"
	BOOTSTRAP_SOURCES.include( modfile.to_s )
end


#
# Tasks
#

# Add some targets to the compiled assets
task :assets => [ BOOTSTRAP_CSS, BOOTSTRAP_RESPONSIVE, BOOTSTRAP_JS, *BOOTSTRAP_IMAGES ]

# Check out the Bootstrap project if it hasn't been already
directory BOOTSTRAP_BASE.to_s
task BOOTSTRAP_BASE do |t|
	sh 'hg', 'clone', BOOTSTRAP_VC_URI.to_s, BOOTSTRAP_BASE.to_s
	Dir.chdir( t.name ) do
		sh 'hg', 'up', BOOTSTRAP_BOOKMARK
	end
end
CLOBBER.include( BOOTSTRAP_BASE.to_s )


# Compile stylesheets from their 'less' sources
file BOOTSTRAP_LESS => BOOTSTRAP_BASE.to_s

file BOOTSTRAP_CSS => [ BOOTSTRAP_LESS, CSSDIR.to_s ] do |task|
	log( task.name )
	less = Less::Parser.new( paths: [BOOTSTRAP_CSSLIB.to_s] )
	tree = less.parse( File.read(task.prerequisites.first) )
	trace "  %s -> %s" % [ task.prerequisites.first, task.name ]
	File.write( task.name, tree.to_css(compress: !$devmode), encoding: 'utf-8' )
end
CLEAN.include( BOOTSTRAP_CSS.to_s )

file BOOTSTRAP_RESPONSIVE => [ BOOTSTRAP_RESPONSIVE_LESS, CSSDIR.to_s ] do |task|
	log( task.name )
	less = Less::Parser.new( paths: [BOOTSTRAP_CSSLIB.to_s] )
	tree = less.parse( File.read(task.prerequisites.first) )
	trace "  %s -> %s" % [ task.prerequisites.first, task.name ]
	File.write( task.name, tree.to_css(compress: !$devmode), encoding: 'utf-8' )
end
CLEAN.include( BOOTSTRAP_RESPONSIVE.to_s )


# Catenate the Bootstrap modules used in fivefish into one bootstrap.min.js
file BOOTSTRAP_SOURCES => BOOTSTRAP_BASE.to_s

file BOOTSTRAP_JS => [ JSDIR.to_s, *BOOTSTRAP_SOURCES ] do |task|
	log( task.name )
	source = ''

	task.prerequisites[1..-1].each do |file|
		trace "  catenating: #{file}"
		source << File.read( file, encoding: 'utf-8' )
	end
	compressed = Uglifier.compile( source ) << "\n"

	File.write( task.name, compressed, encoding: 'utf-8' )
end
CLEAN.include( BOOTSTRAP_JS.to_s )


# Copy rule for copying over bootstrap images
rule( %r:#{IMGDIR}/(.*?)\.png$: => [
	proc {|tn| tn.pathmap((BOOTSTRAP_IMGLIB + '%f').to_s) },
	IMGDIR.to_s
]) do |task|
	cp task.source, task.name, verbose: true
end

