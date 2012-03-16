#! -*- ruby -*-

require 'pathname'

begin
	require 'hoe'
rescue LoadError
	abort "This Rakefile requires hoe (gem install hoe)"
end

Hoe.add_include_dirs 'lib'

gem 'rdoc', '~> 3.12'
require 'fivefish'
require 'rdoc/task'
require 'rake'
require 'rake/clean'

PACKAGE_NAME = 'rdoc-generator-fivefish'
BASEDIR = Pathname( __FILE__ ).dirname
DATADIR = BASEDIR + "data/#{PACKAGE_NAME}"

FONTSDIR = DATADIR + 'fonts'
TTF_FONTS = FileList[ (FONTSDIR + '*.ttf').to_s ]
WOFF_FONTS = TTF_FONTS.pathmap( '%X.woff' )

CLEAN.include( WOFF_FONTS )


Hoe.plugin :deveiate
Hoe.plugin :mercurial
Hoe.plugin :signing
Hoe.plugin :manualgen

Hoe.plugins.delete :rubyforge

hoespec = Hoe.spec( PACKAGE_NAME )  do
	self.readme_file = 'README.rdoc'
	self.history_file = 'History.rdoc'
	self.extra_rdoc_files << 'README.rdoc' << 'History.rdoc'
	self.need_rdoc = false

	self.developer 'Michael Granger', 'ged@FaerieMUD.org'

	self.dependency 'inversion', '~> 0.5'
	self.dependency 'rdoc',      '~> 3.12'

	self.spec_extras[:licenses] = ["BSD"]
	self.require_ruby_version( '>=1.9.3' )
	self.hg_sign_tags = true if self.respond_to?( :hg_sign_tags= )
	self.check_history_on_release = true if self.respond_to?( :check_history_on_release= )
	self.rdoc_locations << "deveiate:/usr/local/www/public/code/#{remote_rdoc_dir}"
end

ENV['VERSION'] ||= hoespec.spec.version.to_s

# Ensure the specs pass before checking in
task 'hg:precheckin' => [:check_history, :check_manifest, :spec]


RDoc::Task.new( :docs ) do |rdoc|
	rdoc.main       = "README.rdoc"
	rdoc.rdoc_dir   = 'doc'
	rdoc.generator  = 'fivefish'

	rdoc.rdoc_files.include( 'README.rdoc', 'History.rdoc', 'lib/**/*.rb' )
end


task :check_manifest => WOFF_FONTS


desc "Compress truetype fonts to WOFF"
rule '.woff' => '.ttf' do |task|
	sh 'sfnt2woff', task.prerequisites.first
end


