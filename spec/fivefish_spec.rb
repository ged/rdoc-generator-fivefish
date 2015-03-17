# -*- ruby -*-
#encoding: utf-8

require 'helpers'
require 'rspec'
require 'fivefish'

describe Fivefish do

	describe "version methods" do
		it "returns a version string if asked" do
			expect( described_class.version_string ).to match( /\w+ [\d.]+/ )
		end


		it "returns a version string with a build number if asked" do
			expect( described_class.version_string(true) ).
				to match( /\w+ [\d.]+ \(build [[:xdigit:]]+\)/ )
		end
	end

end

