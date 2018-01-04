# -*- mode: ruby; ruby-indent-level: 4; tab-width: 4 -*-

require 'rdoc/rdoc'
require 'rdoc/generator/fivefish'

# :title: Fivefish RDoc
#
# Toplevel namespace for Fivefish. The main goods are in RDoc::Generator::Fivefish.
module Fivefish

	# Library version constant
	VERSION = '0.3.0'

	# Version-control revision constant
	REVISION = %q$Revision$

	# Fivefish project URL
	PROJECT_URL = 'https://bitbucket.com/ged/fivefish'


	### Get the library version. If +include_buildnum+ is true, the version string will
	### include the VCS rev ID.
	def self::version_string( include_buildnum=false )
		vstring = "Fivefish RDoc %s" % [ VERSION ]
		vstring << " (build %s)" % [ REVISION[/: ([[:xdigit:]]+)/, 1] || '0' ] if include_buildnum
		return vstring
	end

end # module Fivefish

