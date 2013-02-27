# -*- ruby -*-
#encoding: utf-8

require 'helpers'
require 'rspec'
require 'fivefish'

describe Fivefish do

	describe "version methods" do
		it "returns a version string if asked" do
			described_class.version_string.should =~ /\w+ [\d.]+/
		end


		it "returns a version string with a build number if asked" do
			described_class.version_string(true).should =~ /\w+ [\d.]+ \(build [[:xdigit:]]+\)/
		end
	end

end

