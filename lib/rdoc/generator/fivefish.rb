# -*- mode: ruby; ruby-indent-level: 4; tab-width: 4 -*-

gem 'rdoc'

require 'uri'
require 'yajl'
require 'inversion'
require 'loggability'
require 'fileutils'
require 'pathname'
require 'rdoc/rdoc'
require 'rdoc/generator/json_index'

# The Fivefish generator class.
class RDoc::Generator::Fivefish
	extend Loggability
    include FileUtils


	# Loggability API -- set up a Logger for Fivefish
	log_as :fivefish


	# The data directory in the project if that exists, otherwise the gem datadir
	DATADIR = if ENV['FIVEFISH_DATADIR']
			Pathname( ENV['FIVEFISH_DATADIR'] ).expand_path( Pathname.pwd )
		elsif File.directory?( 'data/rdoc-generator-fivefish' )
			Pathname( 'data/rdoc-generator-fivefish' ).expand_path( Pathname.pwd )
		elsif path = Gem.datadir('rdoc-generator-fivefish')
			Pathname( path )
		else
			raise ScriptError, "can't find the data directory!"
		end

	# Register with RDoc as an alternative generator
    RDoc::RDoc.add_generator( self )


	### Add generator-specific options to the option-parser
	def self::setup_options( rdoc_options )
		op = rdoc_options.option_parser

		op.accept( URI ) do |string|
			uri = URI.parse( string ) rescue nil
			raise OptionParser::InvalidArgument unless uri
			uri
		end
		op.on( '--additional-stylesheet=URL', URI,
		       "Add an additional (preferred) stylesheet",
			   "link to each generated page. This allows",
			   "the output style to be overridden." ) do |url|
			rdoc_options.additional_stylesheet = url
		end
	end


	### Set up some instance variables
	def initialize( store, options )
		@store      = store
		@options    = options
		$DEBUG_RDOC = $VERBOSE || $DEBUG

		self.log.debug "Setting up generator for %p with options: %p" % [ @store, @options ]

		extend( FileUtils::Verbose ) if $DEBUG_RDOC
		extend( FileUtils::DryRun ) if options.dry_run

		@base_dir       = Pathname.pwd.expand_path
		@template_dir   = DATADIR
		@output_dir     = Pathname( @options.op_dir ).expand_path( @base_dir )

		@template_cache = {}
		@files          = nil
		@classes        = nil
		@search_index   = {}

		Inversion::Template.configure( :template_paths => [self.template_dir + 'templates'] )
	end


	######
	public
	######

	# The base directory (current working directory) as a Pathname
	attr_reader :base_dir

	# The directory containing templates as a Pathname
	attr_reader :template_dir

	# The output directory as a Pathname
    attr_reader :output_dir

	# The command-line options given to the rdoc command
	attr_reader :options

	# The RDoc::Store that contains the parsed CodeObjects
	attr_reader :store


	### Output progress information if debugging is enabled
	def debug_msg( *msg )
		return unless $DEBUG_RDOC
		$stderr.puts( *msg )
	end


	### Backward-compatible (no-op) method.
	def class_dir # :nodoc:
		nil
	end
	alias_method :file_dir, :class_dir


	### Create the directories the generated docs will live in if they don't
	### already exist.
	def gen_sub_directories
		self.output_dir.mkpath
	end


	### Build the initial indices and output objects based on the files in the generator's store.
	def generate
		self.populate_data_objects

		self.generate_index_page
		self.generate_class_files
		self.generate_file_files

		self.generate_search_index

		self.copy_static_assets
	end


	### Populate the data objects necessary to generate documentation from the generator's
	### #store.
	def populate_data_objects
		@files   = self.store.all_files.sort
		@classes = self.store.all_classes_and_modules.sort
		@methods = @classes.map {|m| m.method_list }.flatten.sort
		@modsort = self.get_sorted_module_list( @classes )
	end


	### Generate an index page which lists all the classes which are documented.
	def generate_index_page
		self.log.debug "Generating index page"
		layout = self.load_layout_template
		template = self.load_template( 'index.tmpl' )
		out_file = self.output_dir + 'index.html'
		out_file.dirname.mkpath

		mainpage = nil
		if mpname = self.options.main_page
			mainpage = @files.find {|f| f.full_name == mpname }
		else
			mainpage = @files.find {|f| f.full_name =~ /\breadme\b/i }
		end
		self.log.debug "  using main_page (%s)" % [ mainpage ]

		if mainpage
			template.mainpage = mainpage
			template.synopsis = self.extract_synopsis( mainpage )
		end

		layout.rel_prefix = self.output_dir.relative_path_from( out_file.dirname )
		layout.contents = template
		layout.pageclass = 'index-page'

		out_file.open( 'w', 0644 ) {|io| io.print(layout.render) }
	end


	### Generate a documentation file for each class and module
	def generate_class_files
		layout = self.load_layout_template
		template = self.load_template( 'class.tmpl' )

		self.log.debug "Generating class documentation in #{self.output_dir}"

		@classes.each do |klass|
			self.log.debug "  working on %s (%s)" % [klass.full_name, klass.path]

			out_file = self.output_dir + klass.path
			out_file.dirname.mkpath

			template.klass = klass

			layout.contents = template
			layout.rel_prefix = self.output_dir.relative_path_from( out_file.dirname )
			layout.pageclass = 'class-page'

			out_file.open( 'w', 0644 ) {|io| io.print(layout.render) }
		end
	end


	### Generate a documentation file for each file
	def generate_file_files
		layout = self.load_layout_template
		template = self.load_template( 'file.tmpl' )

		self.log.debug "Generating file documentation in #{self.output_dir}"

		@files.select {|f| f.text? }.each do |file|
			out_file = self.output_dir + file.path
			out_file.dirname.mkpath

			self.log.debug "  working on %s (%s)" % [file.full_name, out_file]

			template.file = file

			# If the page itself has an H1, use it for the header, otherwise make one
			# out of the name of the file
			if md = file.description.match( %r{<h1.*?>.*?</h1>}i )
				template.header = md[ 0 ]
				template.description = file.description[ md.offset(0)[1] + 1 .. -1 ]
			else
				template.header = File.basename( file.full_name, File.extname(file.full_name) )
				template.description = file.description
			end

			layout.contents = template
			layout.rel_prefix = self.output_dir.relative_path_from(out_file.dirname)
			layout.pageclass = 'file-page'

			out_file.open( 'w', 0644 ) {|io| io.print(layout.render) }
		end
	end


	### Generate a JSON search index for the quicksearch blank.
	def generate_search_index
		out_file = self.output_dir + 'js/searchindex.js'

		self.log.debug "Generating search index (%s)." % [ out_file ]
		index = []

	    objs = self.get_indexable_objects
		objs.each do |codeobj|
			self.log.debug "  #{codeobj.name}..."
			record = codeobj.search_record
			index << {
				name:    record[2],
				link:    record[4],
				snippet: record[6],
				type:    codeobj.class.name.downcase.sub( /.*::/, '' )
			}
		end

		self.log.debug "  dumping JSON..."
		out_file.dirname.mkpath
		ofh = out_file.open( 'w:utf-8', 0644 )

		json = Yajl.dump( index, pretty: true, indent: "\t" )

		ofh.puts( 'var SearchIndex = ', json, ';' )
	end


	### Copies static files from the static_path into the output directory
	def copy_static_assets
		asset_paths = self.find_static_assets

		self.log.debug "Copying assets from paths: %s" % [ asset_paths.join(', ') ]

		asset_paths.each do |path|

			# For plain files, just install them
			if path.file?
				self.log.debug "  plain file; installing as-is"
				install( path, self.output_dir, :mode => 0644 )

			# Glob all the files out of subdirectories and install them
			elsif path.directory?
				self.log.debug "  directory %p; copying contents" % [ path ]

				Pathname.glob( path + '{css,fonts,img,js}/**/*'.to_s ).each do |asset|
					next if asset.directory? || asset.basename.to_s.start_with?( '.' )

					dst = asset.relative_path_from( path )
					dst.dirname.mkpath

					self.log.debug "    %p -> %p" % [ asset, dst ]
					install asset, dst, :mode => 0644
				end
			end
		end
	end


	#########
	protected
	#########

	### Return an Array of Pathname objects for each file/directory in the
	### list of static assets that should be copied into the output directory.
	def find_static_assets
		paths = self.options.static_path || []
		self.log.debug "Finding asset paths. Static paths: %p" % [ paths ]

		# Add each subdirectory of the template dir
		self.log.debug "  adding directories under %s" % [ self.template_dir ]
		paths << self.template_dir
		self.log.debug "  paths are now: %p" % [ paths ]

		return paths.flatten.compact.uniq
	end


	### Return a list of the documented modules sorted by salience first, then
	### by name.
	def get_sorted_module_list(classes)
		nscounts = classes.inject({}) do |counthash, klass|
			top_level = klass.full_name.gsub( /::.*/, '' )
			counthash[top_level] ||= 0
			counthash[top_level] += 1

			counthash
		end

		# Sort based on how often the top level namespace occurs, and then on the
		# name of the module -- this works for projects that put their stuff into
		# a namespace, of course, but doesn't hurt if they don't.
		classes.sort_by do |klass|
			top_level = klass.full_name.gsub( /::.*/, '' )
			[nscounts[top_level] * -1, klass.full_name]
		end.select do |klass|
			klass.display?
		end
	end


	### Fetch the template with the specified +name+ from the cache or load it
	### and cache it.
	def load_template( name )
		unless @template_cache.key?( name )
			@template_cache[ name ] = Inversion::Template.load( name, encoding:'utf-8' )
		end

		return @template_cache[ name ].dup
	end


	### Load the layout template and return it after setting any values it needs.
	def load_layout_template
		template = self.load_template( 'layout.tmpl' )

		template.files   = @files
		template.classes = @classes
		template.methods = @methods
		template.modsort = @modsort
		template.rdoc_options = @options

		template.rdoc_version = RDoc::VERSION
		template.fivefish_version = Fivefish.version_string

		return template
	end


	### Return a list of CodeObjects that belong in the index.
	def get_indexable_objects
		objs = []

		objs += @classes.select( &:document_self_or_methods ).uniq( &:path )
		objs += @classes.map( &:method_list ).flatten.uniq( &:path )
		objs += @files.select( &:text? )

		return objs
	end


	### Extract a synopsis for the project from the specified +mainpage+ and
	### return it as a String.
	def extract_synopsis( mainpage )
		desc    = mainpage.description
		heading = desc[ %r{(<h1.*?/h1>)}im ]
		paras   = desc.scan( %r{<p\b.*?/p>}im )

		first_para = paras.map( &:strip ).find do |para|
			# Discard paragraphs consisting only of a link
			!( para.start_with?('<p><a') && para.end_with?('/a></p>') )
		end

		return heading + first_para
	end

end # class RDoc::Generator::Fivefish


# Reopen to add custom option attrs.
class RDoc::Options

	##
	# Allow setting a custom stylesheet
	attr_accessor :additional_stylesheet

end

