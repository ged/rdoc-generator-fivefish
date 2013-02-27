# -*- ruby -*-
#encoding: utf-8

require 'helpers'
require 'tmpdir'
require 'rspec'
require 'rdoc/generator/fivefish'

describe RDoc::Generator::Fivefish do

	# Lots of the setup and the examples in this file are ported from
	# the test_rdoc_generator_darkfish.rb file from RDoc itself.
	# Used under the second option in the LICENSE.rdoc file:
	#   https://github.com/rdoc/rdoc/blob/master/LICENSE.rdoc

	before( :all ) do
		@libdir = Pathname.pwd + 'lib'
		@datadir = RDoc::Generator::Fivefish::DATADIR
		@tmpdir = Pathname( Dir.tmpdir ) + "test_rdoc_generator_fivefish_#{$$}"

		@options = RDoc::Options.new
		@options.option_parser = OptionParser.new

		@options.op_dir = @tmpdir.to_s
		@options.generator = described_class
		@options.template_dir = @datadir.to_s
		@options.op_dir = @tmpdir.to_s
	end

	before( :each ) do
		@store          = RDoc::Store.new
		@generator      = described_class.new( @store, @options )

		@rdoc           = RDoc::RDoc.new
		@rdoc.options   = @options
		@rdoc.store     = @store
		@rdoc.generator = @generator

		@top_level      = add_code_objects( @store )
	end

	around( :each ) do |example|
		@tmpdir.mkpath
		Dir.chdir( @tmpdir ) { example.run }
		@tmpdir.rmtree
	end


	#
	# Examples
	#

	it "registers itself as a generator" do
		RDoc::RDoc::GENERATORS.include?( described_class )
	end

	it "configures Inversion to load templates from its data directory" do
		Inversion::Template.template_paths.should == [ @datadir + 'templates' ]
	end


	describe "additional-stylesheet option" do

		it "is added to the options by the setup_options callback" do
			@options.setup_generator( 'fivefish' )
			@options.option_parser.to_a.join.should include( '--additional-stylesheet=URL' )
		end

	end


	describe "all pages" do
	
		it "get the top-level code objects via the layout template" do
			pending "figuring out how to test this" do
				layout_template = stub( "layout template" )
				Inversion::Template.stub( :load ).with( 'layout.tmpl', encoding: 'utf-8' ).
					and_return( layout_template )

				layout_template.should_receive( :files= ).
					with( @store.all_files.sort )
				layout_template.should_receive( :classes= ).
					with( @store.all_classes_and_modules.sort )
				layout_template.should_receive( :methods= ).
					with( @store.all_classes_and_modules.map(&:method_list).flatten.sort )
				layout_template.should_receive( :modsort= ).
					with( 'modsort' )
			
				@generator.generate
			end
		end
		
	end



	#
	# Helpers
	#

	def add_code_objects( store )
		top_level = store.add_file( 'file.rb' )
		top_level.parser = RDoc::Parser::Ruby

		# Klass
		klass = top_level.add_class( RDoc::NormalClass, 'Klass' )

		# Klass::A
		alias_constant = RDoc::Constant.new( 'A', nil, '' )
		alias_constant.record_location( top_level )
		top_level.add_constant( alias_constant )

		# ::A = ::Klass (?)
		klass.add_module_alias( klass, 'A', top_level )

		# Klass#method
		meth = RDoc::AnyMethod.new( nil, 'method' )
		klass.add_method( meth )

		# Klass#method!
		meth_bang = RDoc::AnyMethod.new( nil, 'method!' )
		klass.add_method( meth_bang )

		# attr_accessor :name
		name_attr = RDoc::Attr.new( nil, 'name', 'RW', '' )
		klass.add_attribute( name_attr )

		# Ignored class ::Ignored
		ignored = top_level.add_class( RDoc::NormalClass, 'Ignored' )
		ignored.ignore

		store.complete :private
		
		return top_level
	end




end

