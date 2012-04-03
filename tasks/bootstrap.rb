# -*- rake -*-

require 'rake/clean'
require 'less'

# Tasks for checking out, updating, and compiling Fivefish assets from
# the Bootstrap project.

BOOTSTRAP_BASE            = ASSETDIR + 'bootstrap'
BOOTSTRAP_VC_URI          = 'ssh://hg@deveiate.org/bootstrap-darkfish'
BOOTSTRAP_BOOKMARK        = 'darkfish'
BOOTSTRAP_CSSLIB          = BOOTSTRAP_BASE + 'less'
BOOTSTRAP_JSLIB           = BOOTSTRAP_BASE + 'js'
BOOTSTRAP_IMGLIB          = BOOTSTRAP_BASE + 'img'

BOOTSTRAP_LESS            = BOOTSTRAP_CSSLIB + 'bootstrap.less'
BOOTSTRAP_CSS             = CSSDIR + 'bootstrap.min.css'

BOOTSTRAP_RESPONSIVE_LESS = BOOTSTRAP_CSSLIB + 'responsive.less'
BOOTSTRAP_RESPONSIVE      = CSSDIR + 'bootstrap-responsive.min.css'

BOOTSTRAP_MODULES         = %w[transition popover typeahead modal tooltip]
BOOTSTRAP_MOD_GLOB        = 'bootstrap-{%s}.js' % BOOTSTRAP_MODULES.join(',')
BOOTSTRAP_SOURCES         = FileList[ (BOOTSTRAP_JSLIB + BOOTSTRAP_MOD_GLOB).to_s ]
BOOTSTRAP_JS              = JSDIR + 'bootstrap.js'

BOOTSTRAP_IMGSRC          = FileList[ (BOOTSTRAP_IMGLIB + '*.png').to_s ]
BOOTSTRAP_IMAGES          = BOOTSTRAP_IMGSRC.pathmap( (IMGDIR + '%f').to_s )


#
# Tasks
#

# Add some targets to the compiled assets
task :assets => [ BOOTSTRAP_CSS, BOOTSTRAP_RESPONSIVE, *BOOTSTRAP_IMAGES ]

# Check out the Bootstrap project if it hasn't been already
directory BOOTSTRAP_BASE.to_s
task BOOTSTRAP_BASE do |t|
	sh 'hg', 'qclone', BOOTSTRAP_VC_URI.to_s, BOOTSTRAP_BASE.to_s
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


# Catenate the Bootstrap modules used in fivefish into one bootstrap.js
file BOOTSTRAP_SOURCES => BOOTSTRAP_BASE.to_s

file BOOTSTRAP_JS => [ *BOOTSTRAP_SOURCES ] do |task|
	log( task.name )
	catenate( task.name, *task.prerequisites )
end
CLEAN.include( BOOTSTRAP_JS.to_s )


# Copy rule for copying over bootstrap images
rule( %r:#{IMGDIR}/(.*?)\.png$: => [
	proc {|tn| tn.pathmap((BOOTSTRAP_IMGLIB + '%f').to_s) },
	IMGDIR.to_s
]) do |task|
	cp task.source, task.name, verbose: true
end

