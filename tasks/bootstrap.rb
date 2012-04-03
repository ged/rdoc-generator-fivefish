#

require 'uri'

# Tasks for checking out, updating, and compiling Fivefish assets from
# the Bootstrap project.

BOOTSTRAP_BASE = ASSETDIR + 'bootstrap'
BOOTSTRAP_VC_URI = 'ssh://hg@deveiate.org/bootstrap-darkfish'
BOOTSTRAP_BOOKMARK = 'darkfish'


#
# Helper functions
#



# Check out the Bootstrap project if it hasn't been already
task BOOTSTRAP_BASE do |t|
	sh 'hg', 'qclone', BOOTSTRAP_VC_URI.to_s, BOOTSTRAP_BASE.to_s
	Dir.chdir( t.name ) do
		sh 'hg', 'up', BOOTSTRAP_BOOKMARK
	end
end



