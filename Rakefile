#! -*- ruby -*-

require 'pry'

begin
	require 'hoe'
rescue LoadError
	abort "This Rakefile requires hoe (gem install hoe)"
end

Hoe.add_include_dirs 'lib'

gem 'rdoc', '~> 3.12'
require 'fivefish'
require 'rdoc/task'

Hoe.plugin :deveiate
Hoe.plugin :mercurial
Hoe.plugin :signing
Hoe.plugin :manualgen

Hoe.plugins.delete :rubyforge

hoespec = Hoe.spec 'rdoc-generator-fivefish' do
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


RDoc::Task.new do |rdoc|
	rdoc.main       = "README.rdoc"
	rdoc.rdoc_dir   = 'doc'
	rdoc.generator  = 'fivefish'

	rdoc.rdoc_files.include( 'README.rdoc', 'History.rdoc', 'lib/**/*.rb' )
end

