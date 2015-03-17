# -*- ruby -*-
#encoding: utf-8

require_relative '../../helpers'

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
		@opdir     = @tmpdir + 'docs'
		@storefile = @tmpdir + '.rdoc_store'

		@options = RDoc::Options.new
		@options.option_parser = OptionParser.new

		@options.op_dir = @opdir.to_s
		@options.generator = described_class
		@options.template_dir = @datadir.to_s

		@tmpdir.mkpath
		@store = RDoc::Store.new( @storefile.to_s )
		@store.load_cache

		$stderr.puts "Tmpdir is: %s" % [@tmpdir] if ENV['FIVEFISH_DEVELMODE']
	end

	before( :each ) do
		@generator          = described_class.new( @store, @options )

		@rdoc               = RDoc::RDoc.new
		@rdoc.options       = @options
		@rdoc.store         = @store
		@rdoc.generator     = @generator

		@top_level, @readme = add_code_objects( @store )
	end

	around( :each ) do |example|
		@opdir.mkpath
		Dir.chdir( @opdir ) { example.run }
		@opdir.rmtree unless ENV['FIVEFISH_DEVELMODE']
	end


	#
	# Examples
	#

	it "registers itself as a generator" do
		expect( RDoc::RDoc::GENERATORS ).to include( 'fivefish' => described_class )
	end


	it "configures Inversion to load templates from its data directory" do
		expect( Inversion::Template.template_paths ).to eq( [@datadir + 'templates'] )
	end


	describe "additional-stylesheet option" do

		it "is added to the options by the setup_options callback" do
			@options.setup_generator( 'fivefish' )
			expect( @options.option_parser.to_a.join ).to include( '--additional-stylesheet=URL' )
		end

	end


	describe "generation" do

		before( :each ) do
			@generator.populate_data_objects
		end


		it "combines an index template with the layout template to make the index page" do
			layout_template = get_fixtured_layout_template_mock()

			index_template = double( "index template" )
			expect( Inversion::Template ).to receive( :load ).
				with( 'index.tmpl', encoding: 'utf-8' ).
				and_return( index_template )

			expect( index_template ).to receive( :dup ).and_return( index_template )
			expect( index_template ).to receive( :mainpage= ).with( @readme )
			expect( index_template ).to receive( :synopsis= ).
				with( %{<h1 id="label-Testing+README">Testing <a href="README_md} +
				      %{.html">README</a><span><a href="#label-Testing+README">} +
				      %{&para;</a> <a href="#top">&uarr;</a></span></h1>} +
				      %{<p>This is a readme for testing.</p>} )

			expect( layout_template ).to receive( :contents= ).with( index_template )
			expect( layout_template ).to receive( :pageclass= ).with( 'index-page' )
			expect( layout_template ).to receive( :rel_prefix= ).with( Pathname('.') )

			expect( layout_template ).to receive( :render ).and_return( 'Index page!' )

			@generator.generate_index_page
		end


		it "combines a class template with the layout template to make class pages" do
			classes = @store.all_classes_and_modules

			layout_template = get_fixtured_layout_template_mock()

			class_template = double( "class template" )
			expect( Inversion::Template ).to receive( :load ).
				with( 'class.tmpl', encoding: 'utf-8' ).
				and_return( class_template )
			expect( class_template ).to receive( :dup ).and_return( class_template )

			classes.each do |klass|
				expect( class_template ).to receive( :klass= ).with( klass )
			end

			expect( layout_template ).to receive( :contents= ).with( class_template ).
				exactly( classes.length ).times
			expect( layout_template ).to receive( :pageclass= ).with( 'class-page' ).
				exactly( classes.length ).times
			expect( layout_template ).to receive( :rel_prefix= ).with( Pathname('.') ).
				exactly( classes.length ).times

			expect( layout_template ).to receive( :render ).
				and_return( *classes.map {|k| "#{k.name} class page!"} )

			@generator.generate_class_files
		end


		it "combines a file template with the layout template to make file pages" do
			files = @store.all_files

			layout_template = get_fixtured_layout_template_mock()

			file_template = double( "file template" )
			expect( Inversion::Template ).to receive( :load ).
				with( 'file.tmpl', encoding: 'utf-8' ).
				and_return( file_template )
			expect( file_template ).to receive( :dup ).and_return( file_template )
			expect( file_template ).to receive( :header= ).
				with( %{<h1 id="label-Testing+README">Testing <a href="README_md} +
				      %{.html">README</a><span><a href="#label-Testing+README">} +
				      %{&para;</a> <a href="#top">&uarr;</a></span></h1>} )
			expect( file_template ).to receive( :description= ).
				with( %{\n<p>This is a readme for testing.</p>\n\n<p>It has some more} +
				      %{ stuff</p>\n\n<p>And even more stuff.</p>\n} )

			expect( file_template ).to receive( :file= ).with( @readme )

			expect( layout_template ).to receive( :contents= ).with( file_template ).once
			expect( layout_template ).to receive( :pageclass= ).with( 'file-page' )
			expect( layout_template ).to receive( :rel_prefix= ).with( Pathname('.') )
			expect( layout_template ).to receive( :render ).and_return( "README file page!" )

			@generator.generate_file_files
		end

	end



	#
	# Helpers
	#

	def any_method( name, comment=nil )
		return RDoc::AnyMethod.new( comment, name )
	end


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

		readme = store.add_file( 'README.md' )
		readme.parser = RDoc::Parser::Markdown
		readme.comment = "= Testing README\n\nThis is a readme for testing.\n\n" +
			"It has some more stuff\n\nAnd even more stuff.\n\n"

		store.complete :private

		return top_level, readme
	end


	def get_fixtured_layout_template_mock
		layout_template = double( "layout template" )
		expect( Inversion::Template ).to receive( :load ).
			with( 'layout.tmpl', encoding: 'utf-8' ).
			and_return( layout_template )

		# Work around caching
		expect( layout_template ).to receive( :dup ).and_return( layout_template )

		expect( layout_template ).to receive( :files= ).with( [@readme, @top_level] )
		expect( layout_template ).to receive( :classes= ).
			with( @store.all_classes_and_modules.sort )
		expect( layout_template ).to receive( :methods= ).
			with( @store.all_classes_and_modules.flat_map(&:method_list).sort )
		expect( layout_template ).to receive( :modsort= ) do |sorted_mods|
			expect( sorted_mods ).to include( @store.find_class_named('Klass') )
		end
		expect( layout_template ).to receive( :rdoc_options= ).with( @options )
		expect( layout_template ).to receive( :rdoc_version= ).with( RDoc::VERSION )
		expect( layout_template ).to receive( :fivefish_version= ).with( Fivefish.version_string )

		return layout_template
	end

end

