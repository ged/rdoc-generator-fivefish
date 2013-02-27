# -*- ruby -*-
#encoding: utf-8

# SimpleCov test coverage reporting; enable this using the :coverage rake task
if ENV['COVERAGE']
	$stderr.puts "\n\n>>> Enabling coverage report.\n\n"
	require 'simplecov'
	SimpleCov.start do
		add_filter 'spec'
		add_group "Needing tests" do |file|
			file.covered_percent < 90
		end
	end
end


require 'loggability'
require 'loggability/spechelpers'

require 'rspec'
require 'fivefish'

Loggability.format_with( :color ) if $stdout.tty?


### RSpec helper functions.
module Fivefish::SpecHelpers


end


### Mock with RSpec
RSpec.configure do |c|
	c.mock_with( :rspec )

	c.include( Loggability::SpecHelpers )
	c.include( Fivefish::SpecHelpers )
end

# vim: set nosta noet ts=4 sw=4:

