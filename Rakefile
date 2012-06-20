#! -*- ruby -*-

require 'pathname'

begin
	require 'hoe'
rescue LoadError
	abort "This Rakefile requires hoe (gem install hoe)"
end

Hoe.add_include_dirs 'lib'

require 'rdoc/task'
require 'rake'
require 'rake/clean'

PACKAGE_NAME = 'rdoc-generator-fivefish'
BASEDIR      = Pathname( __FILE__ ).dirname.relative_path_from( Pathname.pwd )

# Layout constants
DATADIR      = BASEDIR + "data/#{PACKAGE_NAME}"
CSSDIR       = DATADIR + 'css'
FONTSDIR     = DATADIR + 'fonts'
JSDIR        = DATADIR + 'js'
IMGDIR       = DATADIR + 'img'

ASSETDIR     = BASEDIR + 'assets'


#
# Helper functions
#

### Output a log message unless running in quiet mode
def log( *messages )
	$stderr.puts( messages.join ) unless Rake.application.options.quiet
end

### Output a tracing message if running in trace mode
def trace( *messages )
	$stderr.puts( messages.join ) if Rake.application.options.trace
end

### Catenate the +source_files+ to form +target_file+.
def catenate( target_file, *source_files )
	trace "Catenating modules to form %s" % [ target_file ]
	File.open( target_file, 'w:utf-8' ) do |target|
		source_files.each do |source|
			trace "  #{source}..."
			target.puts( File.read(source, encoding: 'utf-8') )
		end
	end
end


#
# Hoe setup
#
Hoe.plugin :deveiate
Hoe.plugin :mercurial
Hoe.plugin :signing
Hoe.plugin :manualgen

Hoe.plugins.delete :rubyforge

hoespec = Hoe.spec( PACKAGE_NAME )  do
	self.readme_file = 'README.rdoc'
	self.history_file = 'History.rdoc'
	self.need_rdoc = false

	self.developer 'Michael Granger', 'ged@FaerieMUD.org'

	self.dependency 'inversion', '~> 0.10'
	self.dependency 'yajl-ruby', '~> 1.1'
	self.dependency 'rdoc',      '~> 3.12'

	self.dependency 'uglifier',  '~> 1.2', :developer
	self.dependency 'less',      '~> 2.2', :developer

	self.spec_extras[:licenses] = ["BSD"]
	self.require_ruby_version( '>=1.9.3' )
	self.hg_sign_tags = true if self.respond_to?( :hg_sign_tags= )
	self.check_history_on_release = true if self.respond_to?( :check_history_on_release= )
	self.rdoc_locations << "deveiate:/usr/local/www/public/code/#{remote_rdoc_dir}"
end

ENV['VERSION'] ||= hoespec.spec.version.to_s

task :default => :assets
task :check_manifest => :assets

# Ensure the specs pass before checking in
task 'hg:precheckin' => [:check_history, :check_manifest]

# Create the data directories on demand
directory CSSDIR.to_s
directory FONTSDIR.to_s
directory JSDIR.to_s
directory IMGDIR.to_s


# Dev mode is off by default
$devmode = false

# Enable the development-mode layout template and uncompressed assets
task :dev do
	$stderr.puts "Enabling devel mode"
	$devmode = true
	ENV['FIVEFISH_DEVELMODE'] = 'true'
end


# Eat our own dogfood
task :docs => :assets
RDoc::Task.new( :docs ) do |rdoc|
	rdoc.main       = "README.rdoc"
	rdoc.rdoc_dir   = 'doc'
	rdoc.generator  = 'fivefish'

	rdoc.rdoc_files.include( 'README.rdoc', 'History.rdoc', 'lib/**/*.rb' )
end


# The entrypoint for tasks which want to hang subtasks off of :default
task :assets


# Load all the asset-related tasks
Rake::FileList[ 'tasks/*.rb' ].each do |tasklib|
	require_relative( tasklib )
end


