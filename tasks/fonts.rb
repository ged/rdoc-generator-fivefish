# -*- rake -*-

require 'rake/clean'

FONTSRC     = ASSETDIR + 'fonts'
TTF_FONTS   = FileList[ (FONTSRC + '*.ttf').to_s ]

LICENSE_SRC = FONTSRC + 'OFL.txt'
LICENSE     = LICENSE_SRC.to_s.pathmap( (FONTSDIR + '%f').to_s )

task :assets => [ LICENSE, :fonts ]

# Generate WOFF fonts from the source TTF ones
task :fonts do |t|
	cp TTF_FONTS, FONTSDIR, verbose: true
end

file LICENSE => [ LICENSE_SRC, FONTSDIR.to_s ] do |task|
	cp task.prerequisites.first, task.name, verbose: true
end
CLEAN.include( LICENSE )


