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
		setup_logging()

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


	describe "generation" do

		before( :each ) do
			@generator.populate_data_objects
		end


		it "combines an index template with the layout template to make the index page" do
			layout_template = get_fixtured_layout_template_mock()

			index_template = mock( "index template" )
			Inversion::Template.stub( :load ).with( 'index.tmpl', encoding: 'utf-8' ).
				and_return( index_template )

			index_template.should_receive( :dup ).and_return( index_template )
			index_template.should_receive( :mainpage= ).with( @readme )
			index_template.should_receive( :synopsis= ).
				with( %{<h1 id="label-Testing+README">Testing <a href="README_md} +
				      %{.html">README</a><span><a href="#label-Testing+README">} +
				      %{&para;</a> <a href="#documentation">&uarr;</a></span></h1>} +
				      %{<p>This is a readme for testing.</p>} )

			layout_template.should_receive( :contents= ).with( index_template )
			layout_template.should_receive( :pageclass= ).with( 'index-page' )
			layout_template.should_receive( :rel_prefix= ).with( Pathname('.') )

			layout_template.should_receive( :render ).and_return( 'Index page!' )

			@generator.generate_index_page
		end


		it "combines a class template with the layout template to make class pages" do
			classes = @store.all_classes_and_modules

			layout_template = get_fixtured_layout_template_mock()

			class_template = mock( "class template" )
			Inversion::Template.stub( :load ).with( 'class.tmpl', encoding: 'utf-8' ).
				and_return( class_template )
			class_template.should_receive( :dup ).and_return( class_template )

			classes.each do |klass|
				class_template.should_receive( :klass= ).with( klass )
			end

			layout_template.should_receive( :contents= ).with( class_template ).
				exactly( classes.length ).times
			layout_template.should_receive( :pageclass= ).with( 'class-page' ).
				exactly( classes.length ).times
			layout_template.should_receive( :rel_prefix= ).with( Pathname('.') ).
				exactly( classes.length ).times

			layout_template.should_receive( :render ).
				and_return( *classes.map {|k| "#{k.name} class page!"} )

			@generator.generate_class_files
		end


		it "combines a file template with the layout template to make file pages" do
			files = @store.all_files

			layout_template = get_fixtured_layout_template_mock()

			file_template = mock( "file template" )
			Inversion::Template.stub( :load ).with( 'file.tmpl', encoding: 'utf-8' ).
				and_return( file_template )
			file_template.should_receive( :dup ).and_return( file_template )
			file_template.should_receive( :header= ).
				with( %{<h1 id="label-Testing+README">Testing <a href="README_md} +
				      %{.html">README</a><span><a href="#label-Testing+README">} +
				      %{&para;</a> <a href="#documentation">&uarr;</a></span></h1>} )
			file_template.should_receive( :description= ).
				with( %{\n<p>This is a readme for testing.</p>\n\n<p>It has some more} +
				      %{ stuff</p>\n\n<p>And even more stuff.</p>\n} )

			file_template.should_receive( :file= ).with( @readme )

			layout_template.should_receive( :contents= ).with( file_template ).once
			layout_template.should_receive( :pageclass= ).with( 'file-page' )
			layout_template.should_receive( :rel_prefix= ).with( Pathname('.') )
			layout_template.should_receive( :render ).and_return( "README file page!" )

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
		layout_template = mock( "layout template" )
		Inversion::Template.stub( :load ).with( 'layout.tmpl', encoding: 'utf-8' ).
			and_return( layout_template )

		# Work around caching
		layout_template.should_receive( :dup ).and_return( layout_template )

		layout_template.should_receive( :files= ).with( [@readme, @top_level] )
		layout_template.should_receive( :classes= ).
			with( @store.all_classes_and_modules.sort )
		layout_template.should_receive( :methods= ).
			with( @store.all_classes_and_modules.flat_map(&:method_list).sort )
		layout_template.should_receive( :modsort= ).with do |sorted_mods|
			sorted_mods.should include( @store.find_class_named('Klass') )
		end
		layout_template.should_receive( :rdoc_options= ).with( @options )
		layout_template.should_receive( :rdoc_version= ).with( RDoc::VERSION )
		layout_template.should_receive( :fivefish_version= ).with( Fivefish.version_string )

		return layout_template
	end

end

